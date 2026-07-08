import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/routes.dart';
import '../theme/colors.dart';
import 'ai_orb_widgets.dart';

/// Premium AI assistant FAB — compact iridescent orb.
class AiAssistantFab extends StatefulWidget {
  final double bottom;

  const AiAssistantFab({super.key, this.bottom = 24});

  @override
  State<AiAssistantFab> createState() => _AiAssistantFabState();
}

class _AiAssistantFabState extends State<AiAssistantFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(AppRoutes.aiAssistant)) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      right: 16,
      bottom: widget.bottom,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) {
          final t = _pulse.value;
          return Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandPrimary.withValues(alpha: 0.18 + t * 0.12),
                  blurRadius: 16 + t * 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: child,
          );
        },
        child: Material(
          color: isDark ? const Color(0xFF141414) : Colors.white,
          elevation: isDark ? 0 : 3,
          shadowColor: AppColors.brandPrimary.withValues(alpha: 0.25),
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => context.push(AppRoutes.aiAssistant),
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.brandPrimary.withValues(alpha: isDark ? 0.35 : 0.2),
                    width: 1.5,
                  ),
                ),
                child: const AiOrbLogo(size: 50, showArc: false, animate: true),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
