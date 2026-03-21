import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/utils/tailwind_extensions.dart';
import 'models/chat_models.dart';
import 'services/chat_services.dart';
import 'widgets/chat_widgets.dart';

/// Chat Pages - Support chat functionality
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // State
  ChatState _state = const ChatState();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadConversations();
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
    super.dispose();
  }

  // State management
  void _updateState(ChatState newState) {
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

  // Data loading
  Future<void> _loadConversations() async {
    _setLoading(true);
    
    try {
      final conversations = await ChatServices.loadConversations();
      _updateState(_state.copyWith(conversations: conversations));
    } catch (e) {
      _setError('Failed to load conversations: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    ChatWidgets.setContext(context);
    
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
        ChatConstants.chatPageTitle,
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
    return RefreshIndicator(
      onRefresh: _loadConversations,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_state.isLoading) {
      return ChatWidgets.buildLoadingIndicator();
    }

    if (_state.error != null) {
      return Column(
        children: [
          ChatWidgets.buildErrorMessage(_state.error!),
          ChatWidgets.buildSpacing(),
          ElevatedButton(
            onPressed: _loadConversations,
            child: const Text('Retry'),
          ),
        ],
      );
    }

    if (!_state.hasConversations) {
      return ChatWidgets.buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      itemCount: _state.conversations.length,
      itemBuilder: (context, index) {
        final conversation = _state.conversations[index];
        return ChatWidgets.buildConversationItem(
          conversation: conversation,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ConversationPage(
                  conversationId: conversation.id,
                  conversationTitle: conversation.displayTitle,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Conversation Page - Individual chat conversation
class ConversationPage extends StatefulWidget {
  final String conversationId;
  final String conversationTitle;

  const ConversationPage({
    required this.conversationId,
    required this.conversationTitle,
    super.key,
  });

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // State
  ChatState _state = const ChatState();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _listController = ScrollController();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadConversation();
    _currentUserId = ChatServices.getCurrentUserId();
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
    _messageController.dispose();
    _listController.dispose();
    ChatWidgets.clearContext();
    super.dispose();
  }

  // State management
  void _updateState(ChatState newState) {
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

  // Data loading
  Future<void> _loadConversation() async {
    _setLoading(true);
    
    try {
      final messages = await ChatServices.loadConversation(widget.conversationId);
      _updateState(_state.copyWith(currentMessages: messages));
      
      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_listController.hasClients) {
          _listController.animateTo(
            _listController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      _setError('Failed to load conversation: $e');
    }
  }

  // Message actions
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Clear input immediately
    _messageController.clear();

    try {
      final result = await ChatServices.sendMessage(widget.conversationId, text);
      
      if (!result.success) {
        _showErrorMessage(result.message!);
        // Restore the message if sending failed
        _messageController.text = text;
      } else {
        // Reload conversation to show the new message
        await _loadConversation();
      }
    } catch (e) {
      _showErrorMessage('Failed to send message: $e');
      // Restore the message if sending failed
      _messageController.text = text;
    }
  }

  void _toggleMessageSelection(String messageId) {
    _updateState(_state.toggleMessageSelection(messageId));
  }

  void _clearSelections() {
    _updateState(_state.clearSelections());
  }

  Future<void> _copySelectedMessages() async {
    if (!_state.hasSelectedMessages) return;

    try {
      final result = await ChatServices.copySelectedMessages(
        _state.currentMessages,
        _state.selectedMessageIds,
      );

      if (result.success) {
        _showSuccessMessage(result.message!);
        _clearSelections();
      } else {
        _showErrorMessage(result.message!);
      }
    } catch (e) {
      _showErrorMessage('Copy failed: $e');
    }
  }

  Future<void> _copyConversation() async {
    try {
      final result = await ChatServices.copyConversation(_state.currentMessages);

      if (result.success) {
        _showSuccessMessage(result.message!);
      } else {
        _showErrorMessage(result.message!);
      }
    } catch (e) {
      _showErrorMessage('Copy failed: $e');
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
    ChatWidgets.setContext(context);
    
    return Scaffold(
      backgroundColor: context.isDarkMode ? TailwindColors.gray900 : TailwindColors.gray50,
      appBar: _state.hasSelectedMessages
          ? ChatWidgets.buildSelectionAppBar(
              selectedCount: _state.selectedCount,
              onClose: _clearSelections,
              onCopy: _copySelectedMessages,
            )
          : _buildAppBar(),
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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(widget.conversationTitle),
      actions: [
        IconButton(
          tooltip: ChatConstants.historyLabel,
          icon: const Icon(Icons.history),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ChatPage()),
            );
          },
        ),
        IconButton(
          tooltip: ChatConstants.copyConversationLabel,
          icon: const Icon(Icons.copy),
          onPressed: _copyConversation,
        ),
      ],
      backgroundColor: context.isDarkMode ? TailwindColors.gray800 : Colors.white,
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Expanded(
          child: _buildMessagesList(),
        ),
        ChatWidgets.buildMessageInput(
          controller: _messageController,
          onSend: _sendMessage,
          isLoading: _state.isLoading,
        ),
      ],
    );
  }

  Widget _buildMessagesList() {
    if (_state.isLoading) {
      return ChatWidgets.buildLoadingIndicator();
    }

    if (_state.error != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ChatWidgets.buildErrorMessage(_state.error!),
          ChatWidgets.buildSpacing(),
          ElevatedButton(
            onPressed: _loadConversation,
            child: const Text('Retry'),
          ),
        ],
      );
    }

    if (!_state.hasCurrentMessages) {
      return ChatWidgets.buildEmptyState(message: 'No messages in this conversation');
    }

    return ListView.builder(
      controller: _listController,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      itemCount: _state.currentMessages.length,
      itemBuilder: (context, index) {
        final message = _state.currentMessages[index];
        final isFromUser = message.isFromUser(_currentUserId);
        final isSelected = _state.selectedMessageIds.contains(message.id);

        return ChatWidgets.buildMessageBubble(
          message: message,
          isFromUser: isFromUser,
          isSelected: isSelected,
          onLongPress: () => _toggleMessageSelection(message.id),
          onTap: _state.hasSelectedMessages 
              ? () => _toggleMessageSelection(message.id)
              : null,
        );
      },
    );
  }
}
