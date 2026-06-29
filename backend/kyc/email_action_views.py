"""Public HTML endpoints — admin approves/rejects KYC directly from email links."""

import html
import logging

from django.http import HttpResponse
from django.views import View

from accounts.models import User

from .email_tokens import parse_kyc_action_token
from .constants import KYC_WRONG_INFO_REJECTION_REASON
from .manual_service import (
    ManualKycError,
    approve_kyc_request,
    reject_kyc_request,
)
from .models import KYCRequest

logger = logging.getLogger('bullwave.kyc')


def _get_email_reviewer() -> User:
    admin = User.objects.filter(is_superuser=True).order_by('date_joined').first()
    if admin:
        return admin
    admin = User.objects.filter(is_staff=True).order_by('date_joined').first()
    if admin:
        return admin
    raise ManualKycError('No staff account is configured to process email reviews.')


def _render_page(*, title: str, message: str, success: bool) -> str:
    accent = '#16a34a' if success else '#dc2626'
    icon = '✓' if success else '!'
    safe_title = html.escape(title)
    safe_message = html.escape(message)
    return f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>{safe_title} — BullWave</title>
  <style>
    body {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
           background: #0f172a; color: #e2e8f0; margin: 0; padding: 32px 16px; }}
    .card {{ max-width: 520px; margin: 0 auto; background: #1e293b; border-radius: 16px;
             padding: 32px; border: 1px solid #334155; text-align: center; }}
    .badge {{ width: 64px; height: 64px; border-radius: 50%; background: {accent}22;
              color: {accent}; font-size: 28px; line-height: 64px; margin: 0 auto 20px; }}
    h1 {{ margin: 0 0 12px; font-size: 22px; }}
    p {{ margin: 0; color: #94a3b8; line-height: 1.6; }}
  </style>
</head>
<body>
  <div class="card">
    <div class="badge">{icon}</div>
    <h1>{safe_title}</h1>
    <p>{safe_message}</p>
  </div>
</body>
</html>"""


def _html_response(*, title: str, message: str, success: bool, status: int = 200) -> HttpResponse:
    return HttpResponse(
        _render_page(title=title, message=message, success=success),
        content_type='text/html; charset=utf-8',
        status=status,
    )


class KycEmailApproveView(View):
    """GET /api/v1/kyc/review/approve/?token=..."""

    def get(self, request):
        token = request.GET.get('token', '')
        try:
            request_id, action = parse_kyc_action_token(token)
            if action != 'approve':
                raise ValueError('This link is for rejection, not approval.')
            req = KYCRequest.objects.select_related('user').get(pk=request_id)
        except KYCRequest.DoesNotExist:
            return _html_response(
                title='Request not found',
                message='This KYC request no longer exists.',
                success=False,
                status=404,
            )
        except ValueError as exc:
            return _html_response(title='Invalid link', message=str(exc), success=False, status=400)

        if req.status == KYCRequest.Status.APPROVED:
            return _html_response(
                title='Already approved',
                message=f'KYC for {req.user.phone} was already approved. The user can access the app.',
                success=True,
            )
        if req.status == KYCRequest.Status.REJECTED:
            return _html_response(
                title='Cannot approve',
                message='This request was already rejected. The user must resubmit KYC.',
                success=False,
                status=409,
            )

        try:
            reviewer = _get_email_reviewer()
            approve_kyc_request(req, reviewer)
        except ManualKycError as exc:
            return _html_response(title='Approval failed', message=str(exc), success=False, status=400)
        except Exception:
            logger.exception('Email approve failed for request %s', request_id)
            return _html_response(
                title='Something went wrong',
                message='Could not approve this request. Try Django admin.',
                success=False,
                status=500,
            )

        return _html_response(
            title='KYC approved',
            message=(
                f'{req.full_name} ({req.user.phone}) is verified. '
                f'They have been notified and can access the BullWave app.'
            ),
            success=True,
        )


class KycEmailRejectView(View):
    """GET /api/v1/kyc/review/reject/?token=..."""

    def get(self, request):
        token = request.GET.get('token', '')
        try:
            request_id, action = parse_kyc_action_token(token)
            if action != 'reject':
                raise ValueError('This link is for approval, not rejection.')
            req = KYCRequest.objects.select_related('user').get(pk=request_id)
        except KYCRequest.DoesNotExist:
            return _html_response(
                title='Request not found',
                message='This KYC request no longer exists.',
                success=False,
                status=404,
            )
        except ValueError as exc:
            return _html_response(title='Invalid link', message=str(exc), success=False, status=400)

        if req.status == KYCRequest.Status.REJECTED:
            return _html_response(
                title='Already rejected',
                message='This KYC request was already rejected. The user has been notified.',
                success=True,
            )
        if req.status == KYCRequest.Status.APPROVED:
            return _html_response(
                title='Cannot reject',
                message='This request was already approved.',
                success=False,
                status=409,
            )

        try:
            reviewer = _get_email_reviewer()
            reject_kyc_request(req, reviewer, KYC_WRONG_INFO_REJECTION_REASON)
        except ManualKycError as exc:
            return _html_response(title='Rejection failed', message=str(exc), success=False, status=400)
        except Exception:
            logger.exception('Email reject failed for request %s', request_id)
            return _html_response(
                title='Something went wrong',
                message='Could not reject this request. Try Django admin.',
                success=False,
                status=500,
            )

        return _html_response(
            title='KYC rejected',
            message=(
                f'{req.full_name} ({req.user.phone}) was rejected due to wrong information. '
                f'They can resubmit KYC from the app.'
            ),
            success=True,
        )
