class StationModel {
  final int id;
  final String stationCode;
  final String stationName;
  final String city;
  final String state;
  final double latitude;
  final double longitude;
  final String displayName;

  StationModel({
    required this.id,
    required this.stationCode,
    required this.stationName,
    required this.city,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.displayName,
  });

  factory StationModel.fromJson(Map<String, dynamic> json) {
    return StationModel(
      id: json['id'] ?? 0,
      stationCode: json['station_code'] ?? '',
      stationName: json['station_name'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      displayName: json['display_name'] ?? '${json['station_name']} (${json['station_code']})',
    );
  }
}
