import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show Float32List;
import 'package:flutter/services.dart';
import 'package:flutter_litert/flutter_litert.dart';
import 'package:precision_vision/common/widgets/pv_bounding_box.dart'
    show PVDetection;
import 'package:image/image.dart' as img;

// ─── Data class for a single detection ───────────────────────────────────────
// class PVDetection {
//   final Rect boundingBox; // normalized 0.0–1.0
//   final String label;
//   final double confidence;

//   PVDetection({
//     required this.boundingBox,
//     required this.label,
//     required this.confidence,
//   });
// }

// ─── Main Detector Class ──────────────────────────────────────────────────────
class MobileNetDetector {
  static const int inputSize = 300; // YOLOv8n default input
  static const double confidenceThreshold = 0.4;
  static const double iouThreshold = 0.5;

  late Interpreter _interpreter;
  late IsolateInterpreter _isolateInterpreter;
  late List<String> _labels;
  bool _isProcessing = false;

  // Call this once during app init
  Future<void> load() async {
    _interpreter = await Interpreter.fromAsset('assets/1.tflite');
    // _interpreter = await Interpreter.fromAsset('assets/tflite_model.tflite');


    _interpreter.allocateTensors();
    _isolateInterpreter = await IsolateInterpreter.create(
      address: _interpreter.address,
    );
    // Load COCO labels — one per line in assets/labels.txt
    final labelData = await rootBundle.loadString('assets/labels.txt');
    _labels = labelData.trim().split('\n');
  }

  // ─── STAGE 1: Camera stream callback ───────────────────────────────────────
  // Wire this to: controller.startImageStream(detector.onFrame)
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

  Uint8List _preprocess(CameraImage frame) {
    final rgbImage = _cameraImageToRgb(frame);

    final resized = img.copyResize(
      rgbImage,
      width: inputSize,
      height: inputSize,
    );
    final Uint8List bytes = resized.getBytes();
    final Uint8List intBuffer = Uint8List(inputSize * inputSize * 3);

    // final input = Float32List(1 * inputSize * inputSize * 3);

    int index = 0;

    // for (int y = 0; y < inputSize; y++) {
    //   for (int x = 0; x < inputSize; x++) {
    //     final pixel = resized.getPixel(x, y);

    //     input[index++] = pixel.r / 255.0;
    //     input[index++] = pixel.g / 255.0;
    //     input[index++] = pixel.b / 255.0;
    //   }
    // }

    // return input;

    for (int y = 0; y < inputSize; y++) {
      int srcY = ((y / inputSize) * resized.height).toInt();
      for (int x = 0; x < inputSize; x++) {
        int srcX = ((x / inputSize) * resized.width).toInt();

        int pixelIndex = (srcY * resized.width + srcX) * 4;

        if (pixelIndex + 2 < bytes.length) {
          // Keep the raw integer values between 0 and 255
          intBuffer[index++] = bytes[pixelIndex + 2]; // R
          intBuffer[index++] = bytes[pixelIndex + 1]; // G
          intBuffer[index++] = bytes[pixelIndex]; // B
        } else {
          index += 3;
        }
      }
    }
    return intBuffer;
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
  // YOLOv8n TFLite output shape: [1, 84, 8400]
  //   84 = 4 (cx, cy, w, h) + 80 COCO class scores
  //   8400 = number of anchor predictions
  Future<List<PVDetection>> _runInference(
    Uint8List input,
    // List<List<List<List<double>>>> input,
  ) async {
    // Output buffer shape: [1][84][8400]
    // final outputShape = _interpreter.getOutputTensor(0).shape; // [1, 84, 8400]
    // log(
    //   _interpreter
    //       .getOutputTensors()
    //       .map(((e) => e.toString()))
    //       .toList()
    //       .toString(),
    // );
    // final outputBuffer = List.generate(
    //   1,
    //   (_) => List.generate(
    //     outputShape[1],
    //     (_) => List.filled(outputShape[2], 0.0),
    //   ),
    // );

    try {
      var outputLocationBoxes = List.generate(
        1,
        (_) => List.generate(10, (_) => List.filled(4, 0.0)),
      );
      var outputClassIds = List.generate(1, (_) => List.filled(10, 0.0));
      var outputScores = List.generate(1, (_) => List.filled(10, 0.0));
      var numDetections = List.filled(1, 0.0);

      // var numDetections = _interpreter.getOutputTensor().;

      Map<int, Object> outputBuffers = {
        0: outputLocationBoxes,
        1: outputClassIds,
        2: outputScores,
        3: numDetections,
      };

      var reshapedInput = input.reshape([1, inputSize, inputSize, 3]);
      // _interpreter.run(input, outputBuffer);
      // log(reshapedInput.shape.toString());
      await _isolateInterpreter.runForMultipleInputs([
        reshapedInput,
      ], outputBuffers);

      return await Future.value(
        _parseMobileNetOutput(
          rawBoxes: outputBuffers[0] as List<List<List<double>>>,
          rawClasses: outputBuffers[1] as List<List<double>>,
          rawScores: outputBuffers[2] as List<List<double>>,
          rawNumDetections: outputBuffers[3] as List<double>,
        ),
      );
    } catch (e) {
      rethrow;
    }
    // return _parseOutput(outputBuffer[0]);
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

  List<PVDetection> _parseMobileNetOutput({
    required List<List<List<double>>>
    rawBoxes, // outputBuffers[0] -> Shape: [1, 10, 4]
    required List<List<double>>
    rawClasses, // outputBuffers[1] -> Shape: [1, 10]
    required List<List<double>> rawScores, // outputBuffers[2] -> Shape: [1, 10]
    required List<double> rawNumDetections, // outputBuffers[3] -> Shape: [1]
  }) {
    final List<PVDetection> results = [];

    // MobileNet explicitly tells us exactly how many valid objects were detected
    final int totalDetected = rawNumDetections[0].toInt();

    for (int i = 0; i < totalDetected; i++) {
      final double score = rawScores[0][i];

      // Filter results based on your target confidence threshold
      if (score < confidenceThreshold) continue;

      // MobileNet classes are floats representing the index (e.g., 1.0 = person)
      final int classIndex = rawClasses[0][i].toInt();

      // Safety check to ensure index falls within label boundaries
      if (classIndex < 0 || classIndex >= _labels.length) continue;

      // MobileNet SSD formats bounding box arrays as: [top, left, bottom, right]
      final double top = rawBoxes[0][i][0];
      final double left = rawBoxes[0][i][1];
      final double bottom = rawBoxes[0][i][2];
      final double right = rawBoxes[0][i][3];

      results.add(
        PVDetection(
          boundingBox: Rect.fromLTRB(
            left.clamp(0.0, 1.0),
            top.clamp(0.0, 1.0),
            right.clamp(0.0, 1.0),
            bottom.clamp(0.0, 1.0),
          ),
          label: _labels[classIndex],
          confidence: score,
        ),
      );
    }

    // MobileNet handles anchor overlapping natively in its internal post-processing.
    // You can safely return the results directly without processing a heavy custom NMS!
    return results;
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
    _interpreter.close();
    _isolateInterpreter.close();
  }
}





// import 'dart:isolate';
// import 'package:camera/camera.dart';
// import 'package:precision_vision/camera_stream/application/yolo_inference_worker.dart';
// import 'package:precision_vision/common/widgets/pv_bounding_box.dart';
// class YoloDetector {
//   Isolate? _isolate;
//   SendPort? _sendPort;
//   bool _isProcessing = false;
//   /// Call once during app initialization
//   Future<void> load() async {
//     final receivePort = ReceivePort();
//     _isolate = await Isolate.spawn(
//       yoloInferenceEntry,
//       receivePort.sendPort,
//       debugName: 'YoloWorker',
//     );
//     _sendPort = await receivePort.first as SendPort;
//   }
//   /// Call from camera stream: controller.startImageStream(detector.onFrame)
//   Future<List<PVDetection>> onFrame(CameraImage frame) async {
//     if (_isProcessing || _sendPort == null) return [];
//     _isProcessing = true;
//     try {
//       final response = ReceivePort();
//       final request = InferenceRequest(
//         width: frame.width,
//         height: frame.height,
//         formatGroup: frame.format.group == ImageFormatGroup.yuv420 ? 0 : 1,
//         planes: frame.planes.map((p) => p.bytes).toList(),
//         bytesPerRow: frame.planes.map((p) => p.bytesPerRow).toList(),
//         replyPort: response.sendPort,
//       );
//       _sendPort!.send(request);
//       final result = await response.first as List<PVDetection>;
//       return result;
//     } finally {
//       _isProcessing = false;
//     }
//   }
//   void dispose() {
//     _isolate?.kill(priority: Isolate.immediate);
//     _isolate = null;
//     _sendPort = null;
//   }
// }