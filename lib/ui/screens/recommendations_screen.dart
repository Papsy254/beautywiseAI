import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/recommendation_service.dart';

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
      appBar: AppBar(title: Text("Personalized Recommendations")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Detected: $faceType"),
            const SizedBox(height: 10),
            FutureBuilder<Map<String, dynamic>>(
              future: getRecommendations(faceType),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Loader during fetch
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Column(
                    children: [
                      Text("No recommendations available."),
                      ElevatedButton(
                        onPressed: () {
                          // Trigger retry logic
                        },
                        child: Text("Try Again"),
                      ),
                    ],
                  );
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

  Future<Map<String, dynamic>> getRecommendations(String faceType) async {
    try {
      return await RecommendationService.getRecommendationsBySkinType(faceType);
    } catch (e) {
      print("Error fetching recommendations: $e");
      return {}; // Return an empty map if there's an error
    }
  }
}

class RecommendationHomeScreen extends StatefulWidget {
  const RecommendationHomeScreen({super.key});

  @override
  _RecommendationHomeScreenState createState() =>
      _RecommendationHomeScreenState();
}

class _RecommendationHomeScreenState extends State<RecommendationHomeScreen> {
  List<String> recommendations = [];
  bool isLoading = true; // Manage loading state

  @override
  void initState() {
    super.initState();
    loadRecommendations();
  }

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

  Future<void> getRecommendations() async {
    try {
      user = _auth.currentUser;
      if (user == null) return;
      QuerySnapshot querySnapshot =
          await _firestore
              .collection("recommendation")
              .where("userId", isEqualTo: user?.uid)
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
