class TravelAlternativeModel {
  final int id;
  final int trainId;
  final String alternativeType;
  final String alternativeTypeDisplay;
  final String title;
  final String operator;
  final String departureTime;
  final String arrivalTime;
  final String durationText;
  final String crowdLevel;
  final String fareEstimate;
  final String sourceNote;
  final bool isDemo;

  TravelAlternativeModel({
    required this.id,
    required this.trainId,
    required this.alternativeType,
    required this.alternativeTypeDisplay,
    required this.title,
    required this.operator,
    required this.departureTime,
    required this.arrivalTime,
    required this.durationText,
    required this.crowdLevel,
    required this.fareEstimate,
    required this.sourceNote,
    required this.isDemo,
  });

  factory TravelAlternativeModel.fromJson(Map<String, dynamic> json) {
    return TravelAlternativeModel(
      id: json['id'] ?? 0,
      trainId: json['train'] ?? 0,
      alternativeType: json['alternative_type'] ?? 'TRAIN',
      alternativeTypeDisplay: json['alternative_type_display'] ?? 'Alternative Option',
      title: json['title'] ?? '',
      operator: json['operator'] ?? '',
      departureTime: json['departure_time'] ?? '',
      arrivalTime: json['arrival_time'] ?? '',
      durationText: json['duration_text'] ?? '',
      crowdLevel: json['crowd_level'] ?? 'LOW',
      fareEstimate: json['fare_estimate'] ?? '',
      sourceNote: json['source_note'] ?? 'Demo option – for illustrative comparison',
      isDemo: json['is_demo'] ?? true,
    );
  }
}
