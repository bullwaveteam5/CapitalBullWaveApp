import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'colors.dart';

/// Shared onboarding-style backdrop: pure black + mesh glow + film grain.
class PremiumAppBackdrop extends StatelessWidget {
  final Widget child;
  final int glowVariant;

  const PremiumAppBackdrop({
    super.key,
    required this.child,
    this.glowVariant = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!isDark) {
      return Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF5F0FF),
                  Color(0xFFFAFAFA),
                  Color(0xFFF8FAFC),
                ],
                stops: [0.0, 0.35, 1.0],
              ),
            ),
          ),
          Positioned(
            top: -80,
            left: -40,
            right: -40,
            height: 220,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 0.9,
                  colors: [
                    AppColors.brandPrimary.withValues(alpha: 0.14),
                    AppColors.brandPink.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          child,
        ],
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        PremiumMeshBackground(glowVariant: glowVariant),
        const PremiumFilmGrain(),
        child,
      ],
    );
  }
}

class PremiumMeshBackground extends StatefulWidget {
  final int glowVariant;
  final Color? glowPrimary;
  final Color? glowSecondary;

  const PremiumMeshBackground({
    super.key,
    this.glowVariant = 0,
    this.glowPrimary,
    this.glowSecondary,
  });

  @override
  State<PremiumMeshBackground> createState() => _PremiumMeshBackgroundState();
}

class _PremiumMeshBackgroundState extends State<PremiumMeshBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const _glowSets = [
    (Color(0xFF3B82F6), Color(0xFF6366F1)),
    (Color(0xFF22D3EE), Color(0xFF2DD4BF)),
    (Color(0xFF9333EA), Color(0xFFEC4899)),
    (Color(0xFF818CF8), Color(0xFF34D399)),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final idx = widget.glowVariant.clamp(0, _glowSets.length - 1);
    final primary = widget.glowPrimary ?? _glowSets[idx].$1;
    final secondary = widget.glowSecondary ?? _glowSets[idx].$2;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final scale = 1.0 + t * 0.06;
        final opacity = 0.42 + t * 0.12;

        return Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: Color(0xFF000000)),
            Positioned(
              top: -MediaQuery.sizeOf(context).height * 0.14,
              left: -48,
              right: -48,
              child: Transform.scale(
                scale: scale,
                child: Container(
                  height: MediaQuery.sizeOf(context).height * 0.52,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topCenter,
                      radius: 0.9,
                      colors: [
                        primary.withValues(alpha: opacity),
                        secondary.withValues(alpha: opacity * 0.4),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.sizeOf(context).height * 0.06,
              right: -72,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.brandPink.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class PremiumFilmGrain extends StatelessWidget {
  const PremiumFilmGrain({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _PremiumNoisePainter(),
        size: Size.infinite,
      ),
    );
  }
}

class _PremiumNoisePainter extends CustomPainter {
  final math.Random _rng = math.Random(42);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.024);
    for (var i = 0; i < 2200; i++) {
      canvas.drawCircle(
        Offset(_rng.nextDouble() * size.width, _rng.nextDouble() * size.height),
        0.55,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
