import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../services/auth.dart';
import '../models/medical_profile_models.dart';
import '../services/medical_profile_services.dart';
import '../widgets/medical_profile_widgets.dart';

/// Medical Profile Page - User's medical information management
class MedicalProfilePage extends StatefulWidget {
  const MedicalProfilePage({super.key});

  @override
  State<MedicalProfilePage> createState() => _MedicalProfilePageState();
}

class _MedicalProfilePageState extends State<MedicalProfilePage> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Controllers
  final TextEditingController _conditionsController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _medicationsController = TextEditingController();
  final FocusNode _conditionsFocus = FocusNode();
  final FocusNode _allergiesFocus = FocusNode();
  final FocusNode _medicationsFocus = FocusNode();
  
  // State
  MedicalProfileState _state = const MedicalProfileState(
    profile: MedicalProfile.empty(),
  );

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
    final authService = AuthService.instance;
    await authService.init();
    
    // Load profile and history
    await _loadProfile();
    await _loadHistory();
    
    // Set up auth listener
    authService.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _conditionsController.dispose();
    _allergiesController.dispose();
    _medicationsController.dispose();
    _conditionsFocus.dispose();
    _allergiesFocus.dispose();
    _medicationsFocus.dispose();
    AuthService.instance.removeListener(_onAuthChanged);
    MedicalProfileWidgets.clearContext();
    super.dispose();
  }

  // State management
  void _updateState(MedicalProfileState newState) {
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

  // Data loading
  Future<void> _loadProfile() async {
    try {
      _setLoading(true);
      final profile = await MedicalProfileServices.getCurrentProfile();
      
      if (profile != null) {
        _updateState(_state.updateProfile(profile));
        _updateControllersFromProfile(profile);
      } else {
        _updateState(_state.updateProfile(MedicalProfile.empty()));
        _clearControllers();
      }
    } catch (e) {
      _setError('Failed to load profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadHistory() async {
    try {
      final history = await MedicalProfileServices.loadHistory();
      _updateState(_state.copyWith(history: history));
    } catch (e) {
      debugPrint('Error loading history: $e');
    }
  }

  void _onAuthChanged() {
    _loadProfile();
  }

  // Controller management
  void _updateControllersFromProfile(MedicalProfile profile) {
    _conditionsController.text = profile.formattedConditions;
    _allergiesController.text = profile.formattedAllergies;
    _medicationsController.text = profile.formattedMedications;
  }

  void _clearControllers() {
    _conditionsController.clear();
    _allergiesController.clear();
    _medicationsController.clear();
  }

  // Form submission
  Future<void> _saveProfile() async {
    // Validate form
    final profile = _getProfileFromForm();
    final validation = MedicalProfileServices.validateProfile(profile);
    
    if (!validation.isValid) {
      _setError(validation.errorMessage!);
      return;
    }
    
    _setSaving(true);
    _clearError();
    
    try {
      final result = await MedicalProfileServices.updateProfile(profile);
      
      if (result.success) {
        _updateState(_state.updateProfile(profile));
        _showSuccessMessage(result.message!);
      } else {
        _setError(result.message!);
      }
    } catch (e) {
      _setError('Save failed: $e');
    } finally {
      _setSaving(false);
    }
  }

  MedicalProfile _getProfileFromForm() {
    return MedicalProfile(
      medicalConditions: MedicalProfileServices.parseList(_conditionsController.text),
      allergies: MedicalProfileServices.parseList(_allergiesController.text),
      medications: MedicalProfileServices.parseList(_medicationsController.text),
      lastUpdated: DateTime.now(),
    );
  }

  // Delete profile
  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => MedicalProfileWidgets.buildConfirmDeleteDialog(
        onConfirm: () => Navigator.pop(context, true),
        onCancel: () => Navigator.pop(context, false),
      ),
    );
    
    if (!confirmed) return;
    
    _setSaving(true);
    
    try {
      final result = await MedicalProfileServices.clearProfile();
      
      if (result.success) {
        _updateState(_state.updateProfile(MedicalProfile.empty()));
        _clearControllers();
        _showSuccessMessage(result.message!);
      } else {
        _setError(result.message!);
      }
    } catch (e) {
      _setError('Delete failed: $e');
    } finally {
      _setSaving(false);
    }
  }

  // Add items
  Future<void> _addItem(String kind) async {
    final controller = TextEditingController();
    final title = _getItemTitle(kind);
    final label = _getItemLabel(kind);
    
    final result = await showDialog<String>(
      context: context,
      builder: (_) => MedicalProfileWidgets.buildAddItemDialog(
        title: title,
        label: label,
        controller: controller,
        onAdd: () => Navigator.pop(context, controller.text.trim()),
        onCancel: () => Navigator.pop(context),
      ),
    );
    
    if (result == null || result.isEmpty) return;
    
    // Validate item
    final validation = MedicalProfileServices.validateItem(result, category: kind);
    if (!validation.isValid) {
      _setError(validation.errorMessage!);
      return;
    }
    
    // Add to appropriate controller
    setState(() {
      if (kind == 'condition') {
        final current = MedicalProfileServices.parseList(_conditionsController.text);
        current.add(result);
        _conditionsController.text = MedicalProfileServices.formatList(current);
      } else if (kind == 'allergy') {
        final current = MedicalProfileServices.parseList(_allergiesController.text);
        current.add(result);
        _allergiesController.text = MedicalProfileServices.formatList(current);
      } else if (kind == 'medication') {
        final current = MedicalProfileServices.parseList(_medicationsController.text);
        current.add(result);
        _medicationsController.text = MedicalProfileServices.formatList(current);
      }
    });
  }

  String _getItemTitle(String kind) {
    switch (kind) {
      case 'condition':
        return MedicalProfileConstants.addConditionTitle;
      case 'allergy':
        return MedicalProfileConstants.addAllergyTitle;
      case 'medication':
        return MedicalProfileConstants.addMedicationTitle;
      default:
        return 'Add Item';
    }
  }

  String _getItemLabel(String kind) {
    switch (kind) {
      case 'condition':
        return MedicalProfileConstants.conditionLabel;
      case 'allergy':
        return MedicalProfileConstants.allergyLabel;
      case 'medication':
        return MedicalProfileConstants.medicationLabel;
      default:
        return 'Item';
    }
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
    MedicalProfileWidgets.setContext(context);
    
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: TabBarView(
              children: [
                _buildProfileTab(),
                _buildHistoryTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        MedicalProfileConstants.pageTitle,
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
      bottom: TabBar(
        tabs: [
          Tab(text: MedicalProfileConstants.profileTab),
          Tab(text: MedicalProfileConstants.historyTab),
        ],
        labelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'add_condition') _addItem('condition');
            if (value == 'add_allergy') _addItem('allergy');
            if (value == 'add_med') _addItem('medication');
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'add_condition',
              child: Text('Add condition'),
            ),
            const PopupMenuItem(
              value: 'add_allergy',
              child: Text('Add allergy'),
            ),
            const PopupMenuItem(
              value: 'add_med',
              child: Text('Add medication'),
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

  Widget _buildProfileTab() {
    return Stack(
      children: [
        SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // Profile overview card
                MedicalProfileWidgets.buildProfileOverviewCard(
                  profile: _state.profile,
                  onEdit: () => _setEditing(true),
                  onDelete: _confirmDelete,
                  isLoading: _state.isSaving,
                ),
                
                MedicalProfileWidgets.buildSpacing(height: 12),
                
                // Edit form (shown when editing)
                if (_state.isEditing) ...[
                  MedicalProfileWidgets.buildProfileEditForm(
                    conditionsController: _conditionsController,
                    allergiesController: _allergiesController,
                    medicationsController: _medicationsController,
                    conditionsFocus: _conditionsFocus,
                    allergiesFocus: _allergiesFocus,
                    medicationsFocus: _medicationsFocus,
                  ),
                  
                  MedicalProfileWidgets.buildSpacing(height: 12),
                  
                  // Error message
                  if (_state.hasError)
                    MedicalProfileWidgets.buildErrorMessage(_state.error!),
                  
                  // Save button
                  MedicalProfileWidgets.buildSaveButton(
                    onPressed: _saveProfile,
                    isLoading: _state.isSaving,
                    canSave: _state.canSave,
                  ),
                ] else ...[
                  // Health tips
                  if (_state.hasProfileData) ...[
                    MedicalProfileWidgets.buildHealthTipsCard(
                      tips: MedicalProfileServices.getHealthTips(_state.profile),
                    ),
                    MedicalProfileWidgets.buildSpacing(height: 12),
                  ],
                  
                  // Completeness indicator
                  MedicalProfileWidgets.buildCompletenessIndicator(
                    completeness: MedicalProfileServices.getProfileCompletenessScore(_state.profile),
                  ),
                ],
                
                const Spacer(),
              ],
            ),
          ),
        ),
        
        // Loading overlay
        if (_state.isLoading || _state.isSaving)
          MedicalProfileWidgets.buildLoadingOverlay(),
      ],
    );
  }

  Widget _buildHistoryTab() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // Statistics card
            if (_state.hasHistory)
              FutureBuilder<MedicalProfileStats>(
                future: MedicalProfileServices.getProfileStatistics(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.hasData) {
                    return MedicalProfileWidgets.buildStatisticsCard(stats: snapshot.data!);
                  }
                  return const SizedBox.shrink();
                },
              ),
            
            MedicalProfileWidgets.buildSpacing(height: 12),
            
            // History list
            Expanded(
              child: MedicalProfileWidgets.buildHistoryList(
                history: _state.history,
                isEmpty: !_state.hasHistory,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
