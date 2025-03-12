// import 'dart:io';
// import 'package:firebase_storage/firebase_storage.dart';

// class StorageService {
//   final FirebaseStorage _storage = FirebaseStorage.instance;

//   // Upload file to Firebase Storage
//   Future<String?> uploadFile(String path, File file) async {
//     try {
//       UploadTask uploadTask = _storage.ref(path).putFile(file);
//       TaskSnapshot snapshot = await uploadTask;
//       return await snapshot.ref.getDownloadURL();
//     } catch (e) {
//       print("Storage error: $e");
//       return null;
//     }
//   }
// }
