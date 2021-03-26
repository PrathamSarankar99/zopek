import 'package:camera/camera.dart';

class CameraConfigurations {
  static List<CameraDescription> cameraDescriptionList;
  static CameraDescription firstCamera;

  static initialize() async {
    cameraDescriptionList = await availableCameras();
  }
}
