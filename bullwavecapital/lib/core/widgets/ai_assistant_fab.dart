import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';



import '../constants/assets.dart';

import '../constants/routes.dart';

import '../theme/colors.dart';

import 'app_brand_logo.dart';



/// Floating AI assistant button — corner placement like modern finance apps.

class AiAssistantFab extends StatelessWidget {

  final double bottom;



  const AiAssistantFab({super.key, this.bottom = 24});



  @override

  Widget build(BuildContext context) {

    final location = GoRouterState.of(context).uri.toString();

    if (location.startsWith(AppRoutes.aiAssistant)) {

      return const SizedBox.shrink();

    }



    return Positioned(

      right: 16,

      bottom: bottom,

      child: Material(

        elevation: 8,

        shadowColor: AppColors.brandPink.withValues(alpha: 0.45),

        shape: const CircleBorder(),

        clipBehavior: Clip.antiAlias,

        child: InkWell(

          onTap: () => context.push(AppRoutes.aiAssistant),

          child: Ink(

            decoration: const BoxDecoration(

              gradient: AppColors.accentGradient,

              shape: BoxShape.circle,

            ),

            child: const SizedBox(

              width: 54,

              height: 54,

              child: Center(

                child: AppSvgIcon(

                  asset: AppAssets.featAi,

                  size: 26,

                  color: Colors.white,

                ),

              ),

            ),

          ),

        ),

      ),

    );

  }

}


