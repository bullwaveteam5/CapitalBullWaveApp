"""Signed, time-limited tokens for one-click KYC approve/reject from admin email."""

from django.core.signing import BadSignature, SignatureExpired, TimestampSigner

_SIGNER = TimestampSigner(salt='bullwave-kyc-email-review-v1')
_MAX_AGE_SECONDS = 7 * 24 * 60 * 60  # 7 days

VALID_ACTIONS = frozenset({'approve', 'reject'})


def make_kyc_action_token(request_id: str, action: str) -> str:
    action = (action or '').strip().lower()
    if action not in VALID_ACTIONS:
        raise ValueError(f'Invalid KYC email action: {action}')
    return _SIGNER.sign(f'{request_id}:{action}')


def parse_kyc_action_token(token: str) -> tuple[str, str]:
    """Return (request_id, action). Raises ValueError on invalid/expired token."""
    token = (token or '').strip()
    if not token:
        raise ValueError('Missing review token.')
    try:
        payload = _SIGNER.unsign(token, max_age=_MAX_AGE_SECONDS)
    except SignatureExpired as exc:
        raise ValueError('This review link has expired. Use Django admin instead.') from exc
    except BadSignature as exc:
        raise ValueError('Invalid review link.') from exc

    if ':' not in payload:
        raise ValueError('Malformed review token.')
    request_id, action = payload.split(':', 1)
    if action not in VALID_ACTIONS:
        raise ValueError('Unknown review action.')
    return request_id, action
