// firebase_options.dart

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    } else {
      return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyDiBU67XGIW83s3fCLQv_2EDLAmcueGVrU",
    appId: "1:113645051931:android:a5b50b4a14fc67b5e798be",
    messagingSenderId: "113645051931",
    projectId: "beautywise-ai",
    storageBucket: "beautywise-ai.appspot.com",
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyDiBU67XGIW83s3fCLQv_2EDLAmcueGVrU",
    authDomain: "beautywise-ai.firebaseapp.com",
    projectId: "beautywise-ai",
    storageBucket: "beautywise-ai.appspot.com", // Corrected
    messagingSenderId: "113645051931",
    appId:
        "1:113645051931:android:a5b50b4a14fc67b5e798be", // Replace with correct Web appId
  );
}
