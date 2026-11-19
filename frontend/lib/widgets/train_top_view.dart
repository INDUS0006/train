import 'package:flutter/material.dart';
import '../models/coach_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TrainTopView – Top-down train visualization
//
// Color coding per spec:
//   General   → Red
//   Sleeper   → Yellow
//   AC 3 Tier → Orange
//   AC 2 Tier → Green
//   AC First  → Blue
//
// Dot count per crowd level:
//   VERY_HIGH → 22  HIGH → 15  MEDIUM → 9  LOW → 4  INSUFFICIENT → 0 (shows ?)
// ─────────────────────────────────────────────────────────────────────────────

class TrainTopView extends StatelessWidget {
  final List<CoachModel> coaches;
  final String selectedFilter; // 'ALL' | 'AC' | 'SLEEPER' | 'GENERAL'
  final Function(CoachModel)? onCoachTap;

  const TrainTopView({
    super.key,
    required this.coaches,
    required this.selectedFilter,
    this.onCoachTap,
  });

  // ── Helpers ────────────────────────────────────────────────────────────────

  static const _bg = Color(0xFF0D1B2A);

  bool _isHighlighted(CoachModel c) {
    if (selectedFilter == 'ALL') return true;
    if (selectedFilter == 'AC') return c.coachType.startsWith('AC');
    if (selectedFilter == 'SLEEPER') return c.coachType == 'SLEEPER';
    if (selectedFilter == 'GENERAL') return c.coachType == 'GENERAL';
    return false;
  }

  static Color dotColorForType(String coachType) {
    switch (coachType) {
      case 'GENERAL':
        return const Color(0xFFE53935);
      case 'SLEEPER':
        return const Color(0xFFFDD835);
      case 'AC_3TIER':
        return const Color(0xFFFB8C00);
      case 'AC_2TIER':
        return const Color(0xFF43A047);
      case 'AC_FIRST':
        return const Color(0xFF1E88E5);
      default:
        return const Color(0xFF90A4AE);
    }
  }

  static int dotCountForCrowd(String crowdLevel) {
    switch (crowdLevel) {
      case 'VERY_HIGH':
        return 22;
      case 'HIGH':
        return 15;
      case 'MEDIUM':
        return 9;
      case 'LOW':
        return 4;
      default:
        return 0;
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LegendBar(),
        Container(
          height: 185,
          color: _bg,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const _LocomotiveWidget(),
                const SizedBox(width: 4),
                ...coaches.map((c) {
                  final highlighted = _isHighlighted(c);
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: GestureDetector(
                      onTap:
                          onCoachTap != null ? () => onCoachTap!(c) : null,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 250),
                        opacity: highlighted ? 1.0 : 0.12,
                        child: _CoachWidget(
                          coach: c,
                          dotColor: dotColorForType(c.coachType),
                          dotCount: dotCountForCrowd(c.crowdInfo.crowdLevel),
                          highlighted: highlighted,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        // Scroll hint
        Container(
          color: _bg,
          padding: const EdgeInsets.only(bottom: 8),
          child: const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.swipe_rounded, color: Colors.white24, size: 13),
                SizedBox(width: 4),
                Text('Scroll to see all coaches  •  Tap a coach for details',
                    style: TextStyle(
                        color: Colors.white24,
                        fontSize: 10,
                        fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Legend
// ─────────────────────────────────────────────────────────────────────────────

class _LegendBar extends StatelessWidget {
  static const _items = [
    ('General', Color(0xFFE53935)),
    ('Sleeper', Color(0xFFFDD835)),
    ('AC 3 Tier', Color(0xFFFB8C00)),
    ('AC 2 Tier', Color(0xFF43A047)),
    ('AC First', Color(0xFF1E88E5)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: TrainTopView._bg,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
      child: Wrap(
        spacing: 14,
        runSpacing: 4,
        children: _items
            .map(
              (item) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: item.$2,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: item.$2.withAlpha(130), blurRadius: 4),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(item.$1,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 10.5)),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Locomotive
// ─────────────────────────────────────────────────────────────────────────────

class _LocomotiveWidget extends StatelessWidget {
  const _LocomotiveWidget();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Loco',
            style: TextStyle(
                color: Colors.white38,
                fontSize: 9,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 3),
        // Body
        Container(
          width: 84,
          height: 108,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF154360), Color(0xFF1A5276)],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(26),
              topRight: Radius.circular(8),
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
            border: Border.all(color: Colors.white24, width: 1.5),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x661A5276), blurRadius: 10, spreadRadius: 2),
            ],
          ),
          child: Stack(
            children: [
              // Cab windows
              Positioned(
                top: 10,
                left: 6,
                right: 6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _CabWindow(),
                    _CabWindow(),
                  ],
                ),
              ),
              // Headlight
              Positioned(
                top: 44,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 14,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF176),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0xFFFFF176).withAlpha(150),
                            blurRadius: 8),
                      ],
                    ),
                  ),
                ),
              ),
              // Pantograph line
              Positioned(
                bottom: 25,
                left: 10,
                right: 10,
                child: Container(height: 1.5, color: Colors.white24),
              ),
              const Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: Center(
                  child: Icon(Icons.train, color: Colors.white38, size: 18),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const _BogieRow(width: 84),
      ],
    );
  }
}

class _CabWindow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 18,
      decoration: BoxDecoration(
        color: const Color(0xFF85C1E9).withAlpha(160),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white38, width: 1),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Coach
// ─────────────────────────────────────────────────────────────────────────────

class _CoachWidget extends StatelessWidget {
  final CoachModel coach;
  final Color dotColor;
  final int dotCount;
  final bool highlighted;

  const _CoachWidget({
    required this.coach,
    required this.dotColor,
    required this.dotCount,
    required this.highlighted,
  });

  static String _shortType(String t) {
    switch (t) {
      case 'GENERAL':
        return 'GEN';
      case 'SLEEPER':
        return 'SL';
      case 'AC_3TIER':
        return '3A';
      case 'AC_2TIER':
        return '2A';
      case 'AC_FIRST':
        return '1A';
      default:
        return t.length > 3 ? t.substring(0, 3) : t;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Coach number
        Text(
          coach.coachNumber,
          style: const TextStyle(
              color: Colors.white70,
              fontSize: 9,
              fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 3),
        // Coach body (top-down view)
        Container(
          width: 66,
          height: 106,
          decoration: BoxDecoration(
            color: const Color(0xFF1B2631),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: highlighted ? Colors.white38 : Colors.white12,
              width: highlighted ? 1.5 : 1,
            ),
            boxShadow: highlighted
                ? [
                    BoxShadow(
                        color: dotColor.withAlpha(70),
                        blurRadius: 10,
                        spreadRadius: 1)
                  ]
                : [],
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: _DotGrid(
                dotColor: dotColor, filledDots: dotCount, columns: 4, rows: 6),
          ),
        ),
        const SizedBox(height: 4),
        // Bogies
        const _BogieRow(width: 66),
        const SizedBox(height: 3),
        // Type label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(
            color: dotColor.withAlpha(45),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            _shortType(coach.coachType),
            style: TextStyle(
                color: dotColor, fontSize: 8.5, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dot Grid
// ─────────────────────────────────────────────────────────────────────────────

class _DotGrid extends StatelessWidget {
  final Color dotColor;
  final int filledDots;
  final int columns;
  final int rows;

  const _DotGrid({
    required this.dotColor,
    required this.filledDots,
    required this.columns,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    if (filledDots == 0) {
      return Center(
        child: Text('?',
            style: TextStyle(
                color: Colors.white.withAlpha(30),
                fontSize: 26,
                fontWeight: FontWeight.w900)),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(rows, (row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(columns, (col) {
            final idx = row * columns + col;
            final filled = idx < filledDots;
            return Container(
              width: 7.5,
              height: 7.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled ? dotColor : Colors.white.withAlpha(12),
                boxShadow: filled
                    ? [
                        BoxShadow(
                            color: dotColor.withAlpha(140), blurRadius: 4)
                      ]
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
// Bogies (wheel assemblies shown top-down)
// ─────────────────────────────────────────────────────────────────────────────

class _BogieRow extends StatelessWidget {
  final double width;
  const _BogieRow({required this.width});

  @override
  Widget build(BuildContext context) {
    final bogieW = (width - 8) / 2; // two bogies with 8px gap
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SingleBogie(width: bogieW),
        const SizedBox(width: 8),
        _SingleBogie(width: bogieW),
      ],
    );
  }
}

class _SingleBogie extends StatelessWidget {
  final double width;
  const _SingleBogie({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 16,
      decoration: BoxDecoration(
        color: const Color(0xFF3D3D3D),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [_Wheel(), _Wheel()],
      ),
    );
  }
}

class _Wheel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1A1A1A),
        border: Border.all(color: const Color(0xFF757575), width: 1.5),
      ),
    );
  }
}
