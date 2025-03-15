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
    } catch (e, stackTrace) {
      debugPrint("Error: $e\n$stackTrace");
      throw Exception("Failed to get application directory: $e");
    }
  }

  /// Get the temporary directory (cache storage)
  Future<Directory> getTempDirectory() async {
    try {
      final Directory dir = await getTemporaryDirectory();
      debugPrint("Temporary Directory: ${dir.path}");
      return dir;
    } catch (e, stackTrace) {
      debugPrint("Error: $e\n$stackTrace");
      throw Exception("Failed to get temporary directory: $e");
    }
  }

  /// Get the external storage directory (Android only)
  Future<Directory?> getExternalStorage() async {
    try {
      if (Platform.isAndroid) {
        final Directory? dir = await getExternalStorageDirectory();
        if (dir != null) {
          debugPrint("External Storage Directory: ${dir.path}");
        } else {
          debugPrint("External storage directory not available.");
        }
        return dir;
      }
      return null;
    } catch (e, stackTrace) {
      debugPrint("Error: $e\n$stackTrace");
      return null; // Graceful fallback
    }
  }

  /// Create a custom directory inside the app's document directory
  Future<Directory> createCustomDirectory(String folderName) async {
    try {
      final Directory appDir = await getAppDirectory();
      final Directory customDir = Directory('${appDir.path}/$folderName');

      if (!customDir.existsSync()) {
        await customDir.create(recursive: true);
        debugPrint("Custom Directory Created: ${customDir.path}");
      }

      return customDir;
    } catch (e, stackTrace) {
      debugPrint("Error: $e\n$stackTrace");
      throw Exception("Failed to create custom directory: $e");
    }
  }
}
