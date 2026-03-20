import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/tailwind_extensions.dart';
import '../models/saved_facilities_models.dart';
import '../services/saved_facilities_services.dart';

/// UI components for saved facilities functionality
class SavedFacilitiesWidgets {
  /// Build facility list item
  static Widget buildFacilityItem({
    required SavedFacility facility,
    required VoidCallback onTap,
    required VoidCallback? onCall,
    required VoidCallback? onDelete,
    bool showDistance = false,
    double? distance,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16.w),
        leading: _buildFacilityAvatar(facility),
        title: _buildFacilityTitle(facility),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4.h),
            _buildFacilitySubtitle(facility),
            if (showDistance && distance != null) ...[
              SizedBox(height: 4.h),
              _buildDistanceBadge(distance),
            ],
          ],
        ),
        trailing: _buildActionButtons(
          facility: facility,
          onCall: onCall,
          onDelete: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }

  /// Build facility avatar
  static Widget _buildFacilityAvatar(SavedFacility facility) {
    return CircleAvatar(
      backgroundColor: _getFacilityColor(facility).withOpacity(0.1),
      child: Icon(
        facility.facilityIcon,
        color: _getFacilityColor(facility),
        size: 24.w,
      ),
    );
  }

  /// Build facility title
  static Widget _buildFacilityTitle(SavedFacility facility) {
    return Row(
      children: [
        Expanded(
          child: Text(
            facility.displayName,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
            ),
          ),
        ),
        _buildTypeChip(facility),
      ],
    );
  }

  /// Build facility subtitle
  static Widget _buildFacilitySubtitle(SavedFacility facility) {
    return Text(
      facility.displayAddress,
      style: TextStyle(
        fontSize: 14.sp,
        color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
      ),
    );
  }

  /// Build type chip
  static Widget _buildTypeChip(SavedFacility facility) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: _getFacilityColor(facility).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _getFacilityColor(facility).withOpacity(0.3)),
      ),
      child: Text(
        facility.typeDisplayName,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: _getFacilityColor(facility),
        ),
      ),
    );
  }

  /// Build distance badge
  static Widget _buildDistanceBadge(double distance) {
    String distanceText;
    Color color;
    
    if (distance < 1) {
      distanceText = '${(distance * 1000).toStringAsFixed(0)} m';
      color = Colors.green;
    } else if (distance < 5) {
      distanceText = '${distance.toStringAsFixed(1)} km';
      color = Colors.orange;
    } else {
      distanceText = '${distance.toStringAsFixed(0)} km';
      color = Colors.red;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        distanceText,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  /// Build action buttons
  static Widget _buildActionButtons({
    required SavedFacility facility,
    required VoidCallback? onCall,
    required VoidCallback? onDelete,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (facility.hasPhone)
          IconButton(
            icon: const Icon(Icons.call),
            tooltip: SavedFacilitiesConstants.callTooltip,
            onPressed: onCall,
          ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          tooltip: SavedFacilitiesConstants.deleteTooltip,
          onPressed: onDelete,
        ),
      ],
    );
  }

  /// Build empty state
  static Widget buildEmptyState({
    String message = SavedFacilitiesConstants.noSavedFacilitiesMessage,
    IconData icon = Icons.location_off,
  }) {
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
              icon,
              size: 40.w,
              color: Theme.of(Get.context!).primaryColor,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Start saving facilities to build your healthcare network',
            style: TextStyle(
              fontSize: 14.sp,
              color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
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

  /// Build error state
  static Widget buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: TailwindColors.red50,
              borderRadius: BorderRadius.circular(40.w),
              border: Border.all(
                color: TailwindColors.red200,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.error_outline,
              size: 40.w,
              color: TailwindColors.red500,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            error,
            style: TextStyle(
              fontSize: 14.sp,
              color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build statistics card
  static Widget buildStatisticsCard({
    required FacilityStatistics stats,
  }) {
    if (!stats.hasData) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saved Facilities Statistics',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
              ),
            ),
            SizedBox(height: 12.h),
            _buildStatRow('Total Facilities', stats.totalFacilities.toString()),
            _buildStatRow('With Phone', stats.facilitiesWithPhone.toString()),
            _buildStatRow('With Location', stats.facilitiesWithCoordinates.toString()),
            _buildStatRow('With Email', stats.facilitiesWithEmail.toString()),
            _buildStatRow('With Website', stats.facilitiesWithWebsite.toString()),
            SizedBox(height: 8.h),
            Text(
              'By Type:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
              ),
            ),
            SizedBox(height: 4.h),
            ...stats.typeCounts.entries.map((entry) => 
              Padding(
                padding: EdgeInsets.only(left: 8.w, top: 2.h),
                child: Text(
                  '${entry.key}: ${entry.value}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build statistics row
  static Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
              ),
            ),
          ),
          Text(
            ': ',
            style: TextStyle(
              fontSize: 13.sp,
              color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build search bar
  static Widget buildSearchBar({
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    String hintText = 'Search facilities...',
  }) {
    return Container(
      margin: EdgeInsets.all(16.w),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(TailwindRadius.lg),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }

  /// Build filter chips
  static Widget buildFilterChips({
    required List<String> types,
    required String? selectedType,
    required ValueChanged<String?> onTypeSelected,
  }) {
    return Container(
      height: 50.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          FilterChip(
            label: const Text('All'),
            selected: selectedType == null,
            onSelected: (selected) {
              onTypeSelected(selected ? null : null);
            },
          ),
          SizedBox(width: 8.w),
          ...types.map((type) => Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: FilterChip(
              label: Text(type),
              selected: selectedType == type,
              onSelected: (selected) {
                onTypeSelected(selected ? type : null);
              },
            ),
          )),
        ],
      ),
    );
  }

  /// Build sort options
  static Widget buildSortOptions({
    required String sortBy,
    required ValueChanged<String> onSortChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: DropdownButtonFormField<String>(
        value: sortBy,
        decoration: InputDecoration(
          labelText: 'Sort by',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(TailwindRadius.md),
          ),
        ),
        items: const [
          DropdownMenuItem(value: 'name', child: Text('Name')),
          DropdownMenuItem(value: 'type', child: Text('Type')),
          DropdownMenuItem(value: 'address', child: Text('Address')),
          DropdownMenuItem(value: 'created', child: Text('Date Added')),
        ],
        onChanged: (value) {
          if (value != null) onSortChanged(value);
        },
      ),
    );
  }

  /// Build facility detail sheet
  static Widget buildFacilityDetailSheet({
    required SavedFacility facility,
    required VoidCallback onClose,
    required VoidCallback? onCall,
    required VoidCallback? onEmail,
    required VoidCallback? onWebsite,
    required VoidCallback? onMaps,
  }) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, controller) {
        return SingleChildScrollView(
          controller: controller,
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    _buildFacilityAvatar(facility),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            facility.displayName,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
                            ),
                          ),
                          _buildTypeChip(facility),
                        ],
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 16.h),
                
                // Contact information
                _buildContactSection(
                  facility: facility,
                  onCall: onCall,
                  onEmail: onEmail,
                  onWebsite: onWebsite,
                ),
                
                SizedBox(height: 16.h),
                
                // Location information
                _buildLocationSection(
                  facility: facility,
                  onMaps: onMaps,
                ),
                
                SizedBox(height: 16.h),
                
                // Description
                if (facility.description?.isNotEmpty == true) ...[
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    facility.description!,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray700,
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
                
                // Actions
                _buildActionButtonsRow(
                  facility: facility,
                  onCall: onCall,
                  onMaps: onMaps,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build contact section
  static Widget _buildContactSection({
    required SavedFacility facility,
    required VoidCallback? onCall,
    required VoidCallback? onEmail,
    required VoidCallback? onWebsite,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Information',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
          ),
        ),
        SizedBox(height: 8.h),
        if (facility.hasPhone)
          _buildContactItem(
            icon: Icons.phone,
            label: 'Phone',
            value: facility.formattedPhone,
            onTap: onCall,
          ),
        if (facility.hasEmail)
          _buildContactItem(
            icon: Icons.email,
            label: 'Email',
            value: facility.email!,
            onTap: onEmail,
          ),
        if (facility.hasWebsite)
          _buildContactItem(
            icon: Icons.language,
            label: 'Website',
            value: facility.website!,
            onTap: onWebsite,
          ),
      ],
    );
  }

  /// Build contact item
  static Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          children: [
            Icon(icon, size: 20.w, color: Theme.of(Get.context!).primaryColor),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 16.w),
          ],
        ),
      ),
    );
  }

  /// Build location section
  static Widget _buildLocationSection({
    required SavedFacility facility,
    required VoidCallback? onMaps,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          facility.address,
          style: TextStyle(
            fontSize: 14.sp,
            color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray700,
          ),
        ),
        if (facility.hasCoordinates) ...[
          SizedBox(height: 4.h),
          Text(
            'Lat: ${facility.latitude.toStringAsFixed(4)}, Lng: ${facility.longitude.toStringAsFixed(4)}',
            style: TextStyle(
              fontSize: 12.sp,
              color: Get.context!.isDarkMode ? Colors.white60 : TailwindColors.gray500,
            ),
          ),
          SizedBox(height: 8.h),
          ElevatedButton.icon(
            onPressed: onMaps,
            icon: const Icon(Icons.map),
            label: const Text('Open in Maps'),
          ),
        ],
      ],
    );
  }

  /// Build action buttons row
  static Widget _buildActionButtonsRow({
    required SavedFacility facility,
    required VoidCallback? onCall,
    required VoidCallback? onMaps,
  }) {
    return Row(
      children: [
        if (facility.hasPhone)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onCall,
              icon: const Icon(Icons.call),
              label: const Text('Call'),
            ),
          ),
        if (facility.hasPhone && facility.hasCoordinates)
          SizedBox(width: 12.w),
        if (facility.hasCoordinates)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onMaps,
              icon: const Icon(Icons.map),
              label: const Text('Maps'),
            ),
          ),
      ],
    );
  }

  /// Build delete confirmation dialog
  static Widget buildDeleteConfirmationDialog({
    required String facilityName,
    required VoidCallback onConfirm,
    required VoidCallback onCancel,
  }) {
    return AlertDialog(
      title: const Text('Remove Facility'),
      content: Text('Are you sure you want to remove "$facilityName" from your saved facilities?'),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: onConfirm,
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Remove'),
        ),
      ],
    );
  }

  /// Get facility color
  static Color _getFacilityColor(SavedFacility facility) {
    switch (facility.type.toLowerCase()) {
      case SavedFacilitiesConstants.hospitalType:
        return Colors.red;
      case SavedFacilitiesConstants.pharmacyType:
        return Colors.blue;
      case SavedFacilitiesConstants.clinicType:
        return Colors.green;
      case SavedFacilitiesConstants.laboratoryType:
        return Colors.purple;
      default:
        return Colors.grey;
    }
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
