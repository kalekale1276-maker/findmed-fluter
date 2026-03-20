import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/tailwind_extensions.dart';
import '../../../../widgets/branding_widgets.dart';
import 'models/reset_password_models.dart';
import 'services/reset_password_services.dart';
import 'widgets/reset_password_widgets.dart';

/// Reset Password Page - Password recovery functionality
class ResetPasswordPage extends StatefulWidget {
  final String? initialEmail;
  const ResetPasswordPage({super.key, this.initialEmail});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _adminDefaultPasswordController = TextEditingController();
  final TextEditingController _chatIdController = TextEditingController();
  
  // State
  ResetPasswordState _state = const ResetPasswordState();
  
  // Timers
  Timer? _adminPwdPollTimer;

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

  void _initializeData() {
    if (widget.initialEmail != null && widget.initialEmail!.trim().isNotEmpty) {
      _emailController.text = widget.initialEmail!.trim();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkEmailAndTelegram();
      });
    }
    
    _emailController.addListener(_onEmailChanged);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _emailController.removeListener(_onEmailChanged);
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _adminDefaultPasswordController.dispose();
    _chatIdController.dispose();
    _adminPwdPollTimer?.cancel();
    ResetPasswordWidgets.clearContext();
    super.dispose();
  }

  // State management
  void _updateState(ResetPasswordState newState) {
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

  void _addMessage(String message) {
    _updateState(_state.addMessage(message));
    
    // Auto-remove message after duration
    Future.delayed(const Duration(seconds: ResetPasswordConstants.messageDisplayDuration), () {
      if (mounted) {
        _updateState(_state.removeMessage(message));
      }
    });
  }

  void _updatePasswordVisibility(String field, bool visible) {
    _updateState(_state.updatePasswordVisibility(field, visible));
  }

  // Email handling
  void _onEmailChanged() {
    _checkEmailAndTelegram();
  }

  Future<void> _checkEmailAndTelegram() async {
    final email = _emailController.text.trim();
    
    if (email.isEmpty || !email.contains('@')) {
      _updateState(_state.copyWith(
        emailStatus: EmailVerificationStatus.checking,
        telegramLinkingStatus: TelegramLinkingStatus.idle,
      ));
      return;
    }
    
    _updateState(_state.copyWith(
      emailStatus: EmailVerificationStatus.checking,
      telegramLinkingStatus: TelegramLinkingStatus.idle,
    ));
    
    try {
      final result = await ResetPasswordServices.checkEmailAndTelegram(email);
      
      _updateState(_state.copyWith(
        emailStatus: result['exists'] ? EmailVerificationStatus.exists : EmailVerificationStatus.notExists,
        telegramLinkingStatus: result['telegramLinked'] 
            ? TelegramLinkingStatus.linked 
            : TelegramLinkingStatus.idle,
      ));
    } catch (e) {
      _updateState(_state.copyWith(
        emailStatus: EmailVerificationStatus.error,
        telegramLinkingStatus: TelegramLinkingStatus.error,
      ));
    }
  }

  // Telegram linking
  void _connectTelegram() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          bool linking = false;
          String? linkError;
          bool? chatIdAvailable;
          bool chatIdChecking = false;

          Future<void> checkChatId(String chatId) async {
            final validation = ResetPasswordServices.validateChatId(chatId);
            if (!validation.isValid) {
              setDialogState(() {
                chatIdAvailable = null;
                linkError = validation.errorMessage;
                chatIdChecking = false;
              });
              return;
            }
            
            setDialogState(() {
              chatIdChecking = true;
              chatIdAvailable = null;
              linkError = null;
            });
            
            try {
              final result = await ResetPasswordServices.checkChatIdAvailability(chatId, _emailController.text.trim());
              setDialogState(() {
                chatIdAvailable = result.isAvailable;
                linkError = result.errorMessage;
                chatIdChecking = false;
              });
            } catch (e) {
              setDialogState(() {
                chatIdAvailable = null;
                linkError = ResetPasswordConstants.failedToCheckChatIdMessage;
                chatIdChecking = false;
              });
            }
          }

          return ResetPasswordWidgets.buildTelegramLinkingDialog(
            chatIdController: _chatIdController,
            isLinking: linking,
            linkError: linkError,
            chatIdAvailable: chatIdAvailable,
            chatIdChecking: chatIdChecking,
            onCancel: () => Navigator.pop(context),
            onLink: () async {
              final chatId = _chatIdController.text.trim();
              if (chatId.isEmpty) {
                setDialogState(() => linkError = ResetPasswordConstants.enterChatIdMessage);
                return;
              }
              
              setDialogState(() {
                linking = true;
                linkError = null;
              });
              
              try {
                final result = await ResetPasswordServices.linkTelegram(
                  email: _emailController.text.trim(),
                  chatId: chatId,
                );
                
                if (result.success) {
                  _addMessage(result.message!);
                  _updateState(_state.copyWith(
                    telegramLinkingStatus: TelegramLinkingStatus.linked,
                  ));
                  Navigator.pop(context);
                } else {
                  setDialogState(() {
                    linking = false;
                    linkError = result.message;
                  });
                }
              } catch (e) {
                setDialogState(() {
                  linking = false;
                  linkError = ResetPasswordConstants.failedToLinkTelegramMessage;
                });
              }
            },
          );
        },
      ),
    );
  }

  // Admin reset
  Future<void> _requestAdmin() async {
    _setLoading(true);
    _clearError();
    
    _adminPwdPollTimer?.cancel();
    
    try {
      final result = await ResetPasswordServices.requestAdminReset(_emailController.text.trim());
      
      if (result.success) {
        _updateState(_state.copyWith(
          adminResetStatus: AdminResetStatus.waiting,
          message: result.message,
        ));
        
        // Start polling for admin reset password
        _adminPwdPollTimer = Timer.periodic(
          const Duration(seconds: ResetPasswordConstants.adminPollingIntervalSeconds),
          (_) async {
            try {
              final password = await ResetPasswordServices.pollAdminResetPassword(_emailController.text.trim());
              if (password != null) {
                _updateState(_state.copyWith(
                  adminResetStatus: AdminResetStatus.passwordReady,
                  adminResetPassword: password,
                ));
                _adminPwdPollTimer?.cancel();
              }
            } catch (_) {}
          },
        );
      } else {
        _setError(result.message!);
      }
    } catch (e) {
      _setError(ResetPasswordConstants.failedToRequestAdminResetMessage);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _checkAdminDefaultPassword() async {
    _setLoading(true);
    
    try {
      final isValid = await ResetPasswordServices.verifyAdminDefaultPassword(
        email: _emailController.text.trim(),
        password: _adminDefaultPasswordController.text.trim(),
      );
      
      if (isValid) {
        _addMessage(ResetPasswordConstants.defaultPasswordCorrectMessage);
        await Future.delayed(const Duration(milliseconds: ResetPasswordConstants.loginDelayMs));
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        _addMessage(ResetPasswordConstants.defaultPasswordIncorrectMessage);
      }
    } catch (e) {
      _addMessage(ResetPasswordConstants.defaultPasswordIncorrectMessage);
    } finally {
      _setLoading(false);
    }
  }

  // Telegram reset
  Future<void> _requestReset() async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await ResetPasswordServices.requestTelegramReset(_emailController.text.trim());
      
      if (result.success) {
        _updateState(_state.copyWith(
          isViaTelegram: true,
          message: result.message,
        ));
        _addMessage(result.message!);
      } else {
        _setError(result.message!);
      }
    } catch (e) {
      _setError(ResetPasswordServices.formatErrorMessage(e.toString()));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _confirmReset() async {
    _setLoading(true);
    _clearError();
    
    final otpValidation = ResetPasswordServices.validateOtp(_otpController.text.trim());
    if (!otpValidation.isValid) {
      _setError(otpValidation.errorMessage!);
      _setLoading(false);
      return;
    }
    
    final passwordValidation = ResetPasswordServices.validatePassword(_newPasswordController.text.trim());
    if (!passwordValidation.isValid) {
      _setError(passwordValidation.errorMessage!);
      _setLoading(false);
      return;
    }
    
    try {
      final result = await ResetPasswordServices.confirmReset(
        email: _emailController.text.trim(),
        otp: _otpController.text.trim(),
        newPassword: _newPasswordController.text.trim(),
      );
      
      if (result.success) {
        _addMessage(result.message!);
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        _setError(result.message!);
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _changeAndSavePassword() async {
    _setLoading(true);
    
    final passwordValidation = ResetPasswordServices.validatePasswordConfirmation(
      _newPasswordController.text.trim(),
      _confirmPasswordController.text.trim(),
    );
    
    if (!passwordValidation.isValid) {
      _addMessage(passwordValidation.errorMessage!);
      _setLoading(false);
      return;
    }
    
    try {
      final result = await ResetPasswordServices.changePasswordWithAdmin(
        email: _emailController.text.trim(),
        adminPassword: _adminDefaultPasswordController.text.trim(),
        newPassword: _newPasswordController.text.trim(),
      );
      
      if (result.success) {
        _addMessage('Password changed successfully');
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        _addMessage(result.message!);
      }
    } catch (e) {
      _addMessage('Error: $e');
    } finally {
      _setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ResetPasswordWidgets.setContext(context);
    
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
        ResetPasswordConstants.pageTitle,
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
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: ListView(
        children: [
          // Email input
          ResetPasswordWidgets.buildEmailInput(
            controller: _emailController,
            isChecking: _state.isEmailChecking,
            onChanged: _onEmailChanged,
          ),
          
          ResetPasswordWidgets.buildSpacing(),
          
          // Email checking indicator
          if (_state.isEmailChecking)
            ResetPasswordWidgets.buildEmailCheckingIndicator(),
          
          // Email status indicator
          if (_state.emailExists)
            ResetPasswordWidgets.buildEmailStatusIndicator(
              emailExists: _state.emailExists,
              isTelegramLinked: _state.isTelegramLinked,
            ),
          
          // Action buttons
          if (_state.emailExists)
            ResetPasswordWidgets.buildActionButtons(
              onConnectTelegram: _connectTelegram,
              onRequestAdmin: _requestAdmin,
              onRequestReset: _requestReset,
              isLoading: _state.isLoading,
              showTelegramOption: _state.isTelegramLinked,
              showAdminOption: !_state.isTelegramLinked,
            ),
          
          // Admin reset waiting section
          if (_state.isWaitingAdminReset)
            ResetPasswordWidgets.buildAdminResetWaitingSection(
              onGetDefaultPassword: _requestAdmin,
              adminResetPassword: _state.adminResetPassword,
              isLoading: _state.isLoading,
              onCheckPassword: _checkAdminDefaultPassword,
              passwordCheckMessage: _state.message,
              passwordController: _adminDefaultPasswordController,
              newPasswordController: _newPasswordController,
              confirmPasswordController: _confirmPasswordController,
              onChangePassword: _changeAndSavePassword,
              newPasswordVisible: _state.getPasswordVisibility('newPassword', false),
              confirmPasswordVisible: _state.getPasswordVisibility('confirmPassword', false),
              onToggleNewPasswordVisibility: () => _updatePasswordVisibility('newPassword', !_state.getPasswordVisibility('newPassword', false)),
              onToggleConfirmPasswordVisibility: () => _updatePasswordVisibility('confirmPassword', !_state.getPasswordVisibility('confirmPassword', false)),
            ),
          
          // Reset via Telegram button
          if (_state.isTelegramLinked && !_state.isViaTelegram)
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: ElevatedButton(
                onPressed: _state.isLoading ? null : _requestReset,
                child: Text(ResetPasswordConstants.resetViaTelegramLabel),
              ),
            ),
          
          // OTP fields
          if (_state.isViaTelegram) ...[
            ResetPasswordWidgets.buildOtpFields(
              otpController: _otpController,
              newPasswordController: _newPasswordController,
              confirmPasswordController: _confirmPasswordController,
              otpVisible: _state.getPasswordVisibility('otp', false),
              newPasswordVisible: _state.getPasswordVisibility('newPassword', false),
              confirmPasswordVisible: _state.getPasswordVisibility('confirmPassword', false),
              onToggleOtpVisibility: () => _updatePasswordVisibility('otp', !_state.getPasswordVisibility('otp', false)),
              onToggleNewPasswordVisibility: () => _updatePasswordVisibility('newPassword', !_state.getPasswordVisibility('newPassword', false)),
              onToggleConfirmPasswordVisibility: () => _updatePasswordVisibility('confirmPassword', !_state.getPasswordVisibility('confirmPassword', false)),
            ),
            ResetPasswordWidgets.buildSpacing(),
            ResetPasswordWidgets.buildOtpActionButtons(
              onConfirm: _confirmReset,
              onResend: _requestReset,
              isLoading: _state.isLoading,
            ),
          ],
          
          // Error message
          if (_state.hasError)
            ResetPasswordWidgets.buildErrorMessage(_state.error!),
          
          // Message list
          if (_state.messages.isNotEmpty)
            ResetPasswordWidgets.buildMessageList(
              messages: _state.messages,
              isViaTelegram: _state.isViaTelegram,
            ),
          
          // Additional action buttons for error cases
          if (_state.hasError && _state.message?.toLowerCase().contains('not linked to telegram') == true)
            ResetPasswordWidgets.buildActionButtons(
              onConnectTelegram: _connectTelegram,
              onRequestAdmin: _requestAdmin,
              onRequestReset: null,
              isLoading: _state.isLoading,
              showTelegramOption: false,
              showAdminOption: true,
            ),
        ],
      ),
    );
  }
}
