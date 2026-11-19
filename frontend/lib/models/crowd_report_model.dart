class CrowdReportModel {
  final int id;
  final int trainId;
  final String trainNumber;
  final String trainName;
  final String journeyDate;
  final int? coachId;
  final String? coachNumber;
  final String crowdLevel;
  final String crowdLevelDisplay;
  final String comment;
  final double? latitude;
  final double? longitude;
  final double? gpsAccuracy;
  final String reportSource;
  final bool isValid;
  final String createdAt;

  CrowdReportModel({
    required this.id,
    required this.trainId,
    required this.trainNumber,
    required this.trainName,
    required this.journeyDate,
    this.coachId,
    this.coachNumber,
    required this.crowdLevel,
    required this.crowdLevelDisplay,
    required this.comment,
    this.latitude,
    this.longitude,
    this.gpsAccuracy,
    required this.reportSource,
    required this.isValid,
    required this.createdAt,
  });

  factory CrowdReportModel.fromJson(Map<String, dynamic> json) {
    return CrowdReportModel(
      id: json['id'] ?? 0,
      trainId: json['train'] ?? 0,
      trainNumber: json['train_number'] ?? '',
      trainName: json['train_name'] ?? '',
      journeyDate: json['journey_date'] ?? '',
      coachId: json['coach'],
      coachNumber: json['coach_number'],
      crowdLevel: json['crowd_level'] ?? 'MEDIUM',
      crowdLevelDisplay: json['crowd_level_display'] ?? json['crowd_level'] ?? '',
      comment: json['comment'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      gpsAccuracy: (json['gps_accuracy'] as num?)?.toDouble(),
      reportSource: json['report_source'] ?? 'MANUAL',
      isValid: json['is_valid'] ?? true,
      createdAt: json['created_at'] ?? '',
    );
  }
}
