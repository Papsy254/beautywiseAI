import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/recommendation_service.dart';

// Displays Personalized Recommendations Based on Face Type
class RecommendationResultScreen extends StatelessWidget {
  final int faceTypeIndex;
  final List<String> faceTypes = [
    "Oily Skin",
    "Dry Skin",
    "Combination Skin",
    "Normal Skin",
  ];

  RecommendationResultScreen({super.key, required this.faceTypeIndex});

  @override
  Widget build(BuildContext context) {
    final faceType = faceTypes[faceTypeIndex];

    return Scaffold(
      appBar: AppBar(title: const Text("Personalized Recommendations")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Detected: $faceType"),
            const SizedBox(height: 10),
            // Use FutureBuilder to asynchronously fetch recommendations
            FutureBuilder<Map<String, dynamic>>(
              future: getRecommendations(faceType),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // Loader during fetch
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text("No recommendations available.");
                } else {
                  final data = snapshot.data!;
                  return Column(
                    children: [
                      Text("Recommended Foods: ${data['foods'].join(', ')}"),
                      Text(
                        "Beauty Products: ${data['beauty_products'].join(', ')}",
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Fetch recommendations from the service
  Future<Map<String, dynamic>> getRecommendations(String faceType) async {
    try {
      // Replace with actual service call to fetch recommendations based on the face type
      return await RecommendationService.getRecommendationsBySkinType(faceType);
    } catch (e) {
      print("Error fetching recommendations: $e");
      return {}; // Return empty map in case of error
    }
  }
}

// Fetch and Displays AI Recommendations
class RecommendationHomeScreen extends StatefulWidget {
  const RecommendationHomeScreen({super.key});

  @override
  _RecommendationHomeScreenState createState() =>
      _RecommendationHomeScreenState();
}

class _RecommendationHomeScreenState extends State<RecommendationHomeScreen> {
  List<String> recommendations = [];
  bool isLoading = true; // Added to manage loading state

  @override
  void initState() {
    super.initState();
    loadRecommendations();
  }

  // Fetch and load recommendations
  Future<void> loadRecommendations() async {
    try {
      List<String> fetched = await RecommendationService.getRecommendations();
      if (mounted) {
        setState(() {
          recommendations = fetched;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching recommendations: $e");
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Recommendations")),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator()) // Loader
              : recommendations.isEmpty
              ? const Center(child: Text("No recommendations available."))
              : ListView.builder(
                itemCount: recommendations.length,
                itemBuilder: (context, index) {
                  return ListTile(title: Text(recommendations[index]));
                },
              ),
    );
  }
}

// Displays AI Beauty Recommendations from Firestore
class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  _RecommendationScreenState createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? user;
  List<Map<String, dynamic>> recommendations = [];
  bool isLoading = true; // Added for loading state

  @override
  void initState() {
    super.initState();
    getRecommendations();
  }

  // Fetch recommendations from Firestore for the current user
  Future<void> getRecommendations() async {
    try {
      user = _auth.currentUser;
      if (user == null) return;

      QuerySnapshot querySnapshot =
          await _firestore
              .collection("recommendation")
              .where("userId", isEqualTo: user?.uid) // Null-safe access
              .orderBy("timestamp", descending: true)
              .get();

      if (mounted) {
        setState(() {
          recommendations =
              querySnapshot.docs
                  .map((doc) => doc.data() as Map<String, dynamic>)
                  .toList();
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching recommendations: $e");
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Your AI Beauty Recommendations")),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator()) // Loader
              : recommendations.isEmpty
              ? const Center(child: Text("No recommendations available."))
              : ListView.builder(
                itemCount: recommendations.length,
                itemBuilder: (context, index) {
                  var recommendation = recommendations[index];
                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      leading: const Icon(Icons.star, color: Colors.orange),
                      title: Text(recommendation['productName']),
                      subtitle: Text("Category: ${recommendation['category']}"),
                      trailing: Text("\$${recommendation['price']}"),
                    ),
                  );
                },
              ),
    );
  }
}

// Displays Recommendations Based on Skin Type
class RecommendationsScreen extends StatelessWidget {
  final String skinType;

  const RecommendationsScreen({super.key, required this.skinType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Recommendations")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getRecommendationsBySkinType(skinType),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData && snapshot.data != null) {
            var recommendations = snapshot.data!;
            return ListView(
              children: [
                ListTile(
                  title: Text("Food Recommendations"),
                  subtitle: Text(
                    recommendations['food'] ?? "No food recommendations",
                  ),
                ),
                ListTile(
                  title: Text("Beauty Products"),
                  subtitle: Text(
                    recommendations['products'] ??
                        "No beauty products available",
                  ),
                ),
              ],
            );
          } else {
            return Center(child: Text("No recommendations found"));
          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>> getRecommendationsBySkinType(
    String skinType,
  ) async {
    try {
      var snapshot =
          await FirebaseFirestore.instance
              .collection('recommendations')
              .doc(skinType)
              .get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      } else {
        throw Exception("No recommendations found.");
      }
    } catch (e) {
      print("Error fetching recommendations: $e");
      return {}; // Return an empty map in case of error
    }
  }
}
