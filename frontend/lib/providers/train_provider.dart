import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../core/constants/api_constants.dart';
import '../models/train_model.dart';
import '../models/station_model.dart';
import '../services/api_service.dart';

class TrainProvider with ChangeNotifier {
  List<TrainModel> _searchResults = [];
  List<TrainModel> _featuredTrains = [];
  List<Map<String, dynamic>> _popularRoutes = [];
  Map<String, dynamic> _dashboardStats = {};
  Map<String, dynamic> _crowdExplanation = {};
  List<StationModel> _stations = [];
  List<TrainModel> _savedTrains = [];

  TrainModel? _selectedTrain;
  bool _isSearching = false;
  bool _isLoadingDashboard = false;
  bool _isLoadingDetails = false;
  String? _errorMessage;

  List<TrainModel> get searchResults => _searchResults;
  List<TrainModel> get featuredTrains => _featuredTrains;
  List<Map<String, dynamic>> get popularRoutes => _popularRoutes;
  Map<String, dynamic> get dashboardStats => _dashboardStats;
  Map<String, dynamic> get crowdExplanation => _crowdExplanation;
  List<StationModel> get stations => _stations;
  List<TrainModel> get savedTrains => _savedTrains;
  TrainModel? get selectedTrain => _selectedTrain;

  bool get isSearching => _isSearching;
  bool get isLoadingDashboard => _isLoadingDashboard;
  bool get isLoadingDetails => _isLoadingDetails;
  String? get errorMessage => _errorMessage;

  TrainProvider() {
    loadDashboard();
    loadStations();
  }

  Future<void> loadDashboard() async {
    _isLoadingDashboard = true;
    _errorMessage = null;
    notifyListeners();

    final response = await ApiService.get(ApiConstants.dashboard);
    _isLoadingDashboard = false;

    if (response.success && response.data != null) {
      final data = response.data;
      if (data['featured_trains'] != null) {
        _featuredTrains = (data['featured_trains'] as List)
            .map((t) => TrainModel.fromJson(t))
            .toList();
      }
      if (data['popular_routes'] != null) {
        _popularRoutes = List<Map<String, dynamic>>.from(data['popular_routes']);
      }
      if (data['stats'] != null) {
        _dashboardStats = Map<String, dynamic>.from(data['stats']);
      }
      if (data['crowd_explanation'] != null) {
        _crowdExplanation = Map<String, dynamic>.from(data['crowd_explanation']);
      }
    } else {
      _errorMessage = response.error;
    }
    notifyListeners();
  }

  Future<void> loadStations() async {
    final response = await ApiService.get(ApiConstants.stations);
    if (response.success && response.data != null) {
      _stations = (response.data as List)
          .map((s) => StationModel.fromJson(s))
          .toList();
      notifyListeners();
    }
  }

  Future<bool> searchTrains({
    String fromCode = '',
    String toCode = '',
    DateTime? journeyDate,
    String query = '',
  }) async {
    _isSearching = true;
    _errorMessage = null;
    notifyListeners();

    final dateStr = DateFormat('yyyy-MM-dd').format(journeyDate ?? DateTime.now());
    final queryParams = <String, String>{
      'journey_date': dateStr,
    };
    if (fromCode.isNotEmpty) queryParams['from_code'] = fromCode;
    if (toCode.isNotEmpty) queryParams['to_code'] = toCode;
    if (query.isNotEmpty) queryParams['q'] = query;

    final response = await ApiService.get(
      ApiConstants.trainSearch,
      queryParams: queryParams,
    );
    _isSearching = false;

    if (response.success && response.data != null) {
      final results = response.data['results'] as List? ?? [];
      _searchResults = results.map((t) => TrainModel.fromJson(t)).toList();
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.error ?? 'Failed to search trains.';
      _searchResults = [];
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchTrainDetails(int trainId, {DateTime? journeyDate}) async {
    _isLoadingDetails = true;
    _errorMessage = null;
    notifyListeners();

    final dateStr = DateFormat('yyyy-MM-dd').format(journeyDate ?? DateTime.now());
    final response = await ApiService.get(
      ApiConstants.trainDetail(trainId),
      queryParams: {'journey_date': dateStr},
    );
    _isLoadingDetails = false;

    if (response.success && response.data != null) {
      _selectedTrain = TrainModel.fromJson(response.data);
    } else {
      _errorMessage = response.error ?? 'Failed to load train details.';
    }
    notifyListeners();
  }

  Future<bool> toggleSaveTrain(int trainId) async {
    final response = await ApiService.post(
      ApiConstants.trainToggleSave(trainId),
      requireAuth: true,
    );
    if (response.success) {
      if (_selectedTrain != null && _selectedTrain!.id == trainId) {
        // Toggle in-memory
        final current = _selectedTrain!;
        _selectedTrain = TrainModel(
          id: current.id,
          trainNumber: current.trainNumber,
          trainName: current.trainName,
          sourceStation: current.sourceStation,
          destinationStation: current.destinationStation,
          departureTime: current.departureTime,
          arrivalTime: current.arrivalTime,
          durationHours: current.durationHours,
          runsOnDays: current.runsOnDays,
          isActive: current.isActive,
          isDemoData: current.isDemoData,
          crowdEstimate: current.crowdEstimate,
          isSaved: !(current.isSaved),
          stops: current.stops,
          coaches: current.coaches,
        );
      }
      fetchSavedTrains();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> fetchSavedTrains() async {
    final response = await ApiService.get(ApiConstants.savedTrains, requireAuth: true);
    if (response.success && response.data != null) {
      final results = response.data as List? ?? [];
      _savedTrains = results.map((t) => TrainModel.fromJson(t)).toList();
      notifyListeners();
    }
  }
}
