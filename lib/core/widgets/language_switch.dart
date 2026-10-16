import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../localization/app_language.dart';
import '../theme/app_colors.dart';

/// A fluid Apple iOS-inspired segmented capsule switch for bilingual switching (EN <-> አማ).
/// Features:
/// - Smooth animated sliding capsule indicator
/// - Active text bolding with color interpolation
/// - Haptic selection click on touch
class LanguageSegmentedSwitch extends StatelessWidget {
  final bool isAmharic;

  const LanguageSegmentedSwitch({
    super.key,
    required this.isAmharic,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        AppLanguage.toggleLanguage();
      },
      child: Container(
        width: 88,
        height: 34,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.45),
            width: 0.8,
          ),
        ),
        child: Stack(
          children: [
            // Sliding Capsule Indicator
            AnimatedAlign(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              alignment:
                  isAmharic ? Alignment.centerRight : Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                heightFactor: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 5,
                        offset: const Offset(0, 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Language Labels Row
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            !isAmharic ? FontWeight.bold : FontWeight.w600,
                        color: !isAmharic
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                      child: const Text('EN'),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isAmharic ? FontWeight.bold : FontWeight.w600,
                        color: isAmharic
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                      child: const Text('አማ'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
