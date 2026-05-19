import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:precision_vision/common/theme/app_typography.dart';
import 'package:precision_vision/common/theme/app_colors.dart';

/// Labeled text input following the Precision Vision spec.
///
/// **Light:** White bg, 1px slate border → 2px Safety Yellow on focus.
/// Sharp 90° corners. Label always above.
///
/// **Dark:** Surface-container bg, 12 px radius.
/// Same Safety Yellow focus ring.
///
/// ```dart
/// PVInputField(
///   label: 'Confidence Threshold',
///   hint: '0.0 – 1.0',
///   controller: _thresholdCtrl,
///   keyboardType: TextInputType.number,
/// )
/// ```
class PVInputField extends StatefulWidget {
  const PVInputField({
    required this.label,
    super.key,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.inputFormatters,
    this.obscureText = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.autofocus = false,
    this.enabled = true,
    this.isMonospaced = false,
  });

  final String label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool readOnly;
  final int maxLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final bool autofocus;
  final bool enabled;

  /// Use JetBrains Mono for numeric / coordinate inputs.
  final bool isMonospaced;

  @override
  State<PVInputField> createState() => _PVInputFieldState();
}

class _PVInputFieldState extends State<PVInputField> {
  late final FocusNode _focus;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focus = widget.focusNode ?? FocusNode();
    _focus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focus.hasFocus);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final labelStyle = PVTypography.labelMd.copyWith(
      color: _isFocused
          ? PVColors.safetyYellow
          : widget.enabled
          ? cs.onSurfaceVariant
          : cs.onSurfaceVariant.withAlpha(100),
      fontWeight: FontWeight.w600,
    );

    final inputStyle = PVTypography.bodyMd.copyWith(
      color: cs.onSurface,
      fontFeatures: widget.isMonospaced
          ? const [FontFeature.tabularFigures()]
          : null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label above the field (always visible, per spec)
        Text(widget.label, style: labelStyle),
        const SizedBox(height: 4),
        TextField(
          controller: widget.controller,
          focusNode: _focus,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          obscureText: widget.obscureText,
          readOnly: widget.readOnly,
          maxLines: widget.maxLines,
          autofocus: widget.autofocus,
          enabled: widget.enabled,
          style: inputStyle,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          decoration: InputDecoration(
            hintText: widget.hint,
            helperText: widget.helperText,
            errorText: widget.errorText,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
            // Remove the built-in label (we render it ourselves above)
            floatingLabelBehavior: FloatingLabelBehavior.never,
          ),
        ),
      ],
    );
  }
}

/// A read-only data display variant — monospaced, no border focus animation.
/// Useful for showing live coordinates or detection metadata.
class PVDataField extends StatelessWidget {
  const PVDataField({
    required this.label,
    required this.value,
    super.key,
    this.unit,
  });

  final String label;
  final String value;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: PVTypography.labelCaps.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: PVTypography.dataLg.copyWith(color: cs.onSurface),
            ),
            if (unit != null) ...[
              const SizedBox(width: 4),
              Text(
                unit!,
                style: PVTypography.dataSm.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
