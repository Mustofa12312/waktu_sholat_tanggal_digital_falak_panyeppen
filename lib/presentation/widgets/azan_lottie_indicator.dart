import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

/// Animated Azan indicator — pulsing green circle with mosque icon.
/// Shows when current prayer is active.
class AzanLottieIndicator extends StatefulWidget {
  final bool isActive;
  final String prayerName;
  final double size;

  const AzanLottieIndicator({
    super.key,
    required this.isActive,
    required this.prayerName,
    this.size = 80,
  });

  @override
  State<AzanLottieIndicator> createState() => _AzanLottieIndicatorState();
}

class _AzanLottieIndicatorState extends State<AzanLottieIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _pulse = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _opacity = Tween<double>(
      begin: 0.6,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    if (widget.isActive) {
      _controller.repeat(reverse: false);
    }
  }

  @override
  void didUpdateWidget(AzanLottieIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_controller.isAnimating) {
      _controller.repeat(reverse: false);
    } else if (!widget.isActive && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Pulse ring
            if (widget.isActive)
              AnimatedBuilder(
                animation: _controller,
                builder: (_, __) => Container(
                  width: widget.size * _pulse.value,
                  height: widget.size * _pulse.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent.withOpacity(_opacity.value * 0.3),
                  ),
                ),
              ),
            // Main circle
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: widget.isActive
                      ? [AppColors.accent, AppColors.accentDark]
                      : [AppColors.glassWhite, AppColors.glassBorder],
                ),
                boxShadow: widget.isActive
                    ? [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                Icons.mosque_rounded,
                size: widget.size * 0.45,
                color: widget.isActive
                    ? AppColors.black
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        if (widget.isActive) ...[
          const SizedBox(height: 8),
          Text(
            'Waktu ${widget.prayerName}',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
