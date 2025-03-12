import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecommendationService {
  /// Save recommendations locally in shared_preferences
  static Future<void> saveRecommendations(List<String> recommendations) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recommendations', recommendations);
  }

  /// Retrieve cached recommendations from shared_preferences
  static Future<List<String>> getCachedRecommendations() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('recommendations') ?? [];
  }

  /// Fetch fresh recommendations from Firebase
  static Future<List<String>> fetchRecommendationsFromFirebase() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('recommendations').get();
      List<String> recommendations =
          snapshot.docs.map((doc) => doc['text'].toString()).toList();
      return recommendations;
    } catch (e) {
      print("Error fetching recommendations: $e");
      return [];
    }
  }

  /// Smart fetching: Try cache first, then Firebase if needed
  static Future<List<String>> getRecommendations() async {
    List<String> cached = await getCachedRecommendations();

    if (cached.isNotEmpty) {
      print("Using cached recommendations ✅");
      return cached;
    } else {
      print("Fetching fresh recommendations from Firebase 🔄");
      List<String> fresh = await fetchRecommendationsFromFirebase();
      await saveRecommendations(fresh);
      return fresh;
    }
  }

  /// Get recommendations based on face type
  Map<String, dynamic> getRecommendationsByFaceType(String faceType) {
    final recommendations = {
      "oily_skin": {
        "foods": ["Avocado", "Nuts", "Salmon"],
        "beauty_products": ["Oil-Free Moisturizer", "Clay Mask"],
      },
      "dry_skin": {
        "foods": ["Avocado", "Olive Oil"],
        "beauty_products": ["Hydrating Cream", "Aloe Vera Gel"],
      },
    };
    return recommendations[faceType] ?? {};
  }

  /// Get skin care tip based on face type index
  String getSkinCareTip(int faceTypeIndex) {
    const tips = [
      "For oily skin, avoid heavy oils and moisturize lightly.",
      "Hydrate dry skin by using moisturizers with hyaluronic acid.",
      "Combination skin requires balancing hydration without over-moisturizing.",
      "Normal skin benefits from a regular moisturizing routine.",
    ];
    return tips[faceTypeIndex];
  }
}
