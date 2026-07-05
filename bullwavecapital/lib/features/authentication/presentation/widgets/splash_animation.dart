import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/app_brand_logo.dart';

/// Premium 5-second investment splash — animated trend chart, live tickers, brand reveal.
class SplashAnimation extends StatefulWidget {
  final double progress;

  const SplashAnimation({super.key, this.progress = 0});

  @override
  State<SplashAnimation> createState() => _SplashAnimationState();
}

class _SplashAnimationState extends State<SplashAnimation>
    with TickerProviderStateMixin {
  late AnimationController _main;
  late AnimationController _ticker;
  late Animation<double> _chartProgress;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _taglineFade;
  late Animation<double> _statsFade;
  late Animation<double> _glowPulse;

  static const _tickers = [
    _Ticker('GOLD', '+1.8%', Icons.monetization_on_rounded),
    _Ticker('NIFTY', '+1.24%', Icons.candlestick_chart_rounded),
    _Ticker('SILVER', '+2.1%', Icons.diamond_outlined),
    _Ticker('RELIANCE', '+2.4%', Icons.show_chart_rounded),
    _Ticker('CRUDE', '+1.5%', Icons.local_gas_station_outlined),
    _Ticker('BTC', '+3.2%', Icons.currency_bitcoin_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _main = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    _chartProgress = CurvedAnimation(parent: _main, curve: const Interval(0.05, 0.72, curve: Curves.easeOutCubic));
    _logoScale = Tween<double>(begin: 0.82, end: 1).animate(
      CurvedAnimation(parent: _main, curve: const Interval(0.15, 0.55, curve: Curves.easeOutBack)),
    );
    _logoFade = CurvedAnimation(parent: _main, curve: const Interval(0.12, 0.45, curve: Curves.easeOut));
    _taglineFade = CurvedAnimation(parent: _main, curve: const Interval(0.35, 0.65, curve: Curves.easeOut));
    _statsFade = CurvedAnimation(parent: _main, curve: const Interval(0.5, 0.8, curve: Curves.easeOut));
    _glowPulse = Tween<double>(begin: 0.4, end: 1).animate(
      CurvedAnimation(parent: _main, curve: Curves.easeInOut),
    );

    _main.forward();
  }

  @override
  void dispose() {
    _main.dispose();
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return AnimatedBuilder(
      animation: Listenable.merge([_main, _ticker]),
      builder: (context, _) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0E0618), Color(0xFF1A0A2E), Color(0xFF2D0A3A)],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _GridBackground(opacity: 0.06 + _glowPulse.value * 0.04),
              ...List.generate(_tickers.length, (i) {
                final t = _tickers[i];
                final phase = (_ticker.value + i * 0.16) % 1.0;
                final x = (size.width / (_tickers.length + 1)) * (i + 1);
                final y = size.height * (0.92 - phase * 0.55);
                final opacity = phase < 0.12
                    ? phase / 0.12
                    : phase > 0.88
                        ? (1 - phase) / 0.12
                        : 0.7;
                return Positioned(
                  left: x - 58 + (i.isEven ? -16 : 16),
                  top: y,
                  child: Opacity(
                    opacity: opacity.clamp(0.0, 1.0) * _statsFade.value,
                    child: _TickerChip(ticker: t),
                  ),
                );
              }),
              Positioned(
                left: 20,
                right: 20,
                top: size.height * 0.14,
                height: size.height * 0.36,
                child: CustomPaint(
                  painter: _TrendChartPainter(progress: _chartProgress.value),
                  child: const SizedBox.expand(),
                ),
              ),
              Positioned(
                left: 24,
                top: size.height * 0.13,
                child: Opacity(
                  opacity: _statsFade.value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.green.withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.trending_up_rounded, color: AppColors.green, size: 14),
                        const SizedBox(width: 5),
                        Text(
                          '+${(12.4 * _chartProgress.value).toStringAsFixed(1)}% YTD',
                          style: const TextStyle(
                            color: AppColors.green,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: Transform.scale(
                  scale: _logoScale.value,
                  child: Opacity(
                    opacity: _logoFade.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AppBrandLogo(size: 88, showShadow: true),
                        const SizedBox(height: 22),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Colors.white, Color(0xFFFFE4B5)],
                          ).createShader(bounds),
                          child: Text(
                            'BullWave',
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1,
                                  fontSize: 36,
                                ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        FadeTransition(
                          opacity: _taglineFade,
                          child: Text(
                            'Invest • Trade • Grow',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.2,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 32,
                right: 32,
                bottom: 56,
                child: Column(
                  children: [
                    Opacity(
                      opacity: _taglineFade.value,
                      child: Text(
                        'Markets are live',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: widget.progress > 0 ? widget.progress : _main.value,
                        minHeight: 3,
                        backgroundColor: Colors.white.withValues(alpha: 0.12),
                        color: AppColors.brandPink,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Ticker {
  final String symbol;
  final String change;
  final IconData icon;
  const _Ticker(this.symbol, this.change, this.icon);
}

class _TickerChip extends StatelessWidget {
  final _Ticker ticker;

  const _TickerChip({required this.ticker});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandPink.withValues(alpha: 0.08),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ticker.icon, color: AppColors.brandGold, size: 14),
          const SizedBox(width: 6),
          Text(
            ticker.symbol,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11),
          ),
          const SizedBox(width: 6),
          Text(
            ticker.change,
            style: const TextStyle(color: AppColors.greenSoft, fontWeight: FontWeight.w800, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _GridBackground extends StatelessWidget {
  final double opacity;

  const _GridBackground({required this.opacity});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(opacity: opacity),
      size: Size.infinite,
    );
  }
}

class _GridPainter extends CustomPainter {
  final double opacity;

  _GridPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: opacity)
      ..strokeWidth = 0.5;

    const step = 32.0;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.opacity != opacity;
}

class _TrendChartPainter extends CustomPainter {
  final double progress;

  _TrendChartPainter({required this.progress});

  static final _points = <Offset>[
    const Offset(0.00, 0.78),
    const Offset(0.08, 0.72),
    const Offset(0.16, 0.76),
    const Offset(0.24, 0.58),
    const Offset(0.32, 0.62),
    const Offset(0.40, 0.48),
    const Offset(0.48, 0.52),
    const Offset(0.56, 0.38),
    const Offset(0.64, 0.42),
    const Offset(0.72, 0.28),
    const Offset(0.80, 0.32),
    const Offset(0.88, 0.18),
    const Offset(0.96, 0.12),
    const Offset(1.00, 0.08),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final w = size.width;
    final h = size.height;
    final visibleCount = (progress * (_points.length - 1)).floor().clamp(0, _points.length - 2);
    final partial = (progress * (_points.length - 1)) - visibleCount;

    final path = Path();
    final fillPath = Path();

    final start = Offset(_points[0].dx * w, _points[0].dy * h);
    path.moveTo(start.dx, start.dy);
    fillPath.moveTo(start.dx, h);
    fillPath.lineTo(start.dx, start.dy);

    for (var i = 1; i <= visibleCount; i++) {
      final p = Offset(_points[i].dx * w, _points[i].dy * h);
      path.lineTo(p.dx, p.dy);
      fillPath.lineTo(p.dx, p.dy);
    }

    if (visibleCount < _points.length - 1 && partial > 0) {
      final a = _points[visibleCount];
      final b = _points[visibleCount + 1];
      final p = Offset(
        (a.dx + (b.dx - a.dx) * partial) * w,
        (a.dy + (b.dy - a.dy) * partial) * h,
      );
      path.lineTo(p.dx, p.dy);
      fillPath.lineTo(p.dx, p.dy);
    }

    final lastPoint = fillPath.getBounds().topRight;
    fillPath.lineTo(lastPoint.dx, h);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(0, h),
        [
          AppColors.brandPrimary.withValues(alpha: 0.28),
          AppColors.brandPrimary.withValues(alpha: 0.0),
        ],
      );
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, h * 0.5),
        Offset(w, h * 0.2),
        [AppColors.brandPrimaryLight, AppColors.brandPink],
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);

    // Glow dot at tip
    final tip = path.getBounds();
    if (!tip.isEmpty) {
      final tipX = tip.right;
      final tipY = tip.top + tip.height / 2;
      canvas.drawCircle(
        Offset(tipX, tipY),
        6,
        Paint()..color = AppColors.greenSoft.withValues(alpha: 0.35),
      );
      canvas.drawCircle(
        Offset(tipX, tipY),
        3,
        Paint()..color = Colors.white,
      );
    }

    // Candlestick accents
    final candlePaint = Paint()..style = PaintingStyle.fill;
    for (var i = 1; i < _points.length - 1; i += 2) {
      if (i / (_points.length - 1) > progress) break;
      final px = _points[i].dx * w;
      final py = _points[i].dy * h;
      final up = i % 4 != 0;
      candlePaint.color = (up ? AppColors.green : AppColors.red).withValues(alpha: 0.55);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(px, py + 8), width: 6, height: 14),
          const Radius.circular(2),
        ),
        candlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_TrendChartPainter old) => old.progress != progress;
}
