from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from apps.accounts.models import User


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    list_display = ('username', 'email', 'first_name', 'last_name', 'is_guest', 'location_sharing_enabled', 'is_staff')
    list_filter = ('is_guest', 'location_sharing_enabled', 'is_staff', 'is_active')
    search_fields = ('username', 'email', 'first_name', 'last_name')
    fieldsets = BaseUserAdmin.fieldsets + (
        ('TrainBuddy Preferences', {'fields': ('is_guest', 'phone_number', 'location_sharing_enabled')}),
    )
