from datetime import date
from django.utils import timezone
from rest_framework import permissions, status
from rest_framework.views import APIView
from rest_framework.response import Response
from django.core.management import call_command
from apps.trains.models import Train
from apps.crowd_reports.models import CrowdReport
from apps.crowd_engine.models import CrowdEstimate
from apps.trains.serializers import TrainListSerializer


class DashboardAPIView(APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        today = timezone.localdate()

        # Popular routes
        popular_routes = [
            {
                'from_code': 'HYB',
                'from_name': 'Hyderabad Deccan',
                'to_code': 'BZA',
                'to_name': 'Vijayawada Jn',
                'train_count': Train.objects.filter(source_station__station_code='HYB', destination_station__station_code='BZA').count() or 2,
                'popular_tag': 'Most Searched'
            },
            {
                'from_code': 'BZA',
                'from_name': 'Vijayawada Jn',
                'to_code': 'VSKP',
                'to_name': 'Visakhapatnam Jn',
                'train_count': Train.objects.filter(source_station__station_code='BZA', destination_station__station_code='VSKP').count() or 1,
                'popular_tag': 'Coastal Line'
            },
            {
                'from_code': 'HYB',
                'from_name': 'Hyderabad Deccan',
                'to_code': 'WL',
                'to_name': 'Warangal',
                'train_count': Train.objects.filter(source_station__station_code='HYB').count() or 2,
                'popular_tag': 'Intercity Corridor'
            },
        ]

        # Featured trains
        featured_trains = Train.objects.filter(is_active=True)[:5]
        train_serializer = TrainListSerializer(
            featured_trains,
            many=True,
            context={'journey_date': today, 'user': request.user}
        )

        total_reports_today = CrowdReport.objects.filter(journey_date=today, is_valid=True).count()
        total_trains = Train.objects.filter(is_active=True).count()
        high_crowd_count = CrowdEstimate.objects.filter(
            journey_date=today, coach=None, crowd_level__in=['HIGH', 'VERY_HIGH']
        ).count()

        return Response({
            'tagline': 'Know the train. Know the crowd. Choose how to travel.',
            'prominent_section': 'Check how crowded your train may be before boarding.',
            'today': today.isoformat(),
            'stats': {
                'active_trains_monitored': total_trains,
                'valid_reports_today': total_reports_today,
                'high_crowd_trains': high_crowd_count,
            },
            'popular_routes': popular_routes,
            'featured_trains': train_serializer.data,
            'crowd_explanation': {
                'title': 'How TrainBuddy Crowd Estimates Work',
                'description': 'Our estimation engine aggregates verified passenger submissions with recency weighting and route validation. When insufficient reports exist, we transparently mark it as Insufficient Data rather than guessing.',
                'levels': [
                    {'level': 'LOW', 'label': 'Low', 'color': '#2E7D32', 'desc': 'Seats readily available'},
                    {'level': 'MEDIUM', 'label': 'Medium', 'color': '#F57C00', 'desc': 'Moderate standing'},
                    {'level': 'HIGH', 'label': 'High', 'color': '#C62828', 'desc': 'Heavy standing / packed'},
                    {'level': 'VERY_HIGH', 'label': 'Very High', 'color': '#B71C1C', 'desc': 'Gate rush / overloaded'},
                    {'level': 'INSUFFICIENT_DATA', 'label': 'Not enough data', 'color': '#757575', 'desc': 'Awaiting reports'},
                ]
            },
            'is_demo_mode': True,
            'disclaimer': 'DEMO DATA – NOT LIVE RAILWAY INFORMATION'
        })


class DemoResetAPIView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        try:
            call_command('seed_demo_data', reset=True)
            return Response({
                'message': 'Demo database successfully reset and re-seeded with demonstration records.',
                'status': 'SUCCESS'
            })
        except Exception as e:
            return Response({
                'message': f'Error resetting demo database: {str(e)}',
                'status': 'ERROR'
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
