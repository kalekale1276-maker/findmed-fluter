import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../services/app_config.dart';
import '../../../pages/booking/booking_page.dart';
import 'models/facility_detail_models.dart';
import 'services/facility_detail_services.dart';
import 'widgets/facility_detail_widgets.dart';

/// Facility Detail Page - Detailed facility information and actions
class FacilityDetailPage extends StatefulWidget {
  final Map<String, dynamic> facility;
  
  const FacilityDetailPage({
    super.key,
    required this.facility,
  });

  @override
  State<FacilityDetailPage> createState() => _FacilityDetailPageState();
}

class _FacilityDetailPageState extends State<FacilityDetailPage> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // State
  FacilityDetailState _state = FacilityDetailState(
    facility: FacilityDetail.fromJson(widget.facility),
  );
  
  // Additional data
  FacilityRating? _rating;
  FacilityOperatingHours? _operatingHours;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeData();
    _setupBusinessModeListener();
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
    await _loadAdditionalData();
    await _checkFavoriteStatus();
  }

  void _setupBusinessModeListener() {
    // Listen to business mode changes
    AppConfig.instance.effectiveBusinessMode.addListener(_onBusinessModeChange);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    AppConfig.instance.effectiveBusinessMode.removeListener(_onBusinessModeChange);
    FacilityDetailWidgets.clearContext();
    super.dispose();
  }

  void _onBusinessModeChange() {
    _updateState(_state.updateBusinessMode(AppConfig.instance.businessMode.value));
  }

  // State management
  void _updateState(FacilityDetailState newState) {
    setState(() {
      _state = newState;
    });
  }

  // Data loading
  Future<void> _loadAdditionalData() async {
    try {
      final futures = await Future.wait([
        FacilityDetailServices.getFacilityRating(_state.facility.id),
        FacilityDetailServices.getFacilityOperatingHours(_state.facility.id),
      ]);
      
      if (mounted) {
        setState(() {
          _rating = futures[0] as FacilityRating?;
          _operatingHours = futures[1] as FacilityOperatingHours?;
        });
      }
    } catch (e) {
      debugPrint('Error loading additional data: $e');
    }
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final isFavorite = await FacilityDetailServices.isFavorite(_state.facility.id);
      if (mounted) {
        setState(() {
          _isFavorite = isFavorite;
        });
      }
    } catch (e) {
      debugPrint('Error checking favorite status: $e');
    }
  }

  // Facility actions
  Future<void> _onCall() async {
    final result = await FacilityDetailServices.makePhoneCall(_state.facility);
    _showActionResult(result);
  }

  Future<void> _onDirections() async {
    final result = await FacilityDetailServices.launchDirections(_state.facility);
    _showActionResult(result);
  }

  Future<void> _onBook() async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BookingPage(
          facilityId: _state.facility.id,
          facilityName: _state.facility.name,
        ),
      ),
    );
  }

  Future<void> _onEmail() async {
    final result = await FacilityDetailServices.sendEmail(_state.facility);
    _showActionResult(result);
  }

  Future<void> _onShare() async {
    final result = await FacilityDetailServices.shareFacility(_state.facility);
    _showActionResult(result);
  }

  Future<void> _onToggleFavorite() async {
    try {
      FacilityActionResult result;
      
      if (_isFavorite) {
        result = await FacilityDetailServices.removeFromFavorites(_state.facility.id);
      } else {
        result = await FacilityDetailServices.saveToFavorites(_state.facility);
      }
      
      if (result.success) {
        setState(() {
          _isFavorite = !_isFavorite;
        });
      }
      
      _showActionResult(result);
    } catch (e) {
      _showActionResult(FacilityActionResult.failure(
        FacilityAction.share,
        'Failed to update favorite status: $e',
      ));
    }
  }

  Future<void> _onReportIssue() async {
    // Show report issue dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Issue'),
        content: const Text('This feature will be available soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // UI helpers
  void _showActionResult(FacilityActionResult result) {
    final color = result.success ? Colors.green : Colors.red;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message ?? 'Action completed'),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    FacilityDetailWidgets.setContext(context);
    
    return Scaffold(
      backgroundColor: context.isDarkMode ? TailwindColors.gray900 : TailwindColors.gray50,
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
        _state.facility.name,
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
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            size: context.isMobile ? 20.w : 22.w,
            color: _isFavorite ? Colors.red : (context.isDarkMode ? Colors.white : TailwindColors.gray700),
          ),
          onPressed: _onToggleFavorite,
          tooltip: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
        ),
        IconButton(
          icon: Icon(
            Icons.share,
            size: context.isMobile ? 20.w : 22.w,
            color: context.isDarkMode ? Colors.white : TailwindColors.gray700,
          ),
          onPressed: _onShare,
          tooltip: 'Share facility',
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'report':
                _onReportIssue();
                break;
              case 'email':
                _onEmail();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'report',
              child: Row(
                children: [
                  Icon(Icons.flag, size: 16),
                  SizedBox(width: 8),
                  Text('Report Issue'),
                ],
              ),
            ),
            if (_state.facility.hasEmail)
              const PopupMenuItem(
                value: 'email',
                child: Row(
                  children: [
                    Icon(Icons.email, size: 16),
                    SizedBox(width: 8),
                    Text('Send Email'),
                  ],
                ),
              ),
          ],
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
    return RefreshIndicator(
      onRefresh: _loadAdditionalData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FacilityDetailWidgets.buildSpacing(height: 8),
            FacilityDetailWidgets.buildFacilityHeader(_state.facility),
            FacilityDetailWidgets.buildSpacing(height: 24),
            
            // Rating and completion
            if (_rating != null) ...[
              FacilityDetailWidgets.buildRatingWidget(_rating),
              FacilityDetailWidgets.buildSpacing(),
            ],
            FacilityDetailWidgets.buildCompletionIndicator(_state.facility),
            FacilityDetailWidgets.buildSectionDivider(),
            
            // Basic information
            if (_state.facility.address.isNotEmpty) ...[
              FacilityDetailWidgets.buildInfoCard(
                title: FacilityDetailConstants.addressLabel,
                content: _state.facility.address,
                icon: Icons.location_on,
                iconColor: Colors.red,
                onTap: () => _onDirections(),
              ),
            ],
            
            if (_state.facility.hasPhone) ...[
              FacilityDetailWidgets.buildInfoCard(
                title: FacilityDetailConstants.phoneLabel,
                content: FacilityDetailServices.formatPhoneNumber(_state.facility.phone),
                icon: Icons.phone,
                iconColor: Colors.green,
                onTap: () => _onCall(),
              ),
            ],
            
            if (_state.facility.hasEmail) ...[
              FacilityDetailWidgets.buildInfoCard(
                title: FacilityDetailConstants.emailLabel,
                content: _state.facility.email,
                icon: Icons.email,
                iconColor: Colors.blue,
                onTap: () => _onEmail(),
              ),
            ],
            
            // Services
            FacilityDetailWidgets.buildServicesCard(_state.facility),
            
            // Operating hours
            if (_operatingHours != null) ...[
              FacilityDetailWidgets.buildOperatingHoursWidget(_operatingHours!),
            ],
            
            FacilityDetailWidgets.buildSpacing(height: 24),
            
            // Action buttons
            FacilityDetailWidgets.buildActionButtons(
              facility: _state.facility,
              businessMode: _state.businessMode,
              onCall: _onCall,
              onDirections: _onDirections,
              onBook: _onBook,
            ),
            
            FacilityDetailWidgets.buildSpacing(height: 32),
          ],
        ),
      ),
    );
  }
}
