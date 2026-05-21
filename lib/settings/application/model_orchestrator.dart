import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:precision_vision/settings/data/detector.dart';
import 'package:precision_vision/settings/providers.dart';

class ModelOrchestrator extends Notifier<Detector> {
  @override
  Detector build() {
    return ref.watch(mobileNetDetectorProvider);
  }

  void adjustConfidenceThreshold(double confidence) {
    state.confidenceThreshold = confidence;
  }

  void changeDetectorModel(Detector detector) {
    state = detector;
  }
}
