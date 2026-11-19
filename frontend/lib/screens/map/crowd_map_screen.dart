import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/app_colors.dart';
import '../../models/train_model.dart';
import '../../widgets/demo_banner.dart';

class CrowdMapScreen extends StatefulWidget {
  final TrainModel train;

  const CrowdMapScreen({super.key, required this.train});

  @override
  State<CrowdMapScreen> createState() => _CrowdMapScreenState();
}

class _CrowdMapScreenState extends State<CrowdMapScreen> {
  TrainStopModel? _selectedStop;

  // Find the nearest stop to a tapped map coordinate.
  // This replaces GestureDetector inside Marker children, which causes
  // mouse_tracker.dart:199 assertion loops on Flutter Web.
  void _handleMapTap(TapPosition tapPos, LatLng tappedPoint) {
    const double thresholdDeg = 0.15; // ~15 km radius
    TrainStopModel? nearest;
    double minDist = double.infinity;

    for (final stop in widget.train.stops) {
      final dLat = stop.station.latitude - tappedPoint.latitude;
      final dLng = stop.station.longitude - tappedPoint.longitude;
      final dist = dLat * dLat + dLng * dLng;
      if (dist < minDist) {
        minDist = dist;
        nearest = stop;
      }
    }

    if (nearest != null && minDist < thresholdDeg * thresholdDeg) {
      setState(() => _selectedStop = nearest);
    } else {
      // Tapped away from any stop — dismiss card
      if (_selectedStop != null) setState(() => _selectedStop = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stops = widget.train.stops;

    // ── Empty-state guard ────────────────────────────────────────────────────
    if (stops.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            '${widget.train.trainNumber} Route Map',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
        ),
        body: Column(
          children: [
            const DemoBanner(),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.softBlue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.map_outlined,
                            size: 36, color: AppColors.primaryBlue),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Route data not loaded',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navyBlue),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Open a train from search results\nand tap "Route Map" to see the full route.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ── Route coordinates ────────────────────────────────────────────────────
    final routePoints = stops
        .map((s) => LatLng(s.station.latitude, s.station.longitude))
        .toList();

    final centerCoord = routePoints[routePoints.length ~/ 2];

    // ── Station markers (NO GestureDetector — avoids mouse_tracker crash) ───
    final markers = <Marker>[];
    for (int i = 0; i < stops.length; i++) {
      final stop = stops[i];
      final isFirst = i == 0;
      final isLast = i == stops.length - 1;
      final isSelected = _selectedStop?.stopOrder == stop.stopOrder;

      markers.add(
        Marker(
          point: LatLng(stop.station.latitude, stop.station.longitude),
          width: isSelected ? 52 : 44,
          height: isSelected ? 52 : 44,
          // ⚠️  No GestureDetector here — taps handled by MapOptions.onTap
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.crowdHigh
                  : (isFirst || isLast)
                      ? AppColors.navyBlue
                      : AppColors.primaryBlue,
              shape: BoxShape.circle,
              border: Border.all(
                  color: isSelected ? Colors.white : Colors.white,
                  width: isSelected ? 3.0 : 2.5),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withAlpha(isSelected ? 90 : 50),
                    blurRadius: isSelected ? 8 : 4,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Center(
              child: Text(
                stop.station.stationCode.length > 3
                    ? stop.station.stationCode.substring(0, 3)
                    : stop.station.stationCode,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 9.5,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // ── Simulated train position marker ─────────────────────────────────────
    if (routePoints.length >= 3) {
      final simPos = LatLng(
        (routePoints[1].latitude + routePoints[2].latitude) / 2,
        (routePoints[1].longitude + routePoints[2].longitude) / 2,
      );
      markers.add(
        Marker(
          point: simPos,
          width: 50,
          height: 50,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.crowdHigh,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withAlpha(60),
                    blurRadius: 6,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: const Icon(Icons.train, color: Colors.white, size: 24),
          ),
        ),
      );
    }

    // ── Scaffold ─────────────────────────────────────────────────────────────
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.train.trainNumber} Route Map',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            Text(
              '${widget.train.sourceStation.stationCode} → '
              '${widget.train.destinationStation.stationCode}',
              style: const TextStyle(fontSize: 11, color: AppColors.lightBlue),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const DemoBanner(),
            // Tap-hint strip
            Container(
              width: double.infinity,
              color: AppColors.softBlue,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: const Text(
                '💡 Tap near a station circle to see stop details',
                style: TextStyle(
                    fontSize: 11,
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  // ── Map ───────────────────────────────────────────────────
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: centerCoord,
                      initialZoom: 7.2,
                      // All taps go through MapOptions — no GestureDetector in tree
                      onTap: _handleMapTap,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.trainbuddy.app',
                        errorTileCallback: (tile, error, stackTrace) {},
                      ),
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: routePoints,
                            strokeWidth: 4.5,
                            color: AppColors.primaryBlue,
                          ),
                        ],
                      ),
                      MarkerLayer(markers: markers),
                    ],
                  ),

                  // ── Info badge ────────────────────────────────────────────
                  Positioned(
                    top: 10,
                    left: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withAlpha(28),
                              blurRadius: 6,
                              offset: const Offset(0, 2)),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.satellite_alt_outlined,
                              size: 15, color: AppColors.primaryBlue),
                          SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              'OpenStreetMap • Red marker = simulated demo position',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Stop detail card ──────────────────────────────────────
                  if (_selectedStop != null)
                    Positioned(
                      bottom: 16,
                      left: 14,
                      right: 14,
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.softBlue,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.location_on,
                                    color: AppColors.primaryBlue),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${_selectedStop!.station.stationName}'
                                      ' (${_selectedStop!.station.stationCode})',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                          color: AppColors.navyBlue),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Stop #${_selectedStop!.stopOrder} • '
                                      '${_selectedStop!.distanceKm.toInt()} km • '
                                      'Dept: ${_selectedStop!.departureTime?.substring(0, 5) ?? "--:--"}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.close, size: 18),
                                onPressed: () => setState(
                                    () => _selectedStop = null),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
