import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/train_model.dart';
import '../../providers/journey_provider.dart';
import '../../widgets/demo_banner.dart';

class GpsValidationScreen extends StatefulWidget {
  final TrainModel train;

  const GpsValidationScreen({super.key, required this.train});

  @override
  State<GpsValidationScreen> createState() => _GpsValidationScreenState();
}

class _GpsValidationScreenState extends State<GpsValidationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JourneyProvider>(context, listen: false).checkStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final journeyProv = Provider.of<JourneyProvider>(context);
    final isActive = journeyProv.isJourneyActive;
    final isNearRoute = journeyProv.isNearRoute;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('GPS Journey Validation'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const DemoBanner(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Status Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: isActive ? AppColors.success.withAlpha(25) : AppColors.surfaceMuted,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isActive ? Icons.gps_fixed_rounded : Icons.gps_not_fixed_rounded,
                                size: 34,
                                color: isActive ? AppColors.success : AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              isActive ? 'Journey Tracking Active' : 'Journey Tracking Inactive',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: isActive ? AppColors.success : AppColors.navyBlue,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isActive
                                  ? 'Validated proximity to Train ${widget.train.trainNumber} route corridor.'
                                  : 'Opt-in to confirm your journey and boost crowd estimate quality.',
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                              textAlign: TextAlign.center,
                            ),
                            if (isActive) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isNearRoute ? AppColors.crowdLowBg : AppColors.crowdMediumBg,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isNearRoute ? AppColors.crowdLow : AppColors.crowdMedium,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isNearRoute ? Icons.check_circle : Icons.warning_amber_rounded,
                                      size: 16,
                                      color: isNearRoute ? AppColors.crowdLow : AppColors.crowdMedium,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isNearRoute
                                          ? 'Device confirmed near train route'
                                          : 'Signal detected outside route corridor',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isNearRoute ? AppColors.crowdLow : AppColors.crowdMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Controls
                    if (!isActive)
                      ElevatedButton.icon(
                        onPressed: () {
                          journeyProv.startJourney(widget.train.id);
                        },
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Start GPS Journey Validation'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: () {
                          journeyProv.stopJourney();
                        },
                        icon: const Icon(Icons.stop_rounded),
                        label: const Text('Stop Journey Tracking'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Important Privacy Principles Card (Section 4 & Section 11 compliance)
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.privacy_tip_outlined, color: AppColors.primaryBlue, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Privacy & Accuracy Commitments',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.navyBlue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const _PrivacyBullet(
                              title: 'No Passenger Counting',
                              desc: 'GPS is not used as a passenger-counting mechanism. It only confirms route presence.',
                            ),
                            const _PrivacyBullet(
                              title: 'No Coach Detection',
                              desc: 'GPS cannot and does not claim to identify specific coach numbers.',
                            ),
                            const _PrivacyBullet(
                              title: 'Zero Public Tracking',
                              desc: 'Individual passenger locations are never stored or displayed on any map.',
                            ),
                            const _PrivacyBullet(
                              title: 'Full User Control',
                              desc: 'Tracking requires explicit opt-in and can be revoked at any second.',
                            ),
                          ],
                        ),
                      ),
                    ),
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

class _PrivacyBullet extends StatelessWidget {
  final String title;
  final String desc;

  const _PrivacyBullet({required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check, size: 16, color: AppColors.primaryBlue),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
