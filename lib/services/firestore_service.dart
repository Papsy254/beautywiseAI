import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ Add a new user to Firestore
  Future<void> addUser(String userId, String name, String email) async {
    await _firestore.collection('Users').doc(userId).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ✅ Add scan result
  Future<void> addScanResult(
    String userId,
    String imageUrl,
    String skinType,
  ) async {
    await _firestore.collection('SCAN_RESULTS').add({
      'userId': userId,
      'imageUrl': imageUrl,
      'skinType': skinType,
      'scanDate': FieldValue.serverTimestamp(),
    });
  }

  // ✅ Add recommendation
  Future<void> addRecommendation(
    String userId,
    String skinType,
    List<String> products,
    String tips,
  ) async {
    await _firestore.collection('Recommendations').add({
      'userId': userId,
      'skinType': skinType,
      'products': products,
      'tips': tips,
    });
  }

  // 🔥 Fetch Users
  Future<void> fetchUsers() async {
    QuerySnapshot usersSnapshot = await _firestore.collection('Users').get();
    for (var doc in usersSnapshot.docs) {
      print('User ID: ${doc.id}, Data: ${doc.data()}');
    }
  }

  // 🔥 Fetch Scan Results
  Future<void> fetchScanResults() async {
    QuerySnapshot scanResultsSnapshot =
        await _firestore.collection('SCAN_RESULTS').get();
    for (var doc in scanResultsSnapshot.docs) {
      print('Scan ID: ${doc.id}, Data: ${doc.data()}');
    }
  }

  // 🔥 Fetch Recommendations
  Future<void> fetchRecommendations() async {
    QuerySnapshot recommendationsSnapshot =
        await _firestore.collection('Recommendations').get();
    for (var doc in recommendationsSnapshot.docs) {
      print('Recommendation ID: ${doc.id}, Data: ${doc.data()}');
    }
  }

  // ✏️ Update User
  Future<void> updateUser(String userId, Map<String, dynamic> newData) async {
    await _firestore.collection('Users').doc(userId).update(newData);
    print("User Updated!");
  }

  // ✏️ Update Recommendation
  Future<void> updateRecommendation(
    String recommendationId,
    Map<String, dynamic> newData,
  ) async {
    await _firestore
        .collection('Recommendations')
        .doc(recommendationId)
        .update(newData);
    print("Recommendation Updated!");
  }

  // ✏️ Update SCAN_RESULTS
  Future<void> updateScanResult(
    String scanId,
    Map<String, dynamic> newData,
  ) async {
    await _firestore.collection('SCAN_RESULTS').doc(scanId).update(newData);
    print("Scan Result Updated!");
  }

  // ✅ Save Scan Result (Moved inside class & Fixed `_firestore` reference)
  Future<void> saveScanResult(
    String userId,
    String imageUrl,
    List<double> results,
  ) async {
    await _firestore.collection('scans').add({
      'userId': userId,
      'imageUrl': imageUrl,
      'results': results,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
