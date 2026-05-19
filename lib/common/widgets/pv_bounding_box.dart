import 'package:flutter/material.dart';
import 'package:precision_vision/common/theme/app_colors.dart';
import 'package:precision_vision/common/theme/app_typography.dart';

/// Represents a single detected object to be drawn over a camera feed.
class PVDetection {
  const PVDetection({
    required this.boundingBox,
    required this.label,
    required this.confidence,
    this.color = PVColors.safetyYellow,
  });

  /// Normalised rect in [0, 1] coordinates relative to the widget size.
  final Rect boundingBox;
  final String label;
  final double confidence;
  /// Override per-class color; defaults to Safety Yellow.
  final Color color;
}

/// Overlay widget that draws bounding boxes over any child (typically a
/// camera preview or image).
///
/// **Light spec:** 1px stroke, Safety Yellow, label tag top-left.
/// **Dark spec:** 2px stroke, Safety Yellow outer glow, corner brackets, 12px
/// label radius.
///
/// ```dart
/// PVDetectionOverlay(
///   detections: _detections,
///   child: CameraPreview(_controller),
/// )
/// ```
class PVDetectionOverlay extends StatelessWidget {
  const PVDetectionOverlay({
    required this.child,
    required this.detections,
    super.key,
  });

  final Widget child;
  final List<PVDetection> detections;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        if (detections.isNotEmpty)
          CustomPaint(painter: _BoundingBoxPainter(detections: detections)),
        // Label tags rendered as widgets for correct text rendering
        ...detections.map((d) => _DetectionLabel(detection: d)),
      ],
    );
  }
}

// ─── CustomPainter ────────────────────────────────────────────────────────────

class _BoundingBoxPainter extends CustomPainter {
  const _BoundingBoxPainter({required this.detections});
  final List<PVDetection> detections;

  @override
  void paint(Canvas canvas, Size size) {
    for (final d in detections) {
      final rect = Rect.fromLTWH(
        d.boundingBox.left * size.width,
        d.boundingBox.top * size.height,
        d.boundingBox.width * size.width,
        d.boundingBox.height * size.height,
      );

      // Outer glow (dark mode HUD feel — harmless on light bg)
      final glowPaint = Paint()
        ..color = d.color.withAlpha(60)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 4);
      canvas.drawRect(rect, glowPaint);

      // Main stroke
      final strokePaint = Paint()
        ..color = d.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRect(rect, strokePaint);

      // Corner bracket accents (3x thicker, 12px long)
      _drawCornerBrackets(canvas, rect, d.color);
    }
  }

  void _drawCornerBrackets(Canvas canvas, Rect rect, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.square;

    const len = 12.0;

    // Top-left
    canvas
      ..drawLine(rect.topLeft, rect.topLeft.translate(len, 0), paint)
      ..drawLine(rect.topLeft, rect.topLeft.translate(0, len), paint)
      // Top-right
      ..drawLine(rect.topRight, rect.topRight.translate(-len, 0), paint)
      ..drawLine(rect.topRight, rect.topRight.translate(0, len), paint)
      // Bottom-left
      ..drawLine(rect.bottomLeft, rect.bottomLeft.translate(len, 0), paint)
      ..drawLine(rect.bottomLeft, rect.bottomLeft.translate(0, -len), paint)
      // Bottom-right
      ..drawLine(rect.bottomRight, rect.bottomRight.translate(-len, 0), paint)
      ..drawLine(rect.bottomRight, rect.bottomRight.translate(0, -len), paint);
  }

  @override
  bool shouldRepaint(_BoundingBoxPainter old) => old.detections != detections;
}

// ─── Label tag ────────────────────────────────────────────────────────────────

class _DetectionLabel extends StatelessWidget {
  const _DetectionLabel({required this.detection});
  final PVDetection detection;

  @override
  Widget build(BuildContext context) {
    final pct = ' ${(detection.confidence * 100).toStringAsFixed(0)}%';

    return Positioned.fill(
      child: LayoutBuilder(
        builder: (_, constraints) {
          final left = detection.boundingBox.left * constraints.maxWidth;
          final top = detection.boundingBox.top * constraints.maxHeight;

          return Stack(
            children: [
              Positioned(
                left: left,
                // Place tag just above the box; clamp to screen top
                top: (top - 22).clamp(0, constraints.maxHeight - 22),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  color: detection.color,
                  child: Text(
                    '${detection.label}$pct',
                    style: PVTypography.dataSm.copyWith(
                      color: PVColors.deepSlate,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
