import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../core/constants/api_constants.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';

class JourneyProvider with ChangeNotifier {
  bool _isJourneyActive = false;
  bool _isNearRoute = false;
  String? _statusMessage;
  Map<String, dynamic>? _activeSession;

  bool get isJourneyActive => _isJourneyActive;
  bool get isNearRoute => _isNearRoute;
  String? get statusMessage => _statusMessage;
  Map<String, dynamic>? get activeSession => _activeSession;

  Future<void> checkStatus() async {
    final response = await ApiService.get(ApiConstants.journeyStatus, requireAuth: true);
    if (response.success && response.data != null) {
      _isJourneyActive = response.data['has_active_journey'] ?? false;
      _activeSession = response.data['session'];
      if (_activeSession != null) {
        _isNearRoute = _activeSession!['is_near_route'] ?? false;
      }
      notifyListeners();
    }
  }

  Future<bool> startJourney(int trainId, {DateTime? date}) async {
    await LocationService.requestPermission();
    final pos = await LocationService.getCurrentPosition();

    final dateStr = DateFormat('yyyy-MM-dd').format(date ?? DateTime.now());
    final payload = <String, dynamic>{
      'train_id': trainId,
      'journey_date': dateStr,
    };
    if (pos != null) {
      payload['latitude'] = pos.latitude;
      payload['longitude'] = pos.longitude;
      payload['accuracy'] = pos.accuracy;
    }

    final response = await ApiService.post(
      ApiConstants.journeyStart,
      body: payload,
      requireAuth: true,
    );

    if (response.success && response.data != null) {
      _isJourneyActive = true;
      _isNearRoute = response.data['is_near_route'] ?? false;
      _activeSession = response.data['session'];
      _statusMessage = response.data['message'];
      LocationService.startTracking();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> stopJourney() async {
    final response = await ApiService.post(
      ApiConstants.journeyStop,
      requireAuth: true,
    );

    if (response.success) {
      _isJourneyActive = false;
      _isNearRoute = false;
      _activeSession = null;
      _statusMessage = 'Journey ended.';
      LocationService.stopTracking();
      notifyListeners();
      return true;
    }
    return false;
  }
}
