import 'package:flutter/material.dart';
// import '../../../../core/constants/app_colors.dart';

/// Animated solar gradient background that transitions smoothly
/// between solar phases using AnimatedContainer.
class SolarGradientBg extends StatelessWidget {
  final List<Color> colors;
  final Widget child;

  const SolarGradientBg({super.key, required this.colors, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }
}
