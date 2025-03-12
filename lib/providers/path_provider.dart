import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class PathProviderService {
  /// Get the application document directory (persistent storage)
  Future<Directory> getAppDirectory() async {
    try {
      final Directory dir = await getApplicationDocumentsDirectory();
      debugPrint("Application Directory: ${dir.path}");
      return dir;
    } catch (e) {
      debugPrint("Error getting application directory: $e");
      throw Exception("Failed to get application directory: $e");
    }
  }

  /// Get the temporary directory (cache storage)
  Future<Directory> getTempDirectory() async {
    try {
      final Directory dir = await getTemporaryDirectory();
      debugPrint("Temporary Directory: ${dir.path}");
      return dir;
    } catch (e) {
      debugPrint("Error getting temporary directory: $e");
      throw Exception("Failed to get temporary directory: $e");
    }
  }

  /// Get the external storage directory (Android only)
  Future<Directory?> getExternalStorage() async {
    try {
      final Directory? dir = await getExternalStorageDirectory();
      if (dir != null) {
        debugPrint("External Storage Directory: ${dir.path}");
      } else {
        debugPrint("External storage directory not available.");
      }
      return dir;
    } catch (e) {
      debugPrint("Error getting external storage directory: $e");
      return null; // Avoid throwing an error, as this is optional
    }
  }

  /// Create a custom directory inside the app's document directory
  Future<Directory> createCustomDirectory(String folderName) async {
    try {
      final Directory appDir = await getAppDirectory();
      final Directory customDir = Directory('${appDir.path}/$folderName');

      await customDir.create(recursive: true);
      debugPrint("Custom Directory Created: ${customDir.path}");

      return customDir;
    } catch (e) {
      debugPrint("Error creating custom directory: $e");
      throw Exception("Failed to create custom directory: $e");
    }
  }
}
