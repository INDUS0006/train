import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../core/constants/api_constants.dart';
import '../models/crowd_report_model.dart';
import '../models/travel_alternative_model.dart';
import '../services/api_service.dart';

class CrowdProvider with ChangeNotifier {
  bool _isSubmitting = false;
  String? _statusMessage;
  String? _errorMessage;
  List<CrowdReportModel> _myReports = [];
  List<TravelAlternativeModel> _alternatives = [];
  bool _isLoadingAlternatives = false;

  bool get isSubmitting => _isSubmitting;
  String? get statusMessage => _statusMessage;
  String? get errorMessage => _errorMessage;
  List<CrowdReportModel> get myReports => _myReports;
  List<TravelAlternativeModel> get alternatives => _alternatives;
  bool get isLoadingAlternatives => _isLoadingAlternatives;

  Future<bool> submitReport({
    required int trainId,
    required DateTime journeyDate,
    int? coachId,
    required String crowdLevel,
    String comment = '',
    double? latitude,
    double? longitude,
    double? gpsAccuracy,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    _statusMessage = null;
    notifyListeners();

    final dateStr = DateFormat('yyyy-MM-dd').format(journeyDate);
    final payload = <String, dynamic>{
      'train_id': trainId,
      'journey_date': dateStr,
      'crowd_level': crowdLevel,
      'comment': comment,
    };
    if (coachId != null) payload['coach_id'] = coachId;
    if (latitude != null) payload['latitude'] = latitude;
    if (longitude != null) payload['longitude'] = longitude;
    if (gpsAccuracy != null) payload['gps_accuracy'] = gpsAccuracy;

    final response = await ApiService.post(
      ApiConstants.crowdReports,
      body: payload,
      requireAuth: true,
    );
    _isSubmitting = false;

    if (response.success && response.data != null) {
      _statusMessage = response.data['message'] ?? 'Report submitted successfully.';
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.error ?? 'Failed to submit crowd report.';
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchMyReports() async {
    final response = await ApiService.get(ApiConstants.myReports, requireAuth: true);
    if (response.success && response.data != null) {
      final list = response.data as List? ?? [];
      _myReports = list.map((r) => CrowdReportModel.fromJson(r)).toList();
      notifyListeners();
    }
  }

  Future<void> fetchAlternatives(int trainId) async {
    _isLoadingAlternatives = true;
    notifyListeners();

    final response = await ApiService.get(ApiConstants.trainAlternatives(trainId));
    _isLoadingAlternatives = false;

    if (response.success && response.data != null) {
      final list = response.data['alternatives'] as List? ?? [];
      _alternatives = list.map((a) => TravelAlternativeModel.fromJson(a)).toList();
    } else {
      _alternatives = [];
    }
    notifyListeners();
  }

  Future<bool> resetDemoData() async {
    final response = await ApiService.post(ApiConstants.demoReset);
    return response.success;
  }
}
