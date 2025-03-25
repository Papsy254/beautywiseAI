import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart'; // Google ML Kit for face detection
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth for token handling
import 'package:beautywise_ai/ui/screens/scan_results_screen.dart'; // Import the ScanResultsScreen

class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  File? _selectedImage;
  late FaceDetector faceDetector;
  bool isLoading = false;
  String skinType = "No analysis yet";

  @override
  void initState() {
    super.initState();
    faceDetector = GoogleMlKit.vision.faceDetector();
  }

  // **Pick Image from Camera or Gallery**
  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        isLoading = true;
      });

      detectFaces(_selectedImage!);
    }
  }

  // **Detect faces in the image**
  Future<void> detectFaces(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final List<Face> detectedFaces = await faceDetector.processImage(
      inputImage,
    );

    if (detectedFaces.isNotEmpty) {
      // **Call API to predict skin type**
      await predictSkinType(imageFile);
    } else {
      setState(() {
        skinType = "No face detected";
        isLoading = false;
      });
    }
  }

  // **Send image to API for skin type prediction**
  Future<void> predictSkinType(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(bytes);

      // Get Firebase Auth token
      String? token = await FirebaseAuth.instance.currentUser?.getIdToken();

      final response = await http.post(
        Uri.parse(
          'https://us-central1-aiplatform.googleapis.com/v1/projects/beautywise-ai/locations/us-central1/endpoints/6190555029099773952:predict',
        ),
        headers: {
          "Authorization": "Bearer $token", // Automatically refreshes token
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "instances": [
            {
              "image": {"b64": base64Image},
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          skinType = data['predictions'][0]['skinType'] ?? "Unknown";
          isLoading = false;
        });

        // Navigate to ScanResultsScreen with the skinType
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScanResultsScreen(skinType: skinType),
          ),
        );
      } else {
        setState(() {
          skinType = "Analysis failed";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        skinType = "Error occurred";
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Your Skin")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _selectedImage != null
              ? Image.file(_selectedImage!, height: 200)
              : Text("No Image Selected"),
          SizedBox(height: 20),
          isLoading
              ? CircularProgressIndicator()
              : Text(
                "Skin Type: $skinType",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => pickImage(ImageSource.camera),
                child: Text("Take Photo"),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => pickImage(ImageSource.gallery),
                child: Text("Choose from Gallery"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
