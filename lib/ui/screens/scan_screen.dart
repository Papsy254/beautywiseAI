import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart'; // Import google_ml_kit package
import 'package:beautywise_ai/ui/screens/recommendations_screen.dart'; // Import the recommendations screen

class ScanScreen extends StatefulWidget {
  final File imageFile;

  const ScanScreen({super.key, required this.imageFile});

  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  late List<Face> faces;
  late FaceDetector faceDetector;
  String skinType = 'Not Analyzed';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    faceDetector = GoogleMlKit.vision.faceDetector();
    detectFaces();
  }

  // Detect faces in the image
  Future<void> detectFaces() async {
    final inputImage = InputImage.fromFile(widget.imageFile);
    final List<Face> detectedFaces = await faceDetector.processImage(
      inputImage,
    );

    setState(() {
      faces = detectedFaces;
      isLoading = false; // Face detection is complete
    });

    // After detection, send the result to skin type analysis (further processing)
    analyzeSkinType();
  }

  // Analyze skin type based on detected features (using custom rules or a simple model)
  void analyzeSkinType() {
    if (faces.isNotEmpty) {
      // Simulate a skin type result based on the number of faces detected
      skinType =
          faces.length == 1
              ? 'Oily Skin'
              : 'Normal Skin'; // Example classification
    }

    // Navigate to the recommendations screen and pass the skin type
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => RecommendationResultScreen(
              faceTypeIndex: skinType == 'Oily Skin' ? 0 : 3,
            ),
      ),
    );
  }

  @override
  void dispose() {
    faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scan Results")),
      body: Center(
        child:
            isLoading
                ? CircularProgressIndicator() // Show loading indicator while face detection happens
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.file(widget.imageFile), // Display the image
                    SizedBox(height: 20),
                    Text(
                      "Detected ${faces.length} face(s)",
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Skin Type: $skinType",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
