import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_strings.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Configure system UI for splash screen
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.surface,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) context.go('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Islamic Pattern / Icon Glow
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.1),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 40,
                        spreadRadius: 10,
                      )
                    ],
                  ),
                )
                    .animate(
                        onPlay: (controller) =>
                            controller.repeat(reverse: true))
                    .scale(
                        duration: 2.seconds,
                        begin: const Offset(1, 1),
                        end: const Offset(1.1, 1.1)),

                // Inner container
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.accent.withOpacity(0.5), width: 2),
                  ),
                  child: Icon(
                    Icons.mosque_rounded,
                    size: 70,
                    color: AppColors.accent,
                  ),
                ),
              ],
            )
                .animate()
                .scale(
                    duration: 800.ms,
                    curve: Curves.easeOutBack,
                    begin: const Offset(0, 0))
                .fadeIn(duration: 600.ms)
                .then(delay: 200.ms)
                .shimmer(
                    duration: 1500.ms, color: AppColors.white.withOpacity(0.5)),

            const SizedBox(height: 32),

            // App Name
            Text(
              AppStrings.appName,
              style: AppTypography.headlineLarge.copyWith(
                color: AppColors.textPrimary,
                letterSpacing: 2,
                fontWeight: FontWeight.w800,
              ),
            )
                .animate()
                .slideY(
                    begin: 0.5, end: 0, duration: 600.ms, curve: Curves.easeOut)
                .fadeIn(duration: 600.ms),

            const SizedBox(height: 8),

            // Tagline
            Text(
              'Panduan Ibadah Anda',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.accent,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w500,
              ),
            )
                .animate()
                .slideY(
                    begin: 0.5,
                    end: 0,
                    duration: 600.ms,
                    delay: 200.ms,
                    curve: Curves.easeOut)
                .fadeIn(duration: 600.ms, delay: 200.ms),
          ],
        ),
      ),
    );
  }
}
