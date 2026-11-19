import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/train_model.dart';
import 'package:frontend/models/station_model.dart';
import 'package:frontend/screens/map/crowd_map_screen.dart';

void main() {
  testWidgets('CrowdMapScreen test', (WidgetTester tester) async {
    final st1 = StationModel(
      id: 1, stationCode: 'HYB', stationName: 'Hyderabad',
      city: 'Hyderabad', state: 'Telangana', latitude: 17.39, longitude: 78.46,
      displayName: 'HYB - Hyderabad'
    );
    final st2 = StationModel(
      id: 2, stationCode: 'BZA', stationName: 'Vijayawada',
      city: 'Vijayawada', state: 'Andhra Pradesh', latitude: 16.51, longitude: 80.61,
      displayName: 'BZA - Vijayawada'
    );
    final stop1 = TrainStopModel(id: 1, stopOrder: 1, station: st1, distanceKm: 0, haltMinutes: 0);
    final stop2 = TrainStopModel(id: 2, stopOrder: 2, station: st2, distanceKm: 350, haltMinutes: 0);

    final train = TrainModel(
      id: 1, trainNumber: '12723', trainName: 'Godavari Exp',
      sourceStation: st1, destinationStation: st2,
      departureTime: '17:15:00', arrivalTime: '23:30:00',
      durationHours: 6.25, runsOnDays: 'Daily', isActive: true,
      isDemoData: true,
      crowdEstimate: TrainCrowdEstimate(
        crowdLevel: 'HIGH', validReportCount: 5, confidenceLevel: 'HIGH',
        confidenceScore: 0.8, explanation: 'Test', distribution: {}
      ),
      isSaved: false,
      stops: [stop1, stop2],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: CrowdMapScreen(train: train),
      ),
    );

    expect(find.byType(CrowdMapScreen), findsOneWidget);
  });
}
