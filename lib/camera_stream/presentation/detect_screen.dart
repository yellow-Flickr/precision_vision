import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:precision_vision/settings/data/mobile_net_detector.dart';
import 'package:precision_vision/common/widgets/pv_bounding_box.dart'
    show PVDetection;

// ─── 1. CustomPainter — draws boxes over the camera preview ──────────────────
class BoundingBoxPainter extends CustomPainter {
  final List<PVDetection> detections;
  final Size imageSize; // actual camera frame size
  final Size screenSize; // widget render size

  BoundingBoxPainter({
    required this.detections,
    required this.imageSize,
    required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final boxPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = Colors.lime;

    for (final det in detections) {
      // Bounding box coords are normalized (0–1), scale to widget pixels
      final rect = Rect.fromLTRB(
        det.boundingBox.left * size.width,
        det.boundingBox.top * size.height,
        det.boundingBox.right * size.width,
        det.boundingBox.bottom * size.height,
      );

      canvas.drawRect(rect, boxPaint);

      // Label background
      final label =
          '${det.label} ${(det.confidence * 100).toStringAsFixed(0)}%';
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final labelBg = Rect.fromLTWH(
        rect.left,
        rect.top - 18,
        textPainter.width + 6,
        18,
      );
      canvas.drawRect(labelBg, Paint()..color = Colors.lime);
      textPainter.paint(canvas, Offset(rect.left + 3, rect.top - 17));
    }
  }

  @override
  bool shouldRepaint(BoundingBoxPainter old) => old.detections != detections;
}

// ─── 2. Main Widget — wires camera + detector together ───────────────────────
class DetectorScreen extends StatefulWidget {
  const DetectorScreen({super.key});

  @override
  State<DetectorScreen> createState() => _DetectorScreenState();
}

class _DetectorScreenState extends State<DetectorScreen> {
  CameraController? _cameraController;
  final MobileNetDetector _detector = MobileNetDetector();
  List<PVDetection> _detections = [];
  bool _ready = false;
  double _fps = 0;
  DateTime _lastFrameTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _detector.load();

    final cameras = await availableCameras();
    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset
          .medium, // use medium — high will drop frames on older phones
      enableAudio: false,
      imageFormatGroup:
          ImageFormatGroup.yuv420, // yuv420 on Android; bgra8888 auto on iOS
    );

    await _cameraController!.initialize();

    // ── KEY PART: redirect camera frames to the detector ──────────────────
    _cameraController!.startImageStream((CameraImage frame) async {
      final detections = await _detector.onFrame(frame);

      // FPS counter
      final now = DateTime.now();
      final elapsed = now.difference(_lastFrameTime).inMilliseconds;
      _lastFrameTime = now;

      if (mounted) {
        setState(() {
          _detections = detections;
          _fps = 1000 / elapsed;
        });
      }
    });

    setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview fills screen
          SizedBox.expand(child: CameraPreview(_cameraController!)),

          // Bounding box overlay — must match preview dimensions
          SizedBox.expand(
            child: CustomPaint(
              painter: BoundingBoxPainter(
                detections: _detections,
                imageSize: Size(
                  _cameraController!.value.previewSize!.height,
                  _cameraController!.value.previewSize!.width,
                ),
                screenSize: MediaQuery.of(context).size,
              ),
            ),
          ),

          // FPS counter
          Positioned(
            top: 48,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_fps.toStringAsFixed(1)} FPS',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ),

          // Detection count badge
          Positioned(
            top: 48,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_detections.length} object${_detections.length == 1 ? '' : 's'}',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    _detector.dispose();
    super.dispose();
  }
}
