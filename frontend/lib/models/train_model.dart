import 'station_model.dart';
import 'coach_model.dart';

class TrainModel {
  final int id;
  final String trainNumber;
  final String trainName;
  final StationModel sourceStation;
  final StationModel destinationStation;
  final String departureTime;
  final String arrivalTime;
  final double durationHours;
  final String runsOnDays;
  final bool isActive;
  final bool isDemoData;
  final TrainCrowdEstimate crowdEstimate;
  final bool isSaved;
  final List<TrainStopModel> stops;
  final List<CoachModel> coaches;

  TrainModel({
    required this.id,
    required this.trainNumber,
    required this.trainName,
    required this.sourceStation,
    required this.destinationStation,
    required this.departureTime,
    required this.arrivalTime,
    required this.durationHours,
    required this.runsOnDays,
    required this.isActive,
    required this.isDemoData,
    required this.crowdEstimate,
    required this.isSaved,
    this.stops = const [],
    this.coaches = const [],
  });

  String get routeDisplay => '${sourceStation.stationCode} → ${destinationStation.stationCode}';

  String get durationDisplay {
    final hours = durationHours.floor();
    final minutes = ((durationHours - hours) * 60).round();
    if (minutes > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${hours}h';
  }

  factory TrainModel.fromJson(Map<String, dynamic> json) {
    var rawStops = json['stops'] as List<dynamic>? ?? [];
    List<TrainStopModel> stopsList = rawStops.map((s) => TrainStopModel.fromJson(s)).toList();

    var rawCoaches = json['coaches'] as List<dynamic>? ?? [];
    List<CoachModel> coachesList = rawCoaches.map((c) => CoachModel.fromJson(c)).toList();

    return TrainModel(
      id: json['id'] ?? 0,
      trainNumber: json['train_number'] ?? '',
      trainName: json['train_name'] ?? '',
      sourceStation: StationModel.fromJson(json['source_station'] ?? {}),
      destinationStation: StationModel.fromJson(json['destination_station'] ?? {}),
      departureTime: json['departure_time'] ?? '',
      arrivalTime: json['arrival_time'] ?? '',
      durationHours: (json['duration_hours'] as num?)?.toDouble() ?? 0.0,
      runsOnDays: json['runs_on_days'] ?? 'Daily',
      isActive: json['is_active'] ?? true,
      isDemoData: json['is_demo_data'] ?? true,
      crowdEstimate: TrainCrowdEstimate.fromJson(json['crowd_estimate'] ?? {}),
      isSaved: json['is_saved'] ?? false,
      stops: stopsList,
      coaches: coachesList,
    );
  }
}

class TrainStopModel {
  final int id;
  final int stopOrder;
  final StationModel station;
  final String? arrivalTime;
  final String? departureTime;
  final double distanceKm;
  final int haltMinutes;

  TrainStopModel({
    required this.id,
    required this.stopOrder,
    required this.station,
    this.arrivalTime,
    this.departureTime,
    required this.distanceKm,
    required this.haltMinutes,
  });

  factory TrainStopModel.fromJson(Map<String, dynamic> json) {
    return TrainStopModel(
      id: json['id'] ?? 0,
      stopOrder: json['stop_order'] ?? 1,
      station: StationModel.fromJson(json['station'] ?? {}),
      arrivalTime: json['arrival_time'],
      departureTime: json['departure_time'],
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      haltMinutes: json['halt_minutes'] ?? 2,
    );
  }
}

class TrainCrowdEstimate {
  final String crowdLevel;
  final int validReportCount;
  final String confidenceLevel;
  final double confidenceScore;
  final String? lastUpdated;
  final String explanation;
  final Map<String, dynamic> distribution;

  TrainCrowdEstimate({
    required this.crowdLevel,
    required this.validReportCount,
    required this.confidenceLevel,
    required this.confidenceScore,
    this.lastUpdated,
    required this.explanation,
    required this.distribution,
  });

  factory TrainCrowdEstimate.fromJson(Map<String, dynamic> json) {
    return TrainCrowdEstimate(
      crowdLevel: json['crowd_level'] ?? 'INSUFFICIENT_DATA',
      validReportCount: json['valid_report_count'] ?? 0,
      confidenceLevel: json['confidence_level'] ?? 'NONE',
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: json['last_updated'],
      explanation: json['explanation'] ?? '',
      distribution: (json['distribution'] as Map<String, dynamic>?) ?? {},
    );
  }
}
