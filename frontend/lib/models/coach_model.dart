class CoachModel {
  final int id;
  final String coachNumber;
  final String coachType;
  final String coachTypeDisplay;
  final String coachLabel;
  final int position;
  final CoachCrowdInfo crowdInfo;

  CoachModel({
    required this.id,
    required this.coachNumber,
    required this.coachType,
    required this.coachTypeDisplay,
    required this.coachLabel,
    required this.position,
    required this.crowdInfo,
  });

  factory CoachModel.fromJson(Map<String, dynamic> json) {
    return CoachModel(
      id: json['id'] ?? 0,
      coachNumber: json['coach_number'] ?? '',
      coachType: json['coach_type'] ?? '',
      coachTypeDisplay: json['coach_type_display'] ?? json['coach_type'] ?? '',
      coachLabel: json['coach_label'] ?? '',
      position: json['position'] ?? 1,
      crowdInfo: CoachCrowdInfo.fromJson(json['crowd_info'] ?? {}),
    );
  }
}

class CoachCrowdInfo {
  final String crowdLevel;
  final int validReportCount;
  final String confidenceLevel;
  final double confidenceScore;
  final String? lastUpdated;
  final String explanation;
  final Map<String, dynamic> distribution;

  CoachCrowdInfo({
    required this.crowdLevel,
    required this.validReportCount,
    required this.confidenceLevel,
    required this.confidenceScore,
    this.lastUpdated,
    required this.explanation,
    required this.distribution,
  });

  factory CoachCrowdInfo.fromJson(Map<String, dynamic> json) {
    return CoachCrowdInfo(
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
