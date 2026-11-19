import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/crowd_utils.dart';
import '../../models/coach_model.dart';
import '../../models/train_model.dart';
import '../../providers/train_provider.dart';
import '../../widgets/demo_banner.dart';
import '../../widgets/train_top_view.dart';
import 'submit_crowd_report_screen.dart';

class CoachCrowdScreen extends StatefulWidget {
  final TrainModel train;
  final DateTime journeyDate;

  const CoachCrowdScreen({
    super.key,
    required this.train,
    required this.journeyDate,
  });

  @override
  State<CoachCrowdScreen> createState() => _CoachCrowdScreenState();
}

class _CoachCrowdScreenState extends State<CoachCrowdScreen>
    with SingleTickerProviderStateMixin {
  String _filter = 'ALL';
  CoachModel? _selectedCoach; // tapped coach in train view
  late final ScrollController _listScroll;

  @override
  void initState() {
    super.initState();
    _listScroll = ScrollController();
  }

  @override
  void dispose() {
    _listScroll.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  List<CoachModel> _filtered(List<CoachModel> all) {
    return all.where((c) {
      if (_filter == 'ALL') return true;
      if (_filter == 'AC') return c.coachType.startsWith('AC');
      if (_filter == 'SLEEPER') return c.coachType == 'SLEEPER';
      if (_filter == 'GENERAL') return c.coachType == 'GENERAL';
      return true;
    }).toList();
  }

  void _onCoachTap(CoachModel coach) {
    setState(() => _selectedCoach = coach);
    // scroll list to that coach
    final train = Provider.of<TrainProvider>(context, listen: false).selectedTrain ?? widget.train;
    final filtered = _filtered(train.coaches);
    final idx = filtered.indexWhere((c) => c.id == coach.id);
    if (idx >= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _listScroll.animateTo(
          idx * 148.0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final trainProv = Provider.of<TrainProvider>(context);
    final train = trainProv.selectedTrain ?? widget.train;
    final coaches = train.coaches;
    final filtered = _filtered(coaches);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${train.trainNumber} – Coach View',
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 16)),
            Text(
              '${train.trainName}  •  ${train.sourceStation.stationCode} → ${train.destinationStation.stationCode}',
              style:
                  const TextStyle(fontSize: 11, color: AppColors.lightBlue),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DemoBanner(),

            // ── TOP-DOWN TRAIN VISUALIZATION ──────────────────────────────
            TrainTopView(
              coaches: coaches,
              selectedFilter: _filter,
              onCoachTap: _onCoachTap,
            ),

            // ── FILTER CHIPS ──────────────────────────────────────────────
            _FilterBar(
              coaches: coaches,
              selectedFilter: _filter,
              onFilterChanged: (f) =>
                  setState(() {
                    _filter = f;
                    _selectedCoach = null;
                  }),
            ),

            // ── SECTION LABEL ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: Row(
                children: [
                  const Icon(Icons.view_list_rounded,
                      size: 15, color: AppColors.primaryBlue),
                  const SizedBox(width: 6),
                  Text(
                    '${filtered.length} ${_filterLabel(_filter)} coach${filtered.length == 1 ? '' : 'es'}',
                    style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navyBlue),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: AppColors.border),

            // ── COACH DETAIL LIST ─────────────────────────────────────────
            Expanded(
              child: filtered.isEmpty
                  ? _EmptyState(filter: _filter)
                  : ListView.builder(
                      controller: _listScroll,
                      padding: const EdgeInsets.only(bottom: 24, top: 4),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) {
                        final coach = filtered[i];
                        final isSelected =
                            _selectedCoach?.id == coach.id;
                        return _CoachDetailCard(
                          coach: coach,
                          isSelected: isSelected,
                          onReportTap: () =>
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                    builder: (_) =>
                                        SubmitCrowdReportScreen(
                                      train: train,
                                      journeyDate: widget.journeyDate,
                                      initialCoachId: coach.id,
                                    ),
                                  ))
                                  .then((_) => trainProv.fetchTrainDetails(
                                      train.id,
                                      journeyDate: widget.journeyDate)),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _filterLabel(String f) {
    switch (f) {
      case 'AC':
        return 'AC';
      case 'SLEEPER':
        return 'Sleeper';
      case 'GENERAL':
        return 'General';
      default:
        return 'total';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter Bar
// ─────────────────────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  final List<CoachModel> coaches;
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const _FilterBar({
    required this.coaches,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  int _count(String f) {
    if (f == 'ALL') return coaches.length;
    if (f == 'AC') { return coaches.where((c) => c.coachType.startsWith('AC')).length; }
    if (f == 'SLEEPER') { return coaches.where((c) => c.coachType == 'SLEEPER').length; }
    if (f == 'GENERAL') { return coaches.where((c) => c.coachType == 'GENERAL').length; }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final filters = [
      ('ALL', 'All Coaches', Icons.train_rounded, AppColors.primaryBlue),
      ('AC', 'AC Coaches', Icons.ac_unit_rounded, const Color(0xFF43A047)),
      ('SLEEPER', 'Sleeper', Icons.hotel_rounded, const Color(0xFFFB8C00)),
      ('GENERAL', 'General', Icons.people_rounded, const Color(0xFFE53935)),
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((f) {
            final id = f.$1;
            final label = f.$2;
            final icon = f.$3;
            final color = f.$4;
            final count = _count(id);
            final selected = selectedFilter == id;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onFilterChanged(id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: selected ? color : AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                        color: selected ? color : AppColors.border,
                        width: 1.5),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                                color: color.withAlpha(80),
                                blurRadius: 8,
                                offset: const Offset(0, 3))
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon,
                          size: 15,
                          color: selected ? Colors.white : color),
                      const SizedBox(width: 6),
                      Text(label,
                          style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: selected
                                  ? Colors.white
                                  : AppColors.textPrimary)),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: selected
                              ? Colors.white.withAlpha(50)
                              : color.withAlpha(30),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('$count',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: selected ? Colors.white : color)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Coach Detail Card
// ─────────────────────────────────────────────────────────────────────────────

class _CoachDetailCard extends StatelessWidget {
  final CoachModel coach;
  final bool isSelected;
  final VoidCallback onReportTap;

  const _CoachDetailCard({
    required this.coach,
    required this.isSelected,
    required this.onReportTap,
  });

  @override
  Widget build(BuildContext context) {
    final crowdLevel = coach.crowdInfo.crowdLevel;
    final dotColor = TrainTopView.dotColorForType(coach.coachType);
    final crowdColor = CrowdUtils.getColor(crowdLevel);
    final hasData = crowdLevel != 'INSUFFICIENT_DATA';
    final dotCount =
        TrainTopView.dotCountForCrowd(crowdLevel).clamp(0, 24);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? dotColor : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? dotColor.withAlpha(50)
                : Colors.black.withAlpha(12),
            blurRadius: isSelected ? 12 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Row(
              children: [
                // Mini top-down coach preview
                Container(
                  width: 52,
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1B2A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: dotColor.withAlpha(100), width: 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: _DotGridMini(
                      dotColor: dotColor,
                      filledDots: dotCount,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            coach.coachNumber,
                            style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 17,
                                color: AppColors.navyBlue),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: dotColor.withAlpha(30),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              coach.coachTypeDisplay,
                              style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: dotColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Crowd badge
                      if (hasData)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: crowdColor.withAlpha(25),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: crowdColor.withAlpha(80)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(CrowdUtils.getIcon(crowdLevel),
                                  size: 13, color: crowdColor),
                              const SizedBox(width: 5),
                              Text(
                                CrowdUtils.getLabel(crowdLevel),
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: crowdColor),
                              ),
                            ],
                          ),
                        )
                      else
                        const Text(
                          'Not enough data yet',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              fontStyle: FontStyle.italic),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Crowd explanation ────────────────────────────────────────
            if (coach.crowdInfo.explanation.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                coach.crowdInfo.explanation,
                style: const TextStyle(
                    fontSize: 11.5, color: AppColors.textSecondary),
              ),
            ],

            const SizedBox(height: 10),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 10),

            // ── Stats row ────────────────────────────────────────────────
            Row(
              children: [
                _StatPill(
                  icon: Icons.how_to_vote_outlined,
                  label: '${coach.crowdInfo.validReportCount} reports',
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(width: 8),
                _StatPill(
                  icon: Icons.bar_chart_rounded,
                  label: coach.crowdInfo.confidenceLevel == 'NONE'
                      ? 'No confidence'
                      : '${coach.crowdInfo.confidenceLevel.toLowerCase().replaceAll('_', ' ')} confidence',
                  color: AppColors.textSecondary,
                ),
              ],
            ),

            // ── Dot legend for this coach ─────────────────────────────────
            if (hasData) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        color: dotColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Each dot = 1 passenger (demo illustration, $dotCount / 24 seats)',
                    style: const TextStyle(
                        fontSize: 10.5,
                        color: AppColors.textMuted,
                        fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 10),

            // ── Report button ────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onReportTap,
                icon: const Icon(Icons.edit_note_rounded, size: 16),
                label: const Text('Report Crowd for this Coach'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  side: const BorderSide(color: AppColors.primaryBlue),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  textStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mini dot grid (inside coach detail card preview)
// ─────────────────────────────────────────────────────────────────────────────

class _DotGridMini extends StatelessWidget {
  final Color dotColor;
  final int filledDots;
  static const int _cols = 3;
  static const int _rows = 5;
  static const int _max = _cols * _rows; // 15

  const _DotGridMini({required this.dotColor, required this.filledDots});

  @override
  Widget build(BuildContext context) {
    final filled = (filledDots * _max ~/ 24).clamp(0, _max);
    if (filled == 0) {
      return Center(
        child: Text('?',
            style: TextStyle(
                color: Colors.white.withAlpha(40),
                fontSize: 20,
                fontWeight: FontWeight.w900)),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(_rows, (r) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(_cols, (c) {
            final idx = r * _cols + c;
            final on = idx < filled;
            return Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    on ? dotColor : Colors.white.withAlpha(15),
                boxShadow: on
                    ? [BoxShadow(color: dotColor.withAlpha(120), blurRadius: 3)]
                    : [],
              ),
            );
          }),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small helpers
// ─────────────────────────────────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatPill(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color)),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.train_outlined,
                size: 48,
                color: AppColors.textMuted.withAlpha(100)),
            const SizedBox(height: 14),
            const Text('No coaches in this category',
                style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
