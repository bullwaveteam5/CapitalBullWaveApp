"""F&O option chain derived from live underlying prices (Finnhub spot + synthetic premiums)."""

import logging
import math
import uuid
from datetime import date, timedelta
from decimal import Decimal

from django.core.cache import cache
from django.utils import timezone

from .market_data_service import get_underlying_spot
from .market_symbols import FNO_INDICES, FNO_STOCKS, NIFTY_50
from .models import Stock

logger = logging.getLogger('bullwave.market')

OPTIONS_CACHE_SECONDS = 300


def _is_index(symbol):
    return symbol.upper() in FNO_INDICES


def _strike_step(spot, symbol):
    sym = symbol.upper()
    if sym in ('NIFTY', 'FINNIFTY'):
        return 50
    if sym == 'BANKNIFTY':
        return 100
    if spot >= 5000:
        return 100
    if spot >= 2000:
        return 50
    if spot >= 1000:
        return 20
    if spot >= 500:
        return 10
    return 5


def _round_strike(spot, step):
    return round(spot / step) * step


def _expiry_weekday(symbol):
    """NSE F&O weekly expiry day (Mon=0 … Sun=6). Updated per NSE 2024 schedule."""
    sym = symbol.upper()
    if sym == 'BANKNIFTY':
        return 2  # Wednesday
    if sym in ('NIFTY', 'FINNIFTY'):
        return 1  # Tuesday
    return 3  # Thursday for stock F&O


def _next_expiries(count=4, symbol='NIFTY'):
    """Next weekly expiry dates per NSE F&O schedule for the symbol."""
    target = _expiry_weekday(symbol)
    today = date.today()
    expiries = []
    d = today
    while len(expiries) < count and (d - today).days <= 60:
        if d.weekday() == target and d >= today:
            expiries.append(d)
        d += timedelta(days=1)
    if not expiries:
        days_ahead = (target - today.weekday()) % 7 or 7
        expiries.append(today + timedelta(days=days_ahead))
    return expiries[:count]


def _build_contracts(symbol, spot, expiry, num_strikes=21):
    step = _strike_step(spot, symbol)
    atm = _round_strike(spot, step)
    half = num_strikes // 2
    strikes = [atm + (i - half) * step for i in range(num_strikes)]
    days = max((expiry - date.today()).days, 1)
    vol_factor = 0.018 if _is_index(symbol) else 0.025

    contracts = []
    for strike in strikes:
        if strike <= 0:
            continue
        moneyness = abs(spot - strike) / spot
        base_oi = int(800000 * math.exp(-moneyness * 6)) if _is_index(symbol) else int(120000 * math.exp(-moneyness * 5))
        for opt_type in ('CE', 'PE'):
            intrinsic_call = max(0.0, spot - strike)
            intrinsic_put = max(0.0, strike - spot)
            intrinsic = intrinsic_call if opt_type == 'CE' else intrinsic_put
            time_val = spot * vol_factor * math.sqrt(days / 365) * math.exp(-moneyness * 4)
            ltp = max(round(intrinsic + time_val, 2), 0.05)
            change = round(ltp * 0.02 * (1 if opt_type == 'CE' else -1), 2)
            contracts.append(
                {
                    'id': str(uuid.uuid4()),
                    'symbol': symbol.upper(),
                    'strike': Decimal(str(strike)),
                    'type': opt_type,
                    'ltp': Decimal(str(ltp)),
                    'change': Decimal(str(change)),
                    'oi': base_oi + (50000 if strike == atm else 0),
                    'volume': int(base_oi * 0.15),
                    'expiry': expiry,
                }
            )
    return contracts


def get_option_chain(symbol, expiry=None, fast=False):
    """
    Build F&O chain from live underlying (Finnhub, Yahoo fallback).
    Returns dict with metadata + contract list.
    """
    symbol = symbol.upper().strip()
    allowed = set(FNO_INDICES) | set(FNO_STOCKS) | set(NIFTY_50)
    if symbol not in allowed and not Stock.objects.filter(symbol=symbol).exists():
        return None

    cache_key = f'option_chain:v3:{symbol}:{expiry or "nearest"}'
    cached = cache.get(cache_key)
    if cached is not None:
        return cached
    if fast:
        stock = Stock.objects.filter(symbol=symbol).first()
        spot = float(stock.ltp) if stock and stock.ltp else 0
        if not spot:
            underlying = get_underlying_spot(symbol)
            spot = underlying or 0
        return {
            'symbol': symbol,
            'underlying_value': round(spot, 2),
            'expiry_dates': [],
            'selected_expiry': '',
            'contracts': [],
            'updated_at': timezone.now().isoformat(),
            'source': 'cache_miss',
        }

    spot = get_underlying_spot(symbol)
    if spot is None:
        try:
            spot = float(Stock.objects.get(symbol=symbol).ltp)
        except Stock.DoesNotExist:
            return None

    expiries = _next_expiries(4, symbol=symbol)
    selected = expiry
    if selected:
        try:
            selected = date.fromisoformat(str(selected))
        except ValueError:
            selected = expiries[0]
    else:
        selected = expiries[0]

    contracts = _build_contracts(symbol, spot, selected)

    result = {
        'symbol': symbol,
        'underlying_value': round(spot, 2),
        'expiry_dates': [e.isoformat() for e in expiries],
        'selected_expiry': selected.isoformat(),
        'contracts': contracts,
        'updated_at': timezone.now().isoformat(),
        'source': 'finnhub_live',
    }
    cache.set(cache_key, result, OPTIONS_CACHE_SECONDS)
    return result
