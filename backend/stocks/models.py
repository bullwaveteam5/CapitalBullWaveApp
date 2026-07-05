import uuid

from django.conf import settings
from django.db import models


class Stock(models.Model):
    symbol = models.CharField(max_length=20, unique=True, db_index=True)
    name = models.CharField(max_length=120)
    exchange = models.CharField(max_length=10, default='NSE')
    sector = models.CharField(max_length=60)
    ltp = models.DecimalField(max_digits=12, decimal_places=2)
    change = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    change_percent = models.DecimalField(max_digits=8, decimal_places=2, default=0)
    open_price = models.DecimalField(max_digits=12, decimal_places=2)
    high = models.DecimalField(max_digits=12, decimal_places=2)
    low = models.DecimalField(max_digits=12, decimal_places=2)
    previous_close = models.DecimalField(max_digits=12, decimal_places=2)
    volume = models.BigIntegerField(default=0)
    market_cap_cr = models.DecimalField(max_digits=16, decimal_places=2, default=0)
    pe = models.DecimalField(max_digits=8, decimal_places=2, default=0)
    eps = models.DecimalField(max_digits=8, decimal_places=2, default=0)
    week52_high = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    week52_low = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    roe = models.DecimalField(max_digits=8, decimal_places=2, default=0)
    debt_to_equity = models.DecimalField(max_digits=8, decimal_places=2, default=0)
    revenue_growth = models.DecimalField(max_digits=8, decimal_places=2, default=0)

    def __str__(self):
        return self.symbol


class StockCandle(models.Model):
    class Interval(models.TextChoices):
        M1 = '1m', '1 Minute'
        M5 = '5m', '5 Minutes'
        M30 = '30m', '30 Minutes'
        H1 = '1h', '1 Hour'
        D1 = '1d', '1 Day'
        D90 = '90d', '90 Days'

    stock = models.ForeignKey(Stock, on_delete=models.CASCADE, related_name='candles')
    time = models.DateTimeField()
    open_price = models.DecimalField(max_digits=12, decimal_places=2)
    high = models.DecimalField(max_digits=12, decimal_places=2)
    low = models.DecimalField(max_digits=12, decimal_places=2)
    close = models.DecimalField(max_digits=12, decimal_places=2)
    volume = models.BigIntegerField(default=0)
    interval = models.CharField(max_length=5, choices=Interval.choices, default=Interval.D1)

    class Meta:
        ordering = ['time']
        indexes = [models.Index(fields=['stock', 'interval', 'time'])]


class WatchlistItem(models.Model):
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='watchlist_items'
    )
    stock = models.ForeignKey(Stock, on_delete=models.CASCADE)
    added_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('user', 'stock')
        ordering = ['-added_at']


class StockHolding(models.Model):
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='stock_holdings'
    )
    stock = models.ForeignKey(Stock, on_delete=models.CASCADE)
    quantity = models.PositiveIntegerField()
    avg_price = models.DecimalField(max_digits=12, decimal_places=2)

    class Meta:
        unique_together = ('user', 'stock')


class PriceAlert(models.Model):
    class Condition(models.TextChoices):
        ABOVE = 'above', 'Above'
        BELOW = 'below', 'Below'

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='price_alerts'
    )
    stock = models.ForeignKey(Stock, on_delete=models.CASCADE)
    target_price = models.DecimalField(max_digits=12, decimal_places=2)
    condition = models.CharField(max_length=10, choices=Condition.choices)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)


class SipPlan(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='sip_plans'
    )
    stock = models.ForeignKey(Stock, on_delete=models.CASCADE)
    monthly_amount = models.DecimalField(max_digits=12, decimal_places=2)
    installments_done = models.PositiveIntegerField(default=0)
    total_installments = models.PositiveIntegerField(default=12)
    total_invested = models.DecimalField(max_digits=14, decimal_places=2, default=0)
    current_value = models.DecimalField(max_digits=14, decimal_places=2, default=0)
    next_date = models.DateField()
    is_active = models.BooleanField(default=True)


class PaperTrade(models.Model):
    class Side(models.TextChoices):
        BUY = 'BUY', 'Buy'
        SELL = 'SELL', 'Sell'

    class Status(models.TextChoices):
        EXECUTED = 'Executed', 'Executed'
        PENDING = 'Pending', 'Pending'
        CANCELLED = 'Cancelled', 'Cancelled'

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='paper_trades'
    )
    stock = models.ForeignKey(Stock, on_delete=models.CASCADE)
    side = models.CharField(max_length=4, choices=Side.choices)
    quantity = models.PositiveIntegerField()
    price = models.DecimalField(max_digits=12, decimal_places=2)
    avg_cost = models.DecimalField(max_digits=12, decimal_places=2, null=True, blank=True)
    realized_pnl = models.DecimalField(max_digits=14, decimal_places=2, null=True, blank=True)
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.EXECUTED)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']


class StockNews(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    title = models.CharField(max_length=300)
    summary = models.TextField()
    source = models.CharField(max_length=80)
    published_at = models.DateTimeField()
    related_symbols = models.JSONField(default=list)
    category = models.CharField(max_length=40, default='market')
    stock = models.ForeignKey(
        Stock, null=True, blank=True, on_delete=models.SET_NULL, related_name='news'
    )

    class Meta:
        ordering = ['-published_at']


class OptionContract(models.Model):
    class OptionType(models.TextChoices):
        CE = 'CE', 'Call'
        PE = 'PE', 'Put'

    underlying = models.CharField(max_length=20, db_index=True)
    strike = models.DecimalField(max_digits=12, decimal_places=2)
    option_type = models.CharField(max_length=2, choices=OptionType.choices)
    ltp = models.DecimalField(max_digits=12, decimal_places=2)
    change = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    oi = models.BigIntegerField(default=0)
    volume = models.BigIntegerField(default=0)
    expiry = models.DateField()

    class Meta:
        indexes = [models.Index(fields=['underlying', 'expiry'])]


class DividendRecord(models.Model):
    class Status(models.TextChoices):
        UPCOMING = 'Upcoming', 'Upcoming'
        PAID = 'Paid', 'Paid'

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='dividends'
    )
    stock = models.ForeignKey(Stock, on_delete=models.CASCADE)
    amount_per_share = models.DecimalField(max_digits=8, decimal_places=2)
    ex_date = models.DateField()
    payment_date = models.DateField()
    shares_held = models.PositiveIntegerField(default=0)
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.UPCOMING)


class CommodityHolding(models.Model):
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='commodity_holdings'
    )
    commodity_id = models.CharField(max_length=20, db_index=True)
    quantity = models.PositiveIntegerField()
    avg_price_usd = models.DecimalField(max_digits=12, decimal_places=2)

    class Meta:
        unique_together = ('user', 'commodity_id')


class CommodityTrade(models.Model):
    class Side(models.TextChoices):
        BUY = 'BUY', 'Buy'
        SELL = 'SELL', 'Sell'

    class Status(models.TextChoices):
        EXECUTED = 'Executed', 'Executed'

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='commodity_trades'
    )
    commodity_id = models.CharField(max_length=20, db_index=True)
    side = models.CharField(max_length=4, choices=Side.choices)
    quantity = models.PositiveIntegerField()
    price_usd = models.DecimalField(max_digits=12, decimal_places=2)
    amount_inr = models.DecimalField(max_digits=14, decimal_places=2)
    usd_inr_rate = models.DecimalField(max_digits=8, decimal_places=2)
    avg_cost_usd = models.DecimalField(max_digits=12, decimal_places=2, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']


class OptionHolding(models.Model):
    class AssetClass(models.TextChoices):
        EQUITY_FNO = 'equity_fno', 'Equity F&O'
        COMMODITY = 'commodity', 'Commodity'

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='option_holdings'
    )
    underlying = models.CharField(max_length=20, db_index=True)
    asset_class = models.CharField(max_length=20, choices=AssetClass.choices, default=AssetClass.EQUITY_FNO)
    strike = models.DecimalField(max_digits=12, decimal_places=4)
    option_type = models.CharField(max_length=2)
    expiry = models.DateField()
    quantity = models.PositiveIntegerField()
    avg_premium = models.DecimalField(max_digits=12, decimal_places=4)
    lot_size = models.PositiveIntegerField(default=1)

    class Meta:
        unique_together = ('user', 'underlying', 'strike', 'option_type', 'expiry', 'asset_class')


class OptionTrade(models.Model):
    class Side(models.TextChoices):
        BUY = 'BUY', 'Buy'
        SELL = 'SELL', 'Sell'

    class Status(models.TextChoices):
        EXECUTED = 'Executed', 'Executed'

    class AssetClass(models.TextChoices):
        EQUITY_FNO = 'equity_fno', 'Equity F&O'
        COMMODITY = 'commodity', 'Commodity'

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='option_trades'
    )
    underlying = models.CharField(max_length=20, db_index=True)
    asset_class = models.CharField(max_length=20, choices=AssetClass.choices, default=AssetClass.EQUITY_FNO)
    strike = models.DecimalField(max_digits=12, decimal_places=4)
    option_type = models.CharField(max_length=2)
    expiry = models.DateField()
    side = models.CharField(max_length=4, choices=Side.choices)
    quantity = models.PositiveIntegerField()
    premium = models.DecimalField(max_digits=12, decimal_places=4)
    lot_size = models.PositiveIntegerField(default=1)
    amount_inr = models.DecimalField(max_digits=14, decimal_places=2)
    avg_premium = models.DecimalField(max_digits=12, decimal_places=4, null=True, blank=True)
    realized_pnl_inr = models.DecimalField(max_digits=14, decimal_places=2, null=True, blank=True)
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.EXECUTED)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']


class IpoEvent(models.Model):
    class Status(models.TextChoices):
        UPCOMING = 'upcoming', 'Upcoming'
        OPEN = 'open', 'Open Now'
        CLOSED = 'closed', 'Closed'
        LISTED = 'listed', 'Listed'

    id = models.CharField(primary_key=True, max_length=40)
    company_name = models.CharField(max_length=160)
    symbol = models.CharField(max_length=20, blank=True)
    sector = models.CharField(max_length=80)
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.UPCOMING)
    open_date = models.DateField(null=True, blank=True)
    close_date = models.DateField(null=True, blank=True)
    listing_date = models.DateField(null=True, blank=True)
    price_band_min = models.DecimalField(max_digits=12, decimal_places=2)
    price_band_max = models.DecimalField(max_digits=12, decimal_places=2)
    issue_size_cr = models.DecimalField(max_digits=10, decimal_places=2)
    lot_size = models.PositiveIntegerField(default=1)
    min_investment = models.DecimalField(max_digits=12, decimal_places=2)
    gmp_percent = models.DecimalField(max_digits=8, decimal_places=2, null=True, blank=True)
    subscription_times = models.CharField(max_length=20, blank=True)
    exchange = models.CharField(max_length=10, default='NSE')
    is_featured = models.BooleanField(default=False)
    description = models.TextField(blank=True)

    class Meta:
        ordering = ['open_date', 'listing_date']
        verbose_name = 'IPO event'


class IpoHolding(models.Model):
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='ipo_holdings'
    )
    ipo = models.ForeignKey(IpoEvent, on_delete=models.CASCADE, related_name='holdings')
    lots = models.PositiveIntegerField()
    quantity = models.PositiveIntegerField()
    avg_price = models.DecimalField(max_digits=12, decimal_places=2)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('user', 'ipo')


class IpoTrade(models.Model):
    class Side(models.TextChoices):
        APPLY = 'APPLY', 'Apply'
        SELL = 'SELL', 'Sell'

    class Status(models.TextChoices):
        EXECUTED = 'Executed', 'Executed'
        CANCELLED = 'Cancelled', 'Cancelled'

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='ipo_trades'
    )
    ipo = models.ForeignKey(IpoEvent, on_delete=models.CASCADE, related_name='trades')
    side = models.CharField(max_length=8, choices=Side.choices)
    lots = models.PositiveIntegerField(default=1)
    quantity = models.PositiveIntegerField()
    price = models.DecimalField(max_digits=12, decimal_places=2)
    amount_inr = models.DecimalField(max_digits=14, decimal_places=2)
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.EXECUTED)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']
