import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/tailwind_extensions.dart';
import '../models/reports_models.dart';
import '../services/reports_services.dart';
import '../widgets/reports_widgets.dart';

/// Reports Page - Issue reporting and management
class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  
  // State
  ReportsState _state = const ReportsState();
  ReportCategory _selectedCategory = ReportCategory.other;
  ReportPriority _selectedPriority = ReportPriority.medium;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    
    _fadeController.forward();
    _slideController.forward();
  }

  void _initializeData() async {
    // Load reports data when page opens
    await _loadReports();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    ReportsWidgets.clearContext();
    super.dispose();
  }

  // State management
  void _updateState(ReportsState newState) {
    setState(() {
      _state = newState;
    });
  }

  void _setLoading(bool loading) {
    _updateState(_state.setLoading(loading));
  }

  void _setCreating(bool creating) {
    _updateState(_state.setCreating(creating));
  }

  void _setError(String error) {
    _updateState(_state.setError(error));
  }

  void _clearError() {
    _updateState(_state.clearError());
  }

  void _updateFilter(ReportFilter newFilter) {
    _updateState(_state.copyWith(filter: newFilter));
    _applyFilter();
  }

  // Data loading
  Future<void> _loadReports() async {
    _setLoading(true);
    _clearError();
    
    try {
      final reports = await ReportsServices.loadReports();
      
      // Sort reports by priority and date
      final sortedReports = ReportsServices.sortReports(reports, byPriority: true);
      
      _updateState(_state.updateReports(sortedReports));
    } catch (e) {
      _setError('Failed to load reports: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _applyFilter() {
    if (_state.reports.isEmpty) return;
    
    final filteredReports = ReportsServices.filterReports(_state.reports, _state.filter);
    final sortedReports = ReportsServices.sortReports(filteredReports, byPriority: true);
    
    _updateState(_state.updateReports(sortedReports));
  }

  // Search functionality
  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      _applyFilter();
      return;
    }
    
    final searchResults = ReportsServices.searchReports(_state.reports, query);
    final sortedResults = ReportsServices.sortReports(searchResults, byPriority: true);
    
    _updateState(_state.updateReports(sortedResults));
  }

  // Report creation
  Future<void> _createReport() async {
    // Clear controllers
    _titleController.clear();
    _descriptionController.clear();
    _selectedCategory = ReportCategory.other;
    _selectedPriority = ReportPriority.medium;
    
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: ReportsWidgets.buildCreateReportSheet(
          titleController: _titleController,
          descriptionController: _descriptionController,
          selectedCategory: _selectedCategory,
          selectedPriority: _selectedPriority,
          onCategoryChanged: (category) => _selectedCategory = category,
          onPriorityChanged: (priority) => _selectedPriority = priority,
          onCancel: () => Navigator.pop(ctx),
          onSubmit: () async {
            await _submitReport();
            Navigator.pop(ctx);
          },
          isLoading: _state.isCreating,
        ),
      ),
    );
  }

  Future<void> _submitReport() async {
    if (_titleController.text.trim().isEmpty) {
      _setError('Title is required');
      return;
    }
    
    _setCreating(true);
    _clearError();
    
    try {
      final formData = ReportFormData(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        priority: _selectedPriority,
      );
      
      final result = await ReportsServices.createReport(formData);
      
      if (result.success) {
        _showSuccessMessage(result.message!);
        
        // Reload reports
        await _loadReports();
        
        // Clear controllers
        _titleController.clear();
        _descriptionController.clear();
      } else {
        _setError(result.message!);
      }
    } catch (e) {
      _setError('Failed to create report: $e');
    } finally {
      _setCreating(false);
    }
  }

  // Report interactions
  Future<void> _showReportDetail(Report report) async {
    await showDialog(
      context: context,
      builder: (_) => ReportsWidgets.buildReportDetailDialog(
        report: report,
        onClose: () => Navigator.pop(context),
        onStatusChange: report.isActive ? () => _updateReportStatus(report) : null,
      ),
    );
  }

  Future<void> _updateReportStatus(Report report) async {
    // Show status options
    final newStatus = await _showStatusSelector(report.status);
    if (newStatus == null) return;
    
    try {
      final result = await ReportsServices.updateReportStatus(report.id, newStatus);
      
      if (result.success) {
        _showSuccessMessage('Report status updated');
        
        // Update local state
        final updatedReport = report.copyWith(status: newStatus, updatedAt: DateTime.now());
        _updateState(_state.updateReport(updatedReport));
      } else {
        _showErrorMessage(result.message!);
      }
    } catch (e) {
      _showErrorMessage('Failed to update status: $e');
    }
  }

  Future<ReportStatus?> _showStatusSelector(ReportStatus currentStatus) async {
    return showDialog<ReportStatus>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Update Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ReportStatus.values.map((status) {
            return RadioListTile<ReportStatus>(
              title: Text(_getStatusText(status)),
              value: status,
              groupValue: currentStatus,
              onChanged: (value) {
                Navigator.pop(context, value);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // UI helpers
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _getStatusText(ReportStatus status) {
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

  @override
  Widget build(BuildContext context) {
    ReportsWidgets.setContext(context);
    
    return Scaffold(
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _buildBody(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        ReportsConstants.pageTitle,
        style: TextStyle(
          fontSize: context.responsiveTextLg,
          fontWeight: FontWeight.bold,
          color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
        ),
      ),
      backgroundColor: context.isDarkMode ? TailwindColors.gray800 : Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(
        color: context.isDarkMode ? Colors.white : TailwindColors.gray700,
        size: context.isMobile ? 22.w : 24.w,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadReports,
          tooltip: 'Refresh',
        ),
      ],
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.transparent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_state.isLoading) {
      return ReportsWidgets.buildLoadingIndicator();
    }
    
    if (_state.hasError) {
      return ReportsWidgets.buildErrorState(_state.error!);
    }
    
    return Column(
      children: [
        // Search bar
        ReportsWidgets.buildSearchBar(
          controller: _searchController,
          onChanged: _onSearchChanged,
        ),
        
        // Filter chips
        ReportsWidgets.buildFilterChips(
          filter: _state.filter,
          onFilterChanged: _updateFilter,
        ),
        
        // Statistics card
        if (_state.hasReports)
          FutureBuilder<ReportStatistics>(
            future: Future.value(ReportsServices.calculateStatistics(_state.reports)),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.hasData) {
                return ReportsWidgets.buildStatisticsCard(stats: snapshot.data!);
              }
              return const SizedBox.shrink();
            },
          ),
        
        // Create report button
        Padding(
          padding: EdgeInsets.all(16.w),
          child: ReportsWidgets.buildCreateReportButton(
            onPressed: _createReport,
            isLoading: _state.isCreating,
          ),
        ),
        
        // Reports list
        Expanded(
          child: _state.hasReports
              ? _buildReportsList()
              : ReportsWidgets.buildEmptyState(),
        ),
      ],
    );
  }

  Widget _buildReportsList() {
    return RefreshIndicator(
      onRefresh: _loadReports,
      child: ListView.separated(
        itemCount: _state.reports.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, index) {
          final report = _state.reports[index];
          
          return ReportsWidgets.buildReportItem(
            report: report,
            onTap: () => _showReportDetail(report),
          );
        },
      ),
    );
  }
}
