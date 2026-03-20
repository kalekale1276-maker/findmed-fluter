import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'models/auth_models.dart';
import 'services/auth_services.dart';
import 'widgets/auth_widgets.dart';
import '../../../../services/auth.dart';
import 'reset_password.dart';

/// Authentication Forms - Login and Registration
/// Auth forms are used as full pages. Navigation should use named routes
/// (`/login`, `/register`) to open full-screen auth flows.

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> with TickerProviderStateMixin {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // State
  bool _loading = false;
  String? _error;
  bool _passwordVisible = false;
  
  // Email checking
  final EmailCheckManager _emailCheckManager = EmailCheckManager();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupEmailListener();
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

  void _setupEmailListener() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _email.removeListener(_onEmailChanged);
      _email.addListener(_onEmailChanged);
    });
  }

  void _onEmailChanged() {
    _emailCheckManager.checkEmail(_email.text, () {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _emailCheckManager.dispose();
    _email.removeListener(_onEmailChanged);
    _email.dispose();
    _password.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    Get.clearContext();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    
    setState(() => _loading = true);
    try {
      await AuthServices.login(_email.text.trim(), _password.text.trim());
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      setState(() => _error = msg);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Get.setContext(context);
    
    final isCredentialError = AuthServices.isCredentialError(_error);
    
    return Scaffold(
      backgroundColor: context.isDarkMode ? TailwindColors.gray900 : TailwindColors.gray50,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _buildBody(isCredentialError),
        ),
      ),
    );
  }

  Widget _buildBody(bool isCredentialError) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            SizedBox(height: context.responsiveGapLg),
            _buildHeader(),
            SizedBox(height: context.responsiveGapXl),
            _buildForm(isCredentialError),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(40.w),
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.local_hospital,
            size: 40.w,
            color: Theme.of(context).primaryColor,
          ),
        ),
        SizedBox(height: context.responsiveGap),
        Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
          ),
        ),
        SizedBox(height: context.responsiveGapSm),
        Text(
          'Sign in to your account',
          style: TextStyle(
            fontSize: 16.sp,
            color: context.isDarkMode ? Colors.white70 : TailwindColors.gray600,
          ),
        ),
      ],
    );
  }

  Widget _buildForm(bool isCredentialError) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: context.isDarkMode ? TailwindColors.gray800 : Colors.white,
        borderRadius: BorderRadius.circular(TailwindRadius.xl),
        boxShadow: [TailwindShadows.lg],
      ),
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCredentialError)
              AuthWidgets.buildErrorContainer(
                AuthServices.getCredentialErrorMessage(),
                isCredential: true,
              ),
            AuthWidgets.buildEmailField(
              controller: _email,
              context: context,
              isChecking: _emailCheckManager.isChecking,
              result: _emailCheckManager.result,
              onEmailChanged: _onEmailChanged,
            ),
            AuthWidgets.buildSpacing(),
            AuthWidgets.buildPasswordField(
              controller: _password,
              context: context,
              isVisible: _passwordVisible,
              onVisibilityChanged: () => setState(() => _passwordVisible = !_passwordVisible),
              validator: AuthServices.validateLoginPassword,
            ),
            AuthWidgets.buildSpacing(height: 20),
            AuthWidgets.buildSubmitButton(
              text: 'Login',
              onPressed: _loading ? null : _submit,
              isLoading: _loading,
            ),
            if (_error != null && !isCredentialError) ...[
              AuthWidgets.buildSpacing(),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ],
            if (isCredentialError) ...[
              AuthWidgets.buildSpacing(),
              AuthWidgets.buildNavigationButton(
                text: 'Forgot password?',
                onPressed: _loading ? null : () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ResetPasswordPage(initialEmail: _email.text.trim())
                  ),
                ),
              ),
            ],
            AuthWidgets.buildSpacing(),
            AuthWidgets.buildNavigationButton(
              text: "Don't have an account? Sign up",
              onPressed: _loading ? null : () => Navigator.of(context).pushReplacementNamed('/register'),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> with TickerProviderStateMixin {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _age = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _phone = TextEditingController();
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // State
  bool _loading = false;
  String? _error;
  CountryCode _selectedCountryCode = AuthServices.getDefaultCountryCode();
  PasswordStrength _passwordStrength = const PasswordStrength(label: '', color: Colors.red, score: 1);
  
  // Email checking
  final EmailCheckManager _emailCheckManager = EmailCheckManager();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupEmailListener();
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

  void _setupEmailListener() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _email.removeListener(_onEmailChanged);
      _email.addListener(_onEmailChanged);
    });
  }

  void _onEmailChanged() {
    _emailCheckManager.checkEmail(_email.text, () {
      if (mounted) setState(() {});
    });
  }

  void _onPasswordChanged(String password) {
    setState(() {
      _passwordStrength = PasswordStrength.calculate(password);
    });
  }

  @override
  void dispose() {
    _emailCheckManager.dispose();
    _email.removeListener(_onEmailChanged);
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _name.dispose();
    _age.dispose();
    _phone.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    Get.clearContext();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    
    setState(() => _loading = true);
    try {
      final registrationData = RegistrationData(
        fullName: _name.text.trim(),
        age: int.tryParse(_age.text.trim()) ?? 0,
        email: _email.text.trim(),
        password: _password.text.trim(),
        phone: RegistrationData.normalizePhone('${_selectedCountryCode.code}${_phone.text.trim()}'),
      );
      
      await AuthServices.register(registrationData);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        final msg = e.toString().replaceFirst('Exception: ', '');
        setState(() => _error = msg);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Get.setContext(context);
    
    return Scaffold(
      backgroundColor: context.isDarkMode ? TailwindColors.gray900 : TailwindColors.gray50,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            SizedBox(height: context.responsiveGapLg),
            _buildHeader(),
            SizedBox(height: context.responsiveGapXl),
            _buildForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(40.w),
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.person_add,
            size: 40.w,
            color: Theme.of(context).primaryColor,
          ),
        ),
        SizedBox(height: context.responsiveGap),
        Text(
          'Create Account',
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
          ),
        ),
        SizedBox(height: context.responsiveGapSm),
        Text(
          'Join FindMed today',
          style: TextStyle(
            fontSize: 16.sp,
            color: context.isDarkMode ? Colors.white70 : TailwindColors.gray600,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: context.isDarkMode ? TailwindColors.gray800 : Colors.white,
        borderRadius: BorderRadius.circular(TailwindRadius.xl),
        boxShadow: [TailwindShadows.lg],
      ),
      child: Form(
        key: _form,
        child: ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            AuthWidgets.buildNameField(
              controller: _name,
              context: context,
            ),
            AuthWidgets.buildSpacing(),
            AuthWidgets.buildAgeField(
              controller: _age,
              context: context,
            ),
            AuthWidgets.buildSpacing(),
            AuthWidgets.buildEmailField(
              controller: _email,
              context: context,
              isChecking: _emailCheckManager.isChecking,
              result: _emailCheckManager.result,
              onEmailChanged: _onEmailChanged,
            ),
            AuthWidgets.buildSpacing(),
            _buildPasswordFieldWithStrength(),
            AuthWidgets.buildSpacing(),
            AuthWidgets.buildConfirmPasswordField(
              controller: _confirm,
              password: _password.text,
              context: context,
            ),
            AuthWidgets.buildSpacing(),
            AuthWidgets.buildPhoneInputRow(
              phoneController: _phone,
              selectedCode: _selectedCountryCode,
              onCountryCodeChanged: (code) => setState(() => _selectedCountryCode = code!),
              context: context,
            ),
            AuthWidgets.buildSpacing(height: 20),
            AuthWidgets.buildSubmitButton(
              text: 'Register',
              onPressed: _loading ? null : _submit,
              isLoading: _loading,
              height: 48,
            ),
            if (_error != null) ...[
              AuthWidgets.buildSpacing(),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ],
            AuthWidgets.buildSpacing(),
            AuthWidgets.buildNavigationButton(
              text: 'Already have an account? Sign in',
              onPressed: _loading ? null : () => Navigator.of(context).pushReplacementNamed('/login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordFieldWithStrength() {
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AuthWidgets.buildPasswordField(
              controller: _password,
              context: context,
              validator: PasswordStrength.validatePassword,
              onChanged: (value) => _onPasswordChanged(value),
            ),
            AuthWidgets.buildPasswordStrengthIndicator(_passwordStrength),
          ],
        );
      },
    );
  }
}
