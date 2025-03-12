import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  String skinType = "Not Analyzed";
  bool isLoading = false;

  // Pick Image (Gallery/Camera)
  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });

      // Run AutoML Analysis
      await analyzeImage(_selectedImage!);
    }
  }

  // Run Firebase AutoML Model
  Future<void> analyzeImage(File image) async {
    setState(() {
      isLoading = true;
    });

    try {
      final model = await FirebaseModelDownloader.instance.getModel(
        "skin_scan_model", // Ensure the model name is correct
        FirebaseModelDownloadType.localModel,
      );

      // Simulating model inference (Replace with real MLKit API when available)
      await Future.delayed(Duration(seconds: 2));

      setState(() {
        skinType = "Oily Skin"; // Example result
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Analysis Complete: $skinType")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Skin Scan")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _selectedImage == null
                ? const Text("No Image Selected")
                : Image.file(_selectedImage!, height: 200),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.camera),
                  onPressed: () => pickImage(ImageSource.camera),
                ),
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: () => pickImage(ImageSource.gallery),
                ),
              ],
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : Text(
                  "Detected: $skinType",
                  style: const TextStyle(fontSize: 18),
                ),
          ],
        ),
      ),
    );
  }
}
