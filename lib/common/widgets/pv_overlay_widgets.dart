import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:precision_vision/common/theme/app_colors.dart';
import 'package:precision_vision/common/theme/app_typography.dart';
import 'package:precision_vision/common/theme/themes.dart';
import 'pv_chip.dart';

// ─── Bottom Sheet ─────────────────────────────────────────────────────────────

/// Glass-effect bottom sheet for model switching / settings panels.
///
/// Dark mode: 20 px backdrop blur, 20% opacity surface, 24 px top radius.
/// Light mode: opaque surface container, no blur, sharp corners.
///
/// ```dart
/// showPVBottomSheet(
///   context: context,
///   title: 'Select Model',
///   child: ModelSwitcherList(),
/// );
/// ```
Future<T?> showPVBottomSheet<T>({
  required BuildContext context,
  required String title,
  required Widget child,
  bool showDragHandle = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => PVBottomSheet(
      title: title,
      showDragHandle: showDragHandle,
      child: child,
    ),
  );
}

class PVBottomSheet extends StatelessWidget {
  const PVBottomSheet({
    required this.title,
    required this.child,
    super.key,
    this.showDragHandle = true,
  });

  final String title;
  final Widget child;
  final bool showDragHandle;

  @override
  Widget build(BuildContext context) {
    final isDark = PVTheme.isDark(context);
    final cs = Theme.of(context).colorScheme;

    final content = Container(
      decoration: BoxDecoration(
        color: isDark
            ? PVColors.darkSurfaceContainerLow.withAlpha(210)
            : PVColors.lightSurfaceContainerLow,
        borderRadius: isDark ? PVTheme.drawerRadius : BorderRadius.zero,
        border: Border.all(
          color: isDark
              ? PVColors.darkOutlineVariant.withAlpha(60)
              : PVColors.lightBorder,
          width: 1,
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showDragHandle) ...[
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ] else
              const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    title,
                    style: PVTypography.headlineSm.copyWith(
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            child,
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (!isDark) return content;

    // Dark mode: apply backdrop blur for glassmorphism
    return ClipRRect(
      borderRadius: PVTheme.drawerRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: content,
      ),
    );
  }
}

// ─── Telemetry overlay bar ────────────────────────────────────────────────────

/// Semi-transparent bar pinned to a corner of the camera viewport.
/// Shows live stats: FPS, model name, latency, live status.
///
/// ```dart
/// PVTelemetryBar(
///   fps: '29.7',
///   modelId: 'YOLOv8n',
///   latencyMs: '18ms',
///   isLive: true,
/// )
/// ```
class PVTelemetryBar extends StatelessWidget {
  const PVTelemetryBar({
    required this.fps,
    required this.modelId,
    required this.latencyMs,
    required this.isLive,
    super.key,
  });

  final String fps;
  final String modelId;
  final String latencyMs;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          color: PVColors.glassWhite10,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PVTelemetryChip(label: 'FPS', value: fps),
              const SizedBox(width: 8),
              PVTelemetryChip(label: 'MDL', value: modelId),
              const SizedBox(width: 8),
              PVTelemetryChip(label: 'LAT', value: latencyMs),
              const SizedBox(width: 8),
              PVStatusChip(
                label: isLive ? 'LIVE' : 'PAUSED',
                status: isLive ? PVChipStatus.success : PVChipStatus.neutral,
                dot: true,
                pulsing: isLive,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Floating Action Button pair ──────────────────────────────────────────────

/// Snapshot + Record FAB pair, spec'd for the dark camera UI.
/// Each button uses heavy backdrop blur and a thick border stroke.
///
/// ```dart
/// PVCameraFABs(
///   onSnapshot: _captureFrame,
///   onRecord: _toggleRecord,
///   isRecording: _recording,
/// )
/// ```
class PVCameraFABs extends StatelessWidget {
  const PVCameraFABs({
    required this.onSnapshot,
    required this.onRecord,
    required this.isRecording,
    super.key,
  });

  final VoidCallback onSnapshot;
  final VoidCallback onRecord;
  final bool isRecording;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _GlassFAB(
          icon: Icons.photo_camera_outlined,
          tooltip: 'Snapshot',
          onPressed: onSnapshot,
        ),
        const SizedBox(width: 16),
        _GlassFAB(
          icon: isRecording ? Icons.stop_rounded : Icons.fiber_manual_record,
          tooltip: isRecording ? 'Stop' : 'Record',
          onPressed: onRecord,
          accentColor: isRecording ? const Color(0xFFDC2626) : null,
        ),
      ],
    );
  }
}

class _GlassFAB extends StatelessWidget {
  const _GlassFAB({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.accentColor,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? PVColors.safetyYellow;

    return Tooltip(
      message: tooltip,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: GestureDetector(
            onTap: onPressed,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: PVColors.glassWhite10,
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Confidence slider ────────────────────────────────────────────────────────

/// Confidence threshold filter slider.
/// Track uses Action Green (dark) or Safety Yellow (light).
///
/// ```dart
/// PVConfidenceSlider(
///   value: _threshold,
///   onChanged: (v) => setState(() => _threshold = v),
/// )
/// ```
class PVConfidenceSlider extends StatelessWidget {
  const PVConfidenceSlider({
    required this.value,
    required this.onChanged,
    super.key,
    this.label = 'Confidence Threshold',
  });

  final double value;
  final ValueChanged<double> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label.toUpperCase(),
              style: PVTypography.labelCaps.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            Text(
              '${(value * 100).toStringAsFixed(0)}%',
              style: PVTypography.dataSm.copyWith(color: cs.onSurface),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: cs.primary,
            thumbColor: cs.primary,
            inactiveTrackColor: cs.outlineVariant,
            overlayColor: cs.primary.withAlpha(30),
            trackHeight: 2,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: value,
            onChanged: onChanged,
            min: 0,
            max: 1,
            divisions: 20,
          ),
        ),
      ],
    );
  }
}
