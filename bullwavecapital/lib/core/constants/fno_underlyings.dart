/// F&O underlyings supported by the backend options chain.
class FnoUnderlyings {
  FnoUnderlyings._();

  static const indices = <({String symbol, String label})>[
    (symbol: 'NIFTY', label: 'Nifty 50'),
    (symbol: 'BANKNIFTY', label: 'Bank Nifty'),
    (symbol: 'FINNIFTY', label: 'Fin Nifty'),
  ];

  static const stocks = [
    'RELIANCE', 'TCS', 'HDFCBANK', 'INFY', 'ICICIBANK', 'SBIN', 'ITC', 'BHARTIARTL',
    'KOTAKBANK', 'AXISBANK', 'LT', 'MARUTI', 'TITAN', 'BAJFINANCE', 'HCLTECH',
    'WIPRO', 'TATAMOTORS', 'M&M', 'NTPC', 'ONGC', 'TATASTEEL', 'ADANIENT',
    'SUNPHARMA', 'TECHM', 'HINDALCO', 'JSWSTEEL',
  ];

  static bool isIndex(String symbol) =>
      indices.any((i) => i.symbol == symbol.toUpperCase());
}
