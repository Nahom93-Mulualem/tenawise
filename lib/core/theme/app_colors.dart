import 'package:flutter/material.dart';

/// Centralized, accessible, and inclusive design system tokens for TenaWise (ጤና ዋይዝ).
/// Calibrated for Ethiopian Youth Sexual and Reproductive Health (SRH):
/// - Calming forest green / sage for reassurance, biological health, and growth
/// - Clinical deep teal / blue for professional trust and medical accuracy
/// - Warm terracotta / coral for encouragement, discreet urgent alerts without fear
/// - Soft organic surfaces that reduce visual fatigue and maintain discretion
class AppColors {
  AppColors._();

  // ===========================================================================
  // Light Theme Palette
  // ===========================================================================

  // Primary: Reassuring Forest & Sage (Health, Renewal, Vitality)
  static const Color primary = Color(0xFF134E35);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF266548);
  static const Color onPrimaryContainer = Color(0xFFA6E3C3);
  static const Color primaryLight = Color(0xFFE8F5ED);
  static const Color inversePrimary = Color(0xFF8FD8B0);

  // Secondary: Trust Clinical Deep Teal (Medical rigor, confidentiality)
  static const Color secondary = Color(0xFF1F5E6B);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFD2EFF2);
  static const Color onSecondaryContainer = Color(0xFF0D3B44);

  // Tertiary: Warm Rose & Terracotta (Supportive, reproductive cycle, human warmth)
  static const Color tertiary = Color(0xFF9E432A);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFFFDCD2);
  static const Color onTertiaryContainer = Color(0xFF5E2111);
  static const Color tertiaryFixed = Color(0xFFFFECE6);

  // Neutral Surfaces & Backgrounds (Soft organic paper tone, low glare)
  static const Color surface = Color(0xFFF6FAF7);
  static const Color surfaceDim = Color(0xFFDFE6E1);
  static const Color surfaceBright = Color(0xFFF9FCFA);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFEFF5F1);
  static const Color surfaceContainer = Color(0xFFE7EFEA);
  static const Color surfaceContainerHigh = Color(0xFFDEE7E2);
  static const Color surfaceContainerHighest = Color(0xFFD5DFDA);

  // Typography & Borders (High contrast, readable in bright daylight)
  static const Color onSurface = Color(0xFF16201B);
  static const Color onSurfaceVariant = Color(0xFF435149);
  static const Color outline = Color(0xFF6F7E76);
  static const Color outlineVariant = Color(0xFFCAD4CE);

  // Status & Clinical Triage (Thoughtful, non-stigmatizing, reassuring)
  static const Color emergencyRed = Color(0xFFBA1A1A);
  static const Color onEmergencyRed = Color(0xFFFFFFFF);
  static const Color emergencyContainer = Color(0xFFFFDAD6);
  static const Color onEmergencyContainer = Color(0xFF680003);

  static const Color successGreen = Color(0xFF1A7A4A);
  static const Color successContainer = Color(0xFFD5F3E2);
  static const Color onSuccessContainer = Color(0xFF094425);

  static const Color warningAmber = Color(0xFF9C5A00);
  static const Color warningContainer = Color(0xFFFFDFB6);
  static const Color onWarningContainer = Color(0xFF593000);

  static const Color infoBlue = Color(0xFF165D82);
  static const Color infoContainer = Color(0xFFD7EFFF);
  static const Color onInfoContainer = Color(0xFF063A54);

  // Cycle specific colors (delicate and clear)
  static const Color cyclePeriod = Color(0xFFC84040);
  static const Color cyclePeriodLight = Color(0xFFFFEAEA);
  static const Color cycleFertile = Color(0xFF2A8B78);
  static const Color cycleFertileLight = Color(0xFFE2F7F2);
  static const Color cycleOvulation = Color(0xFF9E5C00);
  static const Color cycleOvulationLight = Color(0xFFFFF4DF);
  static const Color cycleLuteal = Color(0xFF38657B);
  static const Color cycleLutealLight = Color(0xFFE8F4FA);

  // Legacy compatibility getters for existing screens
  static const Color error = emergencyRed;
  static const Color onError = onEmergencyRed;
  static const Color errorContainer = emergencyContainer;
  static const Color onErrorContainer = onEmergencyContainer;
  static const Color inverseSurface = Color(0xFF232D27);
  static const Color inverseOnSurface = Color(0xFFE8F1EC);

  // ===========================================================================
  // Dark Theme Palette (Discreet night-time viewing for privacy)
  // ===========================================================================
  static const Color darkSurface = Color(0xFF111714);
  static const Color darkSurfaceDim = Color(0xFF0D1210);
  static const Color darkSurfaceBright = Color(0xFF18221D);
  static const Color darkSurfaceContainerLowest = Color(0xFF161F1A);
  static const Color darkSurfaceContainerLow = Color(0xFF1B2621);
  static const Color darkSurfaceContainer = Color(0xFF202C26);
  static const Color darkSurfaceContainerHigh = Color(0xFF26342D);
  static const Color darkSurfaceContainerHighest = Color(0xFF2D3C34);

  static const Color darkPrimary = Color(0xFF8FD8B0);
  static const Color darkOnPrimary = Color(0xFF003820);
  static const Color darkPrimaryContainer = Color(0xFF1B593C);
  static const Color darkOnPrimaryContainer = Color(0xFFA6E3C3);

  static const Color darkSecondary = Color(0xFF8CD3DF);
  static const Color darkOnSecondary = Color(0xFF00363E);
  static const Color darkSecondaryContainer = Color(0xFF164A53);
  static const Color darkOnSecondaryContainer = Color(0xFFBCECF5);

  static const Color darkOnSurface = Color(0xFFE0EAE3);
  static const Color darkOnSurfaceVariant = Color(0xFFA5B4AB);
  static const Color darkOutline = Color(0xFF6F7E75);
  static const Color darkOutlineVariant = Color(0xFF3B4841);
}
