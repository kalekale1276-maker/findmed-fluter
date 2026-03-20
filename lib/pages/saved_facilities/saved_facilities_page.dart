import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/tailwind_extensions.dart';
import '../models/saved_facilities_models.dart';
import '../services/saved_facilities_services.dart';
import '../widgets/saved_facilities_widgets.dart';

/// Saved Facilities Page - User's saved healthcare facilities
class SavedFacilitiesPage extends StatefulWidget {
  const SavedFacilitiesPage({super.key});

  @override
  State<SavedFacilitiesPage> createState() => _SavedFacilitiesPageState();
}

class _SavedFacilitiesPageState extends State<SavedFacilitiesPage> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Controllers
  final TextEditingController _searchController = TextEditingController();
  
  // State
  SavedFacilitiesState _state = const SavedFacilitiesState();
  String _sortBy = 'name';

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
    await _loadFacilities();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _searchController.dispose();
    SavedFacilitiesWidgets.clearContext();
    super.dispose();
  }

  // State management
  void _updateState(SavedFacilitiesState newState) {
    setState(() {
      _state = newState;
    });
  }

  void _setLoading(bool loading) {
    _updateState(_state.setLoading(loading));
  }

  void _setDeleting(bool deleting) {
    _updateState(_state.setDeleting(deleting));
  }

  void _setError(String error) {
    _updateState(_state.setError(error));
  }

  void _clearError() {
    _updateState(_state.clearError());
  }

  void _updateSearchQuery(String query) {
    _updateState(_state.updateSearchQuery(query));
  }

  void _updateSelectedType(String? type) {
    _updateState(_state.updateSelectedType(type));
  }

  // Data loading
  Future<void> _loadFacilities() async {
    _setLoading(true);
    _clearError();
    
    try {
      final facilities = await SavedFacilitiesServices.loadSavedFacilities();
      _updateState(_state.updateFacilities(facilities));
    } catch (e) {
      _setError('Failed to load facilities: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Search and filter
  void _onSearchChanged(String query) {
    _updateSearchQuery(query);
  }

  void _onTypeSelected(String? type) {
    _updateSelectedType(type);
  }

  void _onSortChanged(String sortBy) {
    setState(() {
      _sortBy = sortBy;
    });
    _applySorting();
  }

  void _applySorting() {
    if (!_state.hasFacilities) return;
    
    List<SavedFacility> sorted;
    
    switch (_sortBy) {
      case 'name':
        sorted = SavedFacilitiesServices.sortFacilitiesByName(_state.filteredFacilities);
        break;
      case 'type':
        sorted = SavedFacilitiesServices.sortFacilitiesByType(_state.filteredFacilities);
        break;
      case 'address':
        sorted = _state.filteredFacilities;
        break;
      case 'created':
        sorted = _state.filteredFacilities;
        break;
      default:
        sorted = _state.filteredFacilities;
    }
    
    _updateState(_state.updateFacilities(sorted));
  }

  // Facility actions
  Future<void> _callFacility(SavedFacility facility) async {
    try {
      final success = await SavedFacilitiesServices.callFacility(facility.phone);
      if (!success) {
        _showErrorMessage('Failed to make phone call');
      }
    } catch (e) {
      _showErrorMessage('Error making call: $e');
    }
  }

  Future<void> _openFacilityInMaps(SavedFacility facility) async {
    try {
      final success = await SavedFacilitiesServices.openFacilityInMaps(facility);
      if (!success) {
        _showErrorMessage('Failed to open maps');
      }
    } catch (e) {
      _showErrorMessage('Error opening maps: $e');
    }
  }

  Future<void> _sendEmailToFacility(SavedFacility facility) async {
    try {
      if (facility.email == null) return;
      
      final success = await SavedFacilitiesServices.sendEmailToFacility(facility.email!);
      if (!success) {
        _showErrorMessage('Failed to send email');
      }
    } catch (e) {
      _showErrorMessage('Error sending email: $e');
    }
  }

  Future<void> _openFacilityWebsite(SavedFacility facility) async {
    try {
      if (facility.website == null) return;
      
      final success = await SavedFacilitiesServices.openFacilityWebsite(facility.website!);
      if (!success) {
        _showErrorMessage('Failed to open website');
      }
    } catch (e) {
      _showErrorMessage('Error opening website: $e');
    }
  }

  Future<void> _removeFacility(SavedFacility facility) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => SavedFacilitiesWidgets.buildDeleteConfirmationDialog(
        facilityName: facility.displayName,
        onConfirm: () => Navigator.pop(context, true),
        onCancel: () => Navigator.pop(context, false),
      ),
    );
    
    if (!confirmed) return;
    
    _setDeleting(true);
    _clearError();
    
    try {
      final result = await SavedFacilitiesServices.removeSavedFacility(facility.id);
      
      if (result.success) {
        _showSuccessMessage('Facility removed from saved list');
        await _loadFacilities(); // Reload to get updated list
      } else {
        _setError(result.message!);
      }
    } catch (e) {
      _setError('Failed to remove facility: $e');
    } finally {
      _setDeleting(false);
    }
  }

  void _showFacilityDetail(SavedFacility facility) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (_) => SavedFacilitiesWidgets.buildFacilityDetailSheet(
        facility: facility,
        onClose: () => Navigator.pop(context),
        onCall: facility.hasPhone ? () => _callFacility(facility) : null,
        onEmail: facility.hasEmail ? () => _sendEmailToFacility(facility) : null,
        onWebsite: facility.hasWebsite ? () => _openFacilityWebsite(facility) : null,
        onMaps: facility.hasCoordinates ? () => _openFacilityInMaps(facility) : null,
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

  @override
  Widget build(BuildContext context) {
    SavedFacilitiesWidgets.setContext(context);
    
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
        SavedFacilitiesConstants.pageTitle,
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
          onPressed: _loadFacilities,
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
      return SavedFacilitiesWidgets.buildLoadingIndicator();
    }
    
    if (_state.hasError) {
      return SavedFacilitiesWidgets.buildErrorState(_state.error!);
    }
    
    if (!_state.hasFacilities) {
      return SavedFacilitiesWidgets.buildEmptyState();
    }
    
    return Column(
      children: [
        // Search bar
        SavedFacilitiesWidgets.buildSearchBar(
          controller: _searchController,
          onChanged: _onSearchChanged,
        ),
        
        // Filter chips
        if (_state.uniqueTypes.isNotEmpty)
          SavedFacilitiesWidgets.buildFilterChips(
            types: _state.uniqueTypes,
            selectedType: _state.selectedType,
            onTypeSelected: _onTypeSelected,
          ),
        
        // Sort options
        SavedFacilitiesWidgets.buildSortOptions(
          sortBy: _sortBy,
          onSortChanged: _onSortChanged,
        ),
        
        // Statistics card
        if (_state.hasFacilities)
          FutureBuilder<FacilityStatistics>(
            future: Future.value(SavedFacilitiesServices.calculateStatistics(_state.facilities)),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.hasData) {
                return SavedFacilitiesWidgets.buildStatisticsCard(stats: snapshot.data!);
              }
              return const SizedBox.shrink();
            },
          ),
        
        // Facilities list
        Expanded(
          child: _buildFacilitiesList(),
        ),
      ],
    );
  }

  Widget _buildFacilitiesList() {
    return RefreshIndicator(
      onRefresh: _loadFacilities,
      child: ListView.separated(
        itemCount: _state.filteredFacilities.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, index) {
          final facility = _state.filteredFacilities[index];
          
          return SavedFacilitiesWidgets.buildFacilityItem(
            facility: facility,
            onTap: () => _showFacilityDetail(facility),
            onCall: facility.hasPhone ? () => _callFacility(facility) : null,
            onDelete: () => _removeFacility(facility),
          );
        },
      ),
    );
  }
}
