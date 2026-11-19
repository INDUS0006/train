import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/train_model.dart';
import 'crowd_badge.dart';

class TrainCard extends StatelessWidget {
  final TrainModel train;
  final VoidCallback onTap;
  final VoidCallback? onToggleSave;

  const TrainCard({
    super.key,
    required this.train,
    required this.onTap,
    this.onToggleSave,
  });

  @override
  Widget build(BuildContext context) {
    final est = train.crowdEstimate;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Train Number, Name & Bookmark
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.softBlue,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      train.trainNumber,
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      train.trainName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onToggleSave != null)
                    InkWell(
                      onTap: onToggleSave,
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          train.isSaved ? Icons.bookmark : Icons.bookmark_border,
                          size: 20,
                          color: train.isSaved ? AppColors.primaryBlue : AppColors.textMuted,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),

              // Timing & Route Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Departure
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        train.departureTime.length >= 5 ? train.departureTime.substring(0, 5) : train.departureTime,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${train.sourceStation.stationCode} (${train.sourceStation.city})',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  // Duration Line
                  Column(
                    children: [
                      Text(
                        train.durationDisplay,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle)),
                          Container(width: 45, height: 1.5, color: AppColors.primaryBlue),
                          const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primaryBlue),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Daily',
                        style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                      ),
                    ],
                  ),

                  // Arrival
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        train.arrivalTime.length >= 5 ? train.arrivalTime.substring(0, 5) : train.arrivalTime,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${train.destinationStation.stationCode} (${train.destinationStation.city})',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 12),

              // Crowd Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CrowdBadge(crowdLevel: est.crowdLevel),
                  Row(
                    children: [
                      const Icon(Icons.verified_outlined, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        est.validReportCount > 0
                            ? '${est.validReportCount} valid reports'
                            : 'No reports yet',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
