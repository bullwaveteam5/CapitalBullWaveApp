from django.urls import path

from .views import AiHistoryView, AiSuggestionsView, StockAssistantView

urlpatterns = [
    path('ai/stock-assistant/', StockAssistantView.as_view(), name='ai-stock-assistant'),
    path('ai/history/', AiHistoryView.as_view(), name='ai-history'),
    path('ai/suggestions/', AiSuggestionsView.as_view(), name='ai-suggestions'),
]
