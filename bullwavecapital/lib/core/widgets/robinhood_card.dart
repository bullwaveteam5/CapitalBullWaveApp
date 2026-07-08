import 'package:flutter/material.dart';
import '../theme/app_decorations.dart';
import '../constants/dimensions.dart';

class RobinhoodCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool glow;
  final Color? glowColor;

  const RobinhoodCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.glow = false,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: AppDecorations.card(context, glow: glow, glowColor: glowColor, premium: true),
      child: child,
    );

    if (onTap == null) return content;

    return GestureDetector(onTap: onTap, child: content);
  }
}
