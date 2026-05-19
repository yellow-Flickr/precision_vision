import 'package:flutter/material.dart';
import 'package:precision_vision/common/theme/app_colors.dart';
import 'package:precision_vision/common/theme/app_typography.dart';
import 'package:precision_vision/common/theme/themes.dart';

/// Semantic status variants.
enum PVChipStatus { success, warning, error, info, neutral }

extension _PVChipStatusColors on PVChipStatus {
  /// 2px left-border accent color.
  Color accentColor(ColorScheme cs) => switch (this) {
    PVChipStatus.success => const Color(0xFF16A34A),
    PVChipStatus.warning => const Color(0xFFCA8A04),
    PVChipStatus.error => cs.error,
    PVChipStatus.info => cs.tertiary,
    PVChipStatus.neutral => cs.outline,
  };

  /// Subtle background tint.
  Color bgColor(ColorScheme cs) => switch (this) {
    PVChipStatus.success => const Color(0xFF16A34A).withAlpha(20),
    PVChipStatus.warning => const Color(0xFFCA8A04).withAlpha(20),
    PVChipStatus.error => cs.errorContainer.withAlpha(60),
    PVChipStatus.info => cs.tertiaryContainer.withAlpha(60),
    PVChipStatus.neutral => cs.surfaceContainerHigh,
  };
}

/// Status chip with a bold 2px left-side border accent and tinted background.
///
/// ```dart
/// PVStatusChip(label: 'LIVE', status: PVChipStatus.success)
/// PVStatusChip(label: 'ERROR', status: PVChipStatus.error, dot: true)
/// ```
class PVStatusChip extends StatelessWidget {
  const PVStatusChip({
    required this.label,
    required this.status,
    super.key,
    this.dot = false,
    this.pulsing = false,
  });

  final String label;
  final PVChipStatus status;

  /// Show a colored indicator dot before the label.
  final bool dot;

  /// Animate the dot with a pulse (useful for "LIVE" indicators).
  final bool pulsing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accent = status.accentColor(cs);
    final bg = status.bgColor(cs);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(left: BorderSide(color: accent, width: 2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            pulsing
                ? _PulsingDot(color: accent)
                : Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
            const SizedBox(width: 6),
          ],
          Text(label, style: PVTypography.labelCaps.copyWith(color: accent)),
        ],
      ),
    );
  }
}

/// Glass-style overlay chip for telemetry data (FPS, model ID, latency).
/// Uses the dark-mode glassmorphism surface — suitable over video feeds.
///
/// ```dart
/// PVTelemetryChip(label: 'FPS', value: '29.7')
/// PVTelemetryChip(label: 'MODEL', value: 'YOLOv8n')
/// ```
class PVTelemetryChip extends StatelessWidget {
  const PVTelemetryChip({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        color: PVColors.glassWhite10,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label ',
              style: PVTypography.labelCaps.copyWith(color: Colors.white54),
            ),
            Text(
              value,
              style: PVTypography.dataSm.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

/// Confidence score chip — tinted from green (high) → yellow → red (low).
///
/// ```dart
/// PVConfidenceChip(confidence: 0.94) // shows "94%"
/// ```
class PVConfidenceChip extends StatelessWidget {
  const PVConfidenceChip({required this.confidence, super.key});

  /// A value between 0.0 and 1.0.
  final double confidence;

  @override
  Widget build(BuildContext context) {
    final isDark = PVTheme.isDark(context);
    final color = _colorForConfidence(confidence);
    final bg = color.withAlpha(isDark ? 40 : 25);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(isDark ? 4 : 0),
      ),
      child: Text(
        '${(confidence * 100).toStringAsFixed(0)}%',
        style: PVTypography.dataSm.copyWith(color: color),
      ),
    );
  }

  static Color _colorForConfidence(double v) {
    if (v >= 0.75) return const Color(0xFF16A34A);
    if (v >= 0.50) return PVColors.safetyYellow;
    return const Color(0xFFDC2626);
  }
}

// ─── Internal: pulsing dot ────────────────────────────────────────────────────

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color});
  final Color color;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _anim = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder: (_, _) => Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: widget.color.withAlpha((_anim.value * 255).round()),
        shape: BoxShape.circle,
      ),
    ),
  );
}
