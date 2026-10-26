import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// A premium animated floating action launcher featuring:
/// - Breathing pulse aura in idle state
/// - Apple & Emil Kowalski tactile squash & bounce on press
/// - Rotational flourish & ripple expansion when tapped to open the chatbot
class AnimatedFavLauncher extends StatefulWidget {
  final VoidCallback onTap;
  final bool isAmharic;
  final String? tooltip;

  const AnimatedFavLauncher({
    super.key,
    required this.onTap,
    this.isAmharic = false,
    this.tooltip,
  });

  @override
  State<AnimatedFavLauncher> createState() => _AnimatedFavLauncherState();
}

class _AnimatedFavLauncherState extends State<AnimatedFavLauncher>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _pressController;
  late final Animation<double> _pulseScale;
  late final Animation<double> _pressScale;
  late final Animation<double> _rotationAnim;
  late final Animation<double> _rippleAnim;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    // 1. Ambient breathing pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    // 2. Interactive press / open animation
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _pressScale = Tween<double>(begin: 1.0, end: 0.86).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOutBack),
    );

    _rotationAnim = Tween<double>(begin: 0.0, end: 0.12).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOutCubic),
    );

    _rippleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOutQuad),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    setState(() => _isPressed = true);
    _pressController.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  void _handleTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
    HapticFeedback.mediumImpact();
    _pressController.reverse().then((_) {
      widget.onTap();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseController, _pressController]),
        builder: (context, child) {
          final currentScale = (_isPressed ? _pressScale.value : _pulseScale.value);
          final currentRotation = _rotationAnim.value * 2 * math.pi;

          return Transform.scale(
            scale: currentScale,
            child: Transform.rotate(
              angle: currentRotation,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Outer glowing pulsing halo
                  Container(
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.28),
                          AppColors.primary.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),

                  // Expanding ripple burst on press
                  if (_pressController.value > 0.01)
                    Container(
                      width: 54 + (_rippleAnim.value * 28),
                      height: 54 + (_rippleAnim.value * 28),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withValues(
                            alpha: (1.0 - _rippleAnim.value) * 0.45,
                          ),
                          width: 2.0,
                        ),
                      ),
                    ),

                  // Main floating card button
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary,
                          AppColors.primaryContainer,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.38),
                          blurRadius: _isPressed ? 6 : 14,
                          offset: Offset(0, _isPressed ? 2 : 6),
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.2),
                          blurRadius: 2,
                          offset: const Offset(0, -1),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 32,
                          height: 32,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Small sparkle accent badge
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 9,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
