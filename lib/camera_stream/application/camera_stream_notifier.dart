import 'dart:async';
import 'dart:developer';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:precision_vision/camera_stream/domain/camera_stream_state.dart';
import 'package:precision_vision/settings/providers.dart';

/// Riverpod notifier that owns camera lifecycle and wires frames to the current Detector.
class CameraStreamNotifier extends Notifier<CameraStreamState> {
  List<CameraDescription> _cameras = [];
  int _selectedCameraIdx = 0;
  FlashMode _flashMode = FlashMode.off;

  DateTime _lastFrameTime = DateTime.now();

  @override
  CameraStreamState build() {
    // Watch the current detector from the settings module.
    // When the user switches models in settings, this will rebuild the notifier
    // (future enhancement: react to model swaps while streaming).
    ref.watch(modelOrchestratorProvider);

    // Ensure we dispose the camera when this provider is disposed.
    ref.onDispose(() {
      _stopStreamAndDispose();
    });

    // We don't auto-initialize here (side effects in build are bad).
    // Initialization is triggered explicitly from the UI.
    return const CameraStreamState();
  }

  /// One-time camera + detector setup. Call from widget initState.
  Future<void> initialize() async {
    if (state.isInitialized) return;

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        state = state.copyWith(error: 'No cameras available');
        return;
      }

      await _initializeCameraController(_cameras[_selectedCameraIdx]);

      // Start the stream and wire to current detector (fresh read on each frame)
      await state.controller!.startImageStream((CameraImage frame) async {
        final detections = await ref
            .read(modelOrchestratorProvider)
            .onFrame(frame);

        final now = DateTime.now();
        final elapsed = now.difference(_lastFrameTime).inMilliseconds;
        _lastFrameTime = now;

        if (!ref.mounted) return;

        state = state.copyWith(
          detections: detections,
          fps: elapsed > 0 ? 1000 / elapsed : 0,
        );
      });

      state = state.copyWith(isInitialized: true);
    } catch (e, s) {
      log('CameraStreamNotifier initialize error', error: e, stackTrace: s);
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> _initializeCameraController(
    CameraDescription description,
  ) async {
    final controller = CameraController(
      description,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    state = state.copyWith(controller: controller);

    controller.addListener(() {
      if (ref.mounted && controller.value.hasError) {
        state = state.copyWith(
          error: 'Camera error: ${controller.value.errorDescription}',
        );
      }
    });

    await controller.initialize();
    await controller.setFlashMode(_flashMode);
  }

  Future<void> switchCamera() async {
    if (_cameras.length < 2 || state.controller == null) return;

    await _stopStreamAndDispose();

    _selectedCameraIdx = (_selectedCameraIdx + 1) % _cameras.length;

    state = state.copyWith(isInitialized: false, detections: [], fps: 0);

    await _initializeCameraController(_cameras[_selectedCameraIdx]);

    await state.controller!.startImageStream((CameraImage frame) async {
      final detections = await ref
          .read(modelOrchestratorProvider)
          .onFrame(frame);

      final now = DateTime.now();
      final elapsed = now.difference(_lastFrameTime).inMilliseconds;
      _lastFrameTime = now;

      if (!ref.mounted) return;

      state = state.copyWith(
        detections: detections,
        fps: elapsed > 0 ? 1000 / elapsed : 0,
      );
    });

    state = state.copyWith(isInitialized: true);
  }

  Future<void> toggleFlash() async {
    final controller = state.controller;
    if (controller == null) return;

    final next = switch (_flashMode) {
      FlashMode.off => FlashMode.auto,
      FlashMode.auto => FlashMode.always,
      FlashMode.always => FlashMode.torch,
      FlashMode.torch => FlashMode.off,
    };

    try {
      await controller.setFlashMode(next);
      _flashMode = next;
    } catch (e) {
      log('Flash toggle error: $e');
    }
  }

  Future<XFile?> capture() async {
    final controller = state.controller;
    if (controller == null || !controller.value.isInitialized) return null;

    try {
      return await controller.takePicture();
    } catch (e) {
      log('Capture error: $e');
      return null;
    }
  }

  Future<void> _stopStreamAndDispose() async {
    final controller = state.controller;
    if (controller != null) {
      try {
        await controller.stopImageStream();
      } catch (_) {}
      await controller.dispose();
    }
    state = const CameraStreamState();
  }

  FlashMode get currentFlashMode => _flashMode;
}
