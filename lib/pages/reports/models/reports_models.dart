/// Models and constants for reports functionality
class ReportsConstants {
  // UI labels
  static const String pageTitle = 'Reports';
  static const String createReportLabel = 'Create Report';
  static const String titleLabel = 'Title';
  static const String descriptionLabel = 'Description';
  static const String submitLabel = 'Submit';
  static const String cancelLabel = 'Cancel';
  static const String closeLabel = 'Close';
  static const String detailsLabel = 'Details';
  static const String dateLabel = 'Date';
  static const String statusLabel = 'Status';
  static const String noDetailsMessage = 'No further details provided.';
  static const String reportCreatedMessage = 'Report created';
  
  // Status labels
  static const String openStatus = 'Open';
  static const String closedStatus = 'Closed';
  static const String inProgressStatus = 'In Progress';
  static const String resolvedStatus = 'Resolved';
  static const String pendingStatus = 'Pending';
  
  // Report categories
  static const String equipmentCategory = 'Equipment';
  static const String stockoutCategory = 'Stockout';
  static const String facilityCategory = 'Facility';
  static const String staffCategory = 'Staff';
  static const String otherCategory = 'Other';
  
  // Priority levels
  static const String lowPriority = 'Low';
  static const String mediumPriority = 'Medium';
  static const String highPriority = 'High';
  static const String urgentPriority = 'Urgent';
  
  // Animation durations
  static const int animationDurationMs = 300;
  static const int bottomSheetAnimationMs = 250;
  
  // Validation
  static const int titleMinLength = 3;
  static const int titleMaxLength = 100;
  static const int descriptionMaxLength = 1000;
  
  // API endpoints
  static const String reportsEndpoint = '/api/reports';
  static const String submitReportEndpoint = '/api/reports/submit';
}

/// Report status enum
enum ReportStatus {
  open,
  closed,
  inProgress,
  resolved,
  pending,
}

/// Report category enum
enum ReportCategory {
  equipment,
  stockout,
  facility,
  staff,
  other,
}

/// Report priority enum
enum ReportPriority {
  low,
  medium,
  high,
  urgent,
}

/// Report model
class Report {
  final String id;
  final String title;
  final String description;
  final ReportStatus status;
  final ReportCategory category;
  final ReportPriority priority;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;
  final String? userId;
  final String? facilityId;
  final String? assignedTo;
  final List<String> attachments;
  final Map<String, dynamic>? metadata;

  Report({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.category,
    required this.priority,
    required this.createdAt,
    this.updatedAt,
    this.resolvedAt,
    this.userId,
    this.facilityId,
    this.assignedTo,
    this.attachments = const [],
    this.metadata,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: _parseStatus(json['status']),
      category: _parseCategory(json['category']),
      priority: _parsePriority(json['priority']),
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updatedAt']),
      resolvedAt: _parseDateTime(json['resolvedAt']),
      userId: json['userId']?.toString(),
      facilityId: json['facilityId']?.toString(),
      assignedTo: json['assignedTo']?.toString(),
      attachments: _parseStringList(json['attachments']),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  factory Report.fromLegacyMap(Map<String, String> legacy) {
    return Report(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: legacy['title'] ?? '',
      description: '',
      status: _parseStatus(legacy['status']),
      category: ReportCategory.other,
      priority: ReportPriority.medium,
      createdAt: _parseDateTime(legacy['date']) ?? DateTime.now(),
    );
  }

  /// Parse status from string
  static ReportStatus _parseStatus(dynamic status) {
    final statusStr = status?.toString().toLowerCase();
    switch (statusStr) {
      case 'open':
        return ReportStatus.open;
      case 'closed':
        return ReportStatus.closed;
      case 'inprogress':
      case 'in_progress':
        return ReportStatus.inProgress;
      case 'resolved':
        return ReportStatus.resolved;
      case 'pending':
        return ReportStatus.pending;
      default:
        return ReportStatus.open;
    }
  }

  /// Parse category from string
  static ReportCategory _parseCategory(dynamic category) {
    final categoryStr = category?.toString().toLowerCase();
    switch (categoryStr) {
      case 'equipment':
        return ReportCategory.equipment;
      case 'stockout':
        return ReportCategory.stockout;
      case 'facility':
        return ReportCategory.facility;
      case 'staff':
        return ReportCategory.staff;
      case 'other':
        return ReportCategory.other;
      default:
        return ReportCategory.other;
    }
  }

  /// Parse priority from string
  static ReportPriority _parsePriority(dynamic priority) {
    final priorityStr = priority?.toString().toLowerCase();
    switch (priorityStr) {
      case 'low':
        return ReportPriority.low;
      case 'medium':
        return ReportPriority.medium;
      case 'high':
        return ReportPriority.high;
      case 'urgent':
        return ReportPriority.urgent;
      default:
        return ReportPriority.medium;
    }
  }

  /// Parse date time
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (e) {
      return null;
    }
  }

  /// Parse string list
  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String) {
      return [value];
    }
    return [];
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.toString(),
      'category': category.toString(),
      'priority': priority.toString(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'userId': userId,
      'facilityId': facilityId,
      'assignedTo': assignedTo,
      'attachments': attachments,
      'metadata': metadata,
    };
  }

  /// Create copy with updated fields
  Report copyWith({
    String? id,
    String? title,
    String? description,
    ReportStatus? status,
    ReportCategory? category,
    ReportPriority? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? resolvedAt,
    String? userId,
    String? facilityId,
    String? assignedTo,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
  }) {
    return Report(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      userId: userId ?? this.userId,
      facilityId: facilityId ?? this.facilityId,
      assignedTo: assignedTo ?? this.assignedTo,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get formatted date
  String get formattedDate {
    return '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}';
  }

  /// Get formatted date with time
  String get formattedDateTime {
    return '${formattedDate} ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  /// Get status display text
  String get statusText {
    switch (status) {
      case ReportStatus.open:
        return ReportsConstants.openStatus;
      case ReportStatus.closed:
        return ReportsConstants.closedStatus;
      case ReportStatus.inProgress:
        return ReportsConstants.inProgressStatus;
      case ReportStatus.resolved:
        return ReportsConstants.resolvedStatus;
      case ReportStatus.pending:
        return ReportsConstants.pendingStatus;
    }
  }

  /// Get category display text
  String get categoryText {
    switch (category) {
      case ReportCategory.equipment:
        return ReportsConstants.equipmentCategory;
      case ReportCategory.stockout:
        return ReportsConstants.stockoutCategory;
      case ReportCategory.facility:
        return ReportsConstants.facilityCategory;
      case ReportCategory.staff:
        return ReportsConstants.staffCategory;
      case ReportCategory.other:
        return ReportsConstants.otherCategory;
    }
  }

  /// Get priority display text
  String get priorityText {
    switch (priority) {
      case ReportPriority.low:
        return ReportsConstants.lowPriority;
      case ReportPriority.medium:
        return ReportsConstants.mediumPriority;
      case ReportPriority.high:
        return ReportsConstants.highPriority;
      case ReportPriority.urgent:
        return ReportsConstants.urgentPriority;
    }
  }

  /// Check if report is resolved
  bool get isResolved => status == ReportStatus.resolved || status == ReportStatus.closed;

  /// Check if report is active
  bool get isActive => !isResolved;

  /// Get days since creation
  int get daysSinceCreation {
    return DateTime.now().difference(createdAt).inDays;
  }

  /// Get resolution time
  int? get resolutionTime {
    if (resolvedAt == null) return null;
    return resolvedAt!.difference(createdAt).inDays;
  }

  /// Get priority score for sorting
  int get priorityScore {
    switch (priority) {
      case ReportPriority.urgent:
        return 4;
      case ReportPriority.high:
        return 3;
      case ReportPriority.medium:
        return 2;
      case ReportPriority.low:
        return 1;
    }
  }

  /// Get status color
  String get statusColor {
    switch (status) {
      case ReportStatus.open:
        return 'orange';
      case ReportStatus.inProgress:
        return 'blue';
      case ReportStatus.resolved:
        return 'green';
      case ReportStatus.closed:
        return 'gray';
      case ReportStatus.pending:
        return 'yellow';
    }
  }

  /// Get priority color
  String get priorityColor {
    switch (priority) {
      case ReportPriority.urgent:
        return 'red';
      case ReportPriority.high:
        return 'orange';
      case ReportPriority.medium:
        return 'yellow';
      case ReportPriority.low:
        return 'green';
    }
  }
}

/// Reports state model
class ReportsState {
  final List<Report> reports;
  final bool isLoading;
  final bool isCreating;
  final String? error;
  final ReportFilter filter;

  const ReportsState({
    this.reports = const [],
    this.isLoading = false,
    this.isCreating = false,
    this.error,
    this.filter = const ReportFilter(),
  });

  ReportsState copyWith({
    List<Report>? reports,
    bool? isLoading,
    bool? isCreating,
    String? error,
    ReportFilter? filter,
  }) {
    return ReportsState(
      reports: reports ?? this.reports,
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      error: error ?? this.error,
      filter: filter ?? this.filter,
    );
  }

  /// Clear error
  ReportsState clearError() => copyWith(error: null);

  /// Set loading
  ReportsState setLoading(bool loading) => copyWith(isLoading: loading, error: null);

  /// Set creating
  ReportsState setCreating(bool creating) => copyWith(isCreating: creating, error: null);

  /// Set error
  ReportsState setError(String error) => copyWith(isLoading: false, isCreating: false, error: error);

  /// Update reports
  ReportsState updateReports(List<Report> newReports) {
    return copyWith(reports: newReports);
  }

  /// Add report
  ReportsState addReport(Report report) {
    return copyWith(reports: [report, ...reports]);
  }

  /// Update report
  ReportsState updateReport(Report updatedReport) {
    final updatedReports = reports.map((report) {
      if (report.id == updatedReport.id) {
        return updatedReport;
      }
      return report;
    }).toList();
    return copyWith(reports: updatedReports);
  }

  /// Remove report
  ReportsState removeReport(String reportId) {
    final updatedReports = reports.where((report) => report.id != reportId).toList();
    return copyWith(reports: updatedReports);
  }

  /// Check if has error
  bool get hasError => error != null;

  /// Check if is loading
  bool get isAnyLoading => isLoading || isCreating;

  /// Check if has reports
  bool get hasReports => reports.isNotEmpty;

  /// Get active reports
  List<Report> get activeReports => reports.where((report) => report.isActive).toList();

  /// Get resolved reports
  List<Report> get resolvedReports => reports.where((report) => report.isResolved).toList();

  /// Get reports by status
  List<Report> getReportsByStatus(ReportStatus status) {
    return reports.where((report) => report.status == status).toList();
  }

  /// Get reports by category
  List<Report> getReportsByCategory(ReportCategory category) {
    return reports.where((report) => report.category == category).toList();
  }

  /// Get reports by priority
  List<Report> getReportsByPriority(ReportPriority priority) {
    return reports.where((report) => report.priority == priority).toList();
  }
}

/// Report filter model
class ReportFilter {
  final ReportStatus? status;
  final ReportCategory? category;
  final ReportPriority? priority;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchQuery;

  const ReportFilter({
    this.status,
    this.category,
    this.priority,
    this.startDate,
    this.endDate,
    this.searchQuery,
  });

  /// Create copy with updated fields
  ReportFilter copyWith({
    ReportStatus? status,
    ReportCategory? category,
    ReportPriority? priority,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
  }) {
    return ReportFilter(
      status: status ?? this.status,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  /// Clear all filters
  ReportFilter clear() {
    return const ReportFilter();
  }

  /// Check if has any active filters
  bool get hasFilters => 
      status != null || 
      category != null || 
      priority != null || 
      startDate != null || 
      endDate != null || 
      searchQuery?.isNotEmpty == true;

  /// Apply filter to reports
  List<Report> apply(List<Report> reports) {
    return reports.where((report) {
      // Status filter
      if (status != null && report.status != status) return false;

      // Category filter
      if (category != null && report.category != category) return false;

      // Priority filter
      if (priority != null && report.priority != priority) return false;

      // Date range filter
      if (startDate != null && report.createdAt.isBefore(startDate!)) return false;
      if (endDate != null && report.createdAt.isAfter(endDate!)) return false;

      // Search query filter
      if (searchQuery != null && searchQuery!.isNotEmpty) {
        final query = searchQuery!.toLowerCase();
        if (!report.title.toLowerCase().contains(query) &&
            !report.description.toLowerCase().contains(query)) {
          return false;
        }
      }

      return true;
    }).toList();
  }
}

/// Report form data model
class ReportFormData {
  final String title;
  final String description;
  final ReportCategory category;
  final ReportPriority priority;
  final String? facilityId;
  final List<String> attachments;

  ReportFormData({
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    this.facilityId,
    this.attachments = const [],
  });

  /// Validate form data
  ValidationResult validate() {
    final errors = <String>[];
    
    if (title.trim().isEmpty) {
      errors.add('Title is required');
    } else if (title.trim().length < ReportsConstants.titleMinLength) {
      errors.add('Title must be at least ${ReportsConstants.titleMinLength} characters');
    } else if (title.trim().length > ReportsConstants.titleMaxLength) {
      errors.add('Title must be less than ${ReportsConstants.titleMaxLength} characters');
    }
    
    if (description.length > ReportsConstants.descriptionMaxLength) {
      errors.add('Description must be less than ${ReportsConstants.descriptionMaxLength} characters');
    }
    
    return errors.isEmpty 
        ? ValidationResult.valid 
        : ValidationResult.invalid(errors.join(', '));
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title.trim(),
      'description': description.trim(),
      'category': category.toString(),
      'priority': priority.toString(),
      'facilityId': facilityId,
      'attachments': attachments,
    };
  }

  /// Check if form is dirty (has been modified)
  bool get isDirty => title.isNotEmpty || description.isNotEmpty;
}

/// Report statistics model
class ReportStatistics {
  final int totalReports;
  final int openReports;
  final int closedReports;
  final int inProgressReports;
  final int resolvedReports;
  final int pendingReports;
  final Map<ReportCategory, int> categoryCounts;
  final Map<ReportPriority, int> priorityCounts;
  final double averageResolutionTime;
  final DateTime lastUpdated;

  ReportStatistics({
    required this.totalReports,
    required this.openReports,
    required this.closedReports,
    required this.inProgressReports,
    required this.resolvedReports,
    required this.pendingReports,
    required this.categoryCounts,
    required this.priorityCounts,
    required this.averageResolutionTime,
    required this.lastUpdated,
  });

  /// Calculate statistics from reports
  factory ReportStatistics.fromReports(List<Report> reports) {
    final now = DateTime.now();
    
    final totalReports = reports.length;
    final openReports = reports.where((r) => r.status == ReportStatus.open).length;
    final closedReports = reports.where((r) => r.status == ReportStatus.closed).length;
    final inProgressReports = reports.where((r) => r.status == ReportStatus.inProgress).length;
    final resolvedReports = reports.where((r) => r.status == ReportStatus.resolved).length;
    final pendingReports = reports.where((r) => r.status == ReportStatus.pending).length;
    
    final categoryCounts = <ReportCategory, int>{};
    for (final report in reports) {
      categoryCounts[report.category] = (categoryCounts[report.category] ?? 0) + 1;
    }
    
    final priorityCounts = <ReportPriority, int>{};
    for (final report in reports) {
      priorityCounts[report.priority] = (priorityCounts[report.priority] ?? 0) + 1;
    }
    
    final resolvedReportsList = reports.where((r) => r.resolutionTime != null);
    final averageResolutionTime = resolvedReportsList.isNotEmpty
        ? resolvedReportsList.map((r) => r.resolutionTime!).reduce((a, b) => a + b) / resolvedReportsList.length
        : 0.0;

    return ReportStatistics(
      totalReports: totalReports,
      openReports: openReports,
      closedReports: closedReports,
      inProgressReports: inProgressReports,
      resolvedReports: resolvedReports,
      pendingReports: pendingReports,
      categoryCounts: categoryCounts,
      priorityCounts: priorityCounts,
      averageResolutionTime: averageResolutionTime,
      lastUpdated: now,
    );
  }

  /// Get resolution percentage
  double get resolutionPercentage {
    if (totalReports == 0) return 0.0;
    return (resolvedReports + closedReports) / totalReports;
  }

  /// Get most common category
  ReportCategory? get mostCommonCategory {
    if (categoryCounts.isEmpty) return null;
    
    return categoryCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Get most common priority
  ReportPriority? get mostCommonPriority {
    if (priorityCounts.isEmpty) return null;
    
    return priorityCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Check if has data
  bool get hasData => totalReports > 0;
}

/// Report action result
class ReportResult {
  final bool success;
  final String? message;
  final Report? report;

  ReportResult({
    required this.success,
    this.message,
    this.report,
  });

  factory ReportResult.success({
    String? message,
    Report? report,
  }) {
    return ReportResult(
      success: true,
      message: message ?? ReportsConstants.reportCreatedMessage,
      report: report,
    );
  }

  factory ReportResult.failure(String message) {
    return ReportResult(
      success: false,
      message: message,
    );
  }
}

/// Validation result
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult({required this.isValid, this.errorMessage});

  static const ValidationResult valid = ValidationResult(isValid: true);
  
  ValidationResult.invalid(String message) 
      : isValid = false, errorMessage = message;
}
