import 'dart:developer';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_litert/flutter_litert.dart' as tfl;
import 'package:image/image.dart' as img;
import 'package:precision_vision/camera_stream/application/mobile_net_detector.dart';
import 'package:precision_vision/common/precision_vision.dart';

class CameraStream extends StatefulWidget {
  const CameraStream({super.key});

  @override
  State<CameraStream> createState() => _CameraStreamState();
}

class _CameraStreamState extends State<CameraStream>
    with WidgetsBindingObserver {
  CameraController? controller;
  XFile? imageFile;
  bool _isInitialized = false;
  List<CameraDescription> cameras = [];
  // final List<String> _labels = [];
  int selectedCameraIdx = 0;
  FlashMode flashMode = FlashMode.off;
  final MobileNetDetector _detector = MobileNetDetector();
  List<PVDetection> _detections = [];
  double _fps = 0;
  DateTime _lastFrameTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
    // loadLabels();
    // loadModel();
  }

  // late final tfl.Interpreter inter;
  // void loadModel() async {
  //   final modelDelegate = defaultTargetPlatform == TargetPlatform.iOS
  //       ? tfl.GpuDelegate()
  //       : tfl.XNNPackDelegate();
  //   inter = await tfl.Interpreter.fromAsset(
  //     'assets/tflite_model.tflite',
  //     options: tfl.InterpreterOptions()..addDelegate(modelDelegate),
  //   );

  //   final inputTensors = inter.getInputTensors();
  //   final outputTensors = inter.getOutputTensors();
  //   inter.allocateTensors();
  //   log(
  //     '${inputTensors.map((e) => e.toString()).toList()}',
  //     name: 'Model Input Tensors',
  //   );
  //   log(
  //     '${outputTensors.map((e) => e.toString()).toList()}',
  //     name: 'Model Output Tensors',
  //   );
  //   log(
  //     '${outputTensors.map((e) => e.numDimensions()).toList()}',
  //     name: 'Output Tensors Dims',
  //   );
  // }

  // Future<void> loadLabels() async {
  //   final tmp = await rootBundle.loadString('assets/labels.txt');
  //   _labels.addAll(tmp.split('\n'));
  // }

  Future<void> _init() async {
    try {
      cameras = await availableCameras();
      if (cameras.isEmpty) {
        showInSnackBar('No Camera Available');
        return;
      }
      await _detector.load();
      await _initializeCameraController(cameras[0]);
      // ── KEY PART: redirect camera frames to the detector ──────────────────
      controller!.startImageStream((CameraImage frame) async {
        final detections = await _detector.onFrame(frame);

        // FPS counter
        final now = DateTime.now();
        final elapsed = now.difference(_lastFrameTime).inMilliseconds;

        if (!mounted) return;

        setState(() {
          _lastFrameTime = now;
          _detections = detections;
          _fps = 1000 / elapsed;
        });
      });
      setState(() => _isInitialized = true);
    } catch (e) {
      log('Error getting cameras: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          // SizedBox.expand(child: CameraPreview(controller!)),
          SizedBox.expand(
            child: PVDetectionOverlay(
              detections: _detections,
              child: CameraPreview(controller!),
            ),
          ),

          // // FPS counter
          Positioned(
            top: 48,
            right: 16,
            child: PVTelemetryBar(
              fps: _fps.toStringAsFixed(1),
              modelId: 'YOLOV8',
              latencyMs:
                  '${DateTime.now().difference(_lastFrameTime).inMilliseconds} ms',
              isLive: true,
            ),
            //  Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            //   decoration: BoxDecoration(
            //     color: Colors.black54,
            //     borderRadius: BorderRadius.circular(8),
            //   ),
            //   child: Text(
            //     '${_fps.toStringAsFixed(1)} FPS',
            //     style: const TextStyle(color: Colors.white, fontSize: 13),
            //   ),
            // ),
          ),

          // Detection count badge
          Positioned(
            top: 48,
            left: 16,
            child: PVTelemetryChip(
              label: 'Detections',
              value:
                  "${_detections.length} object${_detections.length == 1 ? '' : 's'}",
            ),
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            //   decoration: BoxDecoration(
            //     color: Colors.black54,
            //     borderRadius: BorderRadius.circular(8),
            //   ),
            //   child: Text(
            //     '${_detections.length} object${_detections.length == 1 ? '' : 's'}',
            //     style: const TextStyle(color: Colors.white, fontSize: 13),
            //   ),
            // ),
          ),

          Positioned(
            top: 40,
            right: 16,
            child: Column(
              children: [
                IconButton(
                  icon: Icon(_getFlashIcon()),
                  color: Colors.white,
                  iconSize: 28,
                  onPressed: _toggleFlash,
                ),
                const SizedBox(height: 8),
                IconButton(
                  icon: const Icon(Icons.flip_camera_ios),
                  color: Colors.white,
                  iconSize: 28,
                  onPressed: _switchCamera,
                ),
              ],
            ),
          ),
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
  void dispose() {
    controller?.stopImageStream();
    controller?.dispose();
    _detector.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  IconData _getFlashIcon() {
    switch (flashMode) {
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.torch:
        return Icons.flashlight_on;
      default:
        return Icons.flash_off;
    }
  }

  Future<void> _toggleFlash() async {
    if (controller == null) return;

    final nextMode = switch (flashMode) {
      FlashMode.off => FlashMode.auto,
      FlashMode.auto => FlashMode.always,
      FlashMode.always => FlashMode.torch,
      FlashMode.torch => FlashMode.off,
    };

    try {
      await controller!.setFlashMode(nextMode);
      setState(() => flashMode = nextMode);
    } catch (e) {
      showInSnackBar('Flash error: $e');
    }
  }

  Future<void> _switchCamera() async {
    if (cameras.length < 2) return;

    selectedCameraIdx = (selectedCameraIdx + 1) % cameras.length;
    await controller?.dispose();
    controller = null;
    setState(() {});

    await _initializeCameraController(cameras[selectedCameraIdx]);
  }

  Future<void> _takePicture() async {
    if (controller == null || !controller!.value.isInitialized) return;

    try {
      final file = await controller!.takePicture();
      setState(() => imageFile = file);
      showInSnackBar('Picture saved: ${file.path}');
    } catch (e) {
      showInSnackBar('Capture error: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCameraController(cameraController.description);
    }
  }

  Future<void> _initializeCameraController(
    CameraDescription cameraDescription,
  ) async {
    final cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    controller = cameraController;
    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (cameraController.value.hasError) {
        showInSnackBar(
          'Camera error ${cameraController.value.errorDescription}',
        );
      }
    });

    try {
      await cameraController.initialize();
      await cameraController.setFlashMode(flashMode);
    } on CameraException catch (e) {
      log('${e.code}:\n ${e.description ?? ''}');
      showInSnackBar('Error: ${e.code}\n${e.description}');
    }

    // if (mounted) {
    //   setState(() {});
    // }
  }

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // List<String> getClassification(int noOfDetections, List<int> classes) {
  //   final classifications = <String>[];

  //   final labels = _labels;
  //   final labelLength = (labels.length - 1);

  //   for (int i = 0; i < noOfDetections; i++) {
  //     classifications.add(
  //       classes[i] > labelLength ? '???' : labels[labelLength],
  //     );
  //   }
  //   return classifications;
  // }

  static List<Rect> getLocations(
    List<List<num>> locationsRaw, {
    int modelInputDim = 300,
  }) {
    final locations = <Rect>[];
    final locationsRawLength = locationsRaw.length;

    for (var i = 0; i < locationsRawLength; i++) {
      final raw = locationsRaw[i];

      final yMin = (raw[0] * modelInputDim).toDouble();
      final xMin = (raw[1] * modelInputDim).toDouble();
      final yMax = (raw[2] * modelInputDim).toDouble();
      final xMax = (raw[3] * modelInputDim).toDouble();

      locations.add(Rect.fromLTRB(xMin, yMin, xMax, yMax));
    }
    return locations;
  }

  // AnalyseImageCallBack analyseImage(
  //   img.Image image, {
  //   int modelInputDim = 300,
  // }) {
  //   final resizedImage = img.copyResize(
  //     image,
  //     width: modelInputDim,
  //     height: modelInputDim,
  //   );

  //   // final generatedOutput = _runInference(resizedImage, inter);

  //   final locationsRaw = generatedOutput[0].first as List<List<num>>;
  //   final classessRaw = generatedOutput[1].first as List<num>;
  //   final scores = generatedOutput[2].first as List<num>;
  //   final numberOfDetectionsRaw = generatedOutput[3].first as double;
  //   final locationInRect = getLocations(locationsRaw);
  //   final classes = classessRaw.map(((e) => e.toInt())).toList();
  //   final numberOfDetections = numberOfDetectionsRaw.toInt();

  //   final classification = getClassification(numberOfDetections, classes);

  //   final detectedObjs = <DetectedObject>[];

  //   for (var i = 0; i < numberOfDetections; i++) {
  //     if ((scores[i] > 0.5)) {
  //       detectedObjs.add(
  //         DetectedObject(
  //           label: classification[i],
  //           score: scores[i],
  //           location: locationInRect[i],
  //         ),
  //       );
  //     }
  //   }

  //   return (imageBytes: null, detectedObjs: detectedObjs);
  // }

  static List<List<Object>> _runInference(
    img.Image image,
    tfl.Interpreter interpreter,
  ) {
    final imageMatrix = List.generate(
      image.height,
      (y) => List.generate(image.width, (x) {
        final pixel = image.getPixel(x, y);
        return [pixel.r, pixel.g, pixel.b];
      }),
    );
    final input = [imageMatrix];

    final output = {
      0: [List<List<num>>.filled(10, List<num>.filled(4, 0))],
      1: [List<num>.filled(10, 0)],
      2: [List<num>.filled(10, 0)],
      3: [0.0],
    };

    interpreter.runForMultipleInputs([input], output);
    return output.values.toList();
  }
}

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
