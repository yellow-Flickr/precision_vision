import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:precision_vision/settings/application/model_orchestrator.dart';
import 'package:precision_vision/settings/data/detector.dart';
import 'package:precision_vision/settings/data/mobile_net_detector.dart';
import 'package:precision_vision/settings/data/yolov8_detector.dart';

// Default concrete detector implementation (kept alive while watched)
final mobileNetDetectorProvider = Provider<Detector>((ref) {
  final detector = MobileNetDetector();
  ref.onDispose(detector.dispose);
  return detector;
});

final yoloV8DetectorProvider = Provider<Detector>((ref) {
  final detector = Yolov8Detector();
  ref.onDispose(detector.dispose);
  return detector;
});

// Main orchestrator – holds the currently active detector and exposes controls
final modelOrchestratorProvider = NotifierProvider<ModelOrchestrator, Detector>(
  ModelOrchestrator.new,
);
