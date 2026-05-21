import 'package:camera/camera.dart';
import 'package:precision_vision/common/widgets/pv_bounding_box.dart';

/// Immutable state for the live camera + detection stream.
class CameraStreamState {
  const CameraStreamState({
    this.controller,
    this.detections = const [],
    this.fps = 0.0,
    this.isInitialized = false,
    this.error,
  });

  final CameraController? controller;
  final List<PVDetection> detections;
  final double fps;
  final bool isInitialized;
  final String? error;

  CameraStreamState copyWith({
    CameraController? controller,
    List<PVDetection>? detections,
    double? fps,
    bool? isInitialized,
    String? error,
  }) {
    return CameraStreamState(
      controller: controller ?? this.controller,
      detections: detections ?? this.detections,
      fps: fps ?? this.fps,
      isInitialized: isInitialized ?? this.isInitialized,
      error: error ?? this.error,
    );
  }
}
