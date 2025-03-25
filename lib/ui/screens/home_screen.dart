import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  User? user;
  String userName = "Loading...";
  File? _selectedImage;
  Uint8List? _webImage;
  String detectedSkinType = "";
  double confidenceScore = 0.0;
  List<String> recommendations = [];

  @override
  void initState() {
    super.initState();
    checkUserLogin();
  }

  void checkUserLogin() async {
    user = _auth.currentUser;
    if (user == null) {
      Future.microtask(() {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      });
    } else {
      getUserData();
    }
  }

  Future<void> getUserData() async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection("users").doc(user!.uid).get();
      if (userDoc.exists) {
        setState(() {
          userName = userDoc["name"] ?? "User";
        });
      }
    } catch (e) {
      setState(() {
        userName = "User";
      });
    }
  }

  void logout() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Future<void> pickImage() async {
    if (kIsWeb) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null) {
        setState(() {
          _webImage = result.files.first.bytes;
          _selectedImage = null;
        });
      }
    } else {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _webImage = null;
        });
      }
    }
  }

  Future<void> captureImage() async {
    if (kIsWeb) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null) {
        setState(() {
          _webImage = result.files.first.bytes;
          _selectedImage = null;
        });
      }
    } else {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _webImage = null;
        });
      }
    }
  }

  Future<void> scanImage() async {
    if (_selectedImage == null && _webImage == null) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text("Error"),
              content: const Text("No image uploaded. Please upload an image."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
      );
      return;
    }

    try {
      var result = await getSkinTypeFromAIModel(); // AI model call
      setState(() {
        detectedSkinType =
            result['skinType']; // The skin type returned by the AI model
        confidenceScore =
            result['confidenceScore']; // The confidence score returned by the AI model
        recommendations = getRecommendations(
          detectedSkinType,
        ); // Fetch recommendations based on detected skin type
      });

      showResultsDialog();
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<Map<String, dynamic>> getSkinTypeFromAIModel() async {
    // Simulate an AI model result
    return {'skinType': 'Oily', 'confidenceScore': 92.5};
  }

  List<String> getRecommendations(String skinType) {
    if (skinType == 'Oily') {
      return [
        "Use an oil-free moisturizer",
        "Apply a clay mask weekly",
        "Avoid harsh scrubs",
        "Drink more water",
      ];
    } else if (skinType == 'Dry') {
      return [
        "Use a rich, hydrating moisturizer",
        "Avoid hot water on your face",
        "Use a gentle cleanser",
        "Drink plenty of water to hydrate your skin",
      ];
    } else if (skinType == 'Sensitive') {
      return [
        "Use fragrance-free, gentle products",
        "Avoid harsh exfoliants",
        "Limit sun exposure",
        "Use minimal products to avoid irritation",
      ];
    } else if (skinType == 'Normal') {
      return [
        "Maintain a balanced skincare routine",
        "Use sunscreen daily",
        "Stay hydrated",
        "Consider using a mild cleanser",
      ];
    } else {
      return ["No recommendations available for this skin type."];
    }
  }

  void showResultsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Scan Results"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Skin Type: $detectedSkinType",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Text("Confidence Score: $confidenceScore%"),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      recommendations.map((rec) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(rec),
                          ),
                        );
                      }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Back to Home"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.red,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Hello, $userName",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.red),
                  onPressed: logout,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child:
                      _selectedImage != null
                          ? Image.file(_selectedImage!, fit: BoxFit.cover)
                          : (_webImage != null
                              ? Image.memory(_webImage!, fit: BoxFit.cover)
                              : const Center(
                                child: Text("No image selected."),
                              )),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.camera_alt,
                        color: Colors.red,
                        size: 30,
                      ),
                      onPressed: captureImage,
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: const Icon(
                        Icons.photo_library,
                        color: Colors.blue,
                        size: 30,
                      ),
                      onPressed: pickImage,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: scanImage,
                  child: const Text("Scan Here"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedImage = null;
                      _webImage = null;
                    });
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Remove"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
