import logging

from django.apps import AppConfig

logger = logging.getLogger('bullwave.ai')


class AiConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'ai'

    def ready(self):
        from django.conf import settings

        provider = (settings.AI_PROVIDER or '').lower()

        if provider != 'ollama':
            self._log_cloud_provider(provider, settings)
            return

        from .ollama_client import check_ollama, warmup_model

        ok, message = check_ollama()
        if ok:
            logger.info('AI assistant ready — %s', message)
            warmup_model()
        else:
            logger.warning(
                'AI assistant (Ollama) not ready: %s\n'
                '  1. Install: https://ollama.com/download\n'
                '  2. Run: ollama pull llama3.2:1b  (fast model)\n'
                '  3. Restart Django runserver',
                message,
            )

    def _log_cloud_provider(self, provider, settings):
        ready = False
        model = ''

        if provider == 'openai' and (settings.OPENAI_API_KEY or '').strip():
            ready, model = True, settings.OPENAI_MODEL
        elif provider == 'gemini' and (settings.GEMINI_API_KEY or '').strip():
            ready, model = True, settings.GEMINI_MODEL
        elif provider == 'groq' and (settings.GROQ_API_KEY or '').strip():
            ready, model = True, settings.GROQ_MODEL

        if ready:
            logger.info('AI assistant ready (provider=%s, model=%s)', provider, model)
        else:
            logger.warning('AI assistant NOT configured for provider=%s', provider)
