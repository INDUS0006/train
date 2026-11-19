from django.test import TestCase
from django.urls import reverse
from rest_framework.test import APIClient
from rest_framework import status
from apps.accounts.models import User


class AccountsAPITests(TestCase):
    def setUp(self):
        self.client = APIClient()

    def test_user_registration(self):
        url = reverse('accounts:register')
        data = {
            'username': 'tester1',
            'email': 'tester1@trainbuddy.demo',
            'password': 'Password123!',
            'first_name': 'Test',
            'last_name': 'User'
        }
        response = self.client.post(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertIn('tokens', response.data)
        self.assertIn('access', response.data['tokens'])
        self.assertEqual(response.data['user']['email'], 'tester1@trainbuddy.demo')

    def test_user_login(self):
        User.objects.create_user(
            username='tester2',
            email='tester2@trainbuddy.demo',
            password='Password123!'
        )
        url = reverse('accounts:login')
        data = {
            'email': 'tester2@trainbuddy.demo',
            'password': 'Password123!'
        }
        response = self.client.post(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('tokens', response.data)

    def test_guest_login(self):
        url = reverse('accounts:guest-login')
        response = self.client.post(url, {}, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(response.data['user']['is_guest'])
        self.assertIn('access', response.data['tokens'])
