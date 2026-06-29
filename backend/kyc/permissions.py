"""DRF permissions for KYC-gated resources."""

from rest_framework.permissions import BasePermission

from accounts.models import User

from .manual_service import user_kyc_is_verified
from .models import KycProfile
from .service import get_or_create_profile


class IsKycVerified(BasePermission):
    message = 'Complete KYC verification to access markets.'

    def has_permission(self, request, view):
        if not request.user or not request.user.is_authenticated:
            return False
        if user_kyc_is_verified(request.user):
            return True
        # Legacy Cashfree profile check
        profile = get_or_create_profile(request.user)
        return profile.overall_status == KycProfile.OverallStatus.VERIFIED
