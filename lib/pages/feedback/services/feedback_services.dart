import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../../../services/api.dart';
import '../../../../services/notifications.dart';
import '../models/feedback_models.dart';

/// Services for feedback functionality
class FeedbackServices {
  /// Submit feedback to API
  static Future<FeedbackResult> submitFeedback(FeedbackSubmission submission) async {
    try {
      final payload = submission.toJson();
      final response = await Api.post(FeedbackConstants.feedbackEndpoint, payload);
      
      // Save feedback ID for notifications
      final entry = response['entry'];
      if (entry != null && entry['id'] != null) {
        await NotificationsService.setLastFeedbackId(entry['id'].toString());
      }
      
      return FeedbackResult.success(
        message: FeedbackConstants.successMessage,
        feedbackId: entry?['id']?.toString(),
      );
    } catch (e) {
      debugPrint('Error submitting feedback: $e');
      
      // Fallback to email client
      try {
        final mailtoUrl = submission.mailtoUrl;
        final uri = Uri.parse(mailtoUrl);
        final launched = await launchUrl(uri);
        
        if (launched) {
          return FeedbackResult.fallback(
            message: 'Opening email client to send feedback',
          );
        } else {
          return FeedbackResult.failure('Failed to open email client');
        }
      } catch (emailError) {
        debugPrint('Error opening email client: $emailError');
        return FeedbackResult.failure(
          '${FeedbackConstants.sendFailedMessage}$e',
        );
      }
    }
  }

  /// Upload file to server
  static Future<UploadResult> uploadFile(html.File file) async {
    try {
      // Read file as bytes
      final bytes = await _readFileAsBytes(file);
      
      // Try each upload base
      for (final baseUrl in FeedbackConstants.uploadBases) {
        try {
          final result = await _uploadToServer(baseUrl, file.name, bytes);
          if (result.success) {
            return result;
          }
        } catch (e) {
          debugPrint('Upload failed for $baseUrl: $e');
          continue;
        }
      }
      
      return UploadResult.failure('All upload servers failed');
    } catch (e) {
      debugPrint('Error uploading file: $e');
      return UploadResult.failure('Upload error: $e');
    }
  }

  /// Read file as bytes
  static Future<Uint8List> _readFileAsBytes(html.File file) async {
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    
    await for (final event in reader.onLoad) {
      final arrayBuffer = reader.result as ArrayBuffer;
      return Uint8List.fromList(arrayBuffer.asUint8List());
    }
    
    throw Exception('Failed to read file');
  }

  /// Upload to specific server
  static Future<UploadResult> _uploadToServer(
    String baseUrl,
    String filename,
    Uint8List bytes,
  ) async {
    final uri = Uri.parse('$baseUrl${FeedbackConstants.uploadEndpoint}');
    
    final request = http.MultipartRequest('POST', uri);
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
      ),
    );
    
    final streamedResponse = await request.send().timeout(
      const Duration(seconds: FeedbackConstants.uploadTimeoutSeconds),
    );
    
    final response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        
        return UploadResult.success(
          url: responseData['url']?.toString() ?? responseData['filename']?.toString(),
          filename: responseData['filename']?.toString() ?? filename,
          type: responseData['type']?.toString(),
        );
      } catch (e) {
        debugPrint('Error parsing upload response: $e');
        return UploadResult.failure('Invalid response format');
      }
    } else {
      return UploadResult.failure('Upload failed with status ${response.statusCode}');
    }
  }

  /// Validate file type
  static bool isValidFileType(html.File file) {
    final fileName = file.name.toLowerCase();
    final acceptedTypes = FeedbackConstants.acceptedFileTypes;
    
    // Check MIME type if available
    if (file.type.isNotEmpty) {
      for (final acceptedType in acceptedTypes) {
        if (acceptedType.startsWith('image/') && file.type.startsWith('image/')) {
          return true;
        }
        if (acceptedType == file.type) {
          return true;
        }
        if (acceptedType.startsWith('.') && fileName.endsWith(acceptedType)) {
          return true;
        }
      }
    }
    
    // Check file extension
    for (final acceptedType in acceptedTypes) {
      if (acceptedType.startsWith('.') && fileName.endsWith(acceptedType)) {
        return true;
      }
    }
    
    return false;
  }

  /// Get file size in human readable format
  static String getFormattedFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Check file size limit (10MB)
  static bool isValidFileSize(html.File file) {
    const maxSizeBytes = 10 * 1024 * 1024; // 10MB
    return file.size <= maxSizeBytes;
  }

  /// Get file icon based on type
  static IconData getFileIcon(FeedbackAttachment attachment) {
    if (attachment.isImage) return Icons.image;
    if (attachment.isPdf) return Icons.picture_as_pdf;
    if (attachment.isDocument) return Icons.description;
    return Icons.insert_drive_file;
  }

  /// Get file color based on type
  static Color getFileColor(FeedbackAttachment attachment) {
    if (attachment.isImage) return Colors.blue;
    if (attachment.isPdf) return Colors.red;
    if (attachment.isDocument) return Colors.green;
    return Colors.grey;
  }

  /// Create file picker
  static html.FileUploadInputElement createFilePicker() {
    final input = html.FileUploadInputElement();
    input.accept = FeedbackConstants.acceptedFileTypes.join(',');
    return input;
  }

  /// Pick and upload file
  static Future<UploadResult?> pickAndUploadFile() async {
    try {
      final input = createFilePicker();
      input.click();
      
      final files = await _waitForFileSelection(input);
      if (files == null || files.isEmpty) return null;
      
      final file = files.first;
      
      // Validate file
      if (!isValidFileType(file)) {
        return UploadResult.failure('Invalid file type');
      }
      
      if (!isValidFileSize(file)) {
        return UploadResult.failure('File too large (max 10MB)');
      }
      
      // Upload file
      return await uploadFile(file);
    } catch (e) {
      debugPrint('Error picking file: $e');
      return UploadResult.failure('File picker error: $e');
    }
  }

  /// Wait for file selection
  static Future<List<html.File>?> _waitForFileSelection(html.FileUploadInputElement input) {
    final completer = Completer<List<html.File>?>();
    
    input.onChange.listen((event) {
      final files = input.files;
      completer.complete(files?.toList());
    });
    
    // Handle case where user cancels
    Timer(const Duration(seconds: 30), () {
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    });
    
    return completer.future;
  }

  /// Get feedback categories
  static List<FeedbackCategory> getFeedbackCategories() {
    return FeedbackCategory.getAllCategories();
  }

  /// Submit categorized feedback
  static Future<FeedbackResult> submitCategorizedFeedback({
    required String name,
    required String email,
    required String message,
    required String categoryId,
    List<FeedbackAttachment> attachments = const [],
  }) async {
    // Add category info to message
    final category = getFeedbackCategories()
        .where((c) => c.id == categoryId)
        .firstOrNull;
    
    final categorizedMessage = category != null
        ? '[${category.name}]\n\n$message'
        : message;
    
    final submission = FeedbackSubmission(
      name: name,
      email: email,
      message: categorizedMessage,
      attachments: attachments,
      submittedAt: DateTime.now(),
    );
    
    return await submitFeedback(submission);
  }

  /// Get feedback history (mock implementation)
  static Future<List<FeedbackSubmission>> getFeedbackHistory() async {
    try {
      // This would typically call an API to get user's feedback history
      // For now, return empty list as mock
      await Future.delayed(const Duration(milliseconds: 500));
      return [];
    } catch (e) {
      debugPrint('Error loading feedback history: $e');
      return [];
    }
  }

  /// Delete feedback (mock implementation)
  static Future<bool> deleteFeedback(String feedbackId) async {
    try {
      // This would typically call an API to delete feedback
      // For now, return false as mock
      await Future.delayed(const Duration(milliseconds: 300));
      return false;
    } catch (e) {
      debugPrint('Error deleting feedback: $e');
      return false;
    }
  }

  /// Get feedback statistics (mock implementation)
  static Future<Map<String, dynamic>> getFeedbackStatistics() async {
    try {
      // This would typically call an API to get statistics
      // For now, return mock data
      await Future.delayed(const Duration(milliseconds: 400));
      
      return {
        'totalSubmitted': 0,
        'totalAttachments': 0,
        'averageResponseTime': '24 hours',
        'categories': {
          'bug_report': 0,
          'feature_request': 0,
          'general_feedback': 0,
          'facility_update': 0,
          'complaint': 0,
        },
      };
    } catch (e) {
      debugPrint('Error loading feedback statistics: $e');
      return {};
    }
  }

  /// Validate feedback submission
  static ValidationResult validateFeedbackSubmission({
    required String name,
    required String email,
    required String message,
  }) {
    final submission = FeedbackSubmission(
      name: name,
      email: email,
      message: message,
      submittedAt: DateTime.now(),
    );
    
    return submission.validate();
  }

  /// Format feedback for display
  static String formatFeedbackForDisplay(FeedbackSubmission submission) {
    final buffer = StringBuffer();
    
    if (submission.name.isNotEmpty) {
      buffer.writeln('From: ${submission.name}');
    }
    
    if (submission.email.isNotEmpty) {
      buffer.writeln('Email: ${submission.email}');
    }
    
    buffer.writeln('Date: ${submission.submittedAt.toString()}');
    buffer.writeln();
    buffer.writeln(submission.message);
    
    if (submission.attachments.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Attachments:');
      for (final attachment in submission.attachments) {
        buffer.writeln('- ${attachment.displayName}');
      }
    }
    
    return buffer.toString();
  }

  /// Export feedback to JSON
  static String exportFeedbackToJson(List<FeedbackSubmission> feedbacks) {
    final exportData = feedbacks.map((f) => f.toJson()).toList();
    return jsonEncode(exportData);
  }

  /// Get supported file types for display
  static List<String> getSupportedFileTypes() {
    return [
      'Images (JPG, PNG, GIF)',
      'Documents (PDF, DOC, DOCX, TXT)',
    ];
  }

  /// Get maximum file size for display
  static String getMaxFileSizeDisplay() {
    return '10MB';
  }
}

/// Import required types
import 'dart:async';
