import 'package:camera/camera.dart' show CameraImage;
import 'package:precision_vision/common/widgets/pv_bounding_box.dart'
    show PVDetection;

abstract class Detector {
  Future<void> load();
  abstract double confidenceThreshold;
  Future<List<PVDetection>> onFrame(CameraImage frame,{double confidenceThreshold });

  // Detector copyWith({double? confidenceThreshold});
}
