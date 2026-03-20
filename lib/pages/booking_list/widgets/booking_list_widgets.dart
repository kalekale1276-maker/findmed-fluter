import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/tailwind_extensions.dart';
import '../models/booking_list_models.dart';

/// UI components for booking list functionality
class BookingListWidgets {
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
            BookingListConstants.loadingMessage,
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
  static Widget buildEmptyState() {
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
              Icons.event_busy,
              size: 40.w,
              color: Theme.of(Get.context!).primaryColor,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            BookingListConstants.noBookingsMessage,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'You haven\'t made any bookings yet',
            style: TextStyle(
              fontSize: 14.sp,
              color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
            ),
          ),
        ],
      ),
    );
  }

  /// Build booking card
  static Widget buildBookingCard({
    required BookingListItem booking,
    required VoidCallback? onCancel,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        color: Theme.of(Get.context!).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24.w),
                      ),
                      child: Icon(
                        Icons.local_hospital,
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
                            booking.facilityName,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 14.w,
                                color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                booking.formattedDate,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Icon(
                                Icons.access_time,
                                size: 14.w,
                                color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                booking.formattedTime,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _buildStatusChip(booking),
                  ],
                ),
                if (booking.notes != null && booking.notes!.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Get.context!.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray50,
                      borderRadius: BorderRadius.circular(TailwindRadius.md),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.note,
                          size: 14.w,
                          color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            booking.notes!,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Get.context!.isDarkMode ? Colors.white90 : TailwindColors.gray700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (booking.canCancel) ...[
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: onCancel,
                        icon: Icon(Icons.cancel, size: 16.w),
                        label: Text(BookingListConstants.cancelBookingLabel),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build status chip
  static Widget _buildStatusChip(BookingListItem booking) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: booking.statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: booking.statusColor.withOpacity(0.3),
        ),
      ),
      child: Text(
        booking.statusDisplay,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: booking.statusColor,
        ),
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

  /// Build success message
  static Widget buildSuccessMessage(String message) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(16.w),
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

  /// Build booking statistics card
  static Widget buildStatsCard(BookingStats stats) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(Get.context!).primaryColor.withOpacity(0.1),
            Theme.of(Get.context!).primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
        border: Border.all(
          color: Theme.of(Get.context!).primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Statistics',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Total', stats.total, Theme.of(Get.context!).primaryColor),
              ),
              Expanded(
                child: _buildStatItem('Pending', stats.pending, Colors.orange),
              ),
              Expanded(
                child: _buildStatItem('Confirmed', stats.confirmed, Colors.green),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Completed', stats.completed, Colors.blue),
              ),
              Expanded(
                child: _buildStatItem('Cancelled', stats.cancelled, Colors.red),
              ),
              Expanded(
                child: _buildStatItem('Upcoming', stats.upcoming, Colors.purple),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build statistics item
  static Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
          ),
        ),
      ],
    );
  }

  /// Build filter chip
  static Widget buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          color: isSelected
              ? Colors.white
              : Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray700,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Get.context!.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray100,
      selectedColor: color ?? Theme.of(Get.context!).primaryColor,
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TailwindRadius.md),
        side: BorderSide(
          color: isSelected
              ? (color ?? Theme.of(Get.context!).primaryColor)
              : Get.context!.isDarkMode ? TailwindColors.gray600 : TailwindColors.gray300,
        ),
      ),
    );
  }

  /// Build search bar
  static Widget buildSearchBar({
    required TextEditingController controller,
    required VoidCallback onChanged,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Get.context!.isDarkMode ? TailwindColors.gray800 : Colors.white,
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
        border: Border.all(
          color: Get.context!.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray200,
        ),
        boxShadow: [TailwindShadows.sm],
      ),
      child: TextField(
        controller: controller,
        onChanged: (_) => onChanged(),
        decoration: InputDecoration(
          hintText: 'Search bookings...',
          prefixIcon: Icon(Icons.search, size: 20.w),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(12.w),
          hintStyle: TextStyle(
            fontSize: 14.sp,
            color: Get.context!.isDarkMode ? Colors.white54 : TailwindColors.gray400,
          ),
        ),
        style: TextStyle(
          fontSize: 14.sp,
          color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
        ),
      ),
    );
  }

  /// Build spacing
  static Widget buildSpacing({double height = 16}) {
    return SizedBox(height: height.h);
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
