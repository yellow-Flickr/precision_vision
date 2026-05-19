import 'package:flutter/material.dart';

/// Precision Vision — Color Tokens
/// Two-mode palette: Light (industrial lab) and Dark (HUD/glassmorphism).
abstract final class PVColors {
  // ─── Shared Semantic ─────────────────────────────────────────────────────
  /// Safety Yellow — primary highlight, bounding boxes, active states.
  static const safetyYellow = Color(0xFFF4CE14);
  static const safetyYellowDim = Color(0xFFE9C400);
  static const safetyYellowBright = Color(0xFFFFE16E);

  /// Deep Slate — text on Safety Yellow (AA contrast).
  static const deepSlate = Color(0xFF0F172A);

  /// Action Green — success / high-confidence scores (dark mode).
  static const actionGreen = Color(0xFF7DFFA2);
  static const actionGreenDim = Color(0xFF00E475);

  /// System Blue — secondary info, sliders (dark mode).
  static const systemBlue = Color(0xFFECECFF);
  static const systemBlueDim = Color(0xFFC8CEFF);

  // ─── Light Mode ──────────────────────────────────────────────────────────
  static const lightPrimary = Color(0xFF705D00);
  static const lightOnPrimary = Color(0xFFFFFFFF);
  static const lightPrimaryContainer = Color(0xFFF4CE14);
  static const lightOnPrimaryContainer = Color(0xFF6A5800);
  static const lightInversePrimary = Color(0xFFE9C400);

  static const lightSecondary = Color(0xFF565E74);
  static const lightOnSecondary = Color(0xFFFFFFFF);
  static const lightSecondaryContainer = Color(0xFFDAE2FD);
  static const lightOnSecondaryContainer = Color(0xFF5C647A);

  static const lightTertiary = Color(0xFF006879);
  static const lightOnTertiary = Color(0xFFFFFFFF);
  static const lightTertiaryContainer = Color(0xFF5BE1FF);
  static const lightOnTertiaryContainer = Color(0xFF006273);

  static const lightError = Color(0xFFBA1A1A);
  static const lightOnError = Color(0xFFFFFFFF);
  static const lightErrorContainer = Color(0xFFFFDAD6);
  static const lightOnErrorContainer = Color(0xFF93000A);

  static const lightSurface = Color(0xFFFFF9EF);
  static const lightSurfaceBright = Color(0xFFFFF9EF);
  static const lightSurfaceDim = Color(0xFFE1D9C8);
  static const lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const lightSurfaceContainerLow = Color(0xFFFBF3E1);
  static const lightSurfaceContainer = Color(0xFFF5EDDB);
  static const lightSurfaceContainerHigh = Color(0xFFF0E7D6);
  static const lightSurfaceContainerHighest = Color(0xFFEAE2D0);
  static const lightSurfaceVariant = Color(0xFFEAE2D0);
  static const lightOnSurface = Color(0xFF1F1B11);
  static const lightOnSurfaceVariant = Color(0xFF4D4632);

  static const lightInverseSurface = Color(0xFF343024);
  static const lightInverseOnSurface = Color(0xFFF8F0DE);

  static const lightOutline = Color(0xFF7E7760);
  static const lightOutlineVariant = Color(0xFFD0C6AC);

  static const lightBackground = Color(0xFFFFF9EF);
  static const lightOnBackground = Color(0xFF1F1B11);

  /// Subtle rule / border color for layout boundaries (light).
  static const lightBorder = Color(0xFFE2E8F0);
  static const lightBorderFocus = safetyYellow;

  // ─── Dark Mode ───────────────────────────────────────────────────────────
  static const darkPrimary = Color(0xFFFFECAE);
  static const darkOnPrimary = Color(0xFF3A3000);
  static const darkPrimaryContainer = Color(0xFFF4CE14);
  static const darkOnPrimaryContainer = Color(0xFF6A5800);
  static const darkInversePrimary = Color(0xFF705D00);

  static const darkSecondary = Color(0xFF7DFFA2);
  static const darkOnSecondary = Color(0xFF003918);
  static const darkSecondaryContainer = Color(0xFF05E777);
  static const darkOnSecondaryContainer = Color(0xFF00622E);

  static const darkTertiary = Color(0xFFECECFF);
  static const darkOnTertiary = Color(0xFF001D93);
  static const darkTertiaryContainer = Color(0xFFC8CEFF);
  static const darkOnTertiaryContainer = Color(0xFF2041E9);

  static const darkError = Color(0xFFFFB4AB);
  static const darkOnError = Color(0xFF690005);
  static const darkErrorContainer = Color(0xFF93000A);
  static const darkOnErrorContainer = Color(0xFFFFDAD6);

  static const darkBackground = Color(0xFF0B1326);
  static const darkOnBackground = Color(0xFFDAE2FD);

  static const darkSurface = Color(0xFF0B1326);
  static const darkSurfaceDim = Color(0xFF0B1326);
  static const darkSurfaceBright = Color(0xFF31394D);
  static const darkSurfaceContainerLowest = Color(0xFF060E20);
  static const darkSurfaceContainerLow = Color(0xFF131B2E);
  static const darkSurfaceContainer = Color(0xFF171F33);
  static const darkSurfaceContainerHigh = Color(0xFF222A3D);
  static const darkSurfaceContainerHighest = Color(0xFF2D3449);
  static const darkSurfaceVariant = Color(0xFF2D3449);
  static const darkOnSurface = Color(0xFFDAE2FD);
  static const darkOnSurfaceVariant = Color(0xFFD0C6AC);

  static const darkInverseSurface = Color(0xFFDAE2FD);
  static const darkInverseOnSurface = Color(0xFF283044);

  static const darkOutline = Color(0xFF999078);
  static const darkOutlineVariant = Color(0xFF4D4632);

  /// Glassmorphism tints.
  static const glassWhite10 = Color(0x1AFFFFFF); // 10% white
  static const glassWhite20 = Color(0x33FFFFFF); // 20% white
  static const glassDark80 = Color(0xCC000000);  // 80% black modal
}
