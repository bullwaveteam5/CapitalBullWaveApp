import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/widgets/scale_tap.dart';

class HomeQuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const HomeQuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

/// Primary row — colored rounded-square icons (reference: Shop, In-store, etc.)
class HomePrimaryActionsRow extends StatelessWidget {
  final List<HomeQuickAction> actions;

  const HomePrimaryActionsRow({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: actions.map((action) {
        return Expanded(
          child: _PrimaryActionTile(action: action),
        );
      }).toList(),
    );
  }
}

class _PrimaryActionTile extends StatelessWidget {
  final HomeQuickAction action;

  const _PrimaryActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return ScaleTap(
      onTap: action.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: action.color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: action.color.withValues(alpha: 0.22)),
              ),
              child: Icon(action.icon, color: action.color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              action.label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Secondary row — lighter outline icons (reference: All orders, On its way, etc.)
class HomeSecondaryActionsRow extends StatelessWidget {
  final List<HomeQuickAction> actions;

  const HomeSecondaryActionsRow({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: actions.map((action) {
        return Expanded(
          child: _SecondaryActionTile(action: action),
        );
      }).toList(),
    );
  }
}

class _SecondaryActionTile extends StatelessWidget {
  final HomeQuickAction action;

  const _SecondaryActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return ScaleTap(
      onTap: action.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          children: [
            Icon(action.icon, color: action.color, size: 24),
            const SizedBox(height: 6),
            Text(
              action.label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
