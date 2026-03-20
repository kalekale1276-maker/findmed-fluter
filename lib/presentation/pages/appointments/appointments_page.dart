import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/themes/app_theme.dart';

class AppointmentsPage extends StatelessWidget {
  const AppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Add new appointment
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: FilterChip(
                      label: const Text('Upcoming'),
                      onSelected: (selected) {
                        // TODO: Filter upcoming appointments
                      },
                      selected: true,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: FilterChip(
                      label: const Text('Completed'),
                      onSelected: (selected) {
                        // TODO: Filter completed appointments
                      },
                      selected: false,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: FilterChip(
                      label: const Text('Cancelled'),
                      onSelected: (selected) {
                        // TODO: Filter cancelled appointments
                      },
                      selected: false,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: ListView.builder(
                  itemCount: 5, // TODO: Replace with actual data
                  itemBuilder: (context, index) {
                    return _AppointmentCard(
                      doctorName: 'Dr. ${index % 2 == 0 ? "Smith" : "Johnson"}',
                      facility: 'City Hospital',
                      date: '2024-0${index + 1}-15',
                      time: '${10 + index}:00 AM',
                      status: index == 0 ? 'Confirmed' : 'Pending',
                      onTap: () {
                        // TODO: Navigate to appointment details
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final String doctorName;
  final String facility;
  final String date;
  final String time;
  final String status;
  final VoidCallback onTap;

  const _AppointmentCard({
    required this.doctorName,
    required this.facility,
    required this.date,
    required this.time,
    required this.status,
    required this.onTap,
  });

  Color get _statusColor {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      doctorName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onBackground,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: _statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(
                    Icons.local_hospital,
                    size: 16.w,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    facility,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16.w,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Icon(
                    Icons.access_time,
                    size: 16.w,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
