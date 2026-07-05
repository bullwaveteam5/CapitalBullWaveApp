import 'package:flutter/material.dart';

import 'app_brand_logo.dart';

/// Centered gradient icon orb with gloss — symmetric explore / feature tiles.
class ModernIconBadge extends StatelessWidget {
  final String? asset;
  final IconData? icon;
  final List<Color> gradient;
  final Color iconColor;
  final double size;

  const ModernIconBadge({
    super.key,
    this.asset,
    this.icon,
    required this.gradient,
    this.iconColor = Colors.white,
    this.size = 52,
  }) : assert(asset != null || icon != null);

  @override
  Widget build(BuildContext context) {
    final glyphSize = size * 0.46;

    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          boxShadow: [
            BoxShadow(
              color: gradient.last.withValues(alpha: 0.38),
              blurRadius: 12,
              offset: Offset(0, size * 0.08),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: size * 0.08,
              left: size * 0.12,
              right: size * 0.12,
              child: Container(
                height: size * 0.22,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.42),
                      Colors.white.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            if (asset != null)
              AppSvgIcon(asset: asset!, size: glyphSize, color: iconColor)
            else
              Icon(icon, color: iconColor, size: glyphSize),
          ],
        ),
      ),
    );
  }
}

/// Gradient initial avatar for stock rows.
class ModernStockAvatar extends StatelessWidget {
  final String symbol;
  final double size;

  const ModernStockAvatar({
    super.key,
    required this.symbol,
    this.size = 42,
  });

  @override
  Widget build(BuildContext context) {
    final letter = symbol.isNotEmpty ? symbol.substring(0, 1).toUpperCase() : '?';
    final hue = symbol.hashCode.abs() % 360;
    final hue2 = (hue + 28) % 360;

    Color hsl(double h, double s, double l) =>
        HSLColor.fromAHSL(1, h, s, l).toColor();

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            hsl(hue.toDouble(), 0.55, 0.52),
            hsl(hue2.toDouble(), 0.62, 0.44),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: hsl(hue.toDouble(), 0.55, 0.44).withValues(alpha: 0.28),
            blurRadius: 8,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      child: Text(
        letter,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.42,
          height: 1,
        ),
      ),
    );
  }
}
