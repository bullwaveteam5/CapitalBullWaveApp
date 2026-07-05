from django.contrib import admin

from .models import (
    DividendRecord,
    IpoEvent,
    IpoHolding,
    IpoTrade,
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


@admin.register(IpoEvent)
class IpoEventAdmin(admin.ModelAdmin):
    list_display = ('company_name', 'status', 'open_date', 'close_date', 'listing_date', 'is_featured')
    list_filter = ('status', 'exchange', 'is_featured')
    search_fields = ('company_name', 'symbol', 'sector')


admin.site.register(IpoHolding)
admin.site.register(IpoTrade)
