from django.utils import timezone
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from stocks.models import Stock, WatchlistItem

from .llm_service import LlmError, generate_stock_assistant_reply
from .models import AiChatMessage
from .serializers import AiChatMessageSerializer

DEFAULT_SUGGESTIONS = [
    'Should I buy RELIANCE?',
    'Explain RSI indicator',
    'Best IT stocks today?',
    'Nifty outlook this week',
    'What is P/E ratio?',
    'How does SIP work?',
]

HISTORY_LIMIT = 6


class StockAssistantView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        message = request.data.get('message', '').strip()
        symbol = (request.data.get('symbol') or '').strip().upper()
        if not message:
            return Response({'detail': 'Message is required.'}, status=status.HTTP_400_BAD_REQUEST)

        user = request.user
        user_msg = AiChatMessage.objects.create(
            user=user,
            role=AiChatMessage.Role.USER,
            content=message,
            symbol=symbol,
        )

        recent = AiChatMessage.objects.filter(user=user).order_by('-created_at')[:HISTORY_LIMIT]
        history = [
            {'role': msg.role, 'content': msg.content}
            for msg in reversed(list(recent))
        ]

        try:
            reply_text = generate_stock_assistant_reply(
                user=user,
                message=message,
                symbol=symbol,
                history=history[:-1],
            )
        except LlmError as exc:
            user_msg.delete()
            return Response({'detail': str(exc)}, status=status.HTTP_503_SERVICE_UNAVAILABLE)

        assistant_msg = AiChatMessage.objects.create(
            user=user,
            role=AiChatMessage.Role.ASSISTANT,
            content=reply_text,
            symbol=symbol,
        )

        return Response(
            {
                'role': assistant_msg.role,
                'content': assistant_msg.content,
                'symbol': assistant_msg.symbol,
                'time': assistant_msg.created_at,
                'id': assistant_msg.id,
            }
        )


class AiHistoryView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        messages = AiChatMessage.objects.filter(user=request.user).order_by('created_at')
        return Response(AiChatMessageSerializer(messages, many=True).data)

    def delete(self, request):
        AiChatMessage.objects.filter(user=request.user).delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


class AiSuggestionsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        suggestions = list(DEFAULT_SUGGESTIONS)

        watchlist = (
            WatchlistItem.objects.filter(user=request.user)
            .select_related('stock')
            .order_by('-added_at')[:2]
        )
        for item in watchlist:
            prompt = f'Latest view on {item.stock.symbol}?'
            if prompt not in suggestions:
                suggestions.insert(0, prompt)

        trending = Stock.objects.order_by('-volume')[:2]
        for stock in trending:
            prompt = f'Why is {stock.symbol} moving today?'
            if prompt not in suggestions:
                suggestions.append(prompt)

        return Response({'suggestions': suggestions[:8], 'generatedAt': timezone.now()})
