import 'package:camera/camera.dart' show CameraImage;
import 'package:precision_vision/common/widgets/pv_bounding_box.dart'
    show PVDetection;

abstract class Detector {
  Future<void> load();
  double confidenceThreshold =0.4;
  Future<List<PVDetection>> onFrame(CameraImage frame);
}
