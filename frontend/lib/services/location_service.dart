import 'dart:math';

class GpsPosition {
  final double latitude;
  final double longitude;
  final double accuracy;
  final bool isSimulated;

  GpsPosition({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.isSimulated = false,
  });
}

class LocationService {
  static bool _hasPermission = false;
  static bool _isTracking = false;

  static bool get hasPermission => _hasPermission;
  static bool get isTracking => _isTracking;

  static Future<bool> requestPermission() async {
    // In a real device environment or demo, simulated opt-in consent
    _hasPermission = true;
    return true;
  }

  static void stopTracking() {
    _isTracking = false;
  }

  static void startTracking() {
    _isTracking = true;
  }

  /// Returns current GPS position or simulated coordinate along the train corridor
  static Future<GpsPosition?> getCurrentPosition({double? customLat, double? customLon}) async {
    if (!_hasPermission && customLat == null) return null;

    if (customLat != null && customLon != null) {
      return GpsPosition(
        latitude: customLat,
        longitude: customLon,
        accuracy: 12.0,
        isSimulated: true,
      );
    }

    // Default simulated corridor coordinate near Secunderabad Junction (HYB corridor)
    final rand = Random();
    final lat = 17.4334 + (rand.nextDouble() - 0.5) * 0.02;
    final lon = 78.5042 + (rand.nextDouble() - 0.5) * 0.02;

    return GpsPosition(
      latitude: lat,
      longitude: lon,
      accuracy: 15.0,
      isSimulated: true,
    );
  }
}
