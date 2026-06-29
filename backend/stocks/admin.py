from django.contrib import admin

from .models import (
    DividendRecord,
    OptionContract,
    PaperTrade,
    PriceAlert,
    SipPlan,
    Stock,
    StockCandle,
    StockHolding,
    StockNews,
    WatchlistItem,
)

admin.site.register(Stock)
admin.site.register(StockCandle)
admin.site.register(WatchlistItem)
admin.site.register(StockHolding)
admin.site.register(PriceAlert)
admin.site.register(SipPlan)
admin.site.register(PaperTrade)
admin.site.register(StockNews)
admin.site.register(OptionContract)
admin.site.register(DividendRecord)
