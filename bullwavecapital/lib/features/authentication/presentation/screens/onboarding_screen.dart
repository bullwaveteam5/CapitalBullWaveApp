import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/routes.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/app_brand_logo.dart';
import '../../../profile/presentation/provider/app_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _floatController;
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPageData(
      icon: Icons.candlestick_chart_rounded,
      accent: AppColors.brandPrimary,
      tag: 'MARKETS',
      title: 'Trade Smarter',
      description:
          'Live NSE stocks, commodities, and F&O chains — all in one premium terminal.',
      stats: ['50+ Stocks', 'Live Charts', 'Zero Lag'],
      visual: _VisualType.chart,
    ),
    _OnboardingPageData(
      icon: Icons.diamond_outlined,
      accent: AppColors.brandPink,
      tag: 'COMMODITIES',
      title: 'Gold, Oil & More',
      description:
          'Buy and sell global commodities with real-time prices and option chains.',
      stats: ['Gold & Silver', 'Crude Oil', 'Options'],
      visual: _VisualType.commodity,
    ),
    _OnboardingPageData(
      icon: Icons.verified_user_rounded,
      accent: AppColors.brandTeal,
      tag: 'SECURITY',
      title: 'Bank-Grade Safe',
      description:
          'KYC verified accounts, encrypted payouts, and Cashfree-powered bank linking.',
      stats: ['KYC Verified', '256-bit', 'RBI Ready'],
      visual: _VisualType.shield,
    ),
    _OnboardingPageData(
      icon: Icons.rocket_launch_rounded,
      accent: AppColors.brandMagenta,
      tag: 'GROWTH',
      title: 'Build Your Wealth',
      description:
          'Featured investment plans, portfolio analytics, and AI-powered insights.',
      stats: ['Up to 4% / mo', 'AI Assist', 'SIP'],
      visual: _VisualType.rocket,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _finishOnboarding() {
    context.read<AppProvider>().completeOnboarding();
    context.go(AppRoutes.login);
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(const Color(0xFF1E0A3C), page.accent, 0.15)!,
                  const Color(0xFF581C87),
                  Color.lerp(const Color(0xFF9D174D), page.accent, 0.2)!,
                ],
              ),
            ),
          ),
          ...List.generate(6, (i) => _FloatingOrb(index: i, controller: _floatController)),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const AppBrandLogo(size: 22, showShadow: false),
                            const SizedBox(width: 8),
                            const Text(
                              'BullWave',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _finishOnboarding,
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    itemBuilder: (context, index) {
                      final data = _pages[index];
                      return _OnboardingSlide(
                        data: data,
                        floatAnim: _floatController,
                        isActive: index == _currentPage,
                      );
                    },
                  ),
                ),
                _PageIndicator(count: _pages.length, current: _currentPage),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: AppDimensions.buttonHeight + 4,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            gradient: AppColors.accentGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.brandPink.withValues(alpha: 0.45),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _nextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                letterSpacing: 0.3,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentPage == _pages.length - 1
                                      ? 'Start Investing'
                                      : 'Continue',
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  _currentPage == _pages.length - 1
                                      ? Icons.arrow_forward_rounded
                                      : Icons.east_rounded,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Join thousands of smart investors',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _VisualType { chart, commodity, shield, rocket }

class _OnboardingPageData {
  final IconData icon;
  final Color accent;
  final String tag;
  final String title;
  final String description;
  final List<String> stats;
  final _VisualType visual;

  const _OnboardingPageData({
    required this.icon,
    required this.accent,
    required this.tag,
    required this.title,
    required this.description,
    required this.stats,
    required this.visual,
  });
}

class _OnboardingSlide extends StatelessWidget {
  final _OnboardingPageData data;
  final AnimationController floatAnim;
  final bool isActive;

  const _OnboardingSlide({
    required this.data,
    required this.floatAnim,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: floatAnim,
            builder: (context, child) {
              final dy = math.sin(floatAnim.value * math.pi) * 10;
              return Transform.translate(offset: Offset(0, dy), child: child);
            },
            child: _VisualCard(data: data),
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white.withValues(alpha: 0.08),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: data.accent.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        data.tag,
                        style: TextStyle(
                          color: data.accent,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      data.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 28,
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      data.description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontSize: 15,
                        height: 1.55,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: data.stats
                          .map(
                            (s) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                              ),
                              child: Text(
                                s,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _VisualCard extends StatelessWidget {
  final _OnboardingPageData data;

  const _VisualCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            data.accent.withValues(alpha: 0.35),
            Colors.white.withValues(alpha: 0.06),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: data.accent.withValues(alpha: 0.35),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: data.accent.withValues(alpha: 0.15),
              ),
            ),
          ),
          _VisualContent(data: data),
        ],
      ),
    );
  }
}

class _VisualContent extends StatelessWidget {
  final _OnboardingPageData data;

  const _VisualContent({required this.data});

  @override
  Widget build(BuildContext context) {
    switch (data.visual) {
      case _VisualType.chart:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(data.icon, size: 48, color: Colors.white),
            const SizedBox(height: 16),
            SizedBox(
              width: 200,
              height: 60,
              child: CustomPaint(painter: _MiniChartPainter(color: data.accent)),
            ),
            const SizedBox(height: 8),
            Text(
              '+24.8% this year',
              style: TextStyle(color: AppColors.greenSoft, fontWeight: FontWeight.w800),
            ),
          ],
        );
      case _VisualType.commodity:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _CommodityBubble(label: 'Gold', color: AppColors.commodityGold, icon: Icons.monetization_on),
            const SizedBox(width: 12),
            _CommodityBubble(label: 'Oil', color: AppColors.commodityEnergy, icon: Icons.local_gas_station),
            const SizedBox(width: 12),
            _CommodityBubble(label: 'Silver', color: AppColors.commoditySilver, icon: Icons.diamond_outlined),
          ],
        );
      case _VisualType.shield:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brandTeal.withValues(alpha: 0.2),
                border: Border.all(color: AppColors.brandTeal.withValues(alpha: 0.5), width: 2),
              ),
              child: Icon(data.icon, size: 56, color: AppColors.brandTeal),
            ),
            const SizedBox(height: 12),
            const Text('100% Secure', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ],
        );
      case _VisualType.rocket:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(data.icon, size: 64, color: Colors.white),
            const SizedBox(height: 12),
            ShaderMask(
              shaderCallback: (b) => AppColors.accentGradient.createShader(b),
              child: const Text(
                '₹1Cr+ Plans',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Colors.white),
              ),
            ),
          ],
        );
    }
  }
}

class _CommodityBubble extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _CommodityBubble({required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 11)),
      ],
    );
  }
}

class _MiniChartPainter extends CustomPainter {
  final Color color;

  _MiniChartPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height * 0.7)
      ..lineTo(size.width * 0.2, size.height * 0.5)
      ..lineTo(size.width * 0.4, size.height * 0.55)
      ..lineTo(size.width * 0.6, size.height * 0.3)
      ..lineTo(size.width * 0.8, size.height * 0.35)
      ..lineTo(size.width, size.height * 0.1);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _FloatingOrb extends StatelessWidget {
  final int index;
  final AnimationController controller;

  const _FloatingOrb({required this.index, required this.controller});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final colors = [AppColors.brandPrimary, AppColors.brandPink, AppColors.brandTeal];

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = (controller.value + index * 0.17) % 1.0;
        final x = size.width * (0.1 + index * 0.15);
        final y = size.height * (0.1 + t * 0.3);
        return Positioned(
          left: x,
          top: y,
          child: Container(
            width: 60 + index * 20.0,
            height: 60 + index * 20.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors[index % colors.length].withValues(alpha: 0.08),
            ),
          ),
        );
      },
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final int count;
  final int current;

  const _PageIndicator({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: active
                ? AppColors.accentGradient
                : null,
            color: active ? null : Colors.white.withValues(alpha: 0.3),
          ),
        );
      }),
    );
  }
}
