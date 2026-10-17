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
  final bool enableHover;
  final double hoverOffsetY;

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
    this.enableHover = true,
    this.hoverOffsetY = -3.0,
  });

  @override
  State<TactileCard> createState() => _TactileCardState();
}

class _TactileCardState extends State<TactileCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  bool _isHovered = false;
  bool _isPressed = false;

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
    setState(() => _isPressed = true);
    if (widget.enableHaptics) {
      HapticFeedback.lightImpact();
    }
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap == null) return;
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onTap!();
  }

  void _onTapCancel() {
    if (widget.onTap == null) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  List<BoxShadow>? _computeShadows() {
    final isElevated = _isHovered && !_isPressed && widget.onTap != null && widget.enableHover;
    if (widget.boxShadow != null) {
      if (!isElevated) return widget.boxShadow;
      return widget.boxShadow!.map((s) {
        return BoxShadow(
          color: s.color.withValues(alpha: (s.color.a * 1.35).clamp(0.0, 1.0)),
          blurRadius: s.blurRadius + 6,
          spreadRadius: s.spreadRadius + 1,
          offset: Offset(s.offset.dx, s.offset.dy + 2),
        );
      }).toList();
    }
    if (isElevated) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 10,
          spreadRadius: 1,
          offset: const Offset(0, 4),
        ),
      ];
    }
    return null;
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

    final isElevated = _isHovered && !_isPressed && widget.onTap != null && widget.enableHover;
    final currentShadows = _computeShadows();

    if (widget.color != null ||
        widget.border != null ||
        currentShadows != null ||
        widget.borderRadius != null) {
      content = AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(
          0,
          isElevated ? widget.hoverOffsetY : 0.0,
          0,
        ),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: widget.borderRadius,
          border: widget.border,
          boxShadow: currentShadows,
        ),
        child: content,
      );
    } else if (isElevated) {
      content = AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(
          0,
          widget.hoverOffsetY,
          0,
        ),
        child: content,
      );
    }

    if (widget.onTap == null) {
      return content;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
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
      ),
    );
  }
}
