import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/crowd_utils.dart';
import '../../models/train_model.dart';
import '../../providers/crowd_provider.dart';
import '../../services/location_service.dart';
import '../../widgets/demo_banner.dart';

class SubmitCrowdReportScreen extends StatefulWidget {
  final TrainModel train;
  final DateTime journeyDate;
  final int? initialCoachId;

  const SubmitCrowdReportScreen({
    super.key,
    required this.train,
    required this.journeyDate,
    this.initialCoachId,
  });

  @override
  State<SubmitCrowdReportScreen> createState() => _SubmitCrowdReportScreenState();
}

class _SubmitCrowdReportScreenState extends State<SubmitCrowdReportScreen> {
  int? _selectedCoachId;
  String _selectedCrowdLevel = 'HIGH';
  final _commentController = TextEditingController();
  bool _includeGps = true;

  @override
  void initState() {
    super.initState();
    _selectedCoachId = widget.initialCoachId;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    final crowdProv = Provider.of<CrowdProvider>(context, listen: false);

    GpsPosition? pos;
    if (_includeGps) {
      await LocationService.requestPermission();
      pos = await LocationService.getCurrentPosition();
    }

    final success = await crowdProv.submitReport(
      trainId: widget.train.id,
      journeyDate: widget.journeyDate,
      coachId: _selectedCoachId,
      crowdLevel: _selectedCrowdLevel,
      comment: _commentController.text.trim(),
      latitude: pos?.latitude,
      longitude: pos?.longitude,
      gpsAccuracy: pos?.accuracy,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(crowdProv.statusMessage ?? 'Crowd report recorded successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(crowdProv.errorMessage ?? 'Submission failed.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final crowdProv = Provider.of<CrowdProvider>(context);
    final coaches = widget.train.coaches;

    final crowdOptions = [
      {'level': 'LOW', 'title': 'Low Crowd', 'desc': 'Plenty of seats available, uncrowded', 'color': AppColors.crowdLow},
      {'level': 'MEDIUM', 'title': 'Medium Crowd', 'desc': 'Most seats taken, moderate standing', 'color': AppColors.crowdMedium},
      {'level': 'HIGH', 'title': 'High Crowd', 'desc': 'Heavy standing in aisle, packed bogie', 'color': AppColors.crowdHigh},
      {'level': 'VERY_HIGH', 'title': 'Very High', 'desc': 'Gate rush, impossible to board freely', 'color': AppColors.crowdVeryHigh},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Submit Crowd Report'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const DemoBanner(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Train Header Card
                    Card(
                      elevation: 1,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.softBlue,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.train_rounded, color: AppColors.primaryBlue),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${widget.train.trainNumber} - ${widget.train.trainName}',
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: AppColors.navyBlue),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Journey: ${DateFormat("d MMM yyyy").format(widget.journeyDate)}',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Coach Selector
                    const Text(
                      'Select Coach (Optional)',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int?>(
                          isExpanded: true,
                          value: _selectedCoachId,
                          hint: const Text('Overall Train (No specific coach)'),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('Entire Train (Overall observation)', style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                            ...coaches.map((c) {
                              return DropdownMenuItem<int?>(
                                value: c.id,
                                child: Text('Coach ${c.coachNumber} (${c.coachLabel})'),
                              );
                            }),
                          ],
                          onChanged: (val) {
                            setState(() => _selectedCoachId = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Crowd Level Selector Cards
                    const Text(
                      'How crowded is this coach right now?',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 10),

                    ...crowdOptions.map((opt) {
                      final isSelected = _selectedCrowdLevel == opt['level'];
                      final color = opt['color'] as Color;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: () {
                            setState(() => _selectedCrowdLevel = opt['level'] as String);
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected ? color.withAlpha(25) : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? color : AppColors.border,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  CrowdUtils.getIcon(opt['level'] as String),
                                  color: color,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        opt['title'] as String,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14.5,
                                          color: isSelected ? color : AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        opt['desc'] as String,
                                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                  color: isSelected ? color : AppColors.textMuted,
                                  size: 22,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 10),

                    // Comment field
                    TextField(
                      controller: _commentController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Passenger observation / details (Optional)',
                        hintText: 'e.g. Doors congested, luggage piled in aisle, seats empty...',
                      ),
                    ),
                    const SizedBox(height: 14),

                    // GPS verification toggle
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _includeGps,
                            activeColor: AppColors.primaryBlue,
                            onChanged: (val) => setState(() => _includeGps = val ?? true),
                          ),
                          const SizedBox(width: 6),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'GPS Journey Verification (Recommended)',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.navyBlue),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Attaches route-proximity signal to boost confidence weighting. Exact coordinates are kept private.',
                                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Submit Button
                    ElevatedButton.icon(
                      onPressed: crowdProv.isSubmitting ? null : _handleSubmit,
                      icon: crowdProv.isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.send_rounded, size: 18),
                      label: Text(crowdProv.isSubmitting ? 'Recording Report...' : 'Submit Validated Crowd Report'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
