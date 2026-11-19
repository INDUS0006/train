import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/train_provider.dart';
import '../../widgets/demo_banner.dart';
import '../../widgets/train_card.dart';
import '../search/train_search_results_screen.dart';
import '../search/train_detail_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  String _selectedFromCode = 'HYB';
  String _selectedToCode = 'BZA';
  DateTime _selectedDate = DateTime.now();
  final _searchQueryController = TextEditingController();

  void _swapStations() {
    setState(() {
      final temp = _selectedFromCode;
      _selectedFromCode = _selectedToCode;
      _selectedToCode = temp;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _executeSearch({String? from, String? to, String? query}) {
    final trainProv = Provider.of<TrainProvider>(context, listen: false);
    final fromCode = from ?? _selectedFromCode;
    final toCode = to ?? _selectedToCode;

    trainProv.searchTrains(
      fromCode: fromCode,
      toCode: toCode,
      journeyDate: _selectedDate,
      query: query ?? _searchQueryController.text.trim(),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TrainSearchResultsScreen(
          fromCode: fromCode,
          toCode: toCode,
          journeyDate: _selectedDate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final trainProv = Provider.of<TrainProvider>(context);
    final stations = trainProv.stations;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(35),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.train, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TrainBuddy', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                Text('Crowd Advisor', style: TextStyle(fontSize: 10.5, color: AppColors.lightBlue)),
              ],
            ),
          ],
        ),
        actions: [
          if (auth.isGuest)
            Container(
              margin: const EdgeInsets.only(right: 14),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.shade700,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.person, size: 13, color: Colors.white),
                  SizedBox(width: 4),
                  Text('GUEST DEMO', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Colors.white)),
                ],
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await trainProv.loadDashboard();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DemoBanner(),

              // Welcome & Hero Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 26),
                decoration: const BoxDecoration(
                  color: AppColors.navyBlue,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${auth.user?.displayName ?? "Passenger"} 👋',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Check how crowded your train may be before boarding.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shield_outlined, size: 14, color: AppColors.lightBlue),
                          SizedBox(width: 6),
                          Text(
                            'Verified passenger crowd intelligence',
                            style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Search Box Card (overlapping upward)
              Transform.translate(
                offset: const Offset(0, -14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Search by train number/name
                          TextField(
                            controller: _searchQueryController,
                            decoration: InputDecoration(
                              hintText: 'Search by train name or number (e.g. 12723)',
                              prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.primaryBlue),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onSubmitted: (val) => _executeSearch(query: val),
                          ),
                          const SizedBox(height: 14),

                          // From & To Station Selectors with Swap
                          Row(
                            children: [
                              // From Station
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.border),
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('FROM', style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w700)),
                                      DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          isExpanded: true,
                                          value: stations.any((s) => s.stationCode == _selectedFromCode)
                                              ? _selectedFromCode
                                              : (stations.isNotEmpty ? stations.first.stationCode : 'HYB'),
                                          items: stations.map((s) {
                                            return DropdownMenuItem<String>(
                                              value: s.stationCode,
                                              child: Text('${s.stationCode} - ${s.city}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                                            );
                                          }).toList(),
                                          onChanged: (val) {
                                            if (val != null) setState(() => _selectedFromCode = val);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Swap Button
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: IconButton(
                                  onPressed: _swapStations,
                                  icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.primaryBlue),
                                  tooltip: 'Swap Stations',
                                ),
                              ),
                              // To Station
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.border),
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('TO', style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w700)),
                                      DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          isExpanded: true,
                                          value: stations.any((s) => s.stationCode == _selectedToCode)
                                              ? _selectedToCode
                                              : (stations.length > 5 ? stations[5].stationCode : 'BZA'),
                                          items: stations.map((s) {
                                            return DropdownMenuItem<String>(
                                              value: s.stationCode,
                                              child: Text('${s.stationCode} - ${s.city}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                                            );
                                          }).toList(),
                                          onChanged: (val) {
                                            if (val != null) setState(() => _selectedToCode = val);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Journey Date Picker
                          InkWell(
                            onTap: _pickDate,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white,
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.primaryBlue),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('JOURNEY DATE', style: TextStyle(fontSize: 9.5, color: AppColors.textMuted, fontWeight: FontWeight.w700)),
                                      Text(
                                        DateFormat('EEEE, d MMM yyyy').format(_selectedDate),
                                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.arrow_drop_down, color: AppColors.textMuted),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Search Trains Button
                          ElevatedButton.icon(
                            onPressed: () => _executeSearch(),
                            icon: const Icon(Icons.search, size: 20),
                            label: const Text('Find Trains & Crowd Estimates'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Popular Routes Corridor
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.trending_up, size: 18, color: AppColors.primaryBlue),
                        SizedBox(width: 6),
                        Text(
                          'Popular Demo Corridors',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navyBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: trainProv.popularRoutes.map((route) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ActionChip(
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              avatar: const Icon(Icons.directions_train, size: 16, color: AppColors.primaryBlue),
                              label: Text(
                                '${route['from_code']} → ${route['to_code']} (${route['popular_tag']})',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.navyBlue),
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedFromCode = route['from_code'];
                                  _selectedToCode = route['to_code'];
                                });
                                _executeSearch(from: route['from_code'], to: route['to_code']);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // Crowd Information Legend & Explanation Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.lightbulb_outline, color: AppColors.warning, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'How TrainBuddy Crowd Levels Work',
                              style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.navyBlue),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'We aggregate verified passenger reports with recency weighting and GPS journey confirmation. Honest and transparent:',
                          style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.3),
                        ),
                        const SizedBox(height: 12),
                        // Levels Grid
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: const [
                            _LegendPill(color: AppColors.crowdLow, label: 'Low', desc: 'Seats Available'),
                            _LegendPill(color: AppColors.crowdMedium, label: 'Medium', desc: 'Moderate Standing'),
                            _LegendPill(color: AppColors.crowdHigh, label: 'High', desc: 'Heavy Rush'),
                            _LegendPill(color: AppColors.crowdVeryHigh, label: 'Very High', desc: 'Gate Rush'),
                            _LegendPill(color: AppColors.crowdInsufficient, label: 'No Data', desc: 'Awaiting Reports'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Featured / Popular Trains List
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Monitored Demonstration Trains',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navyBlue,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _executeSearch(),
                      child: const Text('View All', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),

              if (trainProv.isLoadingDashboard)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (trainProv.featuredTrains.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No trains loaded. Pull down to refresh.', style: TextStyle(color: AppColors.textMuted)),
                  ),
                )
              else
                ...trainProv.featuredTrains.map((train) {
                  return TrainCard(
                    train: train,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TrainDetailScreen(trainId: train.id),
                        ),
                      );
                    },
                    onToggleSave: () {
                      trainProv.toggleSaveTrain(train.id);
                    },
                  );
                }),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendPill extends StatelessWidget {
  final Color color;
  final String label;
  final String desc;

  const _LegendPill({required this.color, required this.label, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 11)),
          const SizedBox(width: 4),
          Text('($desc)', style: TextStyle(color: AppColors.textSecondary, fontSize: 10.5)),
        ],
      ),
    );
  }
}
