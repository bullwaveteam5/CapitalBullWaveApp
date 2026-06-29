"""SMS OTP delivery — MSG91, Twilio Messages, Twilio Verify, or console (dev)."""

import logging

import httpx
from django.conf import settings

logger = logging.getLogger('bullwave.integrations')


class SMSError(Exception):
    pass


def uses_twilio_verify() -> bool:
    provider = (getattr(settings, 'SMS_PROVIDER', 'console') or 'console').lower().strip()
    service_sid = (getattr(settings, 'TWILIO_SERVICE_SID', '') or '').strip()
    account_sid = (getattr(settings, 'TWILIO_ACCOUNT_SID', '') or '').strip()
    auth_token = (getattr(settings, 'TWILIO_AUTH_TOKEN', '') or '').strip()
    return provider == 'twilio' and bool(service_sid and account_sid and auth_token)


def send_notification_sms(phone: str, message: str) -> None:
    """Generic transactional SMS (KYC approved, etc.). Falls back to console in dev."""
    provider = (getattr(settings, 'SMS_PROVIDER', 'console') or 'console').lower().strip()
    body = (message or '').strip()
    if not phone or not body:
        return
    if provider == 'twilio' and not uses_twilio_verify():
        _send_twilio_message(phone, body)
    else:
        msg = f'[BullWave SMS] Phone: {phone} | {body}'
        logger.info(msg)
        if settings.DEBUG:
            import sys

            print(msg, flush=True)
            sys.stderr.write(msg + '\n')


def send_otp_sms(phone: str, otp: str) -> None:
    provider = (getattr(settings, 'SMS_PROVIDER', 'console') or 'console').lower().strip()
    if provider == 'msg91':
        _send_msg91(phone, otp)
    elif provider == 'twilio':
        if uses_twilio_verify():
            _send_twilio_verify(phone)
        else:
            _send_twilio(phone, otp)
    else:
        _send_console(phone, otp)


def check_otp_twilio_verify(phone: str, otp: str) -> bool:
    account_sid = (getattr(settings, 'TWILIO_ACCOUNT_SID', '') or '').strip()
    auth_token = (getattr(settings, 'TWILIO_AUTH_TOKEN', '') or '').strip()
    service_sid = (getattr(settings, 'TWILIO_SERVICE_SID', '') or '').strip()
    channel = (getattr(settings, 'TWILIO_VERIFY_CHANNEL', 'sms') or 'sms').strip()

    url = f'https://verify.twilio.com/v2/Services/{service_sid}/VerificationCheck'
    try:
        with httpx.Client(timeout=15) as client:
            response = client.post(
                url,
                data={'To': f'+91{phone}', 'Code': otp, 'Channel': channel},
                auth=(account_sid, auth_token),
            )
    except httpx.HTTPError as exc:
        raise SMSError(f'Twilio Verify connection failed: {exc}') from exc

    if response.is_error:
        raise SMSError(f'Twilio Verify error ({response.status_code}): {response.text[:200]}')

    data = response.json()
    return (data.get('status') or '').lower() == 'approved'


def _send_console(phone: str, otp: str) -> None:
    msg = f'[BullWave OTP] Phone: {phone} | OTP: {otp}'
    logger.info(msg)
    if settings.DEBUG:
        import sys

        print(msg, flush=True)
        sys.stderr.write(msg + '\n')


def _send_msg91(phone: str, otp: str) -> None:
    auth_key = (getattr(settings, 'MSG91_AUTH_KEY', '') or '').strip()
    template_id = (getattr(settings, 'MSG91_TEMPLATE_ID', '') or '').strip()
    if not auth_key or not template_id:
        raise SMSError('MSG91_AUTH_KEY and MSG91_TEMPLATE_ID are required when SMS_PROVIDER=msg91')

    payload = {
        'template_id': template_id,
        'short_url': '0',
        'recipients': [{'mobiles': f'91{phone}', 'otp': otp}],
    }
    try:
        with httpx.Client(timeout=15) as client:
            response = client.post(
                'https://control.msg91.com/api/v5/flow/',
                json=payload,
                headers={'authkey': auth_key, 'Content-Type': 'application/json'},
            )
    except httpx.HTTPError as exc:
        raise SMSError(f'MSG91 connection failed: {exc}') from exc

    if response.is_error:
        raise SMSError(f'MSG91 error ({response.status_code}): {response.text[:200]}')


def _send_twilio_verify(phone: str) -> None:
    account_sid = (getattr(settings, 'TWILIO_ACCOUNT_SID', '') or '').strip()
    auth_token = (getattr(settings, 'TWILIO_AUTH_TOKEN', '') or '').strip()
    service_sid = (getattr(settings, 'TWILIO_SERVICE_SID', '') or '').strip()
    channel = (getattr(settings, 'TWILIO_VERIFY_CHANNEL', 'sms') or 'sms').strip()

    url = f'https://verify.twilio.com/v2/Services/{service_sid}/Verifications'
    try:
        with httpx.Client(timeout=15) as client:
            response = client.post(
                url,
                data={'To': f'+91{phone}', 'Channel': channel},
                auth=(account_sid, auth_token),
            )
    except httpx.HTTPError as exc:
        raise SMSError(f'Twilio Verify connection failed: {exc}') from exc

    if response.is_error:
        raise SMSError(f'Twilio Verify error ({response.status_code}): {response.text[:200]}')

    logger.info('Twilio Verify OTP sent to +91%s', phone)


def _send_twilio_message(phone: str, body: str) -> None:
    account_sid = (getattr(settings, 'TWILIO_ACCOUNT_SID', '') or '').strip()
    auth_token = (getattr(settings, 'TWILIO_AUTH_TOKEN', '') or '').strip()
    from_number = (getattr(settings, 'TWILIO_FROM_NUMBER', '') or '').strip()
    if not all([account_sid, auth_token, from_number]):
        raise SMSError(
            'TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, TWILIO_FROM_NUMBER required for SMS notifications'
        )

    url = f'https://api.twilio.com/2010-04-01/Accounts/{account_sid}/Messages.json'
    try:
        with httpx.Client(timeout=15) as client:
            response = client.post(
                url,
                data={'To': f'+91{phone}', 'From': from_number, 'Body': body},
                auth=(account_sid, auth_token),
            )
    except httpx.HTTPError as exc:
        raise SMSError(f'Twilio connection failed: {exc}') from exc

    if response.is_error:
        raise SMSError(f'Twilio error ({response.status_code}): {response.text[:200]}')


def _send_twilio(phone: str, otp: str) -> None:
    account_sid = (getattr(settings, 'TWILIO_ACCOUNT_SID', '') or '').strip()
    auth_token = (getattr(settings, 'TWILIO_AUTH_TOKEN', '') or '').strip()
    from_number = (getattr(settings, 'TWILIO_FROM_NUMBER', '') or '').strip()
    if not all([account_sid, auth_token, from_number]):
        raise SMSError(
            'TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, TWILIO_FROM_NUMBER required '
            '(or set TWILIO_SERVICE_SID for Twilio Verify)'
        )

    body = f'Your BullWave Capital OTP is {otp}. Valid for {settings.OTP_EXPIRY_MINUTES} minutes.'
    _send_twilio_message(phone, body)
