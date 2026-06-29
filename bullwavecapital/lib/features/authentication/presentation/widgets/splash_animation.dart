import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';

class SplashAnimation extends StatefulWidget {
  const SplashAnimation({super.key});

  @override
  State<SplashAnimation> createState() => _SplashAnimationState();
}

class _SplashAnimationState extends State<SplashAnimation>
    with TickerProviderStateMixin {
  late AnimationController _bullController;
  late AnimationController _tickerController;
  late Animation<double> _bullRise;
  late Animation<double> _bullScale;
  late Animation<double> _titleFade;

  static const _tickers = [
    _Ticker('NIFTY', '+1.24%'),
    _Ticker('SENSEX', '+0.89%'),
    _Ticker('RELIANCE', '+2.41%'),
    _Ticker('TCS', '+1.12%'),
    _Ticker('INFY', '+0.76%'),
    _Ticker('HDFCBANK', '+1.55%'),
  ];

  @override
  void initState() {
    super.initState();
    _bullController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _tickerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    _bullRise = Tween<double>(begin: 80, end: 0).animate(
      CurvedAnimation(parent: _bullController, curve: Curves.easeOutCubic),
    );
    _bullScale = Tween<double>(begin: 0.6, end: 1).animate(
      CurvedAnimation(parent: _bullController, curve: Curves.elasticOut),
    );
    _titleFade = CurvedAnimation(
      parent: _bullController,
      curve: const Interval(0.45, 1, curve: Curves.easeOut),
    );

    _bullController.forward();
  }

  @override
  void dispose() {
    _bullController.dispose();
    _tickerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.splashGradient,
      ),
      child: Stack(
        children: [
          ...List.generate(_tickers.length, (i) {
            final ticker = _tickers[i];
            final xOffset = (size.width / (_tickers.length + 1)) * (i + 1);
            return AnimatedBuilder(
              animation: _tickerController,
              builder: (context, _) {
                final phase = (_tickerController.value + i * 0.14) % 1.0;
                final y = size.height * (1.05 - phase * 1.15);
                final opacity = phase < 0.1
                    ? phase / 0.1
                    : phase > 0.85
                        ? (1 - phase) / 0.15
                        : 0.55;
                return Positioned(
                  left: xOffset - 52 + (i.isEven ? -12 : 12),
                  top: y,
                  child: Opacity(
                    opacity: opacity.clamp(0.0, 1.0),
                    child: _PriceChip(symbol: ticker.symbol, change: ticker.change),
                  ),
                );
              },
            );
          }),
          Center(
            child: AnimatedBuilder(
              animation: _bullController,
              builder: (context, _) {
                return Transform.translate(
                  offset: Offset(0, _bullRise.value),
                  child: Transform.scale(
                    scale: _bullScale.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _BullIcon(size: 88),
                        const SizedBox(height: 28),
                        FadeTransition(
                          opacity: _titleFade,
                          child: Column(
                            children: [
                              Text(
                                'BullWave',
                                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Invest',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.85),
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 48,
            child: AnimatedBuilder(
              animation: _bullController,
              builder: (context, _) {
                return Opacity(
                  opacity: _titleFade.value,
                  child: Column(
                    children: [
                      Icon(
                        Icons.keyboard_arrow_up_rounded,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 28,
                      ),
                      Text(
                        'Markets moving up',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Ticker {
  final String symbol;
  final String change;
  const _Ticker(this.symbol, this.change);
}

class _PriceChip extends StatelessWidget {
  final String symbol;
  final String change;

  const _PriceChip({required this.symbol, required this.change});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            symbol,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            change,
            style: const TextStyle(
              color: Color(0xFFBBF7D0),
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _BullIcon extends StatelessWidget {
  final double size;

  const _BullIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _BullPainter(),
    );
  }
}

class _BullPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Body
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 8), width: size.width * 0.72, height: size.height * 0.48),
      paint,
    );

    // Head
    canvas.drawCircle(Offset(cx + size.width * 0.22, cy - size.height * 0.08), size.width * 0.18, paint);

    // Horns
    final horn = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx + size.width * 0.08, cy - size.height * 0.22),
        width: size.width * 0.22,
        height: size.height * 0.22,
      ),
      math.pi * 1.1,
      math.pi * 0.55,
      false,
      horn,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx + size.width * 0.32, cy - size.height * 0.22),
        width: size.width * 0.22,
        height: size.height * 0.22,
      ),
      math.pi * 1.35,
      math.pi * 0.55,
      false,
      horn,
    );

    // Upward chart line on body
    final chart = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.045
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(cx - size.width * 0.22, cy + size.height * 0.12)
      ..lineTo(cx - size.width * 0.06, cy - size.height * 0.02)
      ..lineTo(cx + size.width * 0.08, cy + size.height * 0.04)
      ..lineTo(cx + size.width * 0.2, cy - size.height * 0.14);
    canvas.drawPath(path, chart);

    // Arrow tip
    canvas.drawLine(
      Offset(cx + size.width * 0.2, cy - size.height * 0.14),
      Offset(cx + size.width * 0.12, cy - size.height * 0.1),
      chart,
    );
    canvas.drawLine(
      Offset(cx + size.width * 0.2, cy - size.height * 0.14),
      Offset(cx + size.width * 0.16, cy - size.height * 0.06),
      chart,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
