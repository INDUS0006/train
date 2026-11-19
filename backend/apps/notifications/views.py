from django.db.models import Q
from rest_framework import permissions, status
from rest_framework.views import APIView
from rest_framework.response import Response
from apps.notifications.models import InAppNotification
from apps.notifications.serializers import InAppNotificationSerializer


class NotificationListAPIView(APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        if request.user.is_authenticated:
            base_qs = InAppNotification.objects.filter(
                Q(user=request.user) | Q(user__isnull=True)
            )
        else:
            base_qs = InAppNotification.objects.filter(
                user__isnull=True
            )

        unread_count = base_qs.filter(is_read=False).count()
        notifications = base_qs.order_by('-created_at')[:30]
        serializer = InAppNotificationSerializer(notifications, many=True)
        return Response({
            'unread_count': unread_count,
            'notifications': serializer.data
        })


class NotificationMarkReadAPIView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk):
        try:
            notif = InAppNotification.objects.get(pk=pk, user=request.user)
            notif.is_read = True
            notif.save()
            return Response({'message': 'Marked as read.'})
        except InAppNotification.DoesNotExist:
            return Response({'detail': 'Notification not found.'}, status=status.HTTP_404_NOT_FOUND)


class NotificationMarkAllReadAPIView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        InAppNotification.objects.filter(user=request.user, is_read=False).update(is_read=True)
        return Response({'message': 'All notifications marked as read.'})
