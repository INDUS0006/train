from datetime import datetime, timedelta
from django.utils import timezone
from django.db.models import Count, Q
from apps.crowd_reports.models import CrowdReport, CrowdLevel, ReportSource
from apps.crowd_engine.models import CrowdEstimate, EstimateCrowdLevel, ConfidenceLevel
from apps.trains.models import Train, Coach


class CrowdEngineService:
    """
    Transparent, weighted crowd estimation service.
    Aggregates valid passenger reports, applies recency and validation weights,
    determines crowd category and confidence level, and handles insufficient data.
    """

    MIN_REPORTS_COACH = 2
    MIN_REPORTS_OVERALL = 3

    LEVEL_MAP = {
        CrowdLevel.LOW: EstimateCrowdLevel.LOW,
        CrowdLevel.MEDIUM: EstimateCrowdLevel.MEDIUM,
        CrowdLevel.HIGH: EstimateCrowdLevel.HIGH,
        CrowdLevel.VERY_HIGH: EstimateCrowdLevel.VERY_HIGH,
    }

    @classmethod
    def calculate_estimate(cls, train, journey_date, coach=None):
        """
        Calculate and persist crowd estimate for a train (overall) or specific coach.
        """
        now = timezone.now()
        reports_qs = CrowdReport.objects.filter(
            train=train,
            journey_date=journey_date,
            is_valid=True
        )

        if coach:
            reports_qs = reports_qs.filter(coach=coach)
            min_required = cls.MIN_REPORTS_COACH
        else:
            min_required = cls.MIN_REPORTS_OVERALL

        valid_reports = list(reports_qs.order_by('-created_at'))
        total_reports = len(valid_reports)

        # Check for insufficient data
        if total_reports < min_required:
            estimate, _ = CrowdEstimate.objects.update_or_create(
                train=train,
                journey_date=journey_date,
                coach=coach,
                defaults={
                    'crowd_level': EstimateCrowdLevel.INSUFFICIENT_DATA,
                    'valid_report_count': total_reports,
                    'confidence_level': ConfidenceLevel.NONE if total_reports == 0 else ConfidenceLevel.LOW,
                    'confidence_score': 0.1 if total_reports > 0 else 0.0,
                    'calculation_method': 'INSUFFICIENT_REPORTS_THRESHOLD',
                    'distribution': {'LOW': 0, 'MEDIUM': 0, 'HIGH': 0, 'VERY_HIGH': 0},
                    'explanation': (
                        f"Only {total_reports} valid report(s) available. "
                        f"At least {min_required} are required for an estimate."
                    )
                }
            )
            return estimate

        # Weighted voting aggregation
        weighted_scores = {
            EstimateCrowdLevel.LOW: 0.0,
            EstimateCrowdLevel.MEDIUM: 0.0,
            EstimateCrowdLevel.HIGH: 0.0,
            EstimateCrowdLevel.VERY_HIGH: 0.0,
        }
        counts = {
            'LOW': 0,
            'MEDIUM': 0,
            'HIGH': 0,
            'VERY_HIGH': 0,
        }

        total_weight = 0.0

        for report in valid_reports:
            target_level = cls.LEVEL_MAP.get(report.crowd_level)
            if not target_level:
                continue

            counts[report.crowd_level] += 1

            # Recency weighting
            age = now - report.created_at
            if age <= timedelta(hours=2):
                recency_weight = 1.5
            elif age <= timedelta(hours=6):
                recency_weight = 1.2
            elif age <= timedelta(hours=12):
                recency_weight = 1.0
            else:
                recency_weight = 0.7

            # Source verification weighting
            source_weight = 1.4 if report.report_source == ReportSource.GPS_VERIFIED else 1.0

            report_weight = recency_weight * source_weight
            weighted_scores[target_level] += report_weight
            total_weight += report_weight

        # Pick winning crowd level
        winning_level = max(weighted_scores, key=weighted_scores.get)
        winning_score = weighted_scores[winning_level]

        # Agreement ratio (0.0 to 1.0)
        agreement = (winning_score / total_weight) if total_weight > 0 else 0.0

        # Calculate confidence
        if total_reports >= 8 and agreement >= 0.65:
            confidence = ConfidenceLevel.HIGH
            confidence_score = min(0.95, 0.7 + (agreement * 0.25))
        elif total_reports >= 4 and agreement >= 0.50:
            confidence = ConfidenceLevel.MEDIUM
            confidence_score = 0.55 + (agreement * 0.2)
        else:
            confidence = ConfidenceLevel.LOW
            confidence_score = 0.35 + (agreement * 0.15)

        explanation = (
            f"Based on {total_reports} valid reports ({agreement * 100:.0f}% weighted agreement). "
            f"Recency and GPS-verification weighted."
        )

        estimate, _ = CrowdEstimate.objects.update_or_create(
            train=train,
            journey_date=journey_date,
            coach=coach,
            defaults={
                'crowd_level': winning_level,
                'valid_report_count': total_reports,
                'confidence_level': confidence,
                'confidence_score': round(confidence_score, 2),
                'calculation_method': 'WEIGHTED_RECENCY_CONSENSUS',
                'distribution': counts,
                'explanation': explanation,
            }
        )
        return estimate

    @classmethod
    def recompute_train_and_coaches(cls, train, journey_date):
        """
        Recompute estimates for the train and all its coaches.
        """
        # Recompute overall train estimate
        overall_estimate = cls.calculate_estimate(train, journey_date, coach=None)

        # Recompute coach-level estimates
        coach_estimates = []
        for coach in train.coaches.all():
            est = cls.calculate_estimate(train, journey_date, coach=coach)
            coach_estimates.append(est)

        return overall_estimate, coach_estimates
