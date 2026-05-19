import 'package:flutter/material.dart';
import 'package:precision_vision/common/theme/app_colors.dart';
import 'package:precision_vision/common/theme/app_typography.dart';
import 'package:precision_vision/common/theme/themes.dart';

/// Button variant following the Precision Vision design spec.
///
/// **Light mode** — sharp corners, no elevation.
/// **Dark mode** — 12 px radius, no elevation.
///
/// ```dart
/// PVButton.primary(label: 'Run Detection', onPressed: _startDetection)
/// PVButton.secondary(label: 'Cancel', onPressed: _cancel)
/// PVButton.ghost(label: 'Settings', onPressed: _openSettings)
/// ```
enum _PVButtonVariant { primary, secondary, ghost }

class PVButton extends StatelessWidget {
  const PVButton._({
    required this.label,
    required this.variant,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    super.key,
  });

  /// Safety Yellow background, Deep Slate text.
  factory PVButton.primary({
    required String label,
    VoidCallback? onPressed,
    Widget? icon,
    bool isLoading = false,
    bool fullWidth = false,
    Key? key,
  }) => PVButton._(
    label: label,
    variant: _PVButtonVariant.primary,
    onPressed: onPressed,
    icon: icon,
    isLoading: isLoading,
    fullWidth: fullWidth,
    key: key,
  );

  /// Deep Slate background, white text (light) / surface container (dark).
  factory PVButton.secondary({
    required String label,
    VoidCallback? onPressed,
    Widget? icon,
    bool isLoading = false,
    bool fullWidth = false,
    Key? key,
  }) => PVButton._(
    label: label,
    variant: _PVButtonVariant.secondary,
    onPressed: onPressed,
    icon: icon,
    isLoading: isLoading,
    fullWidth: fullWidth,
    key: key,
  );

  /// 1px outline, transparent fill.
  factory PVButton.ghost({
    required String label,
    VoidCallback? onPressed,
    Widget? icon,
    bool isLoading = false,
    bool fullWidth = false,
    Key? key,
  }) => PVButton._(
    label: label,
    variant: _PVButtonVariant.ghost,
    onPressed: onPressed,
    icon: icon,
    isLoading: isLoading,
    fullWidth: fullWidth,
    key: key,
  );

  final String label;
  final _PVButtonVariant variant;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final isDark = PVTheme.isDark(context);
    final cs = Theme.of(context).colorScheme;

    final BorderRadius radius = isDark
        ? const BorderRadius.all(Radius.circular(12))
        : BorderRadius.zero;

    final textStyle = PVTypography.labelLg;

    Widget buttonChild = isLoading
        ? SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(_labelColor(isDark, cs)),
            ),
          )
        : icon != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon!,
              const SizedBox(width: 8),
              Text(label, style: textStyle),
            ],
          )
        : Text(label, style: textStyle);

    final button = switch (variant) {
      _PVButtonVariant.primary => ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: PVColors.safetyYellow,
          foregroundColor: PVTheme.safetyYellowText(context),
          shape: RoundedRectangleBorder(borderRadius: radius),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: textStyle,
        ),
        child: buttonChild,
      ),
      _PVButtonVariant.secondary => ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark
              ? PVColors.darkSurfaceContainerHigh
              : PVColors.deepSlate,
          foregroundColor: isDark ? cs.onSurface : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: radius),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: textStyle,
        ),
        child: buttonChild,
      ),
      _PVButtonVariant.ghost => OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.onSurface,
          side: BorderSide(
            color: isDark ? cs.outline : PVColors.lightOutline,
            width: 1,
          ),
          shape: RoundedRectangleBorder(borderRadius: radius),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: textStyle,
        ),
        child: buttonChild,
      ),
    };

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }

  Color _labelColor(bool isDark, ColorScheme cs) => switch (variant) {
    _PVButtonVariant.primary =>
      isDark ? PVColors.darkOnPrimary : PVColors.deepSlate,
    _PVButtonVariant.secondary => isDark ? cs.onSurface : Colors.white,
    _PVButtonVariant.ghost => cs.onSurface,
  };
}
