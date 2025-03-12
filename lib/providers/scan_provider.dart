import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/scan_provider.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ScanProvider>(context, listen: false).initializeCamera();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scanProvider = Provider.of<ScanProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Scan an Image")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (scanProvider.isLoading)
            CircularProgressIndicator()
          else if (scanProvider.capturedImage == null)
            Text("No image captured")
          else
            Image.file(scanProvider.capturedImage!), // Display captured image

          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              try {
                await scanProvider.captureImage();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error capturing image: $e")),
                );
              }
            },
            child: Text("Capture Image"),
          ),

          if (scanProvider.errorMessage != null)
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                scanProvider.errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}
