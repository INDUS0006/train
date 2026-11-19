import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/crowd_utils.dart';
import '../../providers/train_provider.dart';
import '../../widgets/crowd_badge.dart';
import '../../widgets/demo_banner.dart';
import '../crowd/coach_crowd_screen.dart';
import '../crowd/submit_crowd_report_screen.dart';
import '../alternatives/alternatives_screen.dart';
import '../journey/gps_validation_screen.dart';

class TrainDetailScreen extends StatefulWidget {
  final int trainId;
  final DateTime? journeyDate;

  const TrainDetailScreen({
    super.key,
    required this.trainId,
    this.journeyDate,
  });

  @override
  State<TrainDetailScreen> createState() => _TrainDetailScreenState();
}

class _TrainDetailScreenState extends State<TrainDetailScreen> {
  late DateTime _currentDate;

  @override
  void initState() {
    super.initState();
    _currentDate = widget.journeyDate ?? DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TrainProvider>(context, listen: false).fetchTrainDetails(
        widget.trainId,
        journeyDate: _currentDate,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final trainProv = Provider.of<TrainProvider>(context);
    final train = trainProv.selectedTrain;

    if (trainProv.isLoadingDetails || train == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Train Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final est = train.crowdEstimate;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${train.trainNumber} - ${train.trainName}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            Text('${train.sourceStation.stationCode} → ${train.destinationStation.stationCode}', style: const TextStyle(fontSize: 11, color: AppColors.lightBlue)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(train.isSaved ? Icons.bookmark : Icons.bookmark_border),
            onPressed: () {
              trainProv.toggleSaveTrain(train.id);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DemoBanner(),

              // Top Train Overview Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.navyBlue,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              train.departureTime.length >= 5 ? train.departureTime.substring(0, 5) : train.departureTime,
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                            ),
                            Text(
                              '${train.sourceStation.stationName} (${train.sourceStation.stationCode})',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(train.durationDisplay, style: const TextStyle(color: AppColors.lightBlue, fontSize: 12, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              train.arrivalTime.length >= 5 ? train.arrivalTime.substring(0, 5) : train.arrivalTime,
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                            ),
                            Text(
                              '${train.destinationStation.stationName} (${train.destinationStation.stationCode})',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(20),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Journey Date: ${DateFormat("EEEE, d MMM yyyy").format(_currentDate)}',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

              // Overall Crowd Level Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Overall Train Crowd',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.navyBlue,
                              ),
                            ),
                            CrowdBadge(crowdLevel: est.crowdLevel),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          est.explanation.isNotEmpty
                              ? est.explanation
                              : CrowdUtils.getAdvisoryText(est.crowdLevel),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Divider(color: AppColors.border, height: 1),
                        const SizedBox(height: 12),

                        // Stats Grid
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _CrowdStat(
                              label: 'Valid Reports',
                              value: '${est.validReportCount}',
                              icon: Icons.verified,
                              iconColor: AppColors.success,
                            ),
                            _CrowdStat(
                              label: 'Confidence',
                              value: CrowdUtils.formatConfidence(est.confidenceLevel, est.confidenceScore),
                              icon: Icons.analytics_outlined,
                              iconColor: AppColors.primaryBlue,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Action Buttons Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Primary Actions: Coach Crowds & Submit Report
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => CoachCrowdScreen(
                                    train: train,
                                    journeyDate: _currentDate,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.grid_view_rounded, size: 18),
                            label: const Text('Coach Crowds'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => SubmitCrowdReportScreen(
                                    train: train,
                                    journeyDate: _currentDate,
                                  ),
                                ),
                              ).then((_) {
                                trainProv.fetchTrainDetails(train.id, journeyDate: _currentDate);
                              });
                            },
                            icon: const Icon(Icons.rate_review_outlined, size: 18),
                            label: const Text('Report Crowd'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.navyBlue,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Secondary Actions: Alternatives only (Route Map replaced inline)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => AlternativesScreen(train: train),
                                ),
                              );
                            },
                            icon: const Icon(Icons.alt_route_rounded, size: 18),
                            label: const Text('Alternatives'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => GpsValidationScreen(train: train),
                                ),
                              );
                            },
                            icon: const Icon(Icons.my_location_rounded, size: 18),
                            label: const Text('GPS Track'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── INLINE ROUTE TRACKER (replaces Route Map button) ─────────
              _InlineRouteTracker(train: train, journeyDate: _currentDate),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _CrowdStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _CrowdStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _InlineRouteTracker
//
// A live-tracker-style vertical timeline showing every station stop.
// Simulates a train position indicator between two stops.
// Replaces the external "Route Map" button entirely.
// ─────────────────────────────────────────────────────────────────────────────

class _InlineRouteTracker extends StatelessWidget {
  final dynamic train;
  final DateTime journeyDate;

  const _InlineRouteTracker({required this.train, required this.journeyDate});

  /// Simulated "current" stop index — midway through the journey for demo.
  int get _simCurrentStop {
    final n = (train.stops as List).length;
    return n > 2 ? (n ~/ 3) : 0;
  }

  String _fmtTime(String? t) =>
      (t != null && t.length >= 5) ? t.substring(0, 5) : '--:--';

  @override
  Widget build(BuildContext context) {
    final stops = train.stops as List;
    final totalStops = stops.length;
    final currentIdx = _simCurrentStop;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.softBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.route_rounded,
                    color: AppColors.primaryBlue, size: 18),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Route  •  ${train.trainNumber}',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navyBlue),
                  ),
                  Text(
                    '$totalStops stations  •  ${train.sourceStation.stationCode} → ${train.destinationStation.stationCode}',
                    style: const TextStyle(
                        fontSize: 11.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const Spacer(),
              // Day chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.navyBlue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  DateFormat('d MMM').format(journeyDate),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),

        // ── Arrival / Departure column headers ────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              SizedBox(
                width: 52,
                child: Text('Arrival',
                    style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted.withAlpha(160))),
              ),
              const SizedBox(width: 10),
              const SizedBox(width: 24), // timeline column
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Station',
                    style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted)),
              ),
              SizedBox(
                width: 52,
                child: Text('Depart',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted.withAlpha(160))),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // ── Timeline list ──────────────────────────────────────────────────
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 14),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: totalStops,
              itemBuilder: (context, idx) {
                final stop = stops[idx];
                final isFirst = idx == 0;
                final isLast = idx == totalStops - 1;
                final isPassed = idx < currentIdx;
                final isCurrent = idx == currentIdx;
                final isUpcoming = idx > currentIdx;

                return _RouteStopRow(
                  stop: stop,
                  isFirst: isFirst,
                  isLast: isLast,
                  isPassed: isPassed,
                  isCurrent: isCurrent,
                  isUpcoming: isUpcoming,
                  isLastItem: isLast,
                  fmtTime: _fmtTime,
                );
              },
            ),
          ),
        ),

        // ── Demo notice ───────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              const Icon(Icons.info_outline,
                  size: 13, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Train position is simulated for demo purposes. '
                  'Platform numbers are illustrative.',
                  style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textMuted,
                      fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single stop row in the route tracker
// ─────────────────────────────────────────────────────────────────────────────

class _RouteStopRow extends StatelessWidget {
  final dynamic stop;
  final bool isFirst;
  final bool isLast;
  final bool isPassed;
  final bool isCurrent;
  final bool isUpcoming;
  final bool isLastItem;
  final String Function(String?) fmtTime;

  const _RouteStopRow({
    required this.stop,
    required this.isFirst,
    required this.isLast,
    required this.isPassed,
    required this.isCurrent,
    required this.isUpcoming,
    required this.isLastItem,
    required this.fmtTime,
  });

  @override
  Widget build(BuildContext context) {
    // Colours per status
    final lineColor = isPassed
        ? AppColors.primaryBlue
        : AppColors.border;

    final dotBorderColor = isCurrent
        ? AppColors.crowdHigh
        : isPassed || isFirst || isLast
            ? AppColors.primaryBlue
            : AppColors.border;

    final dotBg = isCurrent
        ? AppColors.crowdHigh
        : isPassed
            ? AppColors.primaryBlue
            : Colors.white;

    final textColor =
        isUpcoming ? AppColors.textSecondary : AppColors.textPrimary;
    final timeColor = isPassed
        ? AppColors.textMuted
        : isCurrent
            ? AppColors.primaryBlue
            : AppColors.textPrimary;

    // Platform number simulation
    final platform = (stop.stopOrder % 4) + 1;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Arrival time ─────────────────────────────────────────────
          SizedBox(
            width: 68,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!isFirst)
                    Text(
                      fmtTime(stop.arrivalTime),
                      style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: timeColor),
                    ),
                  if (!isFirst && !isLast && stop.haltMinutes > 0)
                    Text('${stop.haltMinutes}m',
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.textMuted)),
                ],
              ),
            ),
          ),

          // ── Timeline column ───────────────────────────────────────────
          SizedBox(
            width: 32,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Top line
                if (!isFirst)
                  Positioned(
                    top: 0,
                    bottom: 24,
                    child: Container(
                      width: 3,
                      color: lineColor,
                    ),
                  ),
                // Bottom line
                if (!isLastItem)
                  Positioned(
                    top: 24,
                    bottom: 0,
                    child: Container(
                      width: 3,
                      color: isPassed
                          ? AppColors.primaryBlue
                          : AppColors.border,
                    ),
                  ),
                // Station dot / train icon
                Positioned(
                  top: 10,
                  child: isCurrent
                      ? Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.crowdHigh,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: Colors.white, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                  color:
                                      AppColors.crowdHigh.withAlpha(140),
                                  blurRadius: 10,
                                  spreadRadius: 2),
                            ],
                          ),
                          child: const Icon(Icons.train,
                              color: Colors.white, size: 15),
                        )
                      : Container(
                          width: (isFirst || isLast) ? 20 : 14,
                          height: (isFirst || isLast) ? 20 : 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: dotBg,
                            border: Border.all(
                                color: dotBorderColor,
                                width: (isFirst || isLast) ? 3 : 2.5),
                          ),
                          child: isPassed
                              ? const Icon(Icons.check,
                                  size: 8, color: Colors.white)
                              : null,
                        ),
                ),
              ],
            ),
          ),

          // ── Station info ──────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stop.station.stationName,
                    style: TextStyle(
                      fontWeight: (isFirst || isLast || isCurrent)
                          ? FontWeight.w800
                          : FontWeight.w600,
                      fontSize:
                          (isFirst || isLast || isCurrent) ? 13.5 : 12.5,
                      color: isCurrent
                          ? AppColors.navyBlue
                          : textColor,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        stop.station.stationCode,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryBlue.withAlpha(
                                isUpcoming ? 120 : 220)),
                      ),
                      if (stop.distanceKm > 0) ...[
                        const Text('  ·  ',
                            style: TextStyle(
                                color: AppColors.textMuted, fontSize: 10)),
                        Text(
                          '${stop.distanceKm.toInt()} km',
                          style: const TextStyle(
                              fontSize: 10.5, color: AppColors.textMuted),
                        ),
                      ],
                      const Text('  ·  ',
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 10)),
                      Text(
                        'Pf $platform',
                        style: const TextStyle(
                            fontSize: 10.5, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  if (isCurrent)
                    Container(
                      margin: const EdgeInsets.only(top: 3),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.crowdHigh.withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.crowdHigh.withAlpha(80)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.train,
                              size: 10, color: AppColors.crowdHigh),
                          SizedBox(width: 4),
                          Text('Train here (demo)',
                              style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.crowdHigh)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Departure time ────────────────────────────────────────────
          SizedBox(
            width: 54,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!isLast)
                    Text(
                      fmtTime(stop.departureTime),
                      style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: timeColor),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
