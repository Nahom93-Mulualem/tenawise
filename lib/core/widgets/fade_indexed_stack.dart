import 'package:flutter/material.dart';

/// A fluid, state-preserving alternative to [IndexedStack].
///
/// Features:
/// - Preserves state of all children (scroll position, inputs, etc.)
/// - Cross-fades between active and inactive screens
/// - Subtle vertical glide on entry for Apple-style fluid transitions
/// - Disables hit testing for non-active screens via [IgnorePointer]
class FadeIndexedStack extends StatelessWidget {
  final int index;
  final List<Widget> children;
  final Duration duration;

  const FadeIndexedStack({
    super.key,
    required this.index,
    required this.children,
    this.duration = const Duration(milliseconds: 240),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: List.generate(children.length, (i) {
        final isActive = i == index;
        return IgnorePointer(
          ignoring: !isActive,
          child: AnimatedOpacity(
            opacity: isActive ? 1.0 : 0.0,
            duration: duration,
            curve: Curves.easeInOutCubic,
            child: AnimatedSlide(
              offset: isActive ? Offset.zero : const Offset(0, 0.012),
              duration: duration,
              curve: Curves.easeOutCubic,
              child: children[i],
            ),
          ),
        );
      }),
    );
  }
}
