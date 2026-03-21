import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/tailwind_extensions.dart';
import '../models/chat_models.dart';
import '../services/chat_services.dart';

/// UI components for chat functionality
class ChatWidgets {
  /// Build conversation list item
  static Widget buildConversationItem({
    required ChatConversation conversation,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Get.context!.isDarkMode ? TailwindColors.gray800 : Colors.white,
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
        border: Border.all(
          color: Get.context!.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray200,
        ),
        boxShadow: [TailwindShadows.sm],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TailwindRadius.lg),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: Theme.of(Get.context!).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24.w),
                  ),
                  child: Icon(
                    Icons.chat,
                    size: 24.w,
                    color: Theme.of(Get.context!).primaryColor,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conversation.displayTitle,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        conversation.previewText,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      conversation.formattedLastActivity,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Get.context!.isDarkMode ? Colors.white54 : TailwindColors.gray500,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    if (conversation.messageCount > 1)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: Theme.of(Get.context!).primaryColor,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          '${conversation.messageCount}',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build message bubble
  static Widget buildMessageBubble({
    required ChatMessage message,
    required bool isFromUser,
    required bool isSelected,
    required VoidCallback? onLongPress,
    required VoidCallback? onTap,
  }) {
    final mainAlign = isFromUser ? MainAxisAlignment.start : MainAxisAlignment.end;
    final bubbleColor = isFromUser 
        ? (Get.context!.isDarkMode ? TailwindColors.gray600 : TailwindColors.gray200)
        : Theme.of(Get.context!).primaryColor.withOpacity(0.2);
    
    final textColor = isFromUser
        ? (Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900)
        : Theme.of(Get.context!).primaryColor;

    final radius = isFromUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          );

    return Row(
      mainAxisAlignment: mainAlign,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isFromUser) ...[
          _buildUserAvatar(message),
        ],
        GestureDetector(
          onLongPress: onLongPress,
          onTap: onTap,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(Get.context!).size.width * 0.75,
            ),
            margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 4.w),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: isSelected ? Colors.yellow.withOpacity(0.3) : bubbleColor,
              borderRadius: radius,
              border: isSelected 
                  ? Border.all(color: Colors.orange, width: 2)
                  : null,
            ),
            child: Column(
              crossAxisAlignment: isFromUser ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Text(
                  message.text,
                  textAlign: isFromUser ? TextAlign.left : TextAlign.right,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: textColor,
                    height: 1.4,
                  ),
                ),
                if (message.attachments.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  ...message.attachments.map((attachment) => 
                    _buildAttachment(attachment, isFromUser)
                  ),
                ],
                SizedBox(height: 6.h),
                Text(
                  message.getFormattedTime(),
                  textAlign: isFromUser ? TextAlign.left : TextAlign.right,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: isFromUser ? Colors.black54 : textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!isFromUser) ...[
          _buildAdminAvatar(message),
        ],
      ],
    );
  }

  /// Build user avatar
  static Widget _buildUserAvatar(ChatMessage message) {
    return Padding(
      padding: EdgeInsets.only(left: 12.w, right: 8.w, top: 6.h),
      child: CircleAvatar(
        radius: 14.r,
        backgroundColor: Theme.of(Get.context!).primaryColor,
        child: Text(
          message.from.isNotEmpty ? message.from[0].toUpperCase() : 'U',
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Build admin avatar
  static Widget _buildAdminAvatar(ChatMessage message) {
    return Padding(
      padding: EdgeInsets.only(left: 8.w, right: 12.w, top: 6.h),
      child: CircleAvatar(
        radius: 14.r,
        backgroundColor: Get.context!.isDarkMode ? TailwindColors.gray600 : TailwindColors.gray300,
        child: Text(
          message.from.isNotEmpty ? message.from[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: 12.sp,
            color: Get.context!.isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Build attachment widget
  static Widget _buildAttachment(ChatAttachment attachment, bool isFromUser) {
    final textColor = isFromUser
        ? (Get.context!.isDarkMode ? Colors.white70 : Colors.black54)
        : Theme.of(Get.context!).primaryColor;

    return Padding(
      padding: EdgeInsets.only(top: 4.h),
      child: GestureDetector(
        onTap: attachment.canLaunch ? () async {
          await ChatServices.launchAttachment(attachment);
        } : null,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: (Get.context!.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray100)
                .withOpacity(0.5),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: textColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.insert_drive_file,
                size: 16.w,
                color: textColor,
              ),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(
                  attachment.displayName,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: textColor,
                    decoration: attachment.canLaunch ? TextDecoration.underline : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build message input field
  static Widget buildMessageInput({
    required TextEditingController controller,
    required VoidCallback onSend,
    bool isLoading = false,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Get.context!.isDarkMode ? TailwindColors.gray800 : Colors.white,
        border: Border(
          top: BorderSide(
            color: Get.context!.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray200,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: ChatConstants.typeMessageHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                    borderSide: BorderSide(
                      color: Get.context!.isDarkMode ? TailwindColors.gray600 : TailwindColors.gray300,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                    borderSide: BorderSide(
                      color: Theme.of(Get.context!).primaryColor,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Get.context!.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray50,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                ),
                style: TextStyle(
                  fontSize: 15.sp,
                  color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(Get.context!).primaryColor,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: IconButton(
                onPressed: isLoading ? null : onSend,
                icon: isLoading
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(
                        Icons.send,
                        size: 20.w,
                        color: Colors.white,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build loading indicator
  static Widget buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(Get.context!).primaryColor,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading...',
            style: TextStyle(
              fontSize: 16.sp,
              color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
            ),
          ),
        ],
      ),
    );
  }

  /// Build empty state
  static Widget buildEmptyState({String message = 'No conversations yet'}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: Theme.of(Get.context!).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40.w),
              border: Border.all(
                color: Theme.of(Get.context!).primaryColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 40.w,
              color: Theme.of(Get.context!).primaryColor,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Start a conversation to see messages here',
            style: TextStyle(
              fontSize: 14.sp,
              color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
            ),
          ),
        ],
      ),
    );
  }

  /// Build error message
  static Widget buildErrorMessage(String message) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: TailwindColors.red50,
        borderRadius: BorderRadius.circular(TailwindRadius.md),
        border: Border.all(color: TailwindColors.red200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: TailwindColors.red500,
            size: 20.w,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: TailwindColors.red500,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build spacing
  static Widget buildSpacing({double height = 16}) {
    return SizedBox(height: height.h);
  }

  /// Build selection app bar
  static PreferredSizeWidget buildSelectionAppBar({
    required int selectedCount,
    required VoidCallback onClose,
    required VoidCallback onCopy,
  }) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: onClose,
      ),
      title: Text('$selectedCount selected'),
      actions: [
        IconButton(
          tooltip: ChatConstants.copySelectedLabel,
          icon: const Icon(Icons.copy),
          onPressed: onCopy,
        ),
      ],
      backgroundColor: Get.context!.isDarkMode ? TailwindColors.gray800 : Colors.white,
    );
  }

  /// Set context for use in static methods
  static void setContext(BuildContext context) {
    Get.setContext(context);
  }

  /// Clear context when widget is disposed
  static void clearContext() {
    Get.clearContext();
  }
}

/// Helper class to get context
class Get {
  static BuildContext? _context;
  
  static BuildContext get context {
    if (_context == null) {
      throw Exception('Context not set. Call setContext() first.');
    }
    return _context!;
  }
  
  static void setContext(BuildContext context) {
    _context = context;
  }
  
  static void clearContext() {
    _context = null;
  }
}
