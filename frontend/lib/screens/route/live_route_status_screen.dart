import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/train_model.dart';
import '../../providers/train_provider.dart';
import '../../widgets/demo_banner.dart';

class LiveRouteStatusScreen extends StatefulWidget {
  final TrainModel? initialTrain;

  const LiveRouteStatusScreen({super.key, this.initialTrain});

  @override
  State<LiveRouteStatusScreen> createState() => _LiveRouteStatusScreenState();
}

class _LiveRouteStatusScreenState extends State<LiveRouteStatusScreen> {
  int? _selectedTrainId;
  final DateTime _journeyDate = DateTime.now();
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final trainProv = Provider.of<TrainProvider>(context, listen: false);
      if (trainProv.featuredTrains.isEmpty) {
        trainProv.loadDashboard();
      }
      final train = widget.initialTrain ??
          trainProv.selectedTrain ??
          (trainProv.featuredTrains.isNotEmpty ? trainProv.featuredTrains.first : null);

      if (train != null) {
        setState(() => _selectedTrainId = train.id);
        trainProv.fetchTrainDetails(train.id, journeyDate: _journeyDate);
      }
    });
  }

  void _onTrainSelect(TrainModel train) {
    setState(() => _selectedTrainId = train.id);
    Provider.of<TrainProvider>(context, listen: false)
        .fetchTrainDetails(train.id, journeyDate: _journeyDate);
  }

  Future<void> _refresh() async {
    setState(() => _isRefreshing = true);
    final trainProv = Provider.of<TrainProvider>(context, listen: false);
    if (_selectedTrainId != null) {
      await trainProv.fetchTrainDetails(_selectedTrainId!, journeyDate: _journeyDate);
    }
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() => _isRefreshing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Live status refreshed! Demo location updated.'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final trainProv = Provider.of<TrainProvider>(context);
    final allTrains = trainProv.featuredTrains;
    final currentTrain = trainProv.selectedTrain;

    // Fallback if detail not yet loaded
    final activeTrain = (currentTrain != null && currentTrain.id == _selectedTrainId)
        ? currentTrain
        : (allTrains.where((t) => t.id == _selectedTrainId).firstOrNull ?? allTrains.firstOrNull);

    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F8),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Live Train Running Status',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            Text(
              activeTrain != null
                  ? '${activeTrain.trainNumber} - ${activeTrain.trainName}'
                  : 'Track Train Location',
              style: const TextStyle(fontSize: 11, color: AppColors.lightBlue),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Status',
            onPressed: _refresh,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const DemoBanner(),

            // ── TRAIN SELECTOR PILLS ─────────────────────────────────────
            if (allTrains.isNotEmpty)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: allTrains.map((tr) {
                      final isSelected = tr.id == _selectedTrainId;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          avatar: Icon(
                            Icons.train_rounded,
                            size: 16,
                            color: isSelected ? Colors.white : AppColors.primaryBlue,
                          ),
                          label: Text('${tr.trainNumber} ${tr.sourceStation.stationCode}→${tr.destinationStation.stationCode}'),
                          selected: isSelected,
                          onSelected: (_) => _onTrainSelect(tr),
                          selectedColor: AppColors.primaryBlue,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                            fontSize: 12,
                          ),
                          backgroundColor: AppColors.surfaceMuted,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? AppColors.primaryBlue : AppColors.border,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

            // ── TOP TIME BAR (like Image 2: Arrival | Day 1 - Date | Departure) ─
            Container(
              color: const Color(0xFF2C3437),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Arrival',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, color: Colors.white60, size: 12),
                      const SizedBox(width: 5),
                      Text(
                        'Day 1 - ${DateFormat("MMM d, E").format(_journeyDate)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Departure',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            // ── MAIN TIMELINE ROUTE ──────────────────────────────────────
            Expanded(
              child: activeTrain == null
                  ? const Center(child: CircularProgressIndicator())
                  : activeTrain.stops.isEmpty
                      ? const Center(
                          child: Text(
                            'Loading train stops and route...',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      : _buildTimeline(activeTrain),
            ),

            // ── BOTTOM LIVE STATUS BAR (like Image 2) ───────────────────
            if (activeTrain != null && activeTrain.stops.isNotEmpty)
              _buildBottomStatusBar(activeTrain),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(TrainModel train) {
    final stops = train.stops;
    final totalStops = stops.length;

    // Simulated live train index (e.g. 2nd or 3rd stop for demo)
    final currentIdx = totalStops > 3 ? (totalStops ~/ 3) : 1;

    return ListView.builder(
      padding: const EdgeInsets.only(top: 12, bottom: 20),
      itemCount: totalStops,
      itemBuilder: (context, idx) {
        final stop = stops[idx];
        final isFirst = idx == 0;
        final isLast = idx == totalStops - 1;
        final isPassed = idx < currentIdx;
        final isCurrent = idx == currentIdx;
        final isUpcoming = idx > currentIdx;

        // Platform simulation
        final platform = (stop.stopOrder % 3) + 1;

        // Scheduled vs actual/expected delay simulation (like Image 2 red text)
        final schedArr = _formatTime(stop.arrivalTime);
        final schedDept = _formatTime(stop.departureTime);
        final delayMin = isPassed ? 15 : (isCurrent ? 20 : 10);
        final actualArr = _addMinutes(stop.arrivalTime, delayMin);
        final actualDept = _addMinutes(stop.departureTime, delayMin);

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Left: Arrival times ───────────────────────────────────
              SizedBox(
                width: 75,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!isFirst) ...[
                        Text(
                          schedArr,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isPassed ? AppColors.textMuted : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          actualArr,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isPassed
                                ? const Color(0xFFC62828)
                                : isCurrent
                                    ? const Color(0xFFD32F2F)
                                    : const Color(0xFFE53935),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // ── Middle: Continuous Track with Live Train Marker ───────
              SizedBox(
                width: 44,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // Continuous track line
                    Positioned(
                      top: isFirst ? 24 : 0,
                      bottom: isLast ? 24 : 0,
                      child: Container(
                        width: 5,
                        decoration: BoxDecoration(
                          color: isPassed
                              ? const Color(0xFF1976D2)
                              : isCurrent
                                  ? const Color(0xFF1976D2)
                                  : const Color(0xFFCFD8DC),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),

                    // Station Dot or Live Train Position Icon
                    Positioned(
                      top: 14,
                      child: isCurrent
                          ? Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0288D1),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0288D1).withAlpha(120),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.train_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            )
                          : Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: isPassed ? const Color(0xFF1976D2) : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isPassed
                                      ? const Color(0xFF1976D2)
                                      : const Color(0xFF90A4AE),
                                  width: 3,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),

              // ── Station Info + Platform [ 2 ✏️ ] ────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stop.station.stationName,
                        style: TextStyle(
                          fontSize: isCurrent ? 15 : 13.5,
                          fontWeight: isCurrent || isFirst || isLast
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: isCurrent
                              ? AppColors.navyBlue
                              : (isUpcoming ? AppColors.textSecondary : AppColors.textPrimary),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            '${stop.distanceKm.toInt()} km',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Platform pill like Image 2
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFB0BEC5)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Platform $platform',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1565C0),
                                  ),
                                ),
                                const SizedBox(width: 3),
                                const Icon(Icons.edit_outlined, size: 10, color: Color(0xFF1565C0)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Right: Departure times ─────────────────────────────────
              SizedBox(
                width: 75,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!isLast) ...[
                        Text(
                          schedDept,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isPassed ? AppColors.textMuted : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          actualDept,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isPassed
                                ? const Color(0xFFC62828)
                                : isCurrent
                                    ? const Color(0xFFD32F2F)
                                    : const Color(0xFFE53935),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomStatusBar(TrainModel train) {
    final stops = train.stops;
    final currentIdx = stops.length > 3 ? (stops.length ~/ 3) : 1;
    final currentStop = stops[currentIdx];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Departed ${currentStop.station.stationName}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFC62828),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Updates few seconds ago  •  Demo live tracking',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: _refresh,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFF0D47A1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '--:--';
    return timeStr.length >= 5 ? timeStr.substring(0, 5) : timeStr;
  }

  String _addMinutes(String? timeStr, int minutes) {
    if (timeStr == null || timeStr.isEmpty) return '--:--';
    try {
      final parts = timeStr.split(':');
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final totalMin = (h * 60 + m + minutes) % (24 * 60);
      final newH = totalMin ~/ 60;
      final newM = totalMin % 60;
      final hStr = newH.toString().padLeft(2, '0');
      final mStr = newM.toString().padLeft(2, '0');
      return '$hStr:$mStr';
    } catch (_) {
      return timeStr.substring(0, 5);
    }
  }
}
