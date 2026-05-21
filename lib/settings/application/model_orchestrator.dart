import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:precision_vision/settings/data/detector.dart';
import 'package:precision_vision/settings/data/mobile_net_detector.dart';
import 'package:precision_vision/settings/data/yolov8_detector.dart';
import 'package:precision_vision/settings/providers.dart';

class ModelOrchestrator extends Notifier<Detector> {
  @override
  Detector build() {
    // Watch both concrete providers so the orchestrator stays reactive
    // when the active model changes (even though we assign state directly).
    ref.watch(mobileNetDetectorProvider);
    ref.watch(yoloV8DetectorProvider);

    return ref.watch(mobileNetDetectorProvider);
  }

  void adjustConfidenceThreshold(double confidence) {
    state.confidenceThreshold = confidence;
  }

  Future<void> changeToYoloV8() async {
    final detector = ref.read(yoloV8DetectorProvider);
    await detector.load();
    state = detector;
  }

  Future<void> changeToMobileNet() async {
    final detector = ref.read(mobileNetDetectorProvider);
    await detector.load();
    state = detector;
  }

  /// Stable identifier for the currently active model.
  /// Values: 'YOLOv8', 'MobileNet', or 'Unknown'.
  String get currentModel {
    if (state is Yolov8Detector) return 'YOLOv8';
    if (state is MobileNetDetector) return 'MobileNet';
    return 'Unknown';
  }
}
