import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A premium, Apple & Emil Kowalski inspired tactile interactive wrapper.
///
/// Features:
/// - Smooth spring squash to [pressedScale] (default: 0.97x) on tap down
/// - Natural spring return on release or scroll cancellation
/// - Subtle optional haptic feedback on touch
/// - Retains gesture disambiguation so parent ScrollViews scroll smoothly
class TactileCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final Duration duration;
  final BorderRadius? borderRadius;
  final Color? color;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final EdgeInsetsGeometry? padding;
  final bool enableHaptics;

  const TactileCard({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.97,
    this.duration = const Duration(milliseconds: 120),
    this.borderRadius,
    this.color,
    this.border,
    this.boxShadow,
    this.padding,
    this.enableHaptics = true,
  });

  @override
  State<TactileCard> createState() => _TactileCardState();
}

class _TactileCardState extends State<TactileCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: const Duration(milliseconds: 180),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.pressedScale,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutQuad,
        reverseCurve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap == null) return;
    if (widget.enableHaptics) {
      HapticFeedback.lightImpact();
    }
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap == null) return;
    _controller.reverse();
    widget.onTap!();
  }

  void _onTapCancel() {
    if (widget.onTap == null) return;
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = widget.child;

    if (widget.padding != null) {
      content = Padding(
        padding: widget.padding!,
        child: content,
      );
    }

    if (widget.color != null ||
        widget.border != null ||
        widget.boxShadow != null ||
        widget.borderRadius != null) {
      content = AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: widget.borderRadius,
          border: widget.border,
          boxShadow: widget.boxShadow,
        ),
        child: content,
      );
    }

    if (widget.onTap == null) {
      return content;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: content,
      ),
    );
  }
}
