import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/train_provider.dart';
import '../../providers/crowd_provider.dart';
import '../../widgets/demo_banner.dart';
import '../auth/login_screen.dart';
import '../search/train_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _locationSharing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TrainProvider>(context, listen: false).fetchSavedTrains();
      Provider.of<CrowdProvider>(context, listen: false).fetchMyReports();
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.user != null) {
        setState(() => _locationSharing = auth.user!.locationSharingEnabled);
      }
    });
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.refresh_rounded, color: AppColors.primaryBlue),
            SizedBox(width: 8),
            Text('Reset Demo Data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          ],
        ),
        content: const Text(
          'This will reset the backend database back to the clean demonstration state with seeded Hyderabad-Vijayawada trains, coach crowds, and sample reports for your presentation.',
          style: TextStyle(fontSize: 13, height: 1.35),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final crowdProv = Provider.of<CrowdProvider>(context, listen: false);
              final success = await crowdProv.resetDemoData();
              if (!mounted) return;
              if (success) {
                Provider.of<TrainProvider>(context, listen: false).loadDashboard();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✓ Demo database successfully reset for presentation!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Reset Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final trainProv = Provider.of<TrainProvider>(context);
    final crowdProv = Provider.of<CrowdProvider>(context);
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile & Settings'),
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
                    // User Header Card
                    Card(
                      elevation: 1.5,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: auth.isGuest ? Colors.amber.shade700 : AppColors.navyBlue,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  user != null && user.displayName.isNotEmpty
                                      ? user.displayName.substring(0, 1).toUpperCase()
                                      : 'P',
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        user?.displayName ?? 'Guest Passenger',
                                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.navyBlue),
                                      ),
                                      if (auth.isGuest) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.amber.shade100,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text('DEMO', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.amber)),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user?.email ?? 'guest@trainbuddy.demo',
                                    style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Saved Trains Section
                    Row(
                      children: [
                        const Icon(Icons.bookmark_outline, size: 18, color: AppColors.primaryBlue),
                        const SizedBox(width: 8),
                        Text(
                          'Saved Trains (${trainProv.savedTrains.length})',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.navyBlue),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (trainProv.savedTrains.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Text('No saved trains yet. Tap the bookmark icon on any train card to save.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      )
                    else
                      ...trainProv.savedTrains.map((tr) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.train, color: AppColors.primaryBlue),
                            title: Text('${tr.trainNumber} - ${tr.trainName}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                            subtitle: Text('${tr.sourceStation.stationCode} → ${tr.destinationStation.stationCode}'),
                            trailing: const Icon(Icons.chevron_right, size: 18),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => TrainDetailScreen(trainId: tr.id)),
                              );
                            },
                          ),
                        );
                      }),
                    const SizedBox(height: 18),

                    // Reports Submitted by User
                    Row(
                      children: [
                        const Icon(Icons.rate_review_outlined, size: 18, color: AppColors.primaryBlue),
                        const SizedBox(width: 8),
                        Text(
                          'Your Submitted Reports (${crowdProv.myReports.length})',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.navyBlue),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (crowdProv.myReports.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Text('You haven\'t submitted any crowd reports yet.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      )
                    else
                      ...crowdProv.myReports.take(3).map((rep) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text('Train ${rep.trainNumber} • Coach ${rep.coachNumber ?? "Overall"}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                            subtitle: Text('${rep.crowdLevelDisplay} • ${rep.journeyDate}'),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.crowdLowBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('Validated', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.crowdLow)),
                            ),
                          ),
                        );
                      }),
                    const SizedBox(height: 18),

                    // Privacy & Permissions Card
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Privacy & Compliance (DPDP Act)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: AppColors.navyBlue)),
                            const SizedBox(height: 8),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Allow GPS Journey Verification', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                              subtitle: const Text('Enables corridor verification when submitting crowd reports. Individual locations are never stored.', style: TextStyle(fontSize: 11.5)),
                              value: _locationSharing,
                              activeThumbColor: AppColors.primaryBlue,
                              onChanged: (val) {
                                setState(() => _locationSharing = val);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Demo Presentation Controls
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primaryBlue.withAlpha(90)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.present_to_all_rounded, color: AppColors.primaryBlue),
                              SizedBox(width: 8),
                              Text('Demo Presentation Control', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.navyBlue)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Repeatable presentation mode: quickly reset all crowd counts, reports, and estimates back to pristine seeded demo values.',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _showResetDialog,
                            icon: const Icon(Icons.restart_alt_rounded, size: 18),
                            label: const Text('Reset Demo Data to Seed State'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Logout Button
                    ElevatedButton.icon(
                      onPressed: () async {
                        final nav = Navigator.of(context);
                        await auth.logout();
                        if (!mounted) return;
                        nav.pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: const Text('Log Out'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.textMuted,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 32),
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
