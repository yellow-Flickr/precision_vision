import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_litert/flutter_litert.dart';
import 'package:image/image.dart' as img;
import 'package:precision_vision/common/widgets/pv_bounding_box.dart';
import 'package:precision_vision/settings/data/detector.dart';

class Yolov8Detector extends Detector {
  static const int inputSize =
      640; // YOLOv8n default input (common export size)
  static const double iouThreshold = 0.5;

  late Interpreter _interpreter;
  late IsolateInterpreter _isolateInterpreter;
  late List<String> _labels;
  bool _loaded = false;

  // Call this once during app init. Safe to call multiple times.
  @override
  Future<void> load() async {
    if (_loaded) return;
    _interpreter = await Interpreter.fromAsset('assets/tflite_model.tflite');

    _interpreter.allocateTensors();
    _isolateInterpreter = await IsolateInterpreter.create(
      address: _interpreter.address,
    );
    // Load COCO labels — one per line in assets/labels.txt
    final labelData = await rootBundle.loadString('assets/labels.txt');
    _labels = labelData.trim().split('\n');
    _loaded = true;
  }

  // ─── STAGE 1: Camera stream callback ───────────────────────────────────────
  // Wire this to: controller.startImageStream(detector.onFrame)
  @override
  Future<List<PVDetection>> onFrame(CameraImage frame) async {
    // if (_isProcessing) return []; // drop frame if busy
    // _isProcessing = true;
    try {
      final input = _preprocess(frame);
      final detections = await _runInference(input);
      return detections;
    } catch (e, s) {
      log('Inference Error: ${e.toString()}', stackTrace: s);
      rethrow;
    } finally {
      // _isProcessing = false;
    }
  }

  // ─── STAGE 2: CameraImage → Float32List [1, 300, 300, 3] ──────────────────
  // List<List<List<List<double>>>> _preprocess(CameraImage frame) {
  //   // Convert platform-specific format to an img.Image (RGB)
  //   img.Image rgbImage = _cameraImageToRgb(frame);

  //   // Resize to model input size
  //   final resized = img.copyResize(
  //     rgbImage,
  //     width: inputSize,
  //     height: inputSize,
  //   );

  //   // Build the [1, 640, 640, 3] tensor, normalized to [0.0, 1.0]
  //   return List.generate(
  //     1,
  //     (_) => List.generate(
  //       inputSize,
  //       (y) => List.generate(inputSize, (x) {
  //         final pixel = resized.getPixel(x, y);
  //         return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
  //       }),
  //     ),
  //   );
  // }

  /// CameraImage → normalized [1, 640, 640, 3] float tensor (0.0–1.0)
  /// Suitable for typical float32 YOLOv8 exports.
  List<List<List<List<double>>>> _preprocess(CameraImage frame) {
    final rgbImage = _cameraImageToRgb(frame);

    final resized = img.copyResize(
      rgbImage,
      width: inputSize,
      height: inputSize,
    );

    return List.generate(1, (_) {
      return List.generate(inputSize, (y) {
        return List.generate(inputSize, (x) {
          final pixel = resized.getPixel(x, y);
          return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
        });
      });
    });
  }

  img.Image _cameraImageToRgb(CameraImage frame) {
    if (frame.format.group == ImageFormatGroup.yuv420) {
      return _yuv420ToRgb(frame);
    } else if (frame.format.group == ImageFormatGroup.bgra8888) {
      return _bgra8888ToRgb(frame);
    }
    throw Exception('Unsupported image format: ${frame.format.group}');
  }

  img.Image _yuv420ToRgb(CameraImage frame) {
    final int width = frame.width;
    final int height = frame.height;
    final Uint8List yPlane = frame.planes[0].bytes;
    final Uint8List uPlane = frame.planes[1].bytes;
    final Uint8List vPlane = frame.planes[2].bytes;
    final int uvRowStride = frame.planes[1].bytesPerRow;
    final int uvPixelStride = frame.planes[1].bytesPerPixel!;

    final image = img.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int yIndex = y * frame.planes[0].bytesPerRow + x;
        final int uvIndex = (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;

        final int yVal = yPlane[yIndex];
        final int uVal = uPlane[uvIndex] - 128;
        final int vVal = vPlane[uvIndex] - 128;

        final int r = (yVal + 1.402 * vVal).clamp(0, 255).toInt();
        final int g = (yVal - 0.344136 * uVal - 0.714136 * vVal)
            .clamp(0, 255)
            .toInt();
        final int b = (yVal + 1.772 * uVal).clamp(0, 255).toInt();

        image.setPixelRgb(x, y, r, g, b);
      }
    }
    return image;
  }

  img.Image _bgra8888ToRgb(CameraImage frame) {
    final image = img.Image(width: frame.width, height: frame.height);
    final bytes = frame.planes[0].bytes;
    final bytesPerRow = frame.planes[0].bytesPerRow;

    for (int y = 0; y < frame.height; y++) {
      for (int x = 0; x < frame.width; x++) {
        final offset = y * bytesPerRow + x * 4;

        image.setPixelRgb(
          x,
          y,
          bytes[offset + 2],
          bytes[offset + 1],
          bytes[offset],
        );
      }
    }

    return image;
  }

  // ─── STAGE 3: Run model, parse YOLOv8 output ──────────────────────────────
  // YOLOv8n TFLite output shape (typical export): [1, 84, 8400]
  //   84 = 4 (cx, cy, w, h) + 80 COCO class scores
  //   8400 = number of predictions
  Future<List<PVDetection>> _runInference(
    List<List<List<List<double>>>> input,
  ) async {
    // Prepare output buffer for [1, 84, 8400]
    final output = List.generate(
      1,
      (_) => List.generate(84, (_) => List.filled(8400, 0.0)),
    );

    try {
      await _isolateInterpreter.runForMultipleInputs([input], {0: output});

      // The YOLO-specific parser that correctly handles [84, 8400] layout
      return _parseOutput(output[0]);
    } catch (e, s) {
      log('YOLOv8 inference error: $e', stackTrace: s);
      rethrow;
    }
  }

  List<PVDetection> _parseOutput(List<List<double>> raw) {
    final int numDetections = raw[0].length; // 8400
    final List<PVDetection> results = [];

    for (int i = 0; i < numDetections; i++) {
      // Box coords (center-x, center-y, width, height) — all normalized 0–1
      final double cx = raw[0][i];
      final double cy = raw[1][i];
      final double w = raw[2][i];
      final double h = raw[3][i];

      // Class scores start at index 4
      double bestScore = 0.0;
      int bestClass = 0;
      for (int c = 0; c < _labels.length; c++) {
        final score = raw[4 + c][i];
        if (score > bestScore) {
          bestScore = score;
          bestClass = c;
        }
      }

      if (bestScore < confidenceThreshold) continue;

      // Convert cx,cy,w,h → left,top,right,bottom
      results.add(
        PVDetection(
          boundingBox: Rect.fromLTRB(
            (cx - w / 2).clamp(0.0, 1.0),
            (cy - h / 2).clamp(0.0, 1.0),
            (cx + w / 2).clamp(0.0, 1.0),
            (cy + h / 2).clamp(0.0, 1.0),
          ),
          label: _labels[bestClass],
          confidence: bestScore,
        ),
      );
    }

    return _nonMaxSuppression(results);
  }

  // Simple NMS — removes overlapping boxes for the same class
  List<PVDetection> _nonMaxSuppression(List<PVDetection> detections) {
    detections.sort((a, b) => b.confidence.compareTo(a.confidence));
    final List<PVDetection> kept = [];

    for (final det in detections) {
      bool suppressed = false;
      for (final keep in kept) {
        if (keep.label == det.label &&
            _iou(keep.boundingBox, det.boundingBox) > iouThreshold) {
          suppressed = true;
          break;
        }
      }
      if (!suppressed) kept.add(det);
    }
    return kept;
  }

  double _iou(Rect a, Rect b) {
    final intersection = a.intersect(b);
    if (intersection.isEmpty) return 0.0;
    final intersectArea = intersection.width * intersection.height;
    final unionArea = a.width * a.height + b.width * b.height - intersectArea;
    return intersectArea / unionArea;
  }

  void dispose() {
    if (_loaded) {
      _interpreter.close();
      _isolateInterpreter.close();
    }
    _loaded = false;
  }
}

// import 'dart:isolate';
// import 'package:flutter/services.dart';
// import 'package:flutter_litert/flutter_litert.dart';
// import 'package:image/image.dart' as img;
// import 'package:precision_vision/common/widgets/pv_bounding_box.dart';

// // ──────────────────────────────────────────────────────────────────────────────
// // Message sent from main isolate to worker
// // ──────────────────────────────────────────────────────────────────────────────
// class InferenceRequest {
//   final int width;
//   final int height;
//   final int formatGroup; // 0 = yuv420, 1 = bgra8888
//   final List<Uint8List> planes;
//   final List<int> bytesPerRow;
//   final SendPort replyPort;
//   InferenceRequest({
//     required this.width,
//     required this.height,
//     required this.formatGroup,
//     required this.planes,
//     required this.bytesPerRow,
//     required this.replyPort,
//   });
// }

// // ──────────────────────────────────────────────────────────────────────────────
// // Entry point that runs inside the worker isolate
// // ──────────────────────────────────────────────────────────────────────────────
// Future<void> yoloInferenceEntry(SendPort mainSendPort) async {
//   final receivePort = ReceivePort();
//   mainSendPort.send(receivePort.sendPort);
//   late Interpreter interpreter;
//   late List<String> labels;
//   // Load model and labels inside the isolate
//   interpreter = await Interpreter.fromAsset('assets/tflite_model.tflite');
//   final labelData = await rootBundle.loadString('assets/labels.txt');
//   labels = labelData.trim().split('\n');
//   await for (final message in receivePort) {
//     if (message is InferenceRequest) {
//       final result = _processFrame(message, interpreter, labels);
//       message.replyPort.send(result);
//     }
//   }
// }

// // ──────────────────────────────────────────────────────────────────────────────
// // Core processing (preprocess + inference + NMS)
// // ──────────────────────────────────────────────────────────────────────────────
// List<PVDetection> _processFrame(
//   InferenceRequest req,
//   Interpreter interpreter,
//   List<String> labels,
// ) {
//   // Rebuild img.Image from serialized planes
//   final rgbImage = _reconstructImage(req);
//   // Resize to model input
//   final resized = img.copyResize(rgbImage, width: 640, height: 640);
//   // Build normalized input tensor [1, 640, 640, 3]
//   final input = List.generate(
//     1,
//     (_) => List.generate(
//       640,
//       (y) => List.generate(640, (x) {
//         final p = resized.getPixel(x, y);
//         return [p.r / 255.0, p.g / 255.0, p.b / 255.0];
//       }),
//     ),
//   );
//   // Prepare output buffer [1, 84, 8400]
//   final output = List.generate(
//     1,
//     (_) => List.generate(84, (_) => List.filled(8400, 0.0)),
//   );
//   interpreter.run(input, output);
//   return _parseYoloOutput(output[0], labels);
// }

// img.Image _reconstructImage(InferenceRequest req) {
//   final image = img.Image(width: req.width, height: req.height);
//   if (req.formatGroup == 0) {
//     // YUV420
//     final y = req.planes[0];
//     final u = req.planes[1];
//     final v = req.planes[2];
//     final uvRowStride = req.bytesPerRow[1];
//     final uvPixelStride = 2; // typical for Android
//     for (int yPos = 0; yPos < req.height; yPos++) {
//       for (int xPos = 0; xPos < req.width; xPos++) {
//         final yIndex = yPos * req.bytesPerRow[0] + xPos;
//         final uvIndex = (yPos ~/ 2) * uvRowStride + (xPos ~/ 2) * uvPixelStride;
//         final yVal = y[yIndex];
//         final uVal = u[uvIndex] - 128;
//         final vVal = v[uvIndex] - 128;
//         final r = (yVal + 1.402 * vVal).clamp(0, 255).toInt();
//         final g = (yVal - 0.344136 * uVal - 0.714136 * vVal)
//             .clamp(0, 255)
//             .toInt();
//         final b = (yVal + 1.772 * uVal).clamp(0, 255).toInt();
//         image.setPixelRgb(xPos, yPos, r, g, b);
//       }
//     }
//   } else {
//     // BGRA8888
//     final bytes = req.planes[0];
//     for (int i = 0; i < bytes.length; i += 4) {
//       final x = (i ~/ 4) % req.width;
//       final y = (i ~/ 4) ~/ req.width;
//       image.setPixelRgb(x, y, bytes[i + 2], bytes[i + 1], bytes[i]);
//     }
//   }
//   return image;
// }

// List<PVDetection> _parseYoloOutput(
//   List<List<double>> raw,
//   List<String> labels,
// ) {
//   const confidenceThreshold = 0.4;
//   const iouThreshold = 0.5;
//   final numDetections = raw[0].length;
//   final results = <PVDetection>[];
//   for (int i = 0; i < numDetections; i++) {
//     final cx = raw[0][i];
//     final cy = raw[1][i];
//     final w = raw[2][i];
//     final h = raw[3][i];
//     double bestScore = 0.0;
//     int bestClass = 0;
//     for (int c = 0; c < labels.length; c++) {
//       final score = raw[4 + c][i];
//       if (score > bestScore) {
//         bestScore = score;
//         bestClass = c;
//       }
//     }
//     if (bestScore < confidenceThreshold) continue;
//     results.add(
//       PVDetection(
//         boundingBox: Rect.fromLTRB(
//           (cx - w / 2).clamp(0.0, 1.0),
//           (cy - h / 2).clamp(0.0, 1.0),
//           (cx + w / 2).clamp(0.0, 1.0),
//           (cy + h / 2).clamp(0.0, 1.0),
//         ),
//         label: labels[bestClass],
//         confidence: bestScore,
//       ),
//     );
//   }
//   // Simple NMS
//   results.sort((a, b) => b.confidence.compareTo(a.confidence));
//   final kept = <PVDetection>[];
//   for (final det in results) {
//     bool suppressed = false;
//     for (final keep in kept) {
//       if (keep.label == det.label &&
//           _iou(keep.boundingBox, det.boundingBox) > iouThreshold) {
//         suppressed = true;
//         break;
//       }
//     }
//     if (!suppressed) kept.add(det);
//   }
//   return kept;
// }

// double _iou(Rect a, Rect b) {
//   final inter = a.intersect(b);
//   if (inter.isEmpty) return 0.0;
//   final interArea = inter.width * inter.height;
//   final unionArea = a.width * a.height + b.width * b.height - interArea;
//   return interArea / unionArea;
// }

// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:flutter_litert/flutter_litert.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   final cameras = await availableCameras();
//   runApp(MaterialApp(home: LiveObjectDetectionScreen(cameras: cameras)));
// }

// class LiveObjectDetectionScreen extends StatefulWidget {
//   final List<CameraDescription> cameras;
//   const LiveObjectDetectionScreen({Key? key, required this.cameras}) : super(key: key);

//   @override
//   State<LiveObjectDetectionScreen> createState() => _LiveObjectDetectionScreenState();
// }

// class _LiveObjectDetectionScreenState extends State<LiveObjectDetectionScreen> {
//   CameraController? _cameraController;
//   Interpreter? _rootInterpreter;
//   // IsolateInterpreter? _isolateInterpreter;
//   bool _isProcessing = false;

//   // Example output buffers for a typical SSD MobileNet model
//   // Shape structure varies by model configuration (e.g., TFLite SSD / LiteRT Object Detection)
//   List<dynamic> _outputs = [];

//   // Expected model input dimensions
//   final int _inputWidth = 300;
//   final int _inputHeight = 300;

//   @override
//   void initState() {
//     super.initState();
//     _initializeDetector();
//   }

//   Future<void> _initializeDetector() async {
//     // 1. Load the primary model interpreter from assets
//     _rootInterpreter = await Interpreter.fromAsset('assets/mobilenet_ssd.tflite');
//     _rootInterpreter!.allocateTensors();

//     // 2. Create the off-thread IsolateInterpreter using the main interpreter's memory address
//     _isolateInterpreter = await IsolateInterpreter.create(address: _rootInterpreter!.address);

//     // 3. Setup Camera
//     _cameraController = CameraController(
//       widget.cameras[0],
//       ResolutionPreset.medium,
//       enableAudio: false,
//       imageFormatGroup: ImageFormatGroup.bgra8888, // Cleaner format to parse manually than YUV
//     );

//     await _cameraController!.initialize();

//     // 4. Begin processing frames from the live camera stream
//     _cameraController!.startImageStream((CameraImage image) {
//       if (!_isProcessing) {
//         _processCameraImage(image);
//       }
//     });

//     if (mounted) setState(() {});
//   }

//   Future<void> _processCameraImage(CameraImage image) async {
//     _isProcessing = true;

//     try {
//       // Step A: Convert raw camera format into an RGB pixel matrix matching model dimensions
//       // Running this transformation step locally on the main thread is fine for fast loops,
//       // but if performance chokes, this can also be packaged into a separate Dart Isolate.
//       var inputMatrix = _convertCameraImageToRGB(image, _inputWidth, _inputHeight);

//       // Step B: Match your exact model configuration outputs structure
//       // Example allocation for standard SSD Mobilenet:
//       // Location Boxes, Class IDs, Scores, and Number of Detections.
//       var outputLocationBoxes = List.generate(1, (_) => List.generate(10, (_) => List.filled(4, 0.0)));
//       var outputClassIds = List.generate(1, (_) => List.filled(10, 0.0));
//       var outputScores = List.generate(1, (_) => List.filled(10, 0.0));
//       var numDetections = List.filled(1, 0.0);

//       Map<int, dynamic> outputBuffers = {
//         0: outputLocationBoxes,
//         1: outputClassIds,
//         2: outputScores,
//         3: numDetections,
//       };

//       // Step C: Trigger asynchronous off-thread execution inside the IsolateInterpreter
//       await _isolateInterpreter!.runForMultipleInputs([inputMatrix], outputBuffers);

//       // Step D: Extract findings safely on completion
//       setState(() {
//         // Handle bounding box coordinates and display logic here
//         // e.g., outputBuffers[0] contains locations, outputBuffers[2] contains probabilities
//       });

//     } catch (e) {
//       debugPrint("Inference Error: $e");
//     } finally {
//       _isProcessing = false;
//     }
//   }

//   /// Manually extracts BGRA8888 matrix details down to an normalized [1, H, W, 3] Float32 array
//   /// without bringing in external dependencies like the 'image' package.
//   List<dynamic> _convertCameraImageToRGB(CameraImage image, int targetW, int targetH) {
//     final Uint8List bytes = image.planes[0].bytes;
//     final int srcW = image.width;
//     final int srcH = image.height;

//     // Output dynamic array structure structured as: [1, targetH, targetW, 3]
//     var outBuffer = List.generate(
//       1, (_) => List.generate(
//         targetH, (_) => List.generate(
//           targetW, (_) => List.filled(3, 0.0),
//         ),
//       ),
//     );

//     // Simple Nearest-Neighbor scaling calculation to fit camera output size into target ML dimension
//     for (int y = 0; y < targetH; y++) {
//       int srcY = ((y / targetH) * srcH).toInt();
//       for (int x = 0; x < targetW; x++) {
//         int srcX = ((x / targetW) * srcW).toInt();

//         // Target index position in BGRA array
//         int pixelIndex = (srcY * srcW + srcX) * 4;

//         if (pixelIndex + 2 < bytes.length) {
//           // Normalize bytes to floats between [0.0, 1.0] or [-1.0, 1.0] depending on your model requirements
//           double b = bytes[pixelIndex] / 255.0;
//           double g = bytes[pixelIndex + 1] / 255.0;
//           double r = bytes[pixelIndex + 2] / 255.0;

//           outBuffer[0][y][x][0] = r;
//           outBuffer[0][y][x][1] = g;
//           outBuffer[0][y][x][2] = b;
//         }
//       }
//     }
//     return outBuffer;
//   }

//   @override
//   void dispose() {
//     _cameraController?.dispose();
//     _isolateInterpreter?.close();
//     _rootInterpreter?.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_cameraController == null || !_cameraController!.value.isInitialized) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }
//     return Scaffold(
//       appBar: AppBar(title: const Text("LiteRT Background Live Detection")),
//       body: Stack(
//         children: [
//           CameraPreview(_cameraController!),
//           // Overlay widgets/CustomPainters can be dropped here to draw bounding boxes dynamically
//           // derived from the data captured inside `outputBuffers`.
//         ],
//       ),
//     );
//   }
// }
