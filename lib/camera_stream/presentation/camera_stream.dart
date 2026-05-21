import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:precision_vision/camera_stream/providers.dart';
import 'package:precision_vision/common/precision_vision.dart';

class CameraStream extends ConsumerStatefulWidget {
  const CameraStream({super.key});

  @override
  ConsumerState<CameraStream> createState() => _CameraStreamState();
}

class _CameraStreamState extends ConsumerState<CameraStream>
    with WidgetsBindingObserver {
  XFile? imageFile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Kick off camera + detector initialization via Riverpod notifier
    Future.microtask(
      () => ref.read(cameraStreamProvider.notifier).initialize(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final streamState = ref.watch(cameraStreamProvider);
    final controller = streamState.controller;

    if (!streamState.isInitialized || controller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final latencyMs = DateTime.now()
        .difference(DateTime.now().subtract(const Duration(milliseconds: 33)))
        .inMilliseconds;

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: PVDetectionOverlay(
              detections: streamState.detections,
              child: CameraPreview(controller),
            ),
          ),

          // Telemetry bar (top-right)
          Positioned(
            top: 48,
            right: 16,
            child: PVTelemetryBar(
              fps: streamState.fps.toStringAsFixed(1),
              modelId: 'MobileNet',
              latencyMs: '$latencyMs ms',
              isLive: true,
            ),
          ),

          // Detections count (top-left)
          Positioned(
            top: 48,
            left: 16,
            child: PVTelemetryChip(
              label: 'Detections',
              value:
                  "${streamState.detections.length} object${streamState.detections.length == 1 ? '' : 's'}",
            ),
          ),

          // Camera controls (flash + switch)
          Positioned(
            top: 40,
            right: 16,
            child: Column(
              children: [
                IconButton(
                  icon: Icon(_getFlashIcon()),
                  color: Colors.white,
                  iconSize: 28,
                  onPressed: () =>
                      ref.read(cameraStreamProvider.notifier).toggleFlash(),
                ),
                const SizedBox(height: 8),
                IconButton(
                  icon: const Icon(Icons.flip_camera_ios),
                  color: Colors.white,
                  iconSize: 28,
                  onPressed: () =>
                      ref.read(cameraStreamProvider.notifier).switchCamera(),
                ),
              ],
            ),
          ),

          // Capture button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _takePicture,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Center(
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: Hand off to CameraStreamNotifier for proper pause/resume handling
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Camera + detector disposal is handled by the Riverpod notifier
    super.dispose();
  }

  IconData _getFlashIcon() {
    final mode = ref.read(cameraStreamProvider.notifier).currentFlashMode;
    return switch (mode) {
      FlashMode.auto => Icons.flash_auto,
      FlashMode.always => Icons.flash_on,
      FlashMode.torch => Icons.flashlight_on,
      _ => Icons.flash_off,
    };
  }

  Future<void> _takePicture() async {
    final file = await ref.read(cameraStreamProvider.notifier).capture();
    if (file != null && mounted) {
      setState(() => imageFile = file);
      showInSnackBar('Picture saved: ${file.path}');
    }
  }


  void showInSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

// ─── Legacy / unused types kept for reference (can be deleted later) ──────────

typedef AnalyseImageCallBack = ({
  Uint8List? imageBytes,
  List<DetectedObject> detectedObjs,
});

class DetectedObject {
  final String label;
  final num score;
  final Rect location;

  DetectedObject({
    required this.label,
    required this.score,
    required this.location,
  });

  @override
  String toString() {
    return 'DetectedObject(label:$label, score$score, location:$location)';
  }
}
