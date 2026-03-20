import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:findmed/services/admin_api.dart';
import 'package:findmed/services/api.dart';
import 'package:findmed/services/app_config.dart';
import 'package:findmed/services/auth.dart';
import 'package:findmed/services/booking_api.dart';
import 'package:findmed/services/notifications.dart';
import 'package:findmed/services/theme_service.dart';
import 'package:findmed/shared/providers/theme_provider.dart';
import 'package:findmed/shared/providers/user_provider.dart';
import 'package:findmed/widgets/app_drawer.dart';
import 'package:findmed/widgets/branding_widgets.dart';
import 'package:findmed/widgets/lazy_image.dart';
import 'package:findmed/widgets/top_notification.dart';
import '../../../core/utils/tailwind_extensions.dart';
import '../medical_profile/medical_profile_page.dart';
import '../favorites/favorites_page.dart';
import './models/profile_models.dart';
import './services/profile_services.dart';
import './widgets/profile_widgets.dart';

/// Profile Page - User profile management
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _conditionsController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _medicationsController = TextEditingController();
  final TextEditingController _telegramController = TextEditingController();
  
  // Form key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // State
  ProfileState _state = const ProfileState();

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
    // Load profile data when page opens
    await _loadProfile();
    
    // Set up auth listener after initial load
    final authService = AuthService.instance;
    authService.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _conditionsController.dispose();
    _allergiesController.dispose();
    _medicationsController.dispose();
    _telegramController.dispose();
    AuthService.instance.removeListener(_onAuthChanged);
    ProfileWidgets.clearContext();
    super.dispose();
  }

  // State management
  void _updateState(ProfileState newState) {
    setState(() {
      _state = newState;
    });
  }

  void _setLoading(bool loading) {
    _updateState(_state.setLoading(loading));
  }

  void _setSaving(bool saving) {
    _updateState(_state.setSaving(saving));
  }

  void _setError(String error) {
    _updateState(_state.setError(error));
  }

  void _clearError() {
    _updateState(_state.clearError());
  }

  void _setEditing(bool editing) {
    _updateState(_state.setEditing(editing));
  }

  // Data loading - called when page opens
  Future<void> _loadProfile() async {
    _setLoading(true);
    _clearError();
    
    try {
      // Initialize auth service first
      final authService = AuthService.instance;
      await authService.init();
      
      // Load user profile data
      final profile = await ProfileServices.getCurrentProfile();
      if (profile != null) {
        _updateState(_state.updateProfile(profile));
        _updateControllersFromProfile(profile);
      }
    } catch (e) {
      _setError('Failed to load profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _onAuthChanged() {
    _loadProfile();
  }

  void _updateControllersFromProfile(UserProfile profile) {
    _nameController.text = profile.fullName ?? '';
    _emailController.text = profile.email ?? '';
    _phoneController.text = profile.phone ?? '';
    _ageController.text = profile.age?.toString() ?? '';
    _conditionsController.text = profile.formattedConditions;
    _allergiesController.text = profile.formattedAllergies;
    _medicationsController.text = profile.formattedMedications;
  }

  // Form submission
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    _setSaving(true);
    _clearError();
    
    try {
      final formData = ProfileFormData(
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        age: int.tryParse(_ageController.text.trim()),
        medicalConditions: ProfileServices.parseList(_conditionsController.text),
        allergies: ProfileServices.parseList(_allergiesController.text),
        medications: ProfileServices.parseList(_medicationsController.text),
      );
      
      final result = await ProfileServices.updateProfile(formData);
      
      if (result.success) {
        _setEditing(false);
        _showSuccessMessage(result.message!);
        
        // Reload profile to get updated data
        await _loadProfile();
      } else {
        _setError(result.message!);
      }
    } catch (e) {
      _setError('Save failed: $e');
    } finally {
      _setSaving(false);
    }
  }

  // Telegram connection
  Future<void> _connectTelegram() async {
    final chatId = _telegramController.text.trim();
    
    _setSaving(true);
    _clearError();
    
    try {
      final profile = _state.profile;
      if (profile == null) {
        _setError('No profile data available');
        return;
      }
      
      final connection = await ProfileServices.connectTelegram(
        chatId: chatId.isEmpty ? null : chatId,
        userId: profile.id,
        fullName: profile.displayName,
      );
      
      if (connection.isVerified || connection.isLinked) {
        _showSuccessMessage(connection.message ?? ProfileConstants.telegramConnectedMessage);
        
        // Reload profile to get updated telegram info
        await _loadProfile();
      } else {
        if (connection.message?.toLowerCase().contains('not linked') == true ||
            connection.message?.toLowerCase().contains('share your phone') == true) {
          _showErrorMessage(ProfileConstants.phoneMismatchMessage + ': ${connection.message}');
        } else {
          _showErrorMessage('Link failed: ${connection.message}');
        }
      }
    } catch (e) {
      _showErrorMessage('Link failed: $e');
    } finally {
      _setSaving(false);
    }
  }

  // Actions
  Future<void> _logout() async {
    try {
      await ProfileServices.logout();
      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      _showErrorMessage('Logout failed: $e');
    }
  }

  void _showChangePassword() {
    showDialog(
      context: context,
      builder: (_) => ProfileWidgets.buildChangePasswordDialog(
        onCancel: () => Navigator.pop(context),
        onSave: () {
          Navigator.pop(context);
          _showSuccessMessage('Password change functionality coming soon');
        },
      ),
    );
  }

  void _showConnectTelegramDialog() {
    _telegramController.clear();
    
    showDialog(
      context: context,
      builder: (_) => ProfileWidgets.buildConnectTelegramDialog(
        controller: _telegramController,
        isLoading: _state.isSaving,
        onCancel: () {
          Navigator.pop(context);
          _telegramController.clear();
        },
        onConnect: () {
          Navigator.pop(context);
          _connectTelegram();
        },
      ),
    );
  }

  // Navigation
  void _navigateToMedicalProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MedicalProfilePage(),
      ),
    );
  }

  void _navigateToFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const FavoritesPage(),
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
    ProfileWidgets.setContext(context);
    
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
        ProfileConstants.pageTitle,
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
        if (!_state.isEditing)
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _setEditing(true),
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
    return Stack(
      children: [
        SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile avatar
                  Center(
                    child: ProfileWidgets.buildAvatar(
                      displayName: _state.profile?.displayName ?? 'User',
                    ),
                  ),
                  
                  ProfileWidgets.buildSpacing(height: 12),
                  
                  // Agent info
                  if (_state.profile?.isAgent == true) ...[
                    Center(
                      child: ProfileWidgets.buildAgentInfoChip(
                        agentId: _state.profile!.agentId!,
                        facilityType: _state.profile!.agentFacilityType ?? '',
                      ),
                    ),
                    ProfileWidgets.buildSpacing(height: 8),
                  ],
                  
                  // Personal information card
                  ProfileWidgets.buildPersonalInfoCard(
                    fullName: _nameController.text,
                    email: _emailController.text,
                    phone: _phoneController.text,
                    age: int.tryParse(_ageController.text),
                    isEditing: _state.isEditing,
                  ),
                  
                  ProfileWidgets.buildSpacing(height: 12),
                  
                  // Medical profile card
                  ProfileWidgets.buildMedicalProfileCard(
                    conditions: _conditionsController.text,
                    allergies: _allergiesController.text,
                    medications: _medicationsController.text,
                    onTap: _navigateToMedicalProfile,
                  ),
                  
                  ProfileWidgets.buildSpacing(height: 12),
                  
                  // Saved facilities card
                  ProfileWidgets.buildActionCard(
                    icon: Icons.favorite,
                    title: ProfileConstants.savedFacilitiesTitle,
                    onTap: _navigateToFavorites,
                  ),
                  
                  ProfileWidgets.buildSpacing(height: 12),
                  
                  // Error message
                  if (_state.hasError)
                    ProfileWidgets.buildErrorMessage(_state.error!),
                  
                  // Action buttons
                  ProfileWidgets.buildActionButtons(
                    isEditing: _state.isEditing,
                    isLoading: _state.isSaving,
                    onEdit: () => _setEditing(true),
                    onSave: _saveProfile,
                    onLogout: _logout,
                  ),
                  
                  ProfileWidgets.buildSpacing(height: 12),
                  
                  // Change password
                  ProfileWidgets.buildActionCard(
                    icon: Icons.lock,
                    title: ProfileConstants.changePasswordTitle,
                    onTap: _showChangePassword,
                  ),
                  
                  ProfileWidgets.buildSpacing(height: 8),
                  
                  // Connect Telegram
                  ProfileWidgets.buildActionCard(
                    icon: Icons.send,
                    title: ProfileConstants.connectTelegramTitle,
                    subtitle: _state.profile?.telegramDisplayName.isNotEmpty == true
                        ? 'Linked: ${_state.profile!.telegramDisplayName}'
                        : null,
                    onTap: _showConnectTelegramDialog,
                  ),
                  
                  ProfileWidgets.buildSpacing(height: 24),
                  
                  // Profile completeness indicator
                  if (_state.hasProfile)
                    ProfileWidgets.buildProfileCompletenessIndicator(
                      completeness: ProfileServices.getProfileCompletionScore(_state.profile!),
                    ),
                  
                  ProfileWidgets.buildSpacing(height: 12),
                  
                  // Health tips
                  if (_state.hasProfile)
                    ProfileWidgets.buildHealthTipsCard(
                      tips: ProfileServices.getProfileHealthTips(_state.profile!),
                    ),
                ],
              ),
            ),
          ),
        ),
        
        // Loading overlay
        if (_state.isAnyLoading)
          ProfileWidgets.buildLoadingOverlay(),
      ],
    );
  }
}

// Import required pages
import '../medical_profile/medical_profile_page.dart';
import '../favorites/favorites_page.dart';
