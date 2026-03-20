import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/tailwind_extensions.dart';
import '../../../../widgets/app_drawer.dart';
import '../../../../widgets/branding_widgets.dart';
import 'models/emergency_models.dart';
import 'services/emergency_services.dart';
import 'widgets/emergency_widgets.dart';

/// Emergency Page - Emergency services and nearby hospitals
class EmergencyPage extends StatefulWidget {
  const EmergencyPage({super.key});

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  
  // State
  EmergencyState _state = const EmergencyState();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeEmergency();
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
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _fadeController.forward();
    _slideController.forward();
    
    // Pulse animation for SOS button
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // State management
  void _updateState(EmergencyState newState) {
    setState(() {
      _state = newState;
    });
  }

  void _setLoading(bool loading) {
    _updateState(_state.setLoading(loading));
  }

  void _setError(String error) {
    _updateState(_state.setError(error));
  }

  void _clearError() {
    _updateState(_state.clearError());
  }

  // Initialize emergency services
  Future<void> _initializeEmergency() async {
    await _loadEmergencyData();
  }

  // Data loading
  Future<void> _loadEmergencyData() async {
    _setLoading(true);
    
    try {
      // Get current location
      final currentLocation = await EmergencyServices.getCurrentLocation();
      
      // Load emergency facilities
      final facilities = await EmergencyServices.loadEmergencyFacilities(
        currentLocation: currentLocation,
      );
      
      _updateState(_state.copyWith(
        currentLocation: currentLocation,
        facilities: facilities,
        filteredFacilities: facilities,
      ));
      
    } catch (e) {
      _setError('Failed to load emergency facilities: $e');
    } finally {
      _setLoading(false);
    }
  }

  // SOS functionality
  Future<void> _activateSOS() async {
    try {
      // Update state to show SOS is activated
      _updateState(_state.activateSOS());
      
      // Show SOS dialog
      await showDialog(
        context: context,
        builder: (_) => EmergencyWidgets.buildSOSDialog(),
      );
      
      // Send SOS alert if location is available
      if (_state.currentLocation != null) {
        final result = await EmergencyServices.activateSOS(
          location: _state.currentLocation!,
        );
        
        if (!result.success) {
          _showErrorMessage(result.message!);
        }
      }
      
      // Deactivate SOS after dialog
      _updateState(_state.deactivateSOS());
      
    } catch (e) {
      _updateState(_state.deactivateSOS());
      _showErrorMessage('Failed to activate SOS: $e');
    }
  }

  // Search functionality
  void _toggleSearch() {
    final newState = _state.toggleSearch();
    _updateState(newState);
    
    // Clear search if closing
    if (!newState.isSearching) {
      _clearSearch();
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _updateState(_state.clearSearch());
  }

  void _onSearchChanged(String query) {
    _updateState(_state.updateSearchQuery(query));
  }

  // Facility interactions
  void _onFacilityTap(EmergencyFacility facility) async {
    try {
      final success = await EmergencyServices.launchDirections(facility.location);
      if (!success) {
        _showErrorMessage('Unable to open directions');
      }
    } catch (e) {
      _showErrorMessage('Error opening directions: $e');
    }
  }

  void _onFacilityCall(EmergencyFacility facility) async {
    if (!facility.hasPhone) return;
    
    try {
      final success = await EmergencyServices.makePhoneCall(facility.phone);
      if (!success) {
        _showErrorMessage('Unable to make phone call');
      }
    } catch (e) {
      _showErrorMessage('Error making call: $e');
    }
  }

  // UI helpers
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.isDarkMode ? TailwindColors.gray900 : TailwindColors.gray50,
      drawer: AppDrawer(),
      body: BrandingWidgets.buildLoadingOverlay(
        isLoading: _state.isLoading,
        message: 'Finding emergency facilities...',
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadEmergencyData,
        child: Column(
          children: [
            // Emergency branding section
            BrandingWidgets.buildEmergencyBranding(
              title: 'Emergency Services',
              subtitle: 'Find nearby hospitals and emergency care',
            ),
            
            EmergencyWidgets.buildSpacing(height: 12),
            
            // SOS button
            _buildSOSButton(),
            
            EmergencyWidgets.buildSpacing(height: 12),
            
            // Search bar
            EmergencyWidgets.buildSearchBar(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onClear: _clearSearch,
              isSearching: _state.isSearching,
            ),
            
            EmergencyWidgets.buildSpacing(height: 12),
            
            if (!_state.isSearching && _state.hasFacilities)
              _buildStatisticsCard(),
            
            EmergencyWidgets.buildSectionTitle(EmergencyConstants.nearestHospitalsTitle),
            EmergencyWidgets.buildSpacing(height: 8),
            
            Expanded(
              child: _buildFacilitiesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return BrandingWidgets.buildBrandHeaderWidget(
      title: 'Emergency Services',
      subtitle: 'Find nearby hospitals and emergency care',
      showBackButton: false,
      actions: [
        IconButton(
          onPressed: _loadEmergencyData,
          icon: const Icon(Icons.refresh),
          tooltip: EmergencyConstants.refreshTooltip,
        ),
      ],
    );
  }

  Widget _buildSOSButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _state.sosActivated ? _pulseAnimation.value : 1.0,
          child: BrandingWidgets.buildSOSButton(
            onPressed: _activateSOS,
            isActivated: _state.sosActivated,
            size: 120,
          ),
        );
      },
    );
  }

  Widget _buildStatisticsCard() {
    if (!_state.hasFacilities) return const SizedBox.shrink();
    
    final stats = EmergencyServices.getFacilityStatistics(_state.facilities);
    
    return EmergencyWidgets.buildStatisticsCard(
      totalFacilities: stats['total'] as int,
      facilitiesWithPhone: stats['withPhone'] as int,
      nearestDistance: stats['nearestDistance'] as double?,
    );
  }

  Widget _buildFacilitiesList() {
    if (_state.isLoading) {
      return EmergencyWidgets.buildLoadingIndicator();
    }

    if (_state.error != null) {
      return EmergencyWidgets.buildErrorMessage(
        _state.error!,
        onRetry: _loadEmergencyData,
      );
    }

    if (!_state.hasFilteredFacilities) {
      return BrandingWidgets.buildEmptyState(
        message: _state.isSearching 
            ? 'No hospitals found matching your search'
            : EmergencyConstants.noHospitalsMessage,
        subtitle: _state.isSearching 
            ? 'Try adjusting your search terms'
            : 'Check your location and try again',
        icon: Icons.search_off,
        onAction: _state.isSearching ? _clearSearch : _loadEmergencyData,
        actionText: _state.isSearching ? 'Clear Search' : 'Refresh',
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: _state.filteredFacilities.length,
      separatorBuilder: (_, __) => SizedBox(height: 8.h),
      itemBuilder: (context, index) {
        final facility = _state.filteredFacilities[index];
        return EmergencyWidgets.buildFacilityItem(
          facility: facility,
          onTap: () => _onFacilityTap(facility),
          onCall: () => _onFacilityCall(facility),
        );
      },
    );
  }
}
