import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Precision Vision — Theme Definitions
///
/// Usage:
/// ```dart
/// MaterialApp(
///   theme: PVTheme.light,
///   darkTheme: PVTheme.dark,
///   themeMode: ThemeMode.system,
/// )
/// ```
abstract final class PVTheme {
  // ─── Shape tokens ─────────────────────────────────────────────────────────

  /// Light: sharp 90° corners throughout — blueprint / terminal aesthetic.
  static const _sharpShape = RoundedRectangleBorder();

  /// Dark: 12 px radius — approachable "Augmented Intelligence" feel.
  static const _roundedShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
  );

  /// Large panels / bottom sheets (dark only): 24 px top radius only.
  static const BorderRadius drawerRadius = BorderRadius.only(
    topLeft: Radius.circular(24),
    topRight: Radius.circular(24),
  );

  // ─── Color schemes ────────────────────────────────────────────────────────

  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: PVColors.lightPrimary,
    onPrimary: PVColors.lightOnPrimary,
    primaryContainer: PVColors.lightPrimaryContainer,
    onPrimaryContainer: PVColors.lightOnPrimaryContainer,
    inversePrimary: PVColors.lightInversePrimary,
    secondary: PVColors.lightSecondary,
    onSecondary: PVColors.lightOnSecondary,
    secondaryContainer: PVColors.lightSecondaryContainer,
    onSecondaryContainer: PVColors.lightOnSecondaryContainer,
    tertiary: PVColors.lightTertiary,
    onTertiary: PVColors.lightOnTertiary,
    tertiaryContainer: PVColors.lightTertiaryContainer,
    onTertiaryContainer: PVColors.lightOnTertiaryContainer,
    error: PVColors.lightError,
    onError: PVColors.lightOnError,
    errorContainer: PVColors.lightErrorContainer,
    onErrorContainer: PVColors.lightOnErrorContainer,
    surface: PVColors.lightSurface,
    onSurface: PVColors.lightOnSurface,
    onSurfaceVariant: PVColors.lightOnSurfaceVariant,
    outline: PVColors.lightOutline,
    outlineVariant: PVColors.lightOutlineVariant,
    inverseSurface: PVColors.lightInverseSurface,
    onInverseSurface: PVColors.lightInverseOnSurface,
    surfaceContainerLowest: PVColors.lightSurfaceContainerLowest,
    surfaceContainerLow: PVColors.lightSurfaceContainerLow,
    surfaceContainer: PVColors.lightSurfaceContainer,
    surfaceContainerHigh: PVColors.lightSurfaceContainerHigh,
    surfaceContainerHighest: PVColors.lightSurfaceContainerHighest,
  );

  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: PVColors.darkPrimary,
    onPrimary: PVColors.darkOnPrimary,
    primaryContainer: PVColors.darkPrimaryContainer,
    onPrimaryContainer: PVColors.darkOnPrimaryContainer,
    inversePrimary: PVColors.darkInversePrimary,
    secondary: PVColors.darkSecondary,
    onSecondary: PVColors.darkOnSecondary,
    secondaryContainer: PVColors.darkSecondaryContainer,
    onSecondaryContainer: PVColors.darkOnSecondaryContainer,
    tertiary: PVColors.darkTertiary,
    onTertiary: PVColors.darkOnTertiary,
    tertiaryContainer: PVColors.darkTertiaryContainer,
    onTertiaryContainer: PVColors.darkOnTertiaryContainer,
    error: PVColors.darkError,
    onError: PVColors.darkOnError,
    errorContainer: PVColors.darkErrorContainer,
    onErrorContainer: PVColors.darkOnErrorContainer,
    surface: PVColors.darkSurface,
    onSurface: PVColors.darkOnSurface,
    onSurfaceVariant: PVColors.darkOnSurfaceVariant,
    outline: PVColors.darkOutline,
    outlineVariant: PVColors.darkOutlineVariant,
    inverseSurface: PVColors.darkInverseSurface,
    onInverseSurface: PVColors.darkInverseOnSurface,
    surfaceContainerLowest: PVColors.darkSurfaceContainerLowest,
    surfaceContainerLow: PVColors.darkSurfaceContainerLow,
    surfaceContainer: PVColors.darkSurfaceContainer,
    surfaceContainerHigh: PVColors.darkSurfaceContainerHigh,
    surfaceContainerHighest: PVColors.darkSurfaceContainerHighest,
  );

  // ─── Light ThemeData ──────────────────────────────────────────────────────

  static ThemeData get light {
    const cs = _lightColorScheme;
    final textTheme = PVTypography.textTheme(cs.onSurface);

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      textTheme: textTheme,
      scaffoldBackgroundColor: PVColors.lightBackground,
      // ── AppBar ──
      appBarTheme: AppBarTheme(
        backgroundColor: PVColors.lightSurfaceContainerLow,
        foregroundColor: cs.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: PVTypography.headlineMd.copyWith(
          color: cs.onSurface,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        shape: const Border(
          bottom: BorderSide(color: PVColors.lightBorder, width: 1),
        ),
      ),
      // ── Buttons ──
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PVColors.safetyYellow,
          foregroundColor: PVColors.deepSlate,
          textStyle: PVTypography.labelLg,
          shape: _sharpShape,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.onSurface,
          side: const BorderSide(color: PVColors.lightOutline, width: 1),
          textStyle: PVTypography.labelLg,
          shape: _sharpShape,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.primary,
          textStyle: PVTypography.labelLg,
          shape: _sharpShape,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
      // ── Input ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PVColors.lightSurfaceContainerLowest,
        labelStyle: PVTypography.labelMd.copyWith(
          color: cs.onSurfaceVariant,
        ),
        hintStyle: PVTypography.bodyMd.copyWith(
          color: cs.onSurfaceVariant,
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: PVColors.lightOutline, width: 1),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: PVColors.lightOutline, width: 1),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(
            color: PVColors.safetyYellow,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: cs.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: cs.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      // ── Cards ──
      cardTheme: CardThemeData(
        color: PVColors.lightSurfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: const BorderSide(color: PVColors.lightBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      // ── Chips ──
      chipTheme: ChipThemeData(
        backgroundColor: PVColors.lightSurfaceContainer,
        labelStyle: PVTypography.labelMd.copyWith(color: cs.onSurface),
        shape: _sharpShape,
        side: const BorderSide(color: PVColors.lightOutlineVariant, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      // ── Divider ──
      dividerTheme: const DividerThemeData(
        color: PVColors.lightBorder,
        thickness: 1,
        space: 0,
      ),
      // ── BottomSheet ──
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: PVColors.lightSurfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      // ── Slider ──
      sliderTheme: SliderThemeData(
        activeTrackColor: PVColors.safetyYellow,
        thumbColor: PVColors.safetyYellow,
        inactiveTrackColor: PVColors.lightOutlineVariant,
        overlayColor: PVColors.safetyYellow.withAlpha(30),
        trackHeight: 2,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      ),
      // ── ListTile ──
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        selectedTileColor: PVColors.safetyYellow.withAlpha(25),
        iconColor: cs.onSurfaceVariant,
        textColor: cs.onSurface,
        dense: true,
      ),
      // ── FloatingActionButton ──
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: PVColors.safetyYellow,
        foregroundColor: PVColors.deepSlate,
        shape: _sharpShape,
        elevation: 0,
      ),
      // ── Switch ──
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return PVColors.deepSlate;
          }
          return cs.onSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return PVColors.safetyYellow;
          }
          return PVColors.lightSurfaceContainerHigh;
        }),
      ),
    );
  }

  // ─── Dark ThemeData ───────────────────────────────────────────────────────

  static ThemeData get dark {
    const cs = _darkColorScheme;
    final textTheme = PVTypography.textTheme(cs.onSurface);

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      textTheme: textTheme,
      scaffoldBackgroundColor: PVColors.darkBackground,
      // ── AppBar ──
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: cs.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: PVTypography.headlineMd.copyWith(
          color: cs.onSurface,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      // ── Buttons ──
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PVColors.safetyYellow,
          foregroundColor: PVColors.darkOnPrimary,
          textStyle: PVTypography.labelLg,
          shape: _roundedShape,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.onSurface,
          side: BorderSide(color: cs.outline, width: 1),
          textStyle: PVTypography.labelLg,
          shape: _roundedShape,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.primary,
          textStyle: PVTypography.labelLg,
          shape: _roundedShape,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
      // ── Input ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PVColors.darkSurfaceContainerLow,
        labelStyle: PVTypography.labelMd.copyWith(
          color: cs.onSurfaceVariant,
        ),
        hintStyle: PVTypography.bodyMd.copyWith(
          color: cs.onSurfaceVariant,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: PVColors.safetyYellow,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      // ── Cards ──
      cardTheme: CardThemeData(
        color: PVColors.darkSurfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: PVColors.darkOutlineVariant.withAlpha(80),
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      // ── Chips ──
      chipTheme: ChipThemeData(
        backgroundColor: PVColors.darkSurfaceContainer,
        labelStyle: PVTypography.labelMd.copyWith(color: cs.onSurface),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        side: BorderSide(color: cs.outlineVariant, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      // ── Divider ──
      dividerTheme: DividerThemeData(
        color: cs.outlineVariant.withAlpha(80),
        thickness: 1,
        space: 0,
      ),
      // ── BottomSheet ──
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: PVColors.darkSurfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: PVTheme.drawerRadius),
      ),
      // ── Slider ──
      sliderTheme: SliderThemeData(
        activeTrackColor: PVColors.actionGreen,
        thumbColor: PVColors.actionGreen,
        inactiveTrackColor: PVColors.darkOutlineVariant,
        overlayColor: PVColors.actionGreen.withAlpha(30),
        trackHeight: 2,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      ),
      // ── ListTile ──
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        selectedTileColor: PVColors.safetyYellow.withAlpha(25),
        iconColor: cs.onSurfaceVariant,
        textColor: cs.onSurface,
        dense: true,
      ),
      // ── FloatingActionButton ──
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: PVColors.darkSurfaceContainerHighest,
        foregroundColor: cs.onSurface,
        shape: const CircleBorder(),
        elevation: 0,
      ),
      // ── Switch ──
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return PVColors.darkOnPrimary;
          }
          return cs.onSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return PVColors.safetyYellow;
          }
          return PVColors.darkSurfaceContainerHigh;
        }),
      ),
    );
  }

  // ─── Convenience extensions ───────────────────────────────────────────────

  /// Whether [context] is currently in dark mode.
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  /// Safety Yellow with appropriate text color for the current mode.
  static Color safetyYellowText(BuildContext context) =>
      isDark(context) ? PVColors.darkOnPrimary : PVColors.deepSlate;
}
