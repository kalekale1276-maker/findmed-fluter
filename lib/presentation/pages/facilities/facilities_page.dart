import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/themes/app_theme.dart';

class FacilitiesPage extends StatelessWidget {
  const FacilitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Healthcare Facilities'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.h),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search facilities...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: FilterChip(
                      label: const Text('Hospitals'),
                      onSelected: (selected) {
                        // TODO: Filter by hospitals
                      },
                      selected: false,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: FilterChip(
                      label: const Text('Clinics'),
                      onSelected: (selected) {
                        // TODO: Filter by clinics
                      },
                      selected: false,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: FilterChip(
                      label: const Text('Pharmacies'),
                      onSelected: (selected) {
                        // TODO: Filter by pharmacies
                      },
                      selected: false,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: ListView.builder(
                  itemCount: 10, // TODO: Replace with actual data
                  itemBuilder: (context, index) {
                    return _FacilityCard(
                      name: 'City Hospital ${index + 1}',
                      type: index % 2 == 0 ? 'Hospital' : 'Clinic',
                      distance: '${(index + 1) * 0.5} km',
                      rating: 4.5 - (index * 0.1),
                      onTap: () {
                        // TODO: Navigate to facility details
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

class _FacilityCard extends StatelessWidget {
  final String name;
  final String type;
  final String distance;
  final double rating;
  final VoidCallback onTap;

  const _FacilityCard({
    required this.name,
    required this.type,
    required this.distance,
    required this.rating,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.local_hospital,
                  color: AppColors.primary,
                  size: 30.w,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onBackground,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      type,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16.w,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          distance,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Icon(
                          Icons.star,
                          size: 16.w,
                          color: Colors.amber,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16.w,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
