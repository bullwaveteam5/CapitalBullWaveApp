import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/colors.dart';

/// Purple neon arc + iridescent orb — chatbot brand mark.
class AiOrbLogo extends StatefulWidget {
  final double size;
  final bool showArc;
  final bool animate;

  const AiOrbLogo({
    super.key,
    this.size = 56,
    this.showArc = true,
    this.animate = true,
  });

  @override
  State<AiOrbLogo> createState() => _AiOrbLogoState();
}

class _AiOrbLogoState extends State<AiOrbLogo> with SingleTickerProviderStateMixin {
  late AnimationController _spin;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    if (widget.animate) _spin.repeat();
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _spin,
      builder: (context, _) {
        return CustomPaint(
          size: Size.square(widget.size),
          painter: _AiOrbLogoPainter(
            showArc: widget.showArc,
            rotation: widget.animate ? _spin.value * 2 * math.pi : 0,
          ),
        );
      },
    );
  }
}

class _AiOrbLogoPainter extends CustomPainter {
  final bool showArc;
  final double rotation;

  _AiOrbLogoPainter({required this.showArc, required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final orbR = size.width * 0.22;

    if (showArc) {
      _drawNeonArc(canvas, size, cx, cy + orbR * 0.15);
    }

    _drawOrbGlow(canvas, Offset(cx, cy), orbR * 1.8);
    _drawIridescentOrb(canvas, Offset(cx, cy), orbR, rotation);
  }

  void _drawNeonArc(Canvas canvas, Size size, double cx, double cy) {
    final radius = size.width * 0.36;
    const start = math.pi * 1.05;
    const sweep = math.pi * 0.9;

    for (var layer = 4; layer >= 0; layer--) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 + layer * 1.8
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF9333EA).withValues(alpha: 0.08 + layer * 0.06)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, layer * 2.5);

      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius + layer * 1.5),
        start,
        sweep,
        false,
        paint,
      );
    }

    final core = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        colors: [
          Color(0xFF7C3AED),
          Color(0xFFC084FC),
          Color(0xFFEC4899),
          Color(0xFF7C3AED),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      start,
      sweep,
      false,
      core,
    );
  }

  void _drawOrbGlow(Canvas canvas, Offset center, double radius) {
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF9333EA).withValues(alpha: 0.55),
          const Color(0xFF6366F1).withValues(alpha: 0.2),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, glow);
  }

  void _drawIridescentOrb(Canvas canvas, Offset center, double radius, double rotation) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation * 0.15);

    final sphere = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.4),
        radius: 1.1,
        colors: const [
          Color(0xFFFFFFFF),
          Color(0xFF22D3EE),
          Color(0xFF6366F1),
          Color(0xFF9333EA),
          Color(0xFF1E1033),
        ],
        stops: const [0.0, 0.22, 0.5, 0.78, 1.0],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius));

    canvas.drawCircle(Offset.zero, radius, sphere);

    final highlight = Paint()
      ..shader = RadialGradient(
        center: Alignment.topLeft,
        radius: 0.9,
        colors: [
          Colors.white.withValues(alpha: 0.75),
          Colors.white.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(-radius * 0.2, -radius * 0.2), radius: radius * 0.7));
    canvas.drawCircle(Offset(-radius * 0.15, -radius * 0.2), radius * 0.45, highlight);

    canvas.restore();

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.25);
    canvas.drawCircle(center, radius, ring);
  }

  @override
  bool shouldRepaint(covariant _AiOrbLogoPainter old) =>
      old.rotation != rotation || old.showArc != showArc;
}

/// Large listening-state orb with pulse rings.
class AiListeningOrb extends StatefulWidget {
  final double size;
  final bool active;

  const AiListeningOrb({
    super.key,
    this.size = 120,
    this.active = true,
  });

  @override
  State<AiListeningOrb> createState() => _AiListeningOrbState();
}

class _AiListeningOrbState extends State<AiListeningOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    if (widget.active) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant AiListeningOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!widget.active) {
      _pulse.stop();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        final t = widget.active ? _pulse.value : 0.0;
        final ringScale = 1.0 + t * 0.18;

        return SizedBox(
          width: widget.size * 1.4,
          height: widget.size * 1.4,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: ringScale,
                child: Container(
                  width: widget.size * 1.15,
                  height: widget.size * 1.15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.brandPrimary.withValues(alpha: 0.15 + t * 0.2),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              Transform.scale(
                scale: 1.0 + t * 0.06,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brandPrimary.withValues(alpha: 0.45 + t * 0.2),
                        blurRadius: 32,
                        spreadRadius: 4,
                      ),
                      BoxShadow(
                        color: AppColors.brandCyan.withValues(alpha: 0.2),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: AiOrbLogo(size: widget.size, showArc: false, animate: widget.active),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Glass chat bubble for user messages.
class AiGlassBubble extends StatelessWidget {
  final Widget child;
  final bool isUser;
  final Widget? trailing;

  const AiGlassBubble({
    super.key,
    required this.child,
    required this.isUser,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    if (!isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16, right: 48),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AiOrbLogo(size: 28, showArc: false, animate: false),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  child,
                  if (trailing != null) trailing!,
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 48),
      child: Align(
        alignment: Alignment.centerRight,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.brandPrimary.withValues(alpha: 0.35),
                    AppColors.brandPink.withValues(alpha: 0.22),
                  ],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Pill suggestion chip for AI chat.
class AiSuggestionPill extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const AiSuggestionPill({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
