import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/utils/tailwind_extensions.dart';
import 'models/login_models.dart';
import 'services/login_services.dart';
import 'widgets/login_widgets.dart';

/// Login Page - User authentication
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Form controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  // State
  LoginState _state = const LoginState();
  List<SocialLoginProvider> _socialProviders = [];
  List<LoginFeature> _features = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeData();
    _loadRememberMePreference();
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
    _socialProviders = LoginServices.getSupportedProviders();
    _features = LoginServices.getLoginFeatures();
    
    // Initialize social providers
    await LoginServices.initializeSocialProviders();
  }

  Future<void> _loadRememberMePreference() async {
    try {
      final rememberedEmail = await LoginServices.loadRememberMePreference();
      if (rememberedEmail != null) {
        _emailController.text = rememberedEmail;
        _updateState(_state.updateRememberMe(true));
      }
    } catch (e) {
      debugPrint('Error loading remember me preference: $e');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    LoginWidgets.clearContext();
    super.dispose();
  }

  // State management
  void _updateState(LoginState newState) {
    setState(() {
      _state = newState;
    });
  }

  void _setLoading(bool loading) {
    _updateState(_state.setLoading(loading));
  }

  void _setSubmitting(bool submitting) {
    _updateState(_state.setSubmitting(submitting));
  }

  void _setError(String error) {
    _updateState(_state.setError(error));
  }

  void _clearError() {
    _updateState(_state.clearError());
  }

  // Form validation
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return LoginConstants.emailRequiredError;
    }
    if (!LoginServices.isValidEmail(value)) {
      return LoginConstants.emailInvalidError;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return LoginConstants.passwordRequiredError;
    }
    if (value.length < LoginConstants.passwordMinLength) {
      return LoginConstants.passwordMinLengthError;
    }
    return null;
  }

  // Login actions
  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    _setSubmitting(true);
    _clearError();
    
    final startTime = DateTime.now();
    
    try {
      final result = await LoginServices.performLogin(
        email: _state.formData.email,
        password: _state.formData.password,
        rememberMe: _state.rememberMe,
      );
      
      final duration = DateTime.now().difference(startTime).inMilliseconds / 1000.0;
      
      if (result.success) {
        await LoginServices.recordLoginAttempt(
          provider: 'email',
          success: true,
          duration: duration,
        );
        
        _showSuccessMessage(result.message!);
        _navigateToHome();
      } else {
        await LoginServices.recordLoginAttempt(
          provider: 'email',
          success: false,
          duration: duration,
        );
        
        _setError(result.message!);
      }
    } catch (e) {
      final duration = DateTime.now().difference(startTime).inMilliseconds / 1000.0;
      
      await LoginServices.recordLoginAttempt(
        provider: 'email',
        success: false,
        duration: duration,
      );
      
      _setError('Login failed: $e');
    } finally {
      _setSubmitting(false);
    }
  }

  // Social login
  Future<void> _onSocialLogin(String providerId) async {
    _setLoading(true);
    _clearError();
    
    final startTime = DateTime.now();
    
    try {
      final result = await LoginServices.performSocialLogin(provider: providerId);
      
      final duration = DateTime.now().difference(startTime).inMilliseconds / 1000.0;
      
      if (result.success) {
        await LoginServices.recordLoginAttempt(
          provider: providerId,
          success: true,
          duration: duration,
        );
        
        _showSuccessMessage(result.message!);
        _navigateToHome();
      } else {
        await LoginServices.recordLoginAttempt(
          provider: providerId,
          success: false,
          duration: duration,
        );
        
        _setError(result.message!);
      }
    } catch (e) {
      final duration = DateTime.now().difference(startTime).inMilliseconds / 1000.0;
      
      await LoginServices.recordLoginAttempt(
        provider: providerId,
        success: false,
        duration: duration,
      );
      
      _setError('Social login failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Guest login
  Future<void> _onGuestLogin() async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await LoginServices.performGuestLogin();
      
      if (result.success) {
        _showSuccessMessage(result.message!);
        _navigateToHome();
      } else {
        _setError(result.message!);
      }
    } catch (e) {
      _setError('Guest login failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Forgot password
  Future<void> _onForgotPassword() async {
    final email = _state.formData.email;
    if (email.isEmpty) {
      _setError('Please enter your email address first');
      return;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      final success = await LoginServices.resetPassword(email);
      
      if (success) {
        _showSuccessMessage('Password reset instructions sent to your email');
      } else {
        _setError('Failed to send password reset instructions');
      }
    } catch (e) {
      _setError('Password reset failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Navigation
  void _navigateToHome() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  void _navigateToRegister() {
    Navigator.of(context).pushNamed('/register');
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
    LoginWidgets.setContext(context);
    
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
        LoginConstants.pageTitle,
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
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
      return LoginWidgets.buildLoadingIndicator();
    }
    
    return LoginWidgets.buildLoginCard(
      child: Form(
        key: _formKey,
        onChanged: _onFormChanged,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            LoginWidgets.buildHeader(
              title: LoginConstants.welcomeTitle,
              subtitle: LoginConstants.subtitle,
            ),
            
            LoginWidgets.buildSpacing(height: 24),
            
            // Features showcase
            LoginWidgets.buildFeaturesShowcase(features: _features),
            
            LoginWidgets.buildSpacing(height: 24),
            
            // Email field
            LoginWidgets.buildEmailField(
              controller: _emailController,
              validator: _validateEmail,
              enabled: !_state.isSubmitting,
            ),
            
            LoginWidgets.buildSpacing(height: 16),
            
            // Password field
            LoginWidgets.buildPasswordField(
              controller: _passwordController,
              validator: _validatePassword,
              isVisible: _state.isPasswordVisible,
              enabled: !_state.isSubmitting,
              onVisibilityToggle: () => _updateState(_state.togglePasswordVisibility()),
            ),
            
            LoginWidgets.buildSpacing(height: 8),
            
            // Remember me and forgot password
            Row(
              children: [
                Expanded(
                  child: LoginWidgets.buildRememberMeCheckbox(
                    value: _state.rememberMe,
                    onChanged: (value) => _updateState(_state.updateRememberMe(value)),
                  ),
                ),
                LoginWidgets.buildForgotPasswordLink(
                  onTap: _onForgotPassword,
                ),
              ],
            ),
            
            // Error message
            if (_state.hasError) ...[
              LoginWidgets.buildSpacing(height: 8),
              LoginWidgets.buildErrorMessage(_state.error!),
            ],
            
            // Login button
            LoginWidgets.buildLoginButton(
              onPressed: _onLogin,
              isLoading: _state.isSubmitting,
              isValid: _state.isFormValid,
            ),
            
            // Social login buttons
            if (_socialProviders.isNotEmpty) ...[
              LoginWidgets.buildSocialLoginButtons(
                providers: _socialProviders,
                onProviderTap: _onSocialLogin,
              ),
            ],
            
            // Alternative actions
            LoginWidgets.buildAlternativeActions(
              showRegister: true,
              showGuest: _state.showGuestOption && LoginServices.isGuestModeEnabled(),
              onRegisterTap: _navigateToRegister,
              onGuestTap: _onGuestLogin,
            ),
          ],
        ),
      ),
    );
  }

  void _onFormChanged() {
    final formData = LoginFormData(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      rememberMe: _state.rememberMe,
    ).validate();
    
    _updateState(_state.updateFormData(formData));
  }
}
