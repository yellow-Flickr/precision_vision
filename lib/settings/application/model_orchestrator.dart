import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:precision_vision/settings/data/detector.dart';
import 'package:precision_vision/settings/data/mobile_net_detector.dart';
import 'package:precision_vision/settings/data/yolov8_detector.dart';
import 'package:precision_vision/settings/providers.dart';

/// Immutable wrapper that lets the orchestrator emit new state
/// without ever recreating the loaded Detector (and its interpreters).
class ActiveModel {
  const ActiveModel({
    required this.detector,
    required this.confidenceThreshold,
  });

  final Detector detector;
  final double confidenceThreshold;

  ActiveModel copyWith({
    Detector? detector,
    double? confidenceThreshold,
  }) {
    return ActiveModel(
      detector: detector ?? this.detector,
      confidenceThreshold: confidenceThreshold ?? this.confidenceThreshold,
    );
  }
}

class ModelOrchestrator extends Notifier<ActiveModel> {
  @override
  ActiveModel build() {
    // Keep the orchestrator reactive when the underlying concrete providers change
    ref.watch(mobileNetDetectorProvider);
    ref.watch(yoloV8DetectorProvider);

    // Start with MobileNet (your previous default)
    final detector = ref.watch(mobileNetDetectorProvider);
    return ActiveModel(
      detector: detector,
      confidenceThreshold: detector.confidenceThreshold,
    );
  }

  /// Updates the threshold on the live detector (so inference sees it immediately)
  /// and emits a new wrapper so the settings screen rebuilds.
  void adjustConfidenceThreshold(double value) {
    // 1. Mutate the real detector object (inference path keeps working)
    state.detector.confidenceThreshold = value;

    // 2. Replace the wrapper -> Riverpod notifies all watchers
    state = state.copyWith(confidenceThreshold: value);
  }

  Future<void> changeToYoloV8() async {
    final detector = ref.read(yoloV8DetectorProvider);
    await detector.load().then((_) {
      state = ActiveModel(
        detector: detector,
        confidenceThreshold: detector.confidenceThreshold,
      );
    });
  }

  Future<void> changeToMobileNet() async {
    final detector = ref.read(mobileNetDetectorProvider);
    await detector.load().then((_) {
      state = ActiveModel(
        detector: detector,
        confidenceThreshold: detector.confidenceThreshold,
      );
    });
  }

  /// Stable identifier for the currently active model.
  String get currentModel {
    if (state.detector is Yolov8Detector) return 'YOLOv8';
    if (state.detector is MobileNetDetector) return 'MobileNet';
    return 'Unknown';
  }

  /// Convenience getter so existing code can still do
  /// ref.read(modelOrchestratorProvider) and get the real detector.
  Detector get currentDetector => state.detector;
}