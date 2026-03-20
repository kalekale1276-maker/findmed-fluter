import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/tailwind_extensions.dart';
import '../../../../services/auth.dart';
import '../../../../services/theme_service.dart';
import '../../../../services/admin_api.dart';
import '../../../../services/app_config.dart';
import 'models/settings_models.dart';
import 'services/settings_services.dart';
import 'widgets/settings_widgets.dart';

/// Settings Page - Application settings and preferences
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Controllers
  final TextEditingController _backendHostController = TextEditingController();
  
  // State
  SettingsState _state = const SettingsState();

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
    // Load preferences
    await _loadPreferences();
    
    // Initialize auth
    await _initializeAuth();
    
    // Sync server settings
    await _syncServerSettings();
    
    // Setup listeners
    _setupListeners();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _backendHostController.dispose();
    _cleanupListeners();
    SettingsWidgets.clearContext();
    super.dispose();
  }

  // State management
  void _updateState(SettingsState newState) {
    setState(() {
      _state = newState;
    });
  }

  void _updateNotifications(bool value) {
    _updateState(_state.updateNotifications(value));
    SettingsServices.saveNotificationSetting(value);
  }

  void _updateDarkTheme(bool value) {
    _updateState(_state.updateDarkTheme(value));
    SettingsServices.saveDarkThemeSetting(value);
  }

  void _updateAnalytics(bool value) {
    _updateState(_state.updateAnalytics(value));
    SettingsServices.saveAnalyticsSetting(value);
  }

  void _updateBusinessMode(bool value) async {
    final result = await SettingsServices.updateBusinessMode(value);
    
    if (result.success) {
      _updateState(_state.updateBusinessMode(value));
    } else {
      _showErrorMessage(result.message!);
    }
  }

  void _updateServerSettings(Map<String, dynamic> settings) {
    _updateState(_state.updateServerSettings(settings));
  }

  void _setServerLoading(bool loading) {
    _updateState(_state.setServerLoading(loading));
  }

  void _updateBackendHost(String? host) {
    _updateState(_state.updateBackendHost(host));
  }

  // Data loading
  Future<void> _loadPreferences() async {
    try {
      final preferences = await SettingsServices.loadPreferences();
      
      _updateState(_state.copyWith(
        notifications: preferences[SettingsConstants.notificationsKey] ?? SettingsConstants.defaultNotifications,
        darkTheme: preferences[SettingsConstants.darkThemeKey] ?? SettingsConstants.defaultDarkTheme,
        analytics: preferences[SettingsConstants.analyticsKey] ?? SettingsConstants.defaultAnalytics,
      ));
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }
  }

  Future<void> _initializeAuth() async {
    try {
      await AuthService.instance.init();
      
      final authService = AuthService.instance;
      _updateState(_state.updateLoginState(
        authService.isLoggedIn,
        user: authService.user,
      ));
      
      authService.addListener(_onAuthChanged);
    } catch (e) {
      debugPrint('Error initializing auth: $e');
    }
  }

  Future<void> _syncServerSettings() async {
    _setServerLoading(true);
    
    try {
      final result = await SettingsServices.syncServerSettings();
      
      if (result.success) {
        _updateServerSettings(result.data);
        _showSuccessMessage(result.message!);
      } else {
        _showErrorMessage(result.message!);
      }
    } catch (e) {
      _showErrorMessage('Failed to sync server settings: $e');
    } finally {
      _setServerLoading(false);
    }
  }

  // Listeners
  void _setupListeners() {
    // Theme service listener
    ThemeService.instance.isDark.addListener(_onThemeChanged);
    
    // App config listeners
    AppConfig.instance.userBusinessMode.addListener(_onUserBusinessModeChanged);
  }

  void _cleanupListeners() {
    AuthService.instance.removeListener(_onAuthChanged);
    ThemeService.instance.isDark.removeListener(_onThemeChanged);
    AppConfig.instance.userBusinessMode.removeListener(_onUserBusinessModeChanged);
  }

  void _onAuthChanged() {
    _updateState(_state.updateLoginState(
      AuthService.instance.isLoggedIn,
      user: AuthService.instance.user,
    ));
  }

  void _onThemeChanged() {
    if (mounted) {
      _updateState(_state.updateDarkTheme(ThemeService.instance.isDark.value));
    }
  }

  void _onUserBusinessModeChanged() {
    if (mounted) {
      _updateState(_state.copyWith(
        businessMode: AppConfig.instance.userBusinessMode.value,
        effectiveBusinessMode: AppConfig.instance.effectiveBusinessMode.value,
      ));
    }
  }

  // Actions
  void _navigateToProfile() {
    // Navigate to profile page
    debugPrint('Navigate to profile page');
  }

  void _navigateToMedicalProfile() {
    // Navigate to medical profile page
    debugPrint('Navigate to medical profile page');
  }

  void _exportData() {
    showDialog(
      context: context,
      builder: (_) => SettingsWidgets.buildExportDataDialog(),
    );
  }

  Future<void> _clearCache() async {
    final result = await SettingsServices.clearLocalCache();
    
    if (result.success) {
      _showSuccessMessage(result.message!);
      await _loadPreferences(); // Reload preferences
    } else {
      _showErrorMessage(result.message!);
    }
  }

  void _editBackendHost() {
    _backendHostController.text = _state.backendHost ?? '';
    
    showDialog(
      context: context,
      builder: (_) => SettingsWidgets.buildBackendHostDialog(
        controller: _backendHostController,
        onUseDefault: () async {
          final result = await SettingsServices.setBackendHost(null);
          if (result.success) {
            _updateBackendHost(null);
            Navigator.pop(context);
            _showSuccessMessage(result.message!);
          } else {
            _showErrorMessage(result.message!);
          }
        },
        onCancel: () => Navigator.pop(context),
        onSave: () async {
          final host = _backendHostController.text.trim();
          if (host.isEmpty) return;
          
          final validation = SettingsServices.validateBackendHost(host);
          if (!validation.isValid) {
            _showErrorMessage(validation.errorMessage!);
            return;
          }
          
          final result = await SettingsServices.setBackendHost(host);
          if (result.success) {
            _updateBackendHost(host);
            Navigator.pop(context);
            _showSuccessMessage(result.message!);
          } else {
            _showErrorMessage(result.message!);
          }
        },
      ),
    );
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (_) => SettingsWidgets.buildAboutDialog(),
    );
  }

  void _sendFeedback() {
    showDialog(
      context: context,
      builder: (_) => SettingsWidgets.buildFeedbackDialog(),
    );
  }

  void _sendLogs() {
    showDialog(
      context: context,
      builder: (_) => SettingsWidgets.buildSendLogsDialog(),
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
    SettingsWidgets.setContext(context);
    
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
        SettingsConstants.pageTitle,
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
    return ListView(
      padding: EdgeInsets.all(12.w),
      children: [
        // Account section
        SettingsWidgets.buildSectionHeader(SettingsConstants.accountSectionTitle),
        SettingsWidgets.buildAccountCard(
          isLoggedIn: _state.isLoggedIn,
          displayName: _state.userDisplayName,
          email: _state.userEmail,
          onTap: _navigateToProfile,
        ),
        
        SettingsWidgets.buildSpacing(),
        
        // Preferences section
        SettingsWidgets.buildSectionHeader(SettingsConstants.preferencesSectionTitle),
        SettingsWidgets.buildToggleSetting(
          title: SettingsConstants.enableNotificationsLabel,
          icon: Icons.notifications,
          value: _state.notifications,
          onChanged: _updateNotifications,
        ),
        SettingsWidgets.buildToggleSetting(
          title: SettingsConstants.darkThemeLabel,
          icon: Icons.brightness_6,
          value: _state.darkTheme,
          onChanged: _updateDarkTheme,
        ),
        SettingsWidgets.buildToggleSetting(
          title: SettingsConstants.enableAnalyticsLabel,
          icon: Icons.analytics,
          value: _state.analytics,
          onChanged: _updateAnalytics,
        ),
        
        SettingsWidgets.buildSpacing(),
        
        // Medical section
        SettingsWidgets.buildSectionHeader(SettingsConstants.medicalSectionTitle),
        SettingsWidgets.buildNavigationSetting(
          title: SettingsConstants.editMedicalProfileLabel,
          icon: Icons.medical_services,
          onTap: _navigateToMedicalProfile,
        ),
        
        SettingsWidgets.buildSpacing(),
        
        // Data section
        SettingsWidgets.buildSectionHeader(SettingsConstants.dataSectionTitle),
        SettingsWidgets.buildDataSettingsCard(
          onExportData: _exportData,
          onClearCache: _clearCache,
        ),
        
        SettingsWidgets.buildSpacing(),
        
        // System section
        SettingsWidgets.buildSectionHeader(SettingsConstants.systemSectionTitle),
        SettingsWidgets.buildSystemSettingsCard(
          serverSettings: _state.serverSettings,
          isLoading: _state.isLoading,
          onSync: _syncServerSettings,
          onEditBackendHost: _editBackendHost,
        ),
        
        SettingsWidgets.buildSpacing(),
        
        // Support section
        SettingsWidgets.buildSectionHeader(SettingsConstants.supportSectionTitle),
        SettingsWidgets.buildSupportSettingsCard(
          onAbout: _showAbout,
          onFeedback: _sendFeedback,
          onSendLogs: _sendLogs,
        ),
        
        SettingsWidgets.buildSpacing(height: 24),
        
        // Statistics and insights
        if (_state.hasServerSettings)
          FutureBuilder<SettingsAnalytics>(
            future: SettingsServices.getAnalytics(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.hasData) {
                final analytics = snapshot.data!;
                return Column(
                  children: [
                    SettingsWidgets.buildStatisticsCard(stats: analytics),
                    SettingsWidgets.buildSpacing(),
                    SettingsWidgets.buildHealthScoreCard(
                      score: SettingsServices.getSettingsHealthScore(_state),
                      status: SettingsServices.getSettingsHealthStatus(_state),
                    ),
                    SettingsWidgets.buildSpacing(),
                    SettingsWidgets.buildRecommendationsCard(
                      recommendations: SettingsServices.getSettingsRecommendations(_state),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
      ],
    );
  }
}
