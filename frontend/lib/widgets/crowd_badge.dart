import 'package:flutter/material.dart';
import '../core/utils/crowd_utils.dart';

class CrowdBadge extends StatelessWidget {
  final String crowdLevel;
  final bool isSmall;
  final bool showIcon;

  const CrowdBadge({
    super.key,
    required this.crowdLevel,
    this.isSmall = false,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final fgColor = CrowdUtils.getColor(crowdLevel);
    final bgColor = CrowdUtils.getBackgroundColor(crowdLevel);
    final label = CrowdUtils.getLabel(crowdLevel);
    final icon = CrowdUtils.getIcon(crowdLevel);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 12,
        vertical: isSmall ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fgColor.withAlpha(50), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(icon, size: isSmall ? 13 : 16, color: fgColor),
            SizedBox(width: isSmall ? 4 : 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: fgColor,
              fontSize: isSmall ? 11 : 12.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
