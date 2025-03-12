import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  late FaceDetector _faceDetector;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(enableContours: true),
    );
  }

  // Initialize Camera
  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _showError("No cameras available.");
        return;
      }

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high,
      );

      await _cameraController!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      _showError("Error initializing camera: $e");
    }
  }

  // Capture Image and Analyze
  Future<void> _captureAndAnalyze() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        isProcessing) {
      return;
    }

    setState(() => isProcessing = true);

    try {
      final XFile imageFile = await _cameraController!.takePicture();
      final result = await _analyzeImage(File(imageFile.path));
      _showResultDialog(result);
    } catch (e) {
      _showError("Error capturing image: $e");
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }
  }

  // Face Detection Using ML Kit
  Future<String> _analyzeImage(File file) async {
    final inputImage = InputImage.fromFile(file);
    final faces = await _faceDetector.processImage(inputImage);

    return faces.isNotEmpty ? "Face detected!" : "No face detected.";
  }

  // Display Result Dialog
  void _showResultDialog(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Scan Result"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  // Error Handling
  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Face Scanner")),
      body: Column(
        children: [
          Expanded(
            child:
                _cameraController != null &&
                        _cameraController!.value.isInitialized
                    ? CameraPreview(_cameraController!)
                    : const Center(child: CircularProgressIndicator()),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _captureAndAnalyze,
              child: const Text("Scan Face"),
            ),
          ),
        ],
      ),
    );
  }
}
