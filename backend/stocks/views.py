from datetime import date, timedelta
from decimal import Decimal

from django.db.models import Q
from django.utils import timezone
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from core.utils import camelize
from engagement.serializers import MarketIndexSerializer

from .quote_provider import FinnhubError, INDEX_SYMBOLS, provider_label
from .kotak_neo_client import KotakNeoError
from .market_data_service import (
    get_live_candles,
    get_market_snapshot,
    refresh_all_indices,
    refresh_nifty50,
    refresh_stock,
    refresh_stocks,
)
from .models import (
    DividendRecord,
    PaperTrade,
    PriceAlert,
    SipPlan,
    Stock,
    StockHolding,
    WatchlistItem,
)
from kyc.permissions import IsKycVerified

from .trading_service import TradingError, list_recent_trades, place_paper_order
from .portfolio_service import get_stock_portfolio
from .screener_service import get_screener_results, get_screener_sectors
from .dividend_service import sync_user_dividends
from .news_service import fetch_market_news
from .serializers import (
    CreateAlertSerializer,
    CreateSipSerializer,
    PaperOrderSerializer,
    PriceAlertSerializer,
    SipPlanSerializer,
    StockCandleSerializer,
    StockHoldingSerializer,
    StockNewsSerializer,
    StockSerializer,
    ScreenerStockSerializer,
    OptionContractSerializer,
    DividendSerializer,
    PaperTradeSerializer,
)


class MarketLiveView(APIView):
    """Live Nifty 50 + indices (Alpha Vantage / Finnhub / Yahoo)."""
    permission_classes = [IsAuthenticated, IsKycVerified]

    def get(self, request):
        fast = request.query_params.get('fast', '1') != '0'
        force = request.query_params.get('refresh', '0') == '1'
        try:
            snapshot = get_market_snapshot(fast=fast, force_refresh=force)
        except (FinnhubError, KotakNeoError) as exc:
            from .market_symbols import NIFTY_50

            db_stocks = list(Stock.objects.filter(symbol__in=NIFTY_50).order_by('-market_cap_cr'))
            if db_stocks:
                from engagement.models import MarketIndex
                from .quote_provider import INDEX_SYMBOLS

                snapshot = {
                    'stocks': db_stocks,
                    'indices': list(MarketIndex.objects.filter(id__in=INDEX_SYMBOLS.keys())),
                    'updated_at': timezone.now().isoformat(),
                    'provider': f'{provider_label()} (cached)',
                }
            else:
                return Response({'detail': str(exc)}, status=status.HTTP_503_SERVICE_UNAVAILABLE)

        return Response(
            {
                'stocks': StockSerializer(snapshot['stocks'], many=True).data,
                'indices': MarketIndexSerializer(snapshot['indices'], many=True).data,
                'updatedAt': snapshot['updated_at'],
                'provider': snapshot['provider'],
            }
        )


class StockSearchView(APIView):
    permission_classes = [IsAuthenticated, IsKycVerified]

    def get(self, request):
        query = request.query_params.get('q', '').strip()
        live = request.query_params.get('live', '1') != '0'

        try:
            if not query:
                qs = refresh_nifty50() if live else Stock.objects.filter(exchange='NSE').order_by('-market_cap_cr')[:50]
            else:
                qs = Stock.objects.filter(
                    Q(symbol__icontains=query) | Q(name__icontains=query),
                    exchange='NSE',
                )[:30]
                if live and qs.exists():
                    refresh_stocks([s.symbol for s in qs])
                    qs = Stock.objects.filter(pk__in=[s.pk for s in qs])
        except FinnhubError as exc:
            return Response({'detail': str(exc)}, status=status.HTTP_503_SERVICE_UNAVAILABLE)

        if query:
            return Response(StockSerializer(qs, many=True).data)
        return Response(StockSerializer(list(qs[:50]), many=True).data)


class StockQuoteView(APIView):
    permission_classes = [IsAuthenticated, IsKycVerified]

    def get(self, request, symbol):
        try:
            stock = refresh_stock(symbol.upper(), include_fundamentals=True)
        except FinnhubError as exc:
            return Response({'detail': str(exc)}, status=status.HTTP_503_SERVICE_UNAVAILABLE)
        except Stock.DoesNotExist:
            return Response({'detail': 'Stock not found.'}, status=404)

        return Response(
            {
                **StockSerializer(stock).data,
                'updatedAt': timezone.now().isoformat(),
            }
        )


class StockCandlesView(APIView):
    permission_classes = [IsAuthenticated, IsKycVerified]

    def get(self, request, symbol):
        interval = request.query_params.get('interval', '1d')
        fast = request.query_params.get('fast', '').lower() in ('1', 'true', 'yes')
        try:
            candles = get_live_candles(symbol.upper(), interval=interval, fast=fast)
        except FinnhubError as exc:
            return Response({'detail': str(exc)}, status=status.HTTP_503_SERVICE_UNAVAILABLE)
        except Stock.DoesNotExist:
            return Response({'detail': 'Stock not found.'}, status=404)

        return Response(StockCandleSerializer(candles, many=True).data)


class WatchlistView(APIView):
    permission_classes = [IsAuthenticated, IsKycVerified]

    def get(self, request):
        items = WatchlistItem.objects.filter(user=request.user).select_related('stock')
        symbols = [i.stock.symbol for i in items]
        try:
            if symbols:
                refresh_stocks(symbols)
                items = WatchlistItem.objects.filter(user=request.user).select_related('stock')
        except FinnhubError as exc:
            return Response({'detail': str(exc)}, status=status.HTTP_503_SERVICE_UNAVAILABLE)
        return Response(StockSerializer([i.stock for i in items], many=True).data)


class WatchlistSymbolView(APIView):
    permission_classes = [IsAuthenticated, IsKycVerified]

    def post(self, request, symbol):
        try:
            stock = refresh_stock(symbol.upper())
        except FinnhubError as exc:
            return Response({'detail': str(exc)}, status=503)
        WatchlistItem.objects.get_or_create(user=request.user, stock=stock)
        return Response({'success': True}, status=201)

    def delete(self, request, symbol):
        WatchlistItem.objects.filter(
            user=request.user, stock__symbol__iexact=symbol
        ).delete()
        return Response(status=204)


class PortfolioOverviewView(APIView):
    permission_classes = [IsAuthenticated, IsKycVerified]

    def get(self, request):
        refresh = request.query_params.get('refresh', '0').strip() in ('1', 'true', 'yes')
        return Response(camelize(get_stock_portfolio(request.user, refresh=refresh)))


class PortfolioHoldingsView(APIView):
    permission_classes = [IsAuthenticated, IsKycVerified]

    def get(self, request):
        data = get_stock_portfolio(request.user)
        return Response(camelize(data['holdings']))


class PortfolioAnalyticsView(APIView):
    permission_classes = [IsAuthenticated, IsKycVerified]

    def get(self, request):
        data = get_stock_portfolio(request.user)
        summary = data['summary']
        return Response(
            camelize(
                {
                    'total_invested': summary['total_invested'],
                    'current_value': summary['current_value'],
                    'pnl': summary['total_pnl'],
                    'pnl_percent': summary['total_pnl_percent'],
                    'day_pnl': summary['day_pnl'],
                    'day_pnl_percent': summary['day_pnl_percent'],
                    'sector_breakdown': {
                        item['label']: item['value'] for item in data['sector_allocation']
                    },
                    'sector_allocation': data['sector_allocation'],
                    'holdings_count': summary['holdings_count'],
                    'holdings': data['holdings'],
                }
            )
        )


class StockNewsView(APIView):
    permission_classes = [IsAuthenticated, IsKycVerified]

    def get(self, request):
        symbol = request.query_params.get('symbol')
        limit = min(int(request.query_params.get('limit', 20)), 50)
        news = fetch_market_news(limit=limit, symbol=symbol)
        return Response(StockNewsSerializer(news, many=True).data)


class PriceAlertsView(APIView):
    permission_classes = [IsAuthenticated, IsKycVerified]

    def get(self, request):
        alerts = PriceAlert.objects.filter(user=request.user).select_related('stock')
        return Response(PriceAlertSerializer(alerts, many=True).data)

    def post(self, request):
        serializer = CreateAlertSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        symbol = serializer.validated_data['symbol'].upper()
        stock = Stock.objects.filter(symbol=symbol).first()
        if not stock:
            try:
                stock = refresh_stock(symbol)
            except FinnhubError as exc:
                return Response({'detail': str(exc)}, status=503)
        alert = PriceAlert.objects.create(
            user=request.user,
            stock=stock,
            target_price=serializer.validated_data['target_price'],
            condition=serializer.validated_data['condition'],
        )
        return Response(PriceAlertSerializer(alert).data, status=201)


class PriceAlertDetailView(APIView):
    permission_classes = [IsAuthenticated, IsKycVerified]

    def patch(self, request, alert_id):
        try:
            alert = PriceAlert.objects.get(user=request.user, pk=alert_id)
        except PriceAlert.DoesNotExist:
            return Response({'detail': 'Alert not found.'}, status=404)
        if 'is_active' in request.data:
            alert.is_active = bool(request.data['is_active'])
            alert.save(update_fields=['is_active'])
        elif 'isActive' in request.data:
            alert.is_active = bool(request.data['isActive'])
            alert.save(update_fields=['is_active'])
        return Response(PriceAlertSerializer(alert).data)

    def delete(self, request, alert_id):
        deleted, _ = PriceAlert.objects.filter(user=request.user, pk=alert_id).delete()
        if not deleted:
            return Response({'detail': 'Alert not found.'}, status=404)
        return Response(status=204)


class SipPlansView(APIView):
    permission_classes = [IsAuthenticated, IsKycVerified]

    def get(self, request):
        plans = SipPlan.objects.filter(user=request.user, is_active=True).select_related('stock')
        return Response(SipPlanSerializer(plans, many=True).data)

    def post(self, request):
        serializer = CreateSipSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        symbol = serializer.validated_data['symbol'].upper()
        stock = Stock.objects.filter(symbol=symbol).first()
        if not stock:
            try:
                stock = refresh_stock(symbol)
            except FinnhubError as exc:
                return Response({'detail': str(exc)}, status=503)
        plan = SipPlan.objects.create(
            user=request.user,
            stock=stock,
            monthly_amount=serializer.validated_data['monthly_amount'],
            total_installments=serializer.validated_data.get('total_installments', 12),
            next_date=date.today() + timedelta(days=30),
        )
        return Response(SipPlanSerializer(plan).data, status=201)


class SipPlanDetailView(APIView):
    permission_classes = [IsAuthenticated, IsKycVerified]

    def delete(self, request, plan_id):
        updated = SipPlan.objects.filter(user=request.user, pk=plan_id, is_active=True).update(
            is_active=False
        )
        if not updated:
            return Response({'detail': 'SIP plan not found.'}, status=404)
        return Response(status=204)


class OptionChainView(APIView):
    permission_classes = [IsAuthenticated, IsKycVerified]

    def get(self, request, symbol):
        expiry = request.query_params.get('expiry')
        fast = request.query_params.get('fast', '').lower() in ('1', 'true', 'yes')
        try:
            chain = get_option_chain(symbol, expiry=expiry, fast=fast)
        except FinnhubError as exc:
            return Response({'detail': str(exc)}, status=status.HTTP_503_SERVICE_UNAVAILABLE)
        if not chain:
            return Response({'detail': 'Unable to load option chain for this symbol.'}, status=404)

        contracts = OptionContractSerializer(chain['contracts'], many=True).data
        return Response(
            {
                'symbol': chain['symbol'],
                'underlyingValue': chain['underlying_value'],
                'expiryDates': chain['expiry_dates'],
                'selectedExpiry': chain['selected_expiry'],
                'updatedAt': chain['updated_at'],
                'provider': chain['source'],
                'contracts': contracts,
            }
        )


class PaperTradingOrdersView(APIView):
    permission_classes = [IsAuthenticated, IsKycVerified]

    def get(self, request):
        return Response(list_recent_trades(request.user, limit=50))

    def post(self, request):
        serializer = PaperOrderSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data
        try:
            payload = place_paper_order(
                request.user,
                symbol=data['symbol'],
                side=data['side'],
                quantity=data['quantity'],
            )
        except TradingError as exc:
            return Response({'detail': str(exc)}, status=400)
        payload['success'] = True
        payload['message'] = (
            'Sell order executed successfully.'
            if data['side'].upper() == 'SELL'
            else 'Buy order executed successfully.'
        )
        return Response(payload, status=201)


class ScreenerView(APIView):
    permission_classes = [IsAuthenticated, IsKycVerified]

    def get(self, request):
        sector = request.query_params.get('sector')
        min_pe = request.query_params.get('min_pe')
        max_pe = request.query_params.get('max_pe')
        min_roe = request.query_params.get('min_roe')
        max_de = request.query_params.get('max_de')
        sort = request.query_params.get('sort', 'market_cap')
        limit = min(int(request.query_params.get('limit', 50)), 100)

        def _float(val):
            if val in (None, ''):
                return None
            return float(val)

        try:
            stocks = get_screener_results(
                sector=sector,
                min_pe=_float(min_pe),
                max_pe=_float(max_pe),
                min_roe=_float(min_roe),
                max_de=_float(max_de),
                sort=sort,
                limit=limit,
            )
        except FinnhubError as exc:
            return Response({'detail': str(exc)}, status=status.HTTP_503_SERVICE_UNAVAILABLE)

        return Response(
            {
                'sectors': get_screener_sectors(),
                'sort': sort,
                'updatedAt': timezone.now().isoformat(),
                'provider': provider_label(),
                'results': ScreenerStockSerializer(stocks, many=True).data,
            }
        )


class DividendsView(APIView):
    permission_classes = [IsAuthenticated, IsKycVerified]

    def get(self, request):
        sync = request.query_params.get('sync', 'true').lower() != 'false'
        if sync:
            try:
                sync_user_dividends(request.user)
            except Exception:
                pass
        records = DividendRecord.objects.filter(user=request.user).select_related('stock')
        return Response(DividendSerializer(records, many=True).data)
