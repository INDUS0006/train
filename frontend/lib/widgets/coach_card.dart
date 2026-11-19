import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/crowd_utils.dart';
import '../models/coach_model.dart';
import 'crowd_badge.dart';

class CoachCard extends StatelessWidget {
  final CoachModel coach;
  final VoidCallback onReportTap;

  const CoachCard({
    super.key,
    required this.coach,
    required this.onReportTap,
  });

  @override
  Widget build(BuildContext context) {
    final crowd = coach.crowdInfo;
    final hasEnoughData = crowd.crowdLevel != 'INSUFFICIENT_DATA';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Coach Number, Label & Crowd Badge
            Row(
              children: [
                Container(
                  width: 50,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.navyBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      coach.coachNumber,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coach.coachLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        coach.coachTypeDisplay,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                CrowdBadge(crowdLevel: crowd.crowdLevel),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 10),

            // Middle: Explanation or Insufficient Data Alert
            if (hasEnoughData) ...[
              Text(
                crowd.explanation.isNotEmpty
                    ? crowd.explanation
                    : CrowdUtils.getAdvisoryText(crowd.crowdLevel),
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10),
              // Metrics Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_outlined, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        '${crowd.validReportCount} valid passenger reports',
                        style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Text(
                    CrowdUtils.formatConfidence(crowd.confidenceLevel, crowd.confidenceScore),
                    style: const TextStyle(fontSize: 11.5, color: AppColors.primaryBlue, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: AppColors.crowdInsufficient),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Not enough information for this coach yet. Be the first to report!',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),
            // Bottom Action
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: onReportTap,
                icon: const Icon(Icons.add_comment_outlined, size: 16),
                label: const Text('Report Crowd for Coach'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
