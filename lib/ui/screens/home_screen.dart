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
  File? _selectedImage; // For Mobile
  Uint8List? _webImage; // For Web

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
      print("Error fetching user data: $e");
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

  // 📷 Pick image from gallery (Mobile) / File Picker (Web)
  Future<void> pickImage() async {
    if (kIsWeb) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null) {
        setState(() {
          _webImage = result.files.first.bytes; // Store web image data
          _selectedImage = null; // Ensure mobile image is cleared
        });
      }
    } else {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _webImage = null; // Ensure web image is cleared
        });
      }
    }
  }

  // 📷 Capture image using Camera (Mobile) / File Picker (Web)
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

  // 🔍 Simulate scanning process
  Future<void> scanImage() async {
    if (_selectedImage == null && _webImage == null) return;

    // Simulating AI scan (replace with actual scan logic)
    await Future.delayed(const Duration(seconds: 2));

    // Show results in a pop-up
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Scan Results"),
            content: const Text(
              "AI scan completed! Skin type: Normal, Score: 87%",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
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
                      backgroundImage: AssetImage('assets/profile.jpg'),
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

          // Image Display Area (Fixed Size)
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
                  padding: const EdgeInsets.all(10),
                  child:
                      _selectedImage != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              _selectedImage!,
                              width: 250,
                              height: 250,
                              fit: BoxFit.cover,
                            ),
                          )
                          : (_webImage != null
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.memory(
                                  _webImage!,
                                  width: 250,
                                  height: 250,
                                  fit: BoxFit.cover,
                                ),
                              )
                              : const Center(
                                child: Text(
                                  "No image selected.",
                                  textAlign: TextAlign.center,
                                ),
                              )),
                ),
                const SizedBox(height: 10),

                // Buttons below image preview
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: scanImage,
                      child: const Text("Scan Here"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedImage = null;
                          _webImage = null;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text("Remove"),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Image selection buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.image, size: 30),
                  onPressed: pickImage,
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt, size: 30),
                  onPressed: captureImage,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
