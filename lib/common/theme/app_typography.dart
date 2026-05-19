import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Precision Vision — Typography Tokens
///
/// Uniform Inter typeface across all roles and both modes.
/// Weight and tracking do the work that font-switching previously did:
///
///  • Display / Headlines → Inter 700 / 600, tight tracking
///  • Body                → Inter 400, comfortable leading
///  • Labels / Caps       → Inter 700, expanded tracking (all-caps)
///  • Data readouts       → Inter 600 / 500, tabular-nums feature
abstract final class PVTypography {
  // ─── Scale ───────────────────────────────────────────────────────────────

  /// 32 / 40 — page titles, modal headings.
  static TextStyle get headlineLg => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 40 / 32,
        letterSpacing: -0.64, // -0.02 em
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  /// 24 / 32 — section headings, card titles.
  static TextStyle get headlineMd => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
        letterSpacing: -0.24, // -0.01 em
      );

  /// 18 / 28 — sub-headings, panel titles.
  static TextStyle get headlineSm => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 28 / 18,
        letterSpacing: -0.18,
      );

  /// 16 / 24 — primary body copy, descriptions.
  static TextStyle get bodyLg => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
      );

  /// 14 / 20 — secondary body, settings text, list items.
  static TextStyle get bodyMd => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
      );

  /// 12 / 16 — captions, helper text.
  static TextStyle get bodySm => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 16 / 12,
      );

  /// 14 / 20 — button labels, interactive elements.
  static TextStyle get labelLg => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 20 / 14,
        letterSpacing: 0.1,
      );

  /// 12 / 16 — chip labels, field labels, tags.
  static TextStyle get labelMd => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        letterSpacing: 0.4,
      );

  /// 11 / 16 — all-caps section labels, category headers.
  static TextStyle get labelCaps => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        height: 16 / 11,
        letterSpacing: 1.1, // 0.1 em
      );

  /// 18 / 24 — large telemetry values (FPS, confidence %).
  static TextStyle get dataLg => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 24 / 18,
        letterSpacing: -0.18,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  /// 12 / 16 — small telemetry values (coordinates, latency, IDs).
  static TextStyle get dataSm => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        letterSpacing: 0.24,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  // ─── Aliases kept for backwards-compat with existing widget references ────

  /// @deprecated Use [headlineLg]
  static TextStyle get lightHeadlineLg => headlineLg;
  /// @deprecated Use [headlineMd]
  static TextStyle get lightHeadlineMd => headlineMd;
  /// @deprecated Use [bodyLg]
  static TextStyle get lightBodyLg => bodyLg;
  /// @deprecated Use [bodyMd]
  static TextStyle get lightBodyMd => bodyMd;
  /// @deprecated Use [labelMd]
  static TextStyle get lightLabelSm => labelMd;
  /// @deprecated Use [bodyMd]
  static TextStyle get lightCodeMd => bodyMd;
  /// @deprecated Use [headlineLg]
  static TextStyle get darkHeadlineLg => headlineLg;
  /// @deprecated Use [headlineMd]
  static TextStyle get darkHeadlineMd => headlineMd;
  /// @deprecated Use [bodyLg]
  static TextStyle get darkBodyMd => bodyLg;

  // ─── ThemeData TextTheme ──────────────────────────────────────────────────

  /// Shared TextTheme — identical for both modes; color is applied per-theme.
  static TextTheme textTheme(Color onSurface) => TextTheme(
        displayLarge: headlineLg.copyWith(color: onSurface),
        displayMedium: headlineMd.copyWith(color: onSurface),
        displaySmall: headlineSm.copyWith(color: onSurface),
        headlineLarge: headlineLg.copyWith(color: onSurface),
        headlineMedium: headlineMd.copyWith(color: onSurface),
        headlineSmall: headlineSm.copyWith(color: onSurface),
        titleLarge: headlineSm.copyWith(color: onSurface),
        titleMedium: bodyLg.copyWith(
          color: onSurface,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: bodyMd.copyWith(
          color: onSurface,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: bodyLg.copyWith(color: onSurface),
        bodyMedium: bodyMd.copyWith(color: onSurface),
        bodySmall: bodySm.copyWith(color: onSurface),
        labelLarge: labelLg.copyWith(color: onSurface),
        labelMedium: labelMd.copyWith(color: onSurface),
        labelSmall: labelCaps.copyWith(color: onSurface),
      );

  // Keep old per-mode helpers pointing at the unified version.
  static TextTheme lightTextTheme(Color onSurface) => textTheme(onSurface);
  static TextTheme darkTextTheme(Color onSurface) => textTheme(onSurface);
}
