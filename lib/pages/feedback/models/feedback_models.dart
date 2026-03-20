/// Models and constants for feedback functionality
class FeedbackConstants {
  // UI labels
  static const String pageTitle = 'Send Feedback';
  static const String titleLabel = 'Your name (optional)';
  static const String emailLabel = 'Email (optional)';
  static const String messageLabel = 'Message';
  static const String sendButtonLabel = 'Send';
  static const String attachButtonLabel = 'Attach file';
  static const String headerMessage = 'We appreciate your feedback';
  
  // Validation messages
  static const String messageMinLengthError = 'Please enter at least 5 characters';
  static const String successMessage = 'Feedback sent — thank you';
  static const String uploadFailedMessage = 'Upload failed';
  static const String attachmentErrorMessage = 'Attachment error: ';
  static const String sendFailedMessage = 'Failed to send feedback: ';
  
  // Email settings
  static const String supportEmail = 'support@findmed.example';
  static const String emailSubject = 'FindMed Feedback';
  
  // Upload settings
  static const List<String> acceptedFileTypes = [
    'image/*',
    'application/pdf',
    '.doc',
    '.docx',
    '.txt',
  ];
  
  static const List<String> uploadBases = [
    'https://findmed-backend-1.onrender.com',
  ];
  
  static const String uploadEndpoint = '/api/uploads';
  static const String feedbackEndpoint = '/feedback';
  
  // Animation durations
  static const int animationDurationMs = 300;
  static const int uploadTimeoutSeconds = 60;
  
  // Character limits
  static const int messageMinLength = 5;
  static const int messageMaxLength = 1000;
}

/// Feedback submission model
class FeedbackSubmission {
  final String name;
  final String email;
  final String message;
  final List<FeedbackAttachment> attachments;
  final DateTime submittedAt;
  final String? feedbackId;

  FeedbackSubmission({
    required this.name,
    required this.email,
    required this.message,
    this.attachments = const [],
    required this.submittedAt,
    this.feedbackId,
  });

  factory FeedbackSubmission.fromJson(Map<String, dynamic> json) {
    return FeedbackSubmission(
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((a) => FeedbackAttachment.fromJson(Map<String, dynamic>.from(a as Map)))
          .toList() ?? [],
      submittedAt: DateTime.tryParse(json['submittedAt']?.toString() ?? '') ?? DateTime.now(),
      feedbackId: json['feedbackId']?.toString(),
    );
  }

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'email': email.trim(),
      'message': message.trim(),
      'attachments': attachments.map((a) => a.toJson()).toList(),
    };
  }

  /// Validate submission
  ValidationResult validate() {
    if (message.trim().length < FeedbackConstants.messageMinLength) {
      return ValidationResult.invalid(FeedbackConstants.messageMinLengthError);
    }
    
    if (message.trim().length > FeedbackConstants.messageMaxLength) {
      return ValidationResult.invalid('Message is too long (max ${FeedbackConstants.messageMaxLength} characters)');
    }
    
    // Basic email validation if provided
    if (email.isNotEmpty && !isValidEmail(email)) {
      return ValidationResult.invalid('Please enter a valid email address');
    }
    
    return ValidationResult.valid;
  }

  /// Basic email validation
  bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  /// Get formatted email body for mailto
  String get emailBody {
    final buffer = StringBuffer();
    buffer.writeln(message);
    buffer.writeln();
    buffer.writeln('From: $name <$email>');
    return buffer.toString();
  }

  /// Get mailto URL
  String get mailtoUrl {
    final subject = Uri.encodeComponent(FeedbackConstants.emailSubject);
    final body = Uri.encodeComponent(emailBody);
    return 'mailto:${FeedbackConstants.supportEmail}?subject=$subject&body=$body';
  }
}

/// Feedback attachment model
class FeedbackAttachment {
  final String url;
  final String filename;
  final String type;
  final String? size;
  final DateTime? uploadedAt;

  FeedbackAttachment({
    required this.url,
    required this.filename,
    required this.type,
    this.size,
    this.uploadedAt,
  });

  factory FeedbackAttachment.fromJson(Map<String, dynamic> json) {
    return FeedbackAttachment(
      url: json['url']?.toString() ?? '',
      filename: json['filename']?.toString() ?? json['name']?.toString() ?? 'file',
      type: json['type']?.toString() ?? 'file',
      size: json['size']?.toString(),
      uploadedAt: json['uploadedAt'] != null 
          ? DateTime.tryParse(json['uploadedAt'].toString())
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'filename': filename,
      'type': type,
      'size': size,
      'uploadedAt': uploadedAt?.toIso8601String(),
    };
  }

  /// Get display name
  String get displayName {
    return filename.isNotEmpty ? filename : 'Attachment';
  }

  /// Get file extension
  String get fileExtension {
    final parts = filename.split('.');
    return parts.length > 1 ? '.${parts.last}' : '';
  }

  /// Check if image file
  bool get isImage {
    return type.startsWith('image/') || 
           fileExtension.toLowerCase().matches(r'\.(jpg|jpeg|png|gif|bmp|webp)$');
  }

  /// Check if PDF file
  bool get isPdf {
    return type == 'application/pdf' || fileExtension.toLowerCase() == '.pdf';
  }

  /// Check if document file
  bool get isDocument {
    return fileExtension.toLowerCase().matches(r'\.(doc|docx|txt)$');
  }
}

/// Feedback state model
class FeedbackState {
  final bool isLoading;
  final bool isUploading;
  final List<FeedbackAttachment> attachments;
  final String? error;
  final bool isSubmitted;

  const FeedbackState({
    this.isLoading = false,
    this.isUploading = false,
    this.attachments = const [],
    this.error,
    this.isSubmitted = false,
  });

  FeedbackState copyWith({
    bool? isLoading,
    bool? isUploading,
    List<FeedbackAttachment>? attachments,
    String? error,
    bool? isSubmitted,
  }) {
    return FeedbackState(
      isLoading: isLoading ?? this.isLoading,
      isUploading: isUploading ?? this.isUploading,
      attachments: attachments ?? this.attachments,
      error: error ?? this.error,
      isSubmitted: isSubmitted ?? this.isSubmitted,
    );
  }

  /// Clear error
  FeedbackState clearError() => copyWith(error: null);

  /// Set loading
  FeedbackState setLoading(bool loading) => copyWith(isLoading: loading, error: null);

  /// Set uploading
  FeedbackState setUploading(bool uploading) => copyWith(isUploading: uploading, error: null);

  /// Set error
  FeedbackState setError(String error) => copyWith(isLoading: false, isUploading: false, error: error);

  /// Add attachment
  FeedbackState addAttachment(FeedbackAttachment attachment) {
    final updatedAttachments = List<FeedbackAttachment>.from(attachments);
    updatedAttachments.add(attachment);
    return copyWith(attachments: updatedAttachments);
  }

  /// Remove attachment
  FeedbackState removeAttachment(FeedbackAttachment attachment) {
    final updatedAttachments = attachments.where((a) => a.url != attachment.url).toList();
    return copyWith(attachments: updatedAttachments);
  }

  /// Clear attachments
  FeedbackState clearAttachments() => copyWith(attachments: const []);

  /// Mark as submitted
  FeedbackState markSubmitted() => copyWith(isSubmitted: true);

  /// Check if has attachments
  bool get hasAttachments => attachments.isNotEmpty;

  /// Get total attachments count
  int get attachmentCount => attachments.length;
}

/// Feedback result model
class FeedbackResult {
  final bool success;
  final String? message;
  final String? feedbackId;
  final bool usedFallback;

  FeedbackResult({
    required this.success,
    this.message,
    this.feedbackId,
    this.usedFallback = false,
  });

  factory FeedbackResult.success({
    String? message,
    String? feedbackId,
  }) {
    return FeedbackResult(
      success: true,
      message: message ?? FeedbackConstants.successMessage,
      feedbackId: feedbackId,
    );
  }

  factory FeedbackResult.fallback({
    String? message,
  }) {
    return FeedbackResult(
      success: false,
      message: message ?? 'Using fallback method',
      usedFallback: true,
    );
  }

  factory FeedbackResult.failure(String message) {
    return FeedbackResult(
      success: false,
      message: message,
    );
  }
}

/// Upload result model
class UploadResult {
  final bool success;
  final String? url;
  final String? filename;
  final String? type;
  final String? error;

  UploadResult({
    required this.success,
    this.url,
    this.filename,
    this.type,
    this.error,
  });

  factory UploadResult.success({
    required String url,
    String? filename,
    String? type,
  }) {
    return UploadResult(
      success: true,
      url: url,
      filename: filename,
      type: type,
    );
  }

  factory UploadResult.failure(String error) {
    return UploadResult(
      success: false,
      error: error,
    );
  }

  /// Convert to feedback attachment
  FeedbackAttachment toAttachment() {
    if (!success || url == null) {
      throw Exception('Cannot create attachment from failed upload');
    }
    
    return FeedbackAttachment(
      url: url!,
      filename: filename ?? 'attachment',
      type: type ?? 'file',
      uploadedAt: DateTime.now(),
    );
  }
}

/// Validation result
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult({required this.isValid, this.errorMessage});

  static const ValidationResult valid = ValidationResult(isValid: true);
  
  ValidationResult.invalid(String message) 
      : isValid = false, errorMessage = message;
}

/// Feedback category model
class FeedbackCategory {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  FeedbackCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });

  /// Get all feedback categories
  static List<FeedbackCategory> getAllCategories() {
    return [
      FeedbackCategory(
        id: 'bug_report',
        name: 'Bug Report',
        description: 'Report a technical issue or bug',
        icon: Icons.bug_report,
        color: Colors.red,
      ),
      FeedbackCategory(
        id: 'feature_request',
        name: 'Feature Request',
        description: 'Suggest a new feature or improvement',
        icon: Icons.lightbulb,
        color: Colors.blue,
      ),
      FeedbackCategory(
        id: 'general_feedback',
        name: 'General Feedback',
        description: 'Share your thoughts and suggestions',
        icon: Icons.feedback,
        color: Colors.green,
      ),
      FeedbackCategory(
        id: 'facility_update',
        name: 'Facility Update',
        description: 'Report outdated facility information',
        icon: Icons.location_on,
        color: Colors.orange,
      ),
      FeedbackCategory(
        id: 'complaint',
        name: 'Complaint',
        description: 'File a complaint about service or experience',
        icon: Icons.warning,
        color: Colors.purple,
      ),
    ];
  }
}

/// Import required icons
import 'package:flutter/material.dart';
