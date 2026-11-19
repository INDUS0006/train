from datetime import timedelta
from django.utils import timezone
from rest_framework import status, permissions
from rest_framework.views import APIView
from rest_framework.response import Response
from apps.crowd_reports.models import CrowdReport, ReportSource
from apps.crowd_reports.serializers import CrowdReportSerializer, CrowdReportCreateSerializer
from apps.trains.models import Train, Coach
from apps.crowd_engine.services import CrowdEngineService
from apps.crowd_engine.models import CrowdEstimate
from apps.notifications.models import InAppNotification, NotificationType


def get_client_ip(request):
    x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
    if x_forwarded_for:
        return x_forwarded_for.split(',')[0].strip()
    return request.META.get('REMOTE_ADDR')


class CrowdReportCreateAPIView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = CrowdReportCreateSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        data = serializer.validated_data
        train = Train.objects.get(id=data['train_id'])
        journey_date = data['journey_date']
        coach = Coach.objects.get(id=data['coach_id']) if data.get('coach_id') else None
        crowd_level = data['crowd_level']
        comment = data.get('comment', '').strip()
        latitude = data.get('latitude')
        longitude = data.get('longitude')
        gps_accuracy = data.get('gps_accuracy')
        ip_address = get_client_ip(request)
        user = request.user if request.user.is_authenticated else None

        # Determine report source: GPS verified if accurate coordinates provided
        report_source = ReportSource.MANUAL
        if latitude is not None and longitude is not None:
            if gps_accuracy is not None and gps_accuracy <= 100.0:
                report_source = ReportSource.GPS_VERIFIED

        # Anti-spam / Duplicate prevention: check recent submission within 15 minutes
        cutoff_time = timezone.now() - timedelta(minutes=15)
        recent_report_query = CrowdReport.objects.filter(
            train=train,
            journey_date=journey_date,
            coach=coach,
            created_at__gte=cutoff_time
        )
        if user:
            recent_report = recent_report_query.filter(user=user).first()
        else:
            recent_report = recent_report_query.filter(ip_address=ip_address).first()

        if recent_report:
            # Update the existing report to prevent count inflation
            recent_report.crowd_level = crowd_level
            recent_report.comment = comment or recent_report.comment
            recent_report.latitude = latitude or recent_report.latitude
            recent_report.longitude = longitude or recent_report.longitude
            recent_report.gps_accuracy = gps_accuracy or recent_report.gps_accuracy
            recent_report.report_source = report_source
            recent_report.save()
            report = recent_report
            is_updated = True
            msg = "Your existing report from a few minutes ago was updated with your latest observation."
        else:
            # Create new report
            report = CrowdReport.objects.create(
                user=user,
                train=train,
                journey_date=journey_date,
                coach=coach,
                crowd_level=crowd_level,
                comment=comment,
                latitude=latitude,
                longitude=longitude,
                gps_accuracy=gps_accuracy,
                report_source=report_source,
                is_valid=True,
                ip_address=ip_address
            )
            is_updated = False
            msg = "Crowd report submitted successfully. Thank you for contributing!"

        # Trigger crowd estimation recalculation
        CrowdEngineService.recompute_train_and_coaches(train, journey_date)

        # Fetch the updated estimate
        updated_estimate = CrowdEstimate.objects.filter(
            train=train, journey_date=journey_date, coach=coach
        ).first()

        # Generate in-app notification
        if user:
            coach_str = f" for Coach {coach.coach_number}" if coach else ""
            InAppNotification.objects.create(
                user=user,
                title=f"Report Received: {train.train_number}",
                message=f"Your {crowd_level} crowd report{coach_str} on {train.train_name} has been processed and aggregated into crowd estimates.",
                notification_type=NotificationType.NEW_REPORT,
                train=train
            )

        return Response({
            'message': msg,
            'is_updated': is_updated,
            'report': CrowdReportSerializer(report).data,
            'updated_estimate': {
                'crowd_level': updated_estimate.crowd_level if updated_estimate else crowd_level,
                'valid_report_count': updated_estimate.valid_report_count if updated_estimate else 1,
                'confidence_level': updated_estimate.confidence_level if updated_estimate else 'LOW',
                'confidence_score': updated_estimate.confidence_score if updated_estimate else 0.4,
                'last_updated': updated_estimate.last_updated.isoformat() if updated_estimate else None,
                'explanation': updated_estimate.explanation if updated_estimate else ''
            }
        }, status=status.HTTP_201_CREATED if not is_updated else status.HTTP_200_OK)


class MyCrowdReportsListAPIView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        reports = CrowdReport.objects.filter(user=request.user).order_by('-created_at')
        serializer = CrowdReportSerializer(reports, many=True)
        return Response(serializer.data)
