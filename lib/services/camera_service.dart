import 'package:camera/camera.dart';
import 'dart:io';

class CameraService {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;

  // Initialize the camera
  Future<void> initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras!.first,
          ResolutionPreset.high,
        );
        await _cameraController!.initialize();
      }
    } catch (e) {
      print("Camera initialization error: $e");
    }
  }

  // Capture an image
  Future<File?> captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      print("Camera not initialized");
      return null;
    }

    try {
      final XFile file = await _cameraController!.takePicture();
      return File(file.path);
    } catch (e) {
      print("Error capturing image: $e");
      return null;
    }
  }

  // Dispose of the camera controller
  void disposeCamera() {
    _cameraController?.dispose();
  }

  // Get the camera controller
  CameraController? get cameraController => _cameraController;
}
