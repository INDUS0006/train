from django.contrib import admin
from apps.crowd_reports.models import CrowdReport
from apps.crowd_engine.services import CrowdEngineService


@admin.register(CrowdReport)
class CrowdReportAdmin(admin.ModelAdmin):
    list_display = (
        'id', 'train', 'coach', 'journey_date', 'crowd_level',
        'report_source', 'is_valid', 'user', 'created_at'
    )
    list_filter = ('is_valid', 'crowd_level', 'report_source', 'journey_date', 'train')
    search_fields = ('train__train_number', 'train__train_name', 'comment', 'user__email')
    actions = ['mark_as_invalid', 'mark_as_valid']

    @admin.action(description='Mark selected reports as INVALID (spam/outlier)')
    def mark_as_invalid(self, request, queryset):
        updated = queryset.update(is_valid=False, invalidation_reason='Flagged by administrator')
        # Recompute estimates for affected trains
        for report in queryset:
            CrowdEngineService.recompute_train_and_coaches(report.train, report.journey_date)
        self.message_user(request, f"{updated} reports marked as invalid and estimates recalculated.")

    @admin.action(description='Mark selected reports as VALID')
    def mark_as_valid(self, request, queryset):
        updated = queryset.update(is_valid=True, invalidation_reason='')
        for report in queryset:
            CrowdEngineService.recompute_train_and_coaches(report.train, report.journey_date)
        self.message_user(request, f"{updated} reports marked as valid and estimates recalculated.")
