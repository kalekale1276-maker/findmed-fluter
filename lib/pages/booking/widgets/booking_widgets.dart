import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/tailwind_extensions.dart';
import '../models/booking_models.dart';
import '../services/booking_services.dart';

/// UI components for booking functionality
class BookingWidgets {
  /// Build date selection button
  static Widget buildDateSelectionButton({
    required BuildContext context,
    required DateTime? selectedDate,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: context.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray100,
          foregroundColor: context.isDarkMode ? Colors.white : TailwindColors.gray900,
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TailwindRadius.lg),
            side: BorderSide(
              color: context.isDarkMode ? TailwindColors.gray600 : TailwindColors.gray300,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 18.w,
              color: context.isDarkMode ? Colors.white70 : TailwindColors.gray600,
            ),
            SizedBox(width: 8.w),
            Text(
              BookingServices.formatDateForDisplay(selectedDate),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build time selection button
  static Widget buildTimeSelectionButton({
    required BuildContext context,
    required TimeOfDay? selectedTime,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: context.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray100,
          foregroundColor: context.isDarkMode ? Colors.white : TailwindColors.gray900,
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TailwindRadius.lg),
            side: BorderSide(
              color: context.isDarkMode ? TailwindColors.gray600 : TailwindColors.gray300,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.access_time,
              size: 18.w,
              color: context.isDarkMode ? Colors.white70 : TailwindColors.gray600,
            ),
            SizedBox(width: 8.w),
            Text(
              BookingServices.formatTimeForDisplay(selectedTime),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build notes text field
  static Widget buildNotesField({
    required TextEditingController controller,
    required BuildContext context,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.isDarkMode ? TailwindColors.gray800 : Colors.white,
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
        border: Border.all(
          color: context.isDarkMode ? TailwindColors.gray600 : TailwindColors.gray300,
        ),
        boxShadow: [TailwindShadows.sm],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: BookingConstants.notesLabel,
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16.w),
          labelStyle: TextStyle(
            fontSize: 14.sp,
            color: context.isDarkMode ? Colors.white70 : TailwindColors.gray600,
          ),
        ),
        maxLines: 3,
        style: TextStyle(
          fontSize: 15.sp,
          color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
        ),
      ),
    );
  }

  /// Build submit button
  static Widget buildSubmitButton({
    required BuildContext context,
    required VoidCallback onPressed,
    required bool isLoading,
  }) {
    return Container(
      width: double.infinity,
      height: 48.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(TailwindRadius.lg),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    BookingConstants.bookAppointmentLabel,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  /// Build section header
  static Widget buildSectionHeader({
    required BuildContext context,
    required String title,
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14.sp,
              color: context.isDarkMode ? Colors.white70 : TailwindColors.gray600,
            ),
          ),
        ],
      ],
    );
  }

  /// Build date and time selection row
  static Widget buildDateTimeSelectionRow({
    required BuildContext context,
    required DateTime? selectedDate,
    required TimeOfDay? selectedTime,
    required VoidCallback onDatePressed,
    required VoidCallback onTimePressed,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.isDarkMode ? TailwindColors.gray800 : Colors.white,
        borderRadius: BorderRadius.circular(TailwindRadius.xl),
        border: Border.all(
          color: context.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray200,
        ),
        boxShadow: [TailwindShadows.md],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSectionHeader(
            context: context,
            title: BookingConstants.selectDateTimeTitle,
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              buildDateSelectionButton(
                context: context,
                selectedDate: selectedDate,
                onPressed: onDatePressed,
              ),
              SizedBox(width: 12.w),
              buildTimeSelectionButton(
                context: context,
                selectedTime: selectedTime,
                onPressed: onTimePressed,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build error message
  static Widget buildErrorMessage({
    required BuildContext context,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
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
  static Widget buildSuccessMessage({
    required BuildContext context,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
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

  /// Build facility info card
  static Widget buildFacilityInfoCard({
    required BuildContext context,
    required String facilityName,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(TailwindRadius.xl),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(24.w),
            ),
            child: Icon(
              Icons.local_hospital,
              size: 24.w,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booking for',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: context.isDarkMode ? Colors.white70 : TailwindColors.gray600,
                  ),
                ),
                Text(
                  facilityName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
                  ),
                ),
              ],
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

  /// Build loading indicator
  static Widget buildLoadingIndicator() {
    return SizedBox(
      width: 20.w,
      height: 20.w,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }
}
