import 'package:flutter/foundation.dart';

class ApiConstants {
  // Use 127.0.0.1 for Web and Windows desktop, or 10.0.2.2 for Android emulator
  static String get defaultBaseUrl {
    if (kIsWeb) {
      final origin = Uri.base.origin;
      // When developing locally on localhost, point to local Django port 8000
      if (origin.contains('localhost') || origin.contains('127.0.0.1')) {
        return 'http://127.0.0.1:8000';
      }
      // When deployed (e.g. on Vercel), use the same origin domain
      return origin;
    }
    return 'http://127.0.0.1:8000';
  }

  static String baseUrl = defaultBaseUrl;

  // Auth Endpoints
  static String get register => '$baseUrl/api/auth/register/';
  static String get login => '$baseUrl/api/auth/login/';
  static String get guestLogin => '$baseUrl/api/auth/guest-login/';
  static String get refreshToken => '$baseUrl/api/auth/refresh/';
  static String get profile => '$baseUrl/api/auth/profile/';

  // Train Endpoints
  static String get stations => '$baseUrl/api/stations/';
  static String get trains => '$baseUrl/api/trains/';
  static String get trainSearch => '$baseUrl/api/trains/search/';
  static String get savedTrains => '$baseUrl/api/trains/saved/';
  static String trainDetail(int id) => '$baseUrl/api/trains/$id/';
  static String trainStops(int id) => '$baseUrl/api/trains/$id/stops/';
  static String trainCoaches(int id) => '$baseUrl/api/trains/$id/coaches/';
  static String trainToggleSave(int id) => '$baseUrl/api/trains/$id/save/';

  // Crowd Endpoints
  static String trainCrowd(int trainId) => '$baseUrl/api/trains/$trainId/crowd/';
  static String coachCrowd(int trainId, int coachId) => '$baseUrl/api/trains/$trainId/coaches/$coachId/crowd/';
  static String get crowdReports => '$baseUrl/api/crowd-reports/';
  static String get myReports => '$baseUrl/api/crowd-reports/my-reports/';

  // Alternatives
  static String trainAlternatives(int trainId) => '$baseUrl/api/trains/$trainId/alternatives/';

  // Journey Tracking
  static String get journeyStart => '$baseUrl/api/journey/start/';
  static String get journeyStop => '$baseUrl/api/journey/stop/';
  static String get journeyStatus => '$baseUrl/api/journey/status/';

  // Notifications
  static String get notifications => '$baseUrl/api/notifications/';
  static String notificationMarkRead(int id) => '$baseUrl/api/notifications/$id/read/';
  static String get notificationReadAll => '$baseUrl/api/notifications/read-all/';

  // Dashboard & Demo
  static String get dashboard => '$baseUrl/api/dashboard/';
  static String get demoReset => '$baseUrl/api/demo/reset/';
}
