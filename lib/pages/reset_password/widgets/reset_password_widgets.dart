import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/tailwind_extensions.dart';
import '../models/reset_password_models.dart';
import '../services/reset_password_services.dart';

/// UI components for reset password functionality
class ResetPasswordWidgets {
  /// Build email input field
  static Widget buildEmailInput({
    required TextEditingController controller,
    required bool isChecking,
    required VoidCallback? onChanged,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: ResetPasswordConstants.emailLabel,
        suffixIcon: isChecking
            ? SizedBox(
                width: 16.w,
                height: 16.w,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : null,
      ),
      keyboardType: TextInputType.emailAddress,
      onChanged: (_) => onChanged?.call(),
    );
  }

  /// Build email checking indicator
  static Widget buildEmailCheckingIndicator() {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          SizedBox(
            width: 16.w,
            height: 16.w,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 8.w),
          Text(ResetPasswordConstants.checkingEmailMessage),
        ],
      ),
    );
  }

  /// Build email status indicator
  static Widget buildEmailStatusIndicator({
    required bool emailExists,
    required bool isTelegramLinked,
  }) {
    if (emailExists && isTelegramLinked) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 16.w, color: Colors.green[700]),
            SizedBox(width: 6.w),
            Text(
              'Email found • Telegram linked',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.green[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    
    if (emailExists && !isTelegramLinked) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.orange[200]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info, size: 16.w, color: Colors.orange[700]),
            SizedBox(width: 6.w),
            Text(
              'Email found • Telegram not linked',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.orange[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    
    return const SizedBox.shrink();
  }

  /// Build action buttons row
  static Widget buildActionButtons({
    required VoidCallback? onConnectTelegram,
    required VoidCallback? onRequestAdmin,
    required VoidCallback? onRequestReset,
    required bool isLoading,
    required bool showTelegramOption,
    required bool showAdminOption,
  }) {
    if (showTelegramOption && !showAdminOption) {
      return ElevatedButton(
        onPressed: isLoading ? null : onRequestReset,
        child: Text(ResetPasswordConstants.requestResetLabel),
      );
    }
    
    if (showTelegramOption && showAdminOption) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: isLoading ? null : onConnectTelegram,
              child: Text(ResetPasswordConstants.connectTelegramLabel),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading ? null : onRequestAdmin,
              child: Text(ResetPasswordConstants.requestAdminLabel),
            ),
          ),
        ],
      );
    }
    
    return const SizedBox.shrink();
  }

  /// Build admin reset waiting section
  static Widget buildAdminResetWaitingSection({
    required VoidCallback? onGetDefaultPassword,
    required String? adminResetPassword,
    required bool isLoading,
    required VoidCallback? onCheckPassword,
    required String? passwordCheckMessage,
    required TextEditingController passwordController,
    required TextEditingController newPasswordController,
    required TextEditingController confirmPasswordController,
    required VoidCallback? onChangePassword,
    required bool newPasswordVisible,
    required bool confirmPasswordVisible,
    required VoidCallback? onToggleNewPasswordVisibility,
    required VoidCallback? onToggleConfirmPasswordVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ResetPasswordConstants.waitingAdminResetMessage,
          style: TextStyle(color: Colors.orange, fontSize: 14.sp),
        ),
        SizedBox(height: 12.h),
        ElevatedButton(
          onPressed: isLoading ? null : onGetDefaultPassword,
          child: Text(ResetPasswordConstants.getDefaultPasswordLabel),
        ),
        SizedBox(height: 12.h),
        if (adminResetPassword != null) ...[
          _buildDefaultPasswordSection(
            adminResetPassword: adminResetPassword,
            passwordController: passwordController,
            passwordCheckMessage: passwordCheckMessage,
            newPasswordController: newPasswordController,
            confirmPasswordController: confirmPasswordController,
            onChangePassword: onChangePassword,
            newPasswordVisible: newPasswordVisible,
            confirmPasswordVisible: confirmPasswordVisible,
            onToggleNewPasswordVisibility: onToggleNewPasswordVisibility,
            onToggleConfirmPasswordVisibility: onToggleConfirmPasswordVisibility,
          ),
        ] else ...[
          const CircularProgressIndicator(strokeWidth: 2),
        ],
      ],
    );
  }

  /// Build default password section
  static Widget _buildDefaultPasswordSection({
    required String adminResetPassword,
    required TextEditingController passwordController,
    required String? passwordCheckMessage,
    required TextEditingController newPasswordController,
    required TextEditingController confirmPasswordController,
    required VoidCallback? onChangePassword,
    required bool newPasswordVisible,
    required bool confirmPasswordVisible,
    required VoidCallback? onToggleNewPasswordVisibility,
    required VoidCallback? onToggleConfirmPasswordVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              ResetPasswordConstants.defaultPasswordMessage,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
            SelectableText(
              adminResetPassword,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                fontSize: 14.sp,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy),
              tooltip: ResetPasswordConstants.copyPasswordLabel,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: adminResetPassword));
                ScaffoldMessenger.of(Get.context).showSnackBar(
                  const SnackBar(content: Text(ResetPasswordConstants.passwordCopiedMessage)),
                );
              },
            ),
          ],
        ),
        SizedBox(height: 12.h),
        TextField(
          controller: passwordController,
          decoration: InputDecoration(
            labelText: ResetPasswordConstants.defaultPasswordLabel,
            suffixIcon: IconButton(
              icon: const Icon(Icons.visibility),
              onPressed: () {},
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: passwordCheckMessage == 'valid' ? Colors.green : Colors.grey,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: passwordCheckMessage == 'valid' ? Colors.green : Colors.blue,
              ),
            ),
          ),
        ),
        if (passwordCheckMessage == 'valid') ...[
          SizedBox(height: 8.h),
          TextField(
            controller: newPasswordController,
            decoration: InputDecoration(
              labelText: ResetPasswordConstants.newPasswordLabel,
              suffixIcon: IconButton(
                icon: Icon(newPasswordVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: onToggleNewPasswordVisibility,
              ),
            ),
            obscureText: !newPasswordVisible,
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: confirmPasswordController,
            decoration: InputDecoration(
              labelText: ResetPasswordConstants.confirmPasswordLabel,
              suffixIcon: IconButton(
                icon: Icon(confirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: onToggleConfirmPasswordVisibility,
              ),
            ),
            obscureText: !confirmPasswordVisible,
          ),
          SizedBox(height: 8.h),
          ElevatedButton(
            onPressed: onChangePassword,
            child: Text(ResetPasswordConstants.changeAndSavePasswordLabel),
          ),
        ],
      ],
    );
  }

  /// Build Telegram linking dialog
  static Widget buildTelegramLinkingDialog({
    required TextEditingController chatIdController,
    required bool isLinking,
    required String? linkError,
    required bool? chatIdAvailable,
    required bool chatIdChecking,
    required VoidCallback onCancel,
    required VoidCallback onLink,
  }) {
    return AlertDialog(
      title: const Text('Connect Telegram'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTelegramInstructions(),
          SizedBox(height: 6.h),
          _buildTelegramBotInfo(),
          SizedBox(height: 10.h),
          _buildChatIdInput(
            controller: chatIdController,
            linkError: linkError,
            chatIdAvailable: chatIdAvailable,
            chatIdChecking: chatIdChecking,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text(ResetPasswordConstants.cancelLabel),
        ),
        ElevatedButton(
          onPressed: isLinking || chatIdAvailable != true ? null : onLink,
          child: isLinking
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(ResetPasswordConstants.linkTelegramLabel),
        ),
      ],
    );
  }

  /// Build Telegram instructions
  static Widget _buildTelegramInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(ResetPasswordConstants.telegramInstruction1),
        SizedBox(height: 6.h),
        Text(ResetPasswordConstants.telegramInstruction2),
        SizedBox(height: 10.h),
        Text(ResetPasswordConstants.telegramInstruction3),
        SizedBox(height: 6.h),
      ],
    );
  }

  /// Build Telegram bot info
  static Widget _buildTelegramBotInfo() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SelectableText(
                ResetPasswordConstants.telegramBotLink,
                style: const TextStyle(color: Colors.blue),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy),
              tooltip: ResetPasswordConstants.copyLinkLabel,
              onPressed: () {
                Clipboard.setData(const ClipboardData(text: ResetPasswordConstants.telegramBotLink));
                ScaffoldMessenger.of(Get.context).showSnackBar(
                  const SnackBar(content: Text(ResetPasswordConstants.telegramLinkCopiedMessage)),
                );
              },
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            const Text('Bot username: '),
            SelectableText(
              ResetPasswordConstants.telegramBotUsername,
              style: const TextStyle(color: Colors.blue),
            ),
            IconButton(
              icon: const Icon(Icons.copy),
              tooltip: ResetPasswordConstants.copyUsernameLabel,
              onPressed: () {
                Clipboard.setData(const ClipboardData(text: ResetPasswordConstants.telegramBotUsername));
                ScaffoldMessenger.of(Get.context).showSnackBar(
                  const SnackBar(content: Text(ResetPasswordConstants.telegramUsernameCopiedMessage)),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  /// Build chat ID input
  static Widget _buildChatIdInput({
    required TextEditingController controller,
    required String? linkError,
    required bool? chatIdAvailable,
    required bool chatIdChecking,
  }) {
    return Column(
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: ResetPasswordConstants.telegramChatIdLabel,
            errorText: linkError,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: chatIdAvailable == null
                    ? Colors.grey
                    : chatIdAvailable == true
                        ? Colors.green
                        : Colors.red,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: chatIdAvailable == null
                    ? Colors.blue
                    : chatIdAvailable == true
                        ? Colors.green
                        : Colors.red,
              ),
            ),
          ),
          keyboardType: TextInputType.number,
        ),
        if (chatIdAvailable == true)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              ResetPasswordConstants.chatIdAvailableMessage,
              style: TextStyle(color: Colors.green),
            ),
          ),
        if (chatIdChecking)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      ],
    );
  }

  /// Build OTP input fields
  static Widget buildOtpFields({
    required TextEditingController otpController,
    required TextEditingController newPasswordController,
    required TextEditingController confirmPasswordController,
    required bool otpVisible,
    required bool newPasswordVisible,
    required bool confirmPasswordVisible,
    required VoidCallback? onToggleOtpVisibility,
    required VoidCallback? onToggleNewPasswordVisibility,
    required VoidCallback? onToggleConfirmPasswordVisibility,
  }) {
    return Column(
      children: [
        TextField(
          controller: otpController,
          decoration: InputDecoration(
            labelText: ResetPasswordConstants.otpLabel,
            suffixIcon: IconButton(
              icon: Icon(otpVisible ? Icons.visibility : Icons.visibility_off),
              onPressed: onToggleOtpVisibility,
            ),
          ),
          obscureText: !otpVisible,
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: newPasswordController,
          decoration: InputDecoration(
            labelText: ResetPasswordConstants.newPasswordLabel,
            suffixIcon: IconButton(
              icon: Icon(newPasswordVisible ? Icons.visibility : Icons.visibility_off),
              onPressed: onToggleNewPasswordVisibility,
            ),
          ),
          obscureText: !newPasswordVisible,
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: confirmPasswordController,
          decoration: InputDecoration(
            labelText: ResetPasswordConstants.confirmPasswordLabel,
            suffixIcon: IconButton(
              icon: Icon(confirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
              onPressed: onToggleConfirmPasswordVisibility,
            ),
          ),
          obscureText: !confirmPasswordVisible,
        ),
      ],
    );
  }

  /// Build OTP action buttons
  static Widget buildOtpActionButtons({
    required VoidCallback? onConfirm,
    required VoidCallback? onResend,
    required bool isLoading,
  }) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: isLoading ? null : onConfirm,
            child: Text(ResetPasswordConstants.confirmResetLabel),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: OutlinedButton(
            onPressed: isLoading ? null : onResend,
            child: Text(ResetPasswordConstants.resendOtpLabel),
          ),
        ),
      ],
    );
  }

  /// Build message list
  static Widget buildMessageList({
    required List<String> messages,
    required bool isViaTelegram,
  }) {
    return Column(
      children: messages.map((message) => Padding(
        padding: EdgeInsets.only(bottom: 4.h),
        child: AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
            decoration: BoxDecoration(
              color: isViaTelegram ? Colors.green[100] : Colors.red[100],
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              message,
              style: TextStyle(
                color: isViaTelegram ? Colors.green : Colors.red,
                fontSize: 14.sp,
              ),
            ),
          ),
        ),
      )).toList(),
    );
  }

  /// Build error message
  static Widget buildErrorMessage(String message) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 8.h),
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

  /// Build success message
  static Widget buildSuccessMessage(String message) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: TailwindColors.green50,
        borderRadius: BorderRadius.circular(TailwindRadius.md),
        border: Border.all(color: TailwindColors.green200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: TailwindColors.green500,
            size: 20.w,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: TailwindColors.green500,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build loading indicator
  static Widget buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  /// Build step indicator
  static Widget buildStepIndicator({
    required List<ResetPasswordStep> steps,
    required ResetPasswordStep currentStep,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reset Progress',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: steps.map((step) {
              final index = steps.indexOf(step);
              final isCompleted = index < steps.indexOf(currentStep);
              final isCurrent = step == currentStep;
              
              return Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 24.w,
                      height: 24.w,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Colors.green
                            : isCurrent
                                ? Theme.of(Get.context!).primaryColor
                                : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: isCompleted || isCurrent
                          ? Icon(
                              isCompleted ? Icons.check : Icons.circle,
                              size: 14.w,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    if (index < steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 2.h,
                          color: isCompleted ? Colors.green : Colors.grey[300],
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 8.h),
          Text(
            ResetPasswordServices.getStepDescription(currentStep),
            style: TextStyle(
              fontSize: 12.sp,
              color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
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

  /// Build section divider
  static Widget buildSectionDivider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16.h),
      height: 1.h,
      color: Get.context!.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray200,
    );
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
