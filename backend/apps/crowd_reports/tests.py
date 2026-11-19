from datetime import time
from django.test import TestCase
from django.urls import reverse
from django.utils import timezone
from rest_framework.test import APIClient
from rest_framework import status
from apps.accounts.models import User
from apps.stations.models import Station
from apps.trains.models import Train, Coach, CoachType
from apps.crowd_reports.models import CrowdReport, CrowdLevel
from apps.crowd_engine.models import CrowdEstimate


class CrowdReportAPITests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.today = timezone.localdate()

        self.user = User.objects.create_user(
            username='report_tester',
            email='reporter@trainbuddy.demo',
            password='Password123!'
        )
        self.client.force_authenticate(user=self.user)

        st1 = Station.objects.create(station_code='HYB', station_name='Hyderabad', city='Hyderabad', latitude=17.39, longitude=78.46)
        st2 = Station.objects.create(station_code='BZA', station_name='Vijayawada', city='Vijayawada', latitude=16.51, longitude=80.61)

        self.train = Train.objects.create(
            train_number='12723', train_name='Godavari Exp',
            source_station=st1, destination_station=st2,
            departure_time=time(17, 15), arrival_time=time(23, 30),
            duration_hours=6.25, is_active=True
        )
        self.coach_b1 = Coach.objects.create(
            train=self.train, coach_number='B1', coach_type=CoachType.AC_3_TIER, position=1
        )

    def test_crowd_report_submission(self):
        url = reverse('crowd_reports:crowd-report-create')
        data = {
            'train_id': self.train.id,
            'coach_id': self.coach_b1.id,
            'journey_date': self.today.isoformat(),
            'crowd_level': 'MEDIUM',
            'comment': 'Moderate occupancy in coach',
            'latitude': 17.43,
            'longitude': 78.50,
            'gps_accuracy': 15.0
        }
        response = self.client.post(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data['report']['crowd_level'], 'MEDIUM')
        self.assertEqual(CrowdReport.objects.count(), 1)

    def test_invalid_report_rejection(self):
        url = reverse('crowd_reports:crowd-report-create')
        # Missing required train_id and invalid crowd_level
        data = {
            'train_id': 999999,
            'journey_date': self.today.isoformat(),
            'crowd_level': 'NON_EXISTENT_LEVEL'
        }
        response = self.client.post(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('train_id', response.data)
        self.assertIn('crowd_level', response.data)

    def test_duplicate_report_handling(self):
        url = reverse('crowd_reports:crowd-report-create')
        data1 = {
            'train_id': self.train.id,
            'coach_id': self.coach_b1.id,
            'journey_date': self.today.isoformat(),
            'crowd_level': 'LOW',
            'comment': 'Seats free'
        }
        response1 = self.client.post(url, data1, format='json')
        self.assertEqual(response1.status_code, status.HTTP_201_CREATED)
        self.assertEqual(CrowdReport.objects.count(), 1)

        # Immediate second submission by same user for same coach: should update, not duplicate
        data2 = {
            'train_id': self.train.id,
            'coach_id': self.coach_b1.id,
            'journey_date': self.today.isoformat(),
            'crowd_level': 'HIGH',
            'comment': 'Rush increased suddenly'
        }
        response2 = self.client.post(url, data2, format='json')
        self.assertEqual(response2.status_code, status.HTTP_200_OK)
        self.assertTrue(response2.data['is_updated'])
        # Count remains 1! No count inflation!
        self.assertEqual(CrowdReport.objects.count(), 1)
        updated_report = CrowdReport.objects.first()
        self.assertEqual(updated_report.crowd_level, 'HIGH')
        self.assertEqual(updated_report.comment, 'Rush increased suddenly')

    def test_crowd_estimation_recomputation(self):
        # Submit 3 reports to cross coach threshold
        url = reverse('crowd_reports:crowd-report-create')
        # Create 3 reports from distinct users
        u2 = User.objects.create_user(username='u2', email='u2@test.com', password='p')
        u3 = User.objects.create_user(username='u3', email='u3@test.com', password='p')

        CrowdReport.objects.create(
            user=self.user, train=self.train, coach=self.coach_b1,
            journey_date=self.today, crowd_level=CrowdLevel.HIGH, is_valid=True
        )
        CrowdReport.objects.create(
            user=u2, train=self.train, coach=self.coach_b1,
            journey_date=self.today, crowd_level=CrowdLevel.HIGH, is_valid=True
        )
        CrowdReport.objects.create(
            user=u3, train=self.train, coach=self.coach_b1,
            journey_date=self.today, crowd_level=CrowdLevel.HIGH, is_valid=True
        )

        from apps.crowd_engine.services import CrowdEngineService
        estimate = CrowdEngineService.calculate_estimate(self.train, self.today, coach=self.coach_b1)
        self.assertEqual(estimate.crowd_level, 'HIGH')
        self.assertEqual(estimate.valid_report_count, 3)
