import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme_extension.dart';

class HomeSearchBar extends StatelessWidget {
  final VoidCallback onTap;
  final String hint;

  const HomeSearchBar({
    super.key,
    required this.onTap,
    this.hint = 'Search stocks & markets',
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded, size: 22, color: colors.textMuted),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hint,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: colors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
