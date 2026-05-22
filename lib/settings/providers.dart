import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:precision_vision/settings/application/model_orchestrator.dart';
import 'package:precision_vision/settings/data/detector.dart';
import 'package:precision_vision/settings/data/mobile_net_detector.dart';
import 'package:precision_vision/settings/data/yolov8_detector.dart';

// Theme provider for app-wide theme control
enum ThemeModeOption { system, light, dark }

class ThemeNotifier extends Notifier<ThemeModeOption> {
  @override
  ThemeModeOption build() => ThemeModeOption.system;

  void setThemeMode(ThemeModeOption mode) => state = mode;
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeModeOption>(
  ThemeNotifier.new,
);

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
final modelOrchestratorProvider = NotifierProvider<ModelOrchestrator, ActiveModel>(
  ModelOrchestrator.new,
);
// final confidenceThresholdProvider = StateProvider<double>((ref) => 0.4);
