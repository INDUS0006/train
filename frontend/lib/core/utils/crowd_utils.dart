import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CrowdUtils {
  static String getLabel(String? level) {
    switch (level?.toUpperCase()) {
      case 'LOW':
        return 'Low Crowd';
      case 'MEDIUM':
        return 'Medium Crowd';
      case 'HIGH':
        return 'High Crowd';
      case 'VERY_HIGH':
        return 'Very High Crowd';
      case 'INSUFFICIENT_DATA':
      default:
        return 'Not Enough Data';
    }
  }

  static String getShortLabel(String? level) {
    switch (level?.toUpperCase()) {
      case 'LOW':
        return 'Low';
      case 'MEDIUM':
        return 'Medium';
      case 'HIGH':
        return 'High';
      case 'VERY_HIGH':
        return 'Very High';
      case 'INSUFFICIENT_DATA':
      default:
        return 'No Data';
    }
  }

  static Color getColor(String? level) {
    switch (level?.toUpperCase()) {
      case 'LOW':
        return AppColors.crowdLow;
      case 'MEDIUM':
        return AppColors.crowdMedium;
      case 'HIGH':
        return AppColors.crowdHigh;
      case 'VERY_HIGH':
        return AppColors.crowdVeryHigh;
      case 'INSUFFICIENT_DATA':
      default:
        return AppColors.crowdInsufficient;
    }
  }

  static Color getBackgroundColor(String? level) {
    switch (level?.toUpperCase()) {
      case 'LOW':
        return AppColors.crowdLowBg;
      case 'MEDIUM':
        return AppColors.crowdMediumBg;
      case 'HIGH':
        return AppColors.crowdHighBg;
      case 'VERY_HIGH':
        return AppColors.crowdVeryHighBg;
      case 'INSUFFICIENT_DATA':
      default:
        return AppColors.crowdInsufficientBg;
    }
  }

  static IconData getIcon(String? level) {
    switch (level?.toUpperCase()) {
      case 'LOW':
        return Icons.event_seat_outlined;
      case 'MEDIUM':
        return Icons.group_outlined;
      case 'HIGH':
        return Icons.groups_rounded;
      case 'VERY_HIGH':
        return Icons.warning_amber_rounded;
      case 'INSUFFICIENT_DATA':
      default:
        return Icons.help_outline_rounded;
    }
  }

  static String getAdvisoryText(String? level) {
    switch (level?.toUpperCase()) {
      case 'LOW':
        return 'Seats comfortably available. Ideal boarding conditions.';
      case 'MEDIUM':
        return 'Moderate standing expected. Most confirmed seats occupied.';
      case 'HIGH':
        return 'Heavy passenger volume. Crowded aisles and vestibules.';
      case 'VERY_HIGH':
        return 'Severe crowding and gate rush reported. Consider alternative coaches or trains.';
      case 'INSUFFICIENT_DATA':
      default:
        return 'Waiting for valid passenger reports. Transparently unverified.';
    }
  }

  static String formatConfidence(String? confidence, double? score) {
    switch (confidence?.toUpperCase()) {
      case 'HIGH':
        return 'High Confidence (${((score ?? 0.85) * 100).toInt()}%)';
      case 'MEDIUM':
        return 'Medium Confidence (${((score ?? 0.65) * 100).toInt()}%)';
      case 'LOW':
        return 'Low Confidence (${((score ?? 0.40) * 100).toInt()}%)';
      case 'NONE':
      default:
        return 'No Estimate Available';
    }
  }
}
