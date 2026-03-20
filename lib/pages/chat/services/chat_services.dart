import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../../../../services/auth.dart';
import '../../../../services/chat_api.dart';
import '../models/chat_models.dart';

/// Services for chat functionality
class ChatServices {
  static final AuthService _auth = AuthService.instance;

  /// Load all conversations for the user
  static Future<List<ChatConversation>> loadConversations() async {
    try {
      await _auth.init();
      final user = _auth.user;
      final id = user?['id'] ?? user?['_id'];
      
      if (id == null) {
        return [];
      }

      final msgs = await ChatApi.listByUser(id.toString());
      
      // Group messages by conversationId
      final Map<String, List<ChatMessage>> conversationMap = {};
      
      for (final rawMsg in msgs) {
        try {
          final message = ChatMessage.fromJson(rawMsg);
          final conversationId = message.conversationId;
          
          if (!conversationMap.containsKey(conversationId)) {
            conversationMap[conversationId] = [];
          }
          conversationMap[conversationId]!.add(message);
        } catch (e) {
          debugPrint('Error parsing message: $e');
        }
      }

      // Create conversation objects
      final conversations = conversationMap.values
          .map((messages) => ChatConversation.fromMessages(messages))
          .toList();

      // Sort by last activity
      conversations.sort((a, b) {
        final aTime = a.lastActivity ?? DateTime(0);
        final bTime = b.lastActivity ?? DateTime(0);
        return bTime.compareTo(aTime);
      });

      return conversations;
    } catch (e) {
      debugPrint('Error loading conversations: $e');
      rethrow;
    }
  }

  /// Load messages for a specific conversation
  static Future<List<ChatMessage>> loadConversation(String conversationId) async {
    try {
      await _auth.init();
      final msgs = await ChatApi.getConversation(conversationId);
      
      return msgs.map((rawMsg) {
        try {
          return ChatMessage.fromJson(rawMsg);
        } catch (e) {
          debugPrint('Error parsing message: $e');
          return ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            conversationId: conversationId,
            from: 'unknown',
            text: rawMsg.toString(),
            createdAt: DateTime.now(),
          );
        }
      }).toList();
    } catch (e) {
      debugPrint('Error loading conversation: $e');
      rethrow;
    }
  }

  /// Send a message
  static Future<ChatActionResult> sendMessage(String conversationId, String text) async {
    try {
      await _auth.init();
      final user = _auth.user;
      final id = user?['id'] ?? user?['_id'];
      
      final headers = _auth.token != null 
          ? {'Authorization': 'Bearer ${_auth.token}'} 
          : null;
      
      final payload = {
        'conversationId': conversationId,
        'from': id ?? ChatConstants.deviceSender,
        'text': text.trim(),
      };

      await ChatApi.postMessage(payload, headers: headers);
      
      return ChatActionResult.success('Message sent successfully');
    } catch (e) {
      debugPrint('Error sending message: $e');
      return ChatActionResult.failure('${ChatConstants.failedToSendMessage}$e');
    }
  }

  /// Launch attachment URL
  static Future<bool> launchAttachment(ChatAttachment attachment) async {
    if (!attachment.canLaunch) return false;
    
    try {
      return await launchUrlString(attachment.launchableUrl!);
    } catch (e) {
      debugPrint('Error launching attachment: $e');
      return false;
    }
  }

  /// Copy conversation to clipboard
  static Future<ChatActionResult> copyConversation(List<ChatMessage> messages) async {
    if (messages.isEmpty) {
      return ChatActionResult.failure(ChatConstants.noMessagesToCopy);
    }

    try {
      final buffer = StringBuffer();
      
      for (final message in messages) {
        try {
          final senderName = message.getSenderName();
          final time = message.getFormattedFullTime();
          final text = message.text;
          
          buffer.writeln('[$time] $senderName:');
          buffer.writeln(text);
          buffer.writeln('');
          
          // Add attachments if any
          for (final attachment in message.attachments) {
            buffer.writeln('📎 ${attachment.displayName}');
            if (attachment.launchableUrl != null) {
              buffer.writeln('   ${attachment.launchableUrl}');
            }
          }
          buffer.writeln('');
        } catch (e) {
          debugPrint('Error formatting message: $e');
        }
      }

      final finalText = buffer.toString().trim();
      if (finalText.isEmpty) {
        return ChatActionResult.failure(ChatConstants.nothingToCopy);
      }

      await Clipboard.setData(ClipboardData(text: finalText));
      return ChatActionResult.success(ChatConstants.conversationCopied);
    } catch (e) {
      debugPrint('Error copying conversation: $e');
      return ChatActionResult.failure('${ChatConstants.copyFailed}$e');
    }
  }

  /// Copy selected messages to clipboard
  static Future<ChatActionResult> copySelectedMessages(
    List<ChatMessage> allMessages,
    Set<String> selectedIds,
  ) async {
    if (selectedIds.isEmpty) {
      return ChatActionResult.failure(ChatConstants.noMessagesSelected);
    }

    try {
      final buffer = StringBuffer();
      
      for (final message in allMessages) {
        if (!selectedIds.contains(message.id)) continue;
        
        try {
          final senderName = message.getSenderName();
          final time = message.getFormattedFullTime();
          final text = message.text;
          
          buffer.writeln('[$time] $senderName:');
          buffer.writeln(text);
          buffer.writeln('');
          
          // Add attachments if any
          for (final attachment in message.attachments) {
            buffer.writeln('📎 ${attachment.displayName}');
            if (attachment.launchableUrl != null) {
              buffer.writeln('   ${attachment.launchableUrl}');
            }
          }
          buffer.writeln('');
        } catch (e) {
          debugPrint('Error formatting selected message: $e');
        }
      }

      final finalText = buffer.toString().trim();
      if (finalText.isEmpty) {
        return ChatActionResult.failure(ChatConstants.selectedMessagesEmpty);
      }

      await Clipboard.setData(ClipboardData(text: finalText));
      return ChatActionResult.success(ChatConstants.selectedMessagesCopied);
    } catch (e) {
      debugPrint('Error copying selected messages: $e');
      return ChatActionResult.failure('${ChatConstants.copyFailed}$e');
    }
  }

  /// Get current user ID
  static String? getCurrentUserId() {
    final user = _auth.user;
    return user?['id'] ?? user?['_id']?.toString();
  }

  /// Format date for display
  static String formatDate(DateTime date) {
    try {
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays == 0) {
        return DateFormat(ChatConstants.timeFormat).format(date);
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return DateFormat('EEEE').format(date);
      } else {
        return DateFormat(ChatConstants.dateTimeFormat).format(date);
      }
    } catch (_) {
      return '';
    }
  }

  /// Format full date for display
  static String formatFullDate(DateTime date) {
    try {
      return DateFormat(ChatConstants.dateTimeFormat).format(date);
    } catch (_) {
      return '';
    }
  }

  /// Search messages by text
  static List<ChatMessage> searchMessages(List<ChatMessage> messages, String query) {
    if (query.isEmpty) return messages;
    
    final lowerQuery = query.toLowerCase();
    
    return messages.where((message) {
      return message.text.toLowerCase().contains(lowerQuery) ||
             message.getSenderName().toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Filter messages by date range
  static List<ChatMessage> filterMessagesByDate(
    List<ChatMessage> messages,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    if (startDate == null && endDate == null) return messages;
    
    return messages.where((message) {
      final messageDate = DateTime(
        message.createdAt.year,
        message.createdAt.month,
        message.createdAt.day,
      );
      
      if (startDate != null) {
        final start = DateTime(startDate.year, startDate.month, startDate.day);
        if (messageDate.isBefore(start)) return false;
      }
      
      if (endDate != null) {
        final end = DateTime(endDate.year, endDate.month, endDate.day);
        if (messageDate.isAfter(end)) return false;
      }
      
      return true;
    }).toList();
  }

  /// Get message statistics
  static ChatStats getMessageStats(List<ChatMessage> messages) {
    final userMessages = messages.where((m) => m.isFromUser(getCurrentUserId())).toList();
    final adminMessages = messages.where((m) => !m.isFromUser(getCurrentUserId())).toList();
    
    final totalAttachments = messages.fold(0, (sum, msg) => sum + msg.attachments.length);
    
    return ChatStats(
      totalMessages: messages.length,
      userMessages: userMessages.length,
      adminMessages: adminMessages.length,
      totalAttachments: totalAttachments,
      firstMessageDate: messages.isNotEmpty ? messages.first.createdAt : null,
      lastMessageDate: messages.isNotEmpty ? messages.last.createdAt : null,
    );
  }
}

/// Chat statistics
class ChatStats {
  final int totalMessages;
  final int userMessages;
  final int adminMessages;
  final int totalAttachments;
  final DateTime? firstMessageDate;
  final DateTime? lastMessageDate;

  ChatStats({
    required this.totalMessages,
    required this.userMessages,
    required this.adminMessages,
    required this.totalAttachments,
    this.firstMessageDate,
    this.lastMessageDate,
  });

  /// Get conversation duration
  Duration? get conversationDuration {
    if (firstMessageDate == null || lastMessageDate == null) return null;
    return lastMessageDate!.difference(firstMessageDate!);
  }

  /// Get average messages per day
  double get averageMessagesPerDay {
    final duration = conversationDuration;
    if (duration == null || duration.inDays == 0) return 0.0;
    return totalMessages / duration.inDays;
  }
}
