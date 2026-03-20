import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/reports_models.dart';

/// Services for reports functionality
class ReportsServices {
  /// Load reports from storage or API
  static Future<List<Report>> loadReports() async {
    try {
      // In a real app, this would fetch from an API
      // For now, return mock data with legacy support
      await Future.delayed(const Duration(milliseconds: 500));
      
      return [
        Report(
          id: '1',
          title: 'Broken equipment at clinic',
          description: 'Medical equipment in the main clinic is not functioning properly and needs immediate attention.',
          status: ReportStatus.open,
          category: ReportCategory.equipment,
          priority: ReportPriority.high,
          createdAt: DateTime.parse('2025-12-01'),
        ),
        Report(
          id: '2',
          title: 'Stockout: painkillers',
          description: 'The facility is experiencing a shortage of essential painkiller medications.',
          status: ReportStatus.closed,
          category: ReportCategory.stockout,
          priority: ReportPriority.medium,
          createdAt: DateTime.parse('2025-11-21'),
          resolvedAt: DateTime.parse('2025-11-25'),
        ),
        Report(
          id: '3',
          title: 'Facility maintenance required',
          description: 'The building requires maintenance work on the plumbing system.',
          status: ReportStatus.inProgress,
          category: ReportCategory.facility,
          priority: ReportPriority.medium,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Report(
          id: '4',
          title: 'Staff shortage in emergency department',
          description: 'Emergency department is understaffed during night shifts.',
          status: ReportStatus.pending,
          category: ReportCategory.staff,
          priority: ReportPriority.high,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
    } catch (e) {
      debugPrint('Error loading reports: $e');
      return [];
    }
  }

  /// Create a new report
  static Future<ReportResult> createReport(ReportFormData formData) async {
    try {
      // Validate form data
      final validation = formData.validate();
      if (!validation.isValid) {
        return ReportResult.failure(validation.errorMessage!);
      }

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Create new report
      final report = Report(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: formData.title,
        description: formData.description,
        status: ReportStatus.open,
        category: formData.category,
        priority: formData.priority,
        createdAt: DateTime.now(),
        facilityId: formData.facilityId,
        attachments: formData.attachments,
      );

      // In a real app, this would send to backend
      debugPrint('Created report: ${report.title}');

      return ReportResult.success(
        message: ReportsConstants.reportCreatedMessage,
        report: report,
      );
    } catch (e) {
      debugPrint('Error creating report: $e');
      return ReportResult.failure('Failed to create report: $e');
    }
  }

  /// Update report status
  static Future<ReportResult> updateReportStatus(
    String reportId,
    ReportStatus newStatus,
  ) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      // In a real app, this would update via API
      debugPrint('Updated report $reportId to status: $newStatus');

      return ReportResult.success(
        message: 'Report status updated',
      );
    } catch (e) {
      debugPrint('Error updating report status: $e');
      return ReportResult.failure('Failed to update status: $e');
    }
  }

  /// Delete a report
  static Future<ReportResult> deleteReport(String reportId) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      // In a real app, this would delete via API
      debugPrint('Deleted report: $reportId');

      return ReportResult.success(
        message: 'Report deleted',
      );
    } catch (e) {
      debugPrint('Error deleting report: $e');
      return ReportResult.failure('Failed to delete report: $e');
    }
  }

  /// Search reports
  static List<Report> searchReports(
    List<Report> reports,
    String query, {
    ReportFilter? filter,
  }) {
    if (query.trim().isEmpty) return reports;
    
    final lowerQuery = query.toLowerCase();
    
    return reports.where((report) {
      // Search in title and description
      if (report.title.toLowerCase().contains(lowerQuery)) {
        return true;
      }
      
      if (report.description.toLowerCase().contains(lowerQuery)) {
        return true;
      }
      
      return false;
    }).toList();
  }

  /// Filter reports by criteria
  static List<Report> filterReports(
    List<Report> reports,
    ReportFilter filter,
  ) {
    return filter.apply(reports);
  }

  /// Sort reports by priority and date
  static List<Report> sortReports(
    List<Report> reports, {
    bool byPriority = true,
    bool descending = true,
  }) {
    final sorted = List<Report>.from(reports);
    
    if (byPriority) {
      sorted.sort((a, b) {
        final priorityComparison = b.priorityScore.compareTo(a.priorityScore);
        if (priorityComparison != 0) return priorityComparison;
        
        // If same priority, sort by date
        return descending 
            ? b.createdAt.compareTo(a.createdAt)
            : a.createdAt.compareTo(b.createdAt);
      });
    } else {
      sorted.sort((a, b) => descending 
          ? b.createdAt.compareTo(a.createdAt)
          : a.createdAt.compareTo(b.createdAt));
    }
    
    return sorted;
  }

  /// Get reports by status
  static List<Report> getReportsByStatus(
    List<Report> reports,
    ReportStatus status,
  ) {
    return reports.where((report) => report.status == status).toList();
  }

  /// Get reports by category
  static List<Report> getReportsByCategory(
    List<Report> reports,
    ReportCategory category,
  ) {
    return reports.where((report) => report.category == category).toList();
  }

  /// Get reports by priority
  static List<Report> getReportsByPriority(
    List<Report> reports,
    ReportPriority priority,
  ) {
    return reports.where((report) => report.priority == priority).toList();
  }

  /// Get active reports
  static List<Report> getActiveReports(List<Report> reports) {
    return reports.where((report) => report.isActive).toList();
  }

  /// Get resolved reports
  static List<Report> getResolvedReports(List<Report> reports) {
    return reports.where((report) => report.isResolved).toList();
  }

  /// Get reports from date range
  static List<Report> getReportsFromDateRange(
    List<Report> reports,
    DateTime startDate,
    DateTime endDate,
  ) {
    return reports.where((report) {
      return report.createdAt.isAfter(startDate) && 
             report.createdAt.isBefore(endDate);
    }).toList();
  }

  /// Calculate report statistics
  static ReportStatistics calculateStatistics(List<Report> reports) {
    return ReportStatistics.fromReports(reports);
  }

  /// Get report trends
  static Map<String, int> getReportTrends(List<Report> reports) {
    final trends = <String, int>{};
    
    for (final report in reports) {
      final dateKey = report.formattedDate;
      trends[dateKey] = (trends[dateKey] ?? 0) + 1;
    }
    
    return trends;
  }

  /// Get category distribution
  static Map<String, int> getCategoryDistribution(List<Report> reports) {
    final distribution = <String, int>{};
    
    for (final report in reports) {
      final category = report.categoryText;
      distribution[category] = (distribution[category] ?? 0) + 1;
    }
    
    return distribution;
  }

  /// Get priority distribution
  static Map<String, int> getPriorityDistribution(List<Report> reports) {
    final distribution = <String, int>{};
    
    for (final report in reports) {
      final priority = report.priorityText;
      distribution[priority] = (distribution[priority] ?? 0) + 1;
    }
    
    return distribution;
  }

  /// Get status distribution
  static Map<String, int> getStatusDistribution(List<Report> reports) {
    final distribution = <String, int>{};
    
    for (final report in reports) {
      final status = report.statusText;
      distribution[status] = (distribution[status] ?? 0) + 1;
    }
    
    return distribution;
  }

  /// Get average resolution time
  static double getAverageResolutionTime(List<Report> reports) {
    final resolvedReports = reports.where((r) => r.resolutionTime != null);
    
    if (resolvedReports.isEmpty) return 0.0;
    
    final totalDays = resolvedReports
        .map((r) => r.resolutionTime!)
        .reduce((a, b) => a + b);
    
    return totalDays / resolvedReports.length;
  }

  /// Get overdue reports
  static List<Report> getOverdueReports(
    List<Report> reports, {
    int daysThreshold = 7,
  }) {
    final threshold = DateTime.now().subtract(Duration(days: daysThreshold));
    
    return reports.where((report) {
      return report.isActive && report.createdAt.isBefore(threshold);
    }).toList();
  }

  /// Get high priority active reports
  static List<Report> getHighPriorityActiveReports(List<Report> reports) {
    return reports.where((report) {
      return report.isActive && 
             (report.priority == ReportPriority.high || report.priority == ReportPriority.urgent);
    }).toList();
  }

  /// Get recently created reports
  static List<Report> getRecentReports(
    List<Report> reports, {
    int days = 7,
  }) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    
    return reports.where((report) => report.createdAt.isAfter(cutoff)).toList();
  }

  /// Get reports needing attention
  static List<Report> getReportsNeedingAttention(List<Report> reports) {
    return reports.where((report) {
      // High priority and open
      if (report.priority == ReportPriority.urgent && report.status == ReportStatus.open) {
        return true;
      }
      
      // Open for more than 7 days
      if (report.status == ReportStatus.open && report.daysSinceCreation > 7) {
        return true;
      }
      
      return false;
    }).toList();
  }

  /// Export reports to JSON
  static String exportReportsToJson(List<Report> reports) {
    final data = {
      'reports': reports.map((r) => r.toJson()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
      'totalCount': reports.length,
      'statistics': ReportStatistics.fromReports(reports).toJson(),
    };
    
    return _encodeJson(data);
  }

  /// Simple JSON encoder (avoiding dart:convert dependency)
  static String _encodeJson(Map<String, dynamic> data) {
    // This is a simplified JSON encoder for demonstration
    // In a real app, you would use dart:convert
    return '{\n'
        '  "reports": [\n'
        '    // Report data would be serialized here\n'
        '  ],\n'
        '  "exportedAt": "${data['exportedAt']}",\n'
        '  "totalCount": ${data['totalCount']},\n'
        '  "statistics": {}\n'
        '}';
  }

  /// Get report summary
  static String getReportSummary(List<Report> reports) {
    final buffer = StringBuffer();
    
    buffer.writeln('Report Summary');
    buffer.writeln('===============');
    buffer.writeln();
    
    buffer.writeln('Total Reports: ${reports.length}');
    buffer.writeln('Open: ${reports.where((r) => r.status == ReportStatus.open).length}');
    buffer.writeln('In Progress: ${reports.where((r) => r.status == ReportStatus.inProgress).length}');
    buffer.writeln('Resolved: ${reports.where((r) => r.status == ReportStatus.resolved).length}');
    buffer.writeln('Closed: ${reports.where((r) => r.status == ReportStatus.closed).length}');
    buffer.writeln();
    
    if (reports.isNotEmpty) {
      buffer.writeln('Recent Reports:');
      for (int i = 0; i < reports.length && i < 5; i++) {
        final report = reports[i];
        buffer.writeln('• ${report.title} (${report.formattedDate}) - ${report.statusText}');
      }
    }
    
    return buffer.toString();
  }

  /// Validate report data
  static bool validateReportData(Map<String, dynamic> data) {
    try {
      // Check required fields
      if (!data.containsKey('title') || data['title']?.toString().trim().isEmpty == true) {
        return false;
      }
      
      // Check title length
      final title = data['title']?.toString() ?? '';
      if (title.length < ReportsConstants.titleMinLength || 
          title.length > ReportsConstants.titleMaxLength) {
        return false;
      }
      
      // Check description length
      final description = data['description']?.toString() ?? '';
      if (description.length > ReportsConstants.descriptionMaxLength) {
        return false;
      }
      
      return true;
    } catch (e) {
      debugPrint('Error validating report data: $e');
      return false;
    }
  }

  /// Get report recommendations
  static List<String> getReportRecommendations(List<Report> reports) {
    final recommendations = <String>[];
    
    final overdueReports = getOverdueReports(reports);
    if (overdueReports.isNotEmpty) {
      recommendations.add('${overdueReports.length} reports are overdue and need attention');
    }
    
    final highPriorityReports = getHighPriorityActiveReports(reports);
    if (highPriorityReports.isNotEmpty) {
      recommendations.add('${highPriorityReports.length} high priority reports require immediate action');
    }
    
    final openReports = getReportsByStatus(reports, ReportStatus.open);
    if (openReports.length > 10) {
      recommendations.add('Consider prioritizing the ${openReports.length} open reports');
    }
    
    final averageResolutionTime = getAverageResolutionTime(reports);
    if (averageResolutionTime > 5.0) {
      recommendations.add('Average resolution time is ${averageResolutionTime.toStringAsFixed(1)} days - consider improving efficiency');
    }
    
    return recommendations;
  }

  /// Get report insights
  static Map<String, dynamic> getReportInsights(List<Report> reports) {
    final statistics = ReportStatistics.fromReports(reports);
    final trends = getReportTrends(reports);
    final categoryDist = getCategoryDistribution(reports);
    final priorityDist = getPriorityDistribution(reports);
    
    return {
      'statistics': statistics,
      'trends': trends,
      'categoryDistribution': categoryDist,
      'priorityDistribution': priorityDist,
      'recommendations': getReportRecommendations(reports),
      'insights': {
        'mostCommonCategory': statistics.mostCommonCategory?.toString(),
        'mostCommonPriority': statistics.mostCommonPriority?.toString(),
        'resolutionPercentage': (statistics.resolutionPercentage * 100).toStringAsFixed(1) + '%',
        'averageResolutionTime': statistics.averageResolutionTime.toStringAsFixed(1) + ' days',
      },
    };
  }

  /// Simulate real-time updates
  static Stream<Report> simulateRealTimeUpdates() {
    return Stream.periodic(const Duration(seconds: 30), (_) {
      // Simulate random report updates
      return Report(
        id: 'simulated_${DateTime.now().millisecondsSinceEpoch}',
        title: 'System update required',
        description: 'Automated system maintenance needed',
        status: ReportStatus.pending,
        category: ReportCategory.equipment,
        priority: ReportPriority.medium,
        createdAt: DateTime.now(),
      );
    });
  }

  /// Bulk update reports
  static Future<ReportResult> bulkUpdateReports(
    List<String> reportIds,
    ReportStatus newStatus,
  ) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // In a real app, this would update multiple reports via API
      debugPrint('Bulk updated ${reportIds.length} reports to status: $newStatus');

      return ReportResult.success(
        message: 'Updated ${reportIds.length} reports',
      );
    } catch (e) {
      debugPrint('Error bulk updating reports: $e');
      return ReportResult.failure('Failed to update reports: $e');
    }
  }

  /// Get report timeline
  static List<Map<String, dynamic>> getReportTimeline(Report report) {
    final timeline = <Map<String, dynamic>>[];
    
    // Created
    timeline.add({
      'date': report.createdAt,
      'action': 'Created',
      'description': 'Report was created',
      'type': 'creation',
    });
    
    // Updated
    if (report.updatedAt != null && report.updatedAt!.isAfter(report.createdAt)) {
      timeline.add({
        'date': report.updatedAt!,
        'action': 'Updated',
        'description': 'Report was updated',
        'type': 'update',
      });
    }
    
    // Resolved
    if (report.resolvedAt != null) {
      timeline.add({
        'date': report.resolvedAt!,
        'action': 'Resolved',
        'description': 'Report was resolved',
        'type': 'resolution',
      });
    }
    
    // Sort by date
    timeline.sort((a, b) => a['date'].compareTo(b['date']));
    
    return timeline;
  }

  /// Get report performance metrics
  static Map<String, dynamic> getPerformanceMetrics(List<Report> reports) {
    final now = DateTime.now();
    final last30Days = now.subtract(const Duration(days: 30));
    final last7Days = now.subtract(const Duration(days: 7));
    
    final reportsLast30Days = reports.where((r) => r.createdAt.isAfter(last30Days)).toList();
    final reportsLast7Days = reports.where((r) => r.createdAt.isAfter(last7Days)).toList();
    
    return {
      'totalReports': reports.length,
      'reportsLast30Days': reportsLast30Days.length,
      'reportsLast7Days': reportsLast7Days.length,
      'averageReportsPerDay': reportsLast30Days.length / 30.0,
      'resolutionRate': ReportStatistics.fromReports(reports).resolutionPercentage,
      'averageResolutionTime': getAverageResolutionTime(reports),
      'overdueReportsCount': getOverdueReports(reports).length,
      'highPriorityCount': getHighPriorityActiveReports(reports).length,
    };
  }
}
