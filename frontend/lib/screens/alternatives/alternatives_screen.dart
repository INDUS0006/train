import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/train_model.dart';
import '../../models/travel_alternative_model.dart';
import '../../providers/crowd_provider.dart';
import '../../widgets/demo_banner.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Local demo data models (self-contained, no backend needed for car/flight)
// ─────────────────────────────────────────────────────────────────────────────

class _ModeOption {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _ModeOption({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}

class _RichAlternative {
  final String title;
  final String subtitle;
  final String operator;
  final String departure;
  final String arrival;
  final String duration;
  final String distance;
  final String fareMin;
  final String fareMax;
  final String fareNote;
  final List<String> highlights;
  final String disclaimer;

  const _RichAlternative({
    required this.title,
    required this.subtitle,
    required this.operator,
    required this.departure,
    required this.arrival,
    required this.duration,
    required this.distance,
    required this.fareMin,
    required this.fareMax,
    required this.fareNote,
    required this.highlights,
    required this.disclaimer,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Static demo data: HYB → VSKP alternatives
// ─────────────────────────────────────────────────────────────────────────────

const List<_ModeOption> _modes = [
  _ModeOption(id: 'train', label: 'Train', icon: Icons.train_rounded,         color: AppColors.primaryBlue, bgColor: AppColors.softBlue),
  _ModeOption(id: 'bus',   label: 'Bus',   icon: Icons.directions_bus_rounded, color: Color(0xFF2E7D32),     bgColor: Color(0xFFE8F5E9)),
  _ModeOption(id: 'car',   label: 'Car',   icon: Icons.directions_car_rounded, color: Color(0xFFE65100),     bgColor: Color(0xFFFFF3E0)),
  _ModeOption(id: 'flight',label: 'Flight',icon: Icons.flight_rounded,         color: Color(0xFF6A1B9A),     bgColor: Color(0xFFF3E5F5)),
];

final Map<String, List<_RichAlternative>> _demoData = {
  'train': [
    _RichAlternative(
      title: '17210 – Seshadri Express',
      subtitle: 'Hyderabad → Visakhapatnam',
      operator: 'South Central Railway',
      departure: '20:30', arrival: '12:00',
      duration: '15h 30m', distance: '711 km',
      fareMin: '₹375', fareMax: '₹1,145',
      fareNote: 'Sleeper – 3A. Book on IRCTC.',
      highlights: ['Less crowded departure', 'Overnight journey', 'Pantry car available', 'Reservation required'],
      disclaimer: 'DEMO DATA – Schedule may differ. Check IRCTC for live availability.',
    ),
    _RichAlternative(
      title: '12760 – Charminar SF Express',
      subtitle: 'Hyderabad → Visakhapatnam',
      operator: 'South Central Railway',
      departure: '06:00', arrival: '17:30',
      duration: '11h 30m', distance: '711 km',
      fareMin: '₹425', fareMax: '₹1,320',
      fareNote: 'Superfast surcharge applies.',
      highlights: ['Superfast train', 'Daytime journey', 'Lower crowd reported', '8 stops en route'],
      disclaimer: 'DEMO DATA – Schedule may differ. Check IRCTC for live availability.',
    ),
  ],
  'bus': [
    _RichAlternative(
      title: 'TSRTC Volvo A/C Sleeper',
      subtitle: 'Hyderabad MGBS → Visakhapatnam RTC Complex',
      operator: 'Telangana State RTC',
      departure: '18:00', arrival: '06:30',
      duration: '12h 30m', distance: '720 km via NH-16',
      fareMin: '₹900', fareMax: '₹1,200',
      fareNote: 'Per seat. Book at TSRTC counter or website.',
      highlights: ['Volvo A/C Sleeper', 'Reclining seats', 'EN-route meal stops', 'GPS tracked buses'],
      disclaimer: 'DEMO DATA – Fare and schedule approximate. Verify at TSRTC website.',
    ),
    _RichAlternative(
      title: 'Private Sleeper (RedBus)',
      subtitle: 'Hyderabad → Visakhapatnam (Multiple Operators)',
      operator: 'SRS / Orange / KALLADA Travels',
      departure: '19:00–21:00', arrival: '06:00–08:00',
      duration: '11–13h', distance: '~720 km via NH-16',
      fareMin: '₹700', fareMax: '₹1,500',
      fareNote: 'Price varies by operator & seat type.',
      highlights: ['Multiple operators', 'Sleeper & semi-sleeper', 'Book on RedBus / AbhiBus', 'Live tracking available'],
      disclaimer: 'DEMO DATA – Prices from online aggregators. Subject to change.',
    ),
    _RichAlternative(
      title: 'APSRTC Super Luxury',
      subtitle: 'Hyderabad → Visakhapatnam',
      operator: 'Andhra Pradesh State RTC',
      departure: '20:00', arrival: '07:00',
      duration: '11h', distance: '707 km',
      fareMin: '₹550', fareMax: '₹850',
      fareNote: 'Non-A/C Super Luxury class.',
      highlights: ['Government operated', 'Economical option', 'Multiple boarding points', 'Reclining seats'],
      disclaimer: 'DEMO DATA – Confirm at nearest APSRTC counter.',
    ),
  ],
  'car': [
    _RichAlternative(
      title: 'Self-Drive via NH-65 → NH-16',
      subtitle: 'Hyderabad → Visakhapatnam (Recommended Route)',
      operator: 'Your own vehicle',
      departure: 'Flexible', arrival: 'Flexible',
      duration: '~10–11h (non-stop)', distance: '707 km',
      fareMin: '₹3,500', fareMax: '₹5,000',
      fareNote: 'Fuel estimate (petrol car, ~15 km/l). Tolls ≈ ₹650.',
      highlights: [
        'Route: HYB → Warangal → Khammam → Rajahmundry → Vizag',
        'Tolls: Approx ₹650 (NH-16 & NH-65)',
        'Petrol stops: Every 150–200 km',
        'Overnight driving not recommended',
      ],
      disclaimer: 'DEMO DATA – Fuel price and toll rates are approximate.',
    ),
    _RichAlternative(
      title: 'Outstation Cab (OLA / Uber)',
      subtitle: 'Hyderabad → Visakhapatnam (One-way taxi)',
      operator: 'OLA Outstation / Uber Intercity / Savaari',
      departure: 'Book 24h+ in advance', arrival: '~10–11h later',
      duration: '10–11h', distance: '707 km',
      fareMin: '₹5,500', fareMax: '₹8,000',
      fareNote: 'Sedan / SUV rate. Driver allowance included.',
      highlights: [
        'Door-to-door pickup',
        'AC sedan or SUV',
        'Professional driver',
        'Tolls included in most packages',
      ],
      disclaimer: 'DEMO DATA – Fare from OLA Outstation / Savaari website (approximate).',
    ),
    _RichAlternative(
      title: 'Car Rental (Self-Drive)',
      subtitle: 'Pick up Hyderabad, Drop Visakhapatnam',
      operator: 'Zoomcar / Myles / Revv',
      departure: 'Flexible', arrival: 'Flexible',
      duration: '10–11h driving', distance: '707 km',
      fareMin: '₹3,000', fareMax: '₹4,500',
      fareNote: 'Per day rental + per km charge. One-way fee applies.',
      highlights: [
        'Choose your own car',
        'Fuel on renter',
        'One-way drop may incur extra charge',
        'Minimum age 21 & valid DL required',
      ],
      disclaimer: 'DEMO DATA – Rates from Zoomcar app (illustrative).',
    ),
  ],
  'flight': [
    _RichAlternative(
      title: 'IndiGo / Air India Express',
      subtitle: 'Rajiv Gandhi Intl Airport (HYD) → Visakhapatnam Airport (VTZ)',
      operator: 'IndiGo / Air India Express',
      departure: '06:00–21:00 (multiple)', arrival: '+1h 10m',
      duration: '1h 10m (flight)', distance: '~500 km (air)',
      fareMin: '₹2,500', fareMax: '₹8,000',
      fareNote: 'Economy class. Add airport transfers (~₹500–₹800 each end).',
      highlights: [
        '5–8 daily flights (approx)',
        'Door-to-door ~4–5h including transfers',
        'Book on MakeMyTrip / IRCTC Air / airline app',
        'Carry-on: 1 bag up to 7 kg free',
      ],
      disclaimer: 'DEMO DATA – Fare and schedule from public aggregators. Subject to change.',
    ),
    _RichAlternative(
      title: 'SpiceJet / Akasa Air',
      subtitle: 'Hyderabad (HYD) → Visakhapatnam (VTZ)',
      operator: 'SpiceJet / Akasa Air',
      departure: 'Morning & evening slots',
      arrival: '+1h 10m',
      duration: '1h 10m (flight)', distance: '~500 km (air)',
      fareMin: '₹1,800', fareMax: '₹6,500',
      fareNote: 'Economy. Budget airlines often cheaper on advance booking.',
      highlights: [
        'Competitive fares on early booking',
        'Web check-in available',
        'Minimal luggage: add check-in if needed',
        'Compare on Skyscanner / Paytm Travel',
      ],
      disclaimer: 'DEMO DATA – Illustrative fares. Book directly with airline.',
    ),
  ],
};

// ─────────────────────────────────────────────────────────────────────────────
// Main Screen
// ─────────────────────────────────────────────────────────────────────────────

class AlternativesScreen extends StatefulWidget {
  final TrainModel train;

  const AlternativesScreen({super.key, required this.train});

  @override
  State<AlternativesScreen> createState() => _AlternativesScreenState();
}

class _AlternativesScreenState extends State<AlternativesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedMode = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _modes.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedMode = _tabController.index);
      }
    });
    // Also fetch backend alternatives (train alternatives from API)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CrowdProvider>(context, listen: false)
          .fetchAlternatives(widget.train.id);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get _fromCode => widget.train.sourceStation.stationCode;
  String get _toCode   => widget.train.destinationStation.stationCode;

  @override
  Widget build(BuildContext context) {
    final mode = _modes[_selectedMode];

    // Merge backend train alternatives into demo train list
    final crowdProv = Provider.of<CrowdProvider>(context);
    final backendTrains = crowdProv.alternatives;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Travel Alternatives',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            Text('$_fromCode → $_toCode  •  ${widget.train.trainNumber}',
                style: const TextStyle(fontSize: 11, color: AppColors.lightBlue)),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const DemoBanner(),

            // ── Route summary strip ───────────────────────────────────────
            Container(
              color: AppColors.navyBlue,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _RouteEndPoint(code: _fromCode, label: widget.train.sourceStation.stationName),
                  Column(
                    children: [
                      const Icon(Icons.arrow_forward, color: Colors.white54, size: 18),
                      const SizedBox(height: 2),
                      Text(widget.train.trainNumber,
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 10)),
                    ],
                  ),
                  _RouteEndPoint(code: _toCode, label: widget.train.destinationStation.stationName, alignRight: true),
                ],
              ),
            ),

            // ── Mode selector tabs ────────────────────────────────────────
            Container(
              color: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: List.generate(_modes.length, (i) {
                  final m = _modes[i];
                  final selected = _selectedMode == i;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedMode = i);
                        _tabController.animateTo(i);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selected ? m.color : m.bgColor,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: selected
                              ? [BoxShadow(color: m.color.withAlpha(80), blurRadius: 8, offset: const Offset(0, 3))]
                              : [],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(m.icon,
                                size: 22,
                                color: selected ? Colors.white : m.color),
                            const SizedBox(height: 4),
                            Text(m.label,
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: selected ? Colors.white : m.color)),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const Divider(height: 1, color: AppColors.border),

            // ── Content ───────────────────────────────────────────────────
            Expanded(
              child: _buildModeContent(mode, backendTrains, crowdProv.isLoadingAlternatives),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeContent(
      _ModeOption mode, List<TravelAlternativeModel> backendTrains, bool loading) {
    final richItems = _demoData[mode.id] ?? [];

    if (mode.id == 'train' && loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Merge backend alternatives (train mode only)
    final backendCards = mode.id == 'train'
        ? backendTrains
            .where((a) => a.alternativeType.toUpperCase() == 'TRAIN')
            .map((a) => _BackendAlternativeCard(alt: a, modeColor: mode.color))
            .toList()
        : <Widget>[];

    final allItems = <Widget>[
      // mode intro
      _ModeIntroCard(mode: mode),
      ...backendCards,
      ...richItems.map((r) => _RichAlternativeCard(alt: r, mode: mode)),
    ];

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: allItems.length,
      itemBuilder: (context, i) => allItems[i],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _RouteEndPoint extends StatelessWidget {
  final String code;
  final String label;
  final bool alignRight;

  const _RouteEndPoint({required this.code, required this.label, this.alignRight = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(code,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 20,
                letterSpacing: 1)),
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 10),
            overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

class _ModeIntroCard extends StatelessWidget {
  final _ModeOption mode;
  const _ModeIntroCard({required this.mode});

  String get _description {
    switch (mode.id) {
      case 'train': return 'Other trains on the same route with lower reported crowd levels.';
      case 'bus':   return 'Overnight and daytime bus services operated by state and private operators.';
      case 'car':   return 'Self-drive and cab options with route details, toll estimate and fuel cost.';
      case 'flight':return 'Flights between nearest airports. Much faster but pricier than train.';
      default:      return 'Alternative options for your journey.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: mode.bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: mode.color.withAlpha(60)),
      ),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: mode.color, borderRadius: BorderRadius.circular(12)),
            child: Icon(mode.icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${mode.label} Options',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: mode.color)),
                const SizedBox(height: 2),
                Text(_description,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Rich demo card — used for all modes
class _RichAlternativeCard extends StatefulWidget {
  final _RichAlternative alt;
  final _ModeOption mode;
  const _RichAlternativeCard({required this.alt, required this.mode});

  @override
  State<_RichAlternativeCard> createState() => _RichAlternativeCardState();
}

class _RichAlternativeCardState extends State<_RichAlternativeCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.alt;
    final m = widget.mode;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: m.color.withAlpha(50)),
      ),
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────────
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: m.bgColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(m.icon, color: m.color, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: AppColors.navyBlue)),
                            const SizedBox(height: 2),
                            Text(a.subtitle,
                                style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // ── Quick stats row ───────────────────────────────────────
                  Row(
                    children: [
                      _StatChip(icon: Icons.schedule_rounded,    label: a.duration,  color: m.color),
                      const SizedBox(width: 8),
                      _StatChip(icon: Icons.straighten_rounded,  label: a.distance,  color: m.color),
                      const SizedBox(width: 8),
                      _StatChip(icon: Icons.currency_rupee,      label: '${a.fareMin}–${a.fareMax}', color: m.color),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded detail ───────────────────────────────────────────────
          if (_expanded) ...[
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timing
                  _DetailRow(
                    icon: Icons.departure_board_rounded,
                    label: 'Departure',
                    value: a.departure,
                    color: m.color,
                  ),
                  const SizedBox(height: 6),
                  _DetailRow(
                    icon: Icons.flag_rounded,
                    label: 'Arrival',
                    value: a.arrival,
                    color: m.color,
                  ),
                  const SizedBox(height: 6),
                  _DetailRow(
                    icon: Icons.person_outline_rounded,
                    label: 'Operator',
                    value: a.operator,
                    color: m.color,
                  ),
                  const SizedBox(height: 10),

                  // Highlights
                  Text('What to know',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                          color: m.color)),
                  const SizedBox(height: 6),
                  ...a.highlights.map((h) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.check_circle_outline,
                                size: 15, color: m.color),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(h,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textPrimary)),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 10),

                  // Fare box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: m.bgColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: m.color.withAlpha(60)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.currency_rupee, color: m.color, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${a.fareMin} – ${a.fareMax}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                      color: m.color)),
                              Text(a.fareNote,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Disclaimer
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline,
                            size: 14, color: Color(0xFFF57F17)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(a.disclaimer,
                              style: const TextStyle(
                                  fontSize: 10.5,
                                  color: Color(0xFF5D4037),
                                  fontStyle: FontStyle.italic)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Backend train alternative card (from API)
class _BackendAlternativeCard extends StatelessWidget {
  final TravelAlternativeModel alt;
  final Color modeColor;
  const _BackendAlternativeCard({required this.alt, required this.modeColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: modeColor.withAlpha(50)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppColors.softBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.train_rounded,
                      color: AppColors.primaryBlue, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(alt.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: AppColors.navyBlue)),
                      Text(alt.operator,
                          style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _StatChip(
                    icon: Icons.schedule_rounded,
                    label:
                        '${alt.departureTime.substring(0, 5)} (${alt.durationText})',
                    color: modeColor),
                const SizedBox(width: 8),
                if (alt.fareEstimate.isNotEmpty)
                  _StatChip(
                      icon: Icons.currency_rupee,
                      label: alt.fareEstimate,
                      color: modeColor),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(alt.sourceNote,
                  style: const TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFF5D4037),
                      fontStyle: FontStyle.italic)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tiny reusable widgets
// ─────────────────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 6),
        SizedBox(
          width: 70,
          child: Text('$label:',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
        ),
      ],
    );
  }
}
