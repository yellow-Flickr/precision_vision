
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:precision_vision/camera_stream/application/camera_stream_notifier.dart';
import 'package:precision_vision/camera_stream/domain/camera_stream_state.dart';
import 'package:precision_vision/common/widgets/pv_bounding_box.dart';


/// Main provider for the live camera + detection experience.
final cameraStreamProvider =
    NotifierProvider<CameraStreamNotifier, CameraStreamState>(
      CameraStreamNotifier.new,
    );

/// Convenient selectors (use with .select for minimal rebuilds)
final liveDetectionsProvider = Provider<List<PVDetection>>((ref) {
  return ref.watch(cameraStreamProvider.select((s) => s.detections));
});

final liveFpsProvider = Provider<double>((ref) {
  return ref.watch(cameraStreamProvider.select((s) => s.fps));
});

final cameraControllerProvider = Provider<CameraController?>((ref) {
  return ref.watch(cameraStreamProvider.select((s) => s.controller));
});
