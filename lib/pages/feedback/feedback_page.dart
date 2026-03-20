import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import './models/feedback_models.dart';
import './services/feedback_services.dart';
import './widgets/feedback_widgets.dart';

/// Feedback Page - User feedback submission
class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  
  // State
  FeedbackState _state = const FeedbackState();
  String _selectedCategoryId = 'general_feedback';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
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

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    FeedbackWidgets.clearContext();
    super.dispose();
  }

  // State management
  void _updateState(FeedbackState newState) {
    setState(() {
      _state = newState;
    });
  }

  void _setLoading(bool loading) {
    _updateState(_state.setLoading(loading));
  }

  void _setUploading(bool uploading) {
    _updateState(_state.setUploading(uploading));
  }

  void _setError(String error) {
    _updateState(_state.setError(error));
  }

  void _clearError() {
    _updateState(_state.clearError());
  }

  // Form validation
  bool _isFormValid() {
    final message = _messageController.text.trim();
    return message.length >= FeedbackConstants.messageMinLength;
  }

  // Feedback submission
  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;
    
    _setLoading(true);
    _clearError();
    
    try {
      final submission = FeedbackSubmission(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        message: _messageController.text.trim(),
        attachments: _state.attachments,
        submittedAt: DateTime.now(),
      );
      
      final result = await FeedbackServices.submitFeedback(submission);
      
      if (result.success) {
        _showSuccessDialog(result.message!);
        _clearForm();
      } else if (result.usedFallback) {
        _showInfoMessage(result.message!);
        _clearForm();
      } else {
        _setError(result.message!);
      }
    } catch (e) {
      _setError('Failed to send feedback: $e');
    } finally {
      _setLoading(false);
    }
  }

  // File attachment
  Future<void> _pickAndUploadFile() async {
    if (_state.isUploading) return;
    
    _setUploading(true);
    _clearError();
    
    try {
      final result = await FeedbackServices.pickAndUploadFile();
      
      if (result != null) {
        if (result.success) {
          final attachment = result.toAttachment();
          _updateState(_state.addAttachment(attachment));
        } else {
          _setError(result.error!);
        }
      }
    } catch (e) {
      _setError('Attachment error: $e');
    } finally {
      _setUploading(false);
    }
  }

  void _removeAttachment(FeedbackAttachment attachment) {
    _updateState(_state.removeAttachment(attachment));
  }

  // Category selection
  void _onCategoryChanged(String categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
  }

  // Form management
  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _messageController.clear();
    _updateState(_state.clearAttachments());
    _updateState(_state.markSubmitted());
  }

  // UI helpers
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => FeedbackWidgets.buildSuccessDialog(
        message: message,
        onContinue: () => Navigator.of(context).pop(),
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

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showInfoMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).primaryColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    FeedbackWidgets.setContext(context);
    
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
        FeedbackConstants.pageTitle,
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
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FeedbackWidgets.buildHeader(),
              FeedbackWidgets.buildSpacing(height: 24),
              
              // Category selector
              FeedbackWidgets.buildCategorySelector(
                selectedCategoryId: _selectedCategoryId,
                onCategoryChanged: _onCategoryChanged,
              ),
              FeedbackWidgets.buildSectionDivider(),
              
              // Form fields
              FeedbackWidgets.buildFormField(
                controller: _nameController,
                label: FeedbackConstants.titleLabel,
                optional: true,
              ),
              
              FeedbackWidgets.buildFormField(
                controller: _emailController,
                label: FeedbackConstants.emailLabel,
                keyboardType: TextInputType.emailAddress,
                optional: true,
              ),
              
              FeedbackWidgets.buildFormField(
                controller: _messageController,
                label: FeedbackConstants.messageLabel,
                hintText: 'Please share your detailed feedback here...',
                minLines: 4,
                maxLines: 8,
                validator: (value) {
                  if (value == null || value.trim().length < FeedbackConstants.messageMinLength) {
                    return FeedbackConstants.messageMinLengthError;
                  }
                  if (value.trim().length > FeedbackConstants.messageMaxLength) {
                    return 'Message is too long (max ${FeedbackConstants.messageMaxLength} characters)';
                  }
                  return null;
                },
              ),
              
              // Attachments
              FeedbackWidgets.buildAttachmentSection(
                attachments: _state.attachments,
                onAttach: _pickAndUploadFile,
                onRemove: _removeAttachment,
                isUploading: _state.isUploading,
              ),
              
              // Error message
              if (_state.error != null) ...[
                FeedbackWidgets.buildErrorMessage(_state.error!),
                FeedbackWidgets.buildSpacing(height: 8),
              ],
              
              // Info message
              FeedbackWidgets.buildInfoMessage(
                'Your feedback helps us improve FindMed. We typically respond within 24 hours.',
              ),
              
              // Submit button
              FeedbackWidgets.buildSubmitButton(
                onPressed: _submitFeedback,
                isLoading: _state.isLoading,
                isValid: _isFormValid(),
              ),
              
              FeedbackWidgets.buildSpacing(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
