import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final _analytics = FirebaseAnalytics.instance;

  static Future<void> logSkinTypePrediction(String skinType) async {
    await _analytics.logEvent(
      name: 'skin_type_prediction',
      parameters: {'skin_type': skinType},
    );
  }
}
