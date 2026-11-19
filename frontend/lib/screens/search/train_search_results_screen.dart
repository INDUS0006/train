import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/train_provider.dart';
import '../../widgets/demo_banner.dart';
import '../../widgets/train_card.dart';
import 'train_detail_screen.dart';

class TrainSearchResultsScreen extends StatelessWidget {
  final String fromCode;
  final String toCode;
  final DateTime journeyDate;

  const TrainSearchResultsScreen({
    super.key,
    required this.fromCode,
    required this.toCode,
    required this.journeyDate,
  });

  @override
  Widget build(BuildContext context) {
    final trainProv = Provider.of<TrainProvider>(context);
    final results = trainProv.searchResults;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$fromCode → $toCode',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
            ),
            Text(
              DateFormat('d MMM yyyy').format(journeyDate),
              style: const TextStyle(fontSize: 11, color: AppColors.lightBlue),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const DemoBanner(),

            // Results Summary Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.train_outlined, size: 18, color: AppColors.primaryBlue),
                      const SizedBox(width: 8),
                      Text(
                        '${results.length} Available Train${results.length == 1 ? "" : "s"}',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.softBlue,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Live Crowd Monitored',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.border, height: 1),

            // Results List
            Expanded(
              child: trainProv.isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : results.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search_off_rounded, size: 54, color: AppColors.textMuted),
                                const SizedBox(height: 16),
                                const Text(
                                  'No trains found for this route',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Try searching for Hyderabad (HYB) to Vijayawada (BZA)',
                                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    trainProv.searchTrains(fromCode: 'HYB', toCode: 'BZA', journeyDate: journeyDate);
                                  },
                                  child: const Text('Show Hyderabad → Vijayawada'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            final train = results[index];
                            return TrainCard(
                              train: train,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => TrainDetailScreen(
                                      trainId: train.id,
                                      journeyDate: journeyDate,
                                    ),
                                  ),
                                );
                              },
                              onToggleSave: () {
                                trainProv.toggleSaveTrain(train.id);
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
