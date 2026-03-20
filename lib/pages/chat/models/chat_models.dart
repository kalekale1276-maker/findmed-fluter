/// Models and constants for chat functionality
class ChatConstants {
  // UI labels
  static const String chatPageTitle = 'Support Chat';
  static const String noConversationsMessage = 'No conversations';
  static const String loadingMessage = 'Loading conversations...';
  static const String typeMessageHint = 'Type a message';
  static const String sendButtonLabel = 'Send';
  static const String copyConversationLabel = 'Copy conversation';
  static const String copySelectedLabel = 'Copy selected';
  static const String historyLabel = 'History';
  static const String closeLabel = 'Close';
  
  // Message status
  static const String adminSender = 'admin';
  static const String deviceSender = 'device';
  
  // Error messages
  static const String failedToSendMessage = 'Failed to send: ';
  static const String noMessagesToCopy = 'No messages to copy';
  static const String nothingToCopy = 'Nothing to copy';
  static const String copyFailed = 'Copy failed: ';
  static const String noMessagesSelected = 'No messages selected';
  static const String selectedMessagesEmpty = 'Selected messages empty';
  static const String conversationCopied = 'Conversation copied to clipboard';
  static const String selectedMessagesCopied = 'Selected messages copied';
  
  // Date formats
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yMdjm';
}

/// Chat message model
class ChatMessage {
  final String id;
  final String conversationId;
  final String from;
  final String text;
  final DateTime createdAt;
  final Map<String, dynamic> meta;
  final List<ChatAttachment> attachments;
  final bool isSelected;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.from,
    required this.text,
    required this.createdAt,
    this.meta = const {},
    this.attachments = const [],
    this.isSelected = false,
  });

  /// Create from API response
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final id = (json['_id'] ?? json['id']).toString();
    final conversationId = (json['conversationId'] ?? '').toString();
    final from = (json['from'] ?? '').toString();
    final text = (json['text'] ?? '').toString();
    final createdAtStr = json['createdAt'] ?? json['created_at'];
    final createdAt = DateTime.tryParse(createdAtStr.toString()) ?? DateTime.now();
    
    final meta = json['meta'] is Map ? Map<String, dynamic>.from(json['meta']) : {};
    final attachmentsRaw = json['attachments'] ?? meta['attachments'] ?? json['files'] ?? meta['files'];
    
    final attachments = <ChatAttachment>[];
    if (attachmentsRaw is List) {
      for (final att in attachmentsRaw) {
        if (att is Map) {
          attachments.add(ChatAttachment.fromJson(Map<String, dynamic>.from(att)));
        } else {
          attachments.add(ChatAttachment(url: att.toString()));
        }
      }
    }
    
    return ChatMessage(
      id: id,
      conversationId: conversationId,
      from: from,
      text: text,
      createdAt: createdAt,
      meta: meta,
      attachments: attachments,
    );
  }

  /// Check if message is from current user
  bool isFromUser(String? userId) {
    if (userId == null) return from.toLowerCase() != ChatConstants.adminSender;
    
    final userSenderId = userId.toString();
    if (from == userSenderId) return true;
    
    // Check meta fields
    final metaVals = [
      meta['userId'],
      meta['senderId'],
      meta['recipientId'],
      meta['deviceId'],
    ];
    
    for (final val in metaVals) {
      if (val != null && val.toString() == userSenderId) {
        return true;
      }
    }
    
    return false;
  }

  /// Get sender name for display
  String getSenderName() {
    final senderName = meta['fullName'] ?? meta['name'] ?? from;
    return senderName.toString().isNotEmpty ? senderName.toString() : from;
  }

  /// Get formatted time
  String getFormattedTime() {
    try {
      final now = DateTime.now();
      final difference = now.difference(createdAt);
      
      if (difference.inDays == 0) {
        return '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
      } else {
        return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
      }
    } catch (_) {
      return '';
    }
  }

  /// Get formatted full time
  String getFormattedFullTime() {
    try {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  /// Create copy with selection
  ChatMessage copyWith({bool? isSelected}) {
    return ChatMessage(
      id: id,
      conversationId: conversationId,
      from: from,
      text: text,
      createdAt: createdAt,
      meta: meta,
      attachments: attachments,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'from': from,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'meta': meta,
      'attachments': attachments.map((a) => a.toJson()).toList(),
    };
  }
}

/// Chat attachment model
class ChatAttachment {
  final String? url;
  final String? name;
  final String? filename;
  final String? caption;
  final String? title;
  final String? link;
  final String? path;

  ChatAttachment({
    this.url,
    this.name,
    this.filename,
    this.caption,
    this.title,
    this.link,
    this.path,
  });

  factory ChatAttachment.fromJson(Map<String, dynamic> json) {
    return ChatAttachment(
      url: json['url'] ?? json['link'] ?? json['path'],
      name: json['name'] ?? json['filename'] ?? json['url'],
      filename: json['filename'],
      caption: json['caption'],
      title: json['title'],
      link: json['link'],
      path: json['path'],
    );
  }

  /// Get display name
  String get displayName {
    return name ?? filename ?? url ?? 'Document';
  }

  /// Get launchable URL
  String? get launchableUrl {
    return url ?? link ?? path;
  }

  /// Check if attachment can be launched
  bool get canLaunch => launchableUrl != null;

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'name': name,
      'filename': filename,
      'caption': caption,
      'title': title,
      'link': link,
      'path': path,
    };
  }
}

/// Chat conversation model
class ChatConversation {
  final String id;
  final ChatMessage lastMessage;
  final int messageCount;
  final DateTime? lastActivity;

  ChatConversation({
    required this.id,
    required this.lastMessage,
    this.messageCount = 1,
    this.lastActivity,
  });

  factory ChatConversation.fromMessages(List<ChatMessage> messages) {
    if (messages.isEmpty) {
      throw ArgumentError('Messages list cannot be empty');
    }

    // Sort messages by date
    final sortedMessages = List<ChatMessage>.from(messages)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final latestMessage = sortedMessages.first;
    final conversationId = latestMessage.conversationId;

    return ChatConversation(
      id: conversationId,
      lastMessage: latestMessage,
      messageCount: messages.length,
      lastActivity: latestMessage.createdAt,
    );
  }

  /// Get display title
  String get displayTitle {
    final senderName = lastMessage.getSenderName();
    return 'Conversation $id${senderName.isNotEmpty ? ' - $senderName' : ''}';
  }

  /// Get preview text
  String get previewText {
    final text = lastMessage.text;
    if (text.length > 50) {
      return '${text.substring(0, 50)}...';
    }
    return text;
  }

  /// Get formatted last activity
  String get formattedLastActivity {
    return lastMessage.getFormattedFullTime();
  }
}

/// Chat state model
class ChatState {
  final List<ChatConversation> conversations;
  final List<ChatMessage> currentMessages;
  final bool isLoading;
  final String? error;
  final Set<String> selectedMessageIds;

  const ChatState({
    this.conversations = const [],
    this.currentMessages = const [],
    this.isLoading = true,
    this.error,
    this.selectedMessageIds = const {},
  });

  ChatState copyWith({
    List<ChatConversation>? conversations,
    List<ChatMessage>? currentMessages,
    bool? isLoading,
    String? error,
    Set<String>? selectedMessageIds,
  }) {
    return ChatState(
      conversations: conversations ?? this.conversations,
      currentMessages: currentMessages ?? this.currentMessages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedMessageIds: selectedMessageIds ?? this.selectedMessageIds,
    );
  }

  /// Check if there are any conversations
  bool get hasConversations => conversations.isNotEmpty;

  /// Check if there are any current messages
  bool get hasCurrentMessages => currentMessages.isNotEmpty;

  /// Check if any messages are selected
  bool get hasSelectedMessages => selectedMessageIds.isNotEmpty;

  /// Get selected count
  int get selectedCount => selectedMessageIds.length;

  /// Clear error
  ChatState clearError() => copyWith(error: null);

  /// Set loading
  ChatState setLoading(bool loading) => copyWith(isLoading: loading, error: null);

  /// Set error
  ChatState setError(String error) => copyWith(isLoading: false, error: error);

  /// Toggle message selection
  ChatState toggleMessageSelection(String messageId) {
    final newSelected = Set<String>.from(selectedMessageIds);
    if (newSelected.contains(messageId)) {
      newSelected.remove(messageId);
    } else {
      newSelected.add(messageId);
    }
    return copyWith(selectedMessageIds: newSelected);
  }

  /// Clear all selections
  ChatState clearSelections() => copyWith(selectedMessageIds: const {});
}

/// Chat action result
class ChatActionResult {
  final bool success;
  final String? message;

  ChatActionResult({
    required this.success,
    this.message,
  });

  factory ChatActionResult.success(String message) {
    return ChatActionResult(
      success: true,
      message: message,
    );
  }

  factory ChatActionResult.failure(String message) {
    return ChatActionResult(
      success: false,
      message: message,
    );
  }
}
