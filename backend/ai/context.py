from stocks.models import Stock, StockHolding, WatchlistItem
from engagement.models import MarketIndex


def build_user_context(user, symbol=''):
    """Compact context for faster LLM inference."""
    lines = []

    indices = MarketIndex.objects.all()[:3]
    if indices:
        lines.append(
            'Indices: '
            + ', '.join(f'{i.short_name} {i.change_percent:+.1f}%' for i in indices)
        )

    watchlist = (
        WatchlistItem.objects.filter(user=user)
        .select_related('stock')
        .order_by('-added_at')[:4]
    )
    if watchlist:
        lines.append(
            'Watchlist: ' + ', '.join(f'{w.stock.symbol} ₹{w.stock.ltp}' for w in watchlist)
        )

    holdings = (
        StockHolding.objects.filter(user=user)
        .select_related('stock')
        .order_by('-quantity')[:4]
    )
    if holdings:
        lines.append(
            'Holdings: '
            + ', '.join(f'{h.stock.symbol}x{h.quantity}' for h in holdings)
        )

    symbol = symbol.strip().upper()
    if symbol:
        stock = Stock.objects.filter(symbol__iexact=symbol).first()
        if stock:
            lines.append(
                f'{stock.symbol}: ₹{stock.ltp} ({stock.change_percent:+.1f}%), PE {stock.pe}'
            )

    return '\n'.join(lines) if lines else 'No portfolio data yet.'
