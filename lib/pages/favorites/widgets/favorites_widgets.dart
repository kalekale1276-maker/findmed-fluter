import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/tailwind_extensions.dart';
import '../../../../widgets/app_drawer.dart';
import '../models/favorites_models.dart';
import '../services/favorites_services.dart';

/// UI components for favorites functionality
class FavoritesWidgets {
  /// Build favorite list item
  static Widget buildFavoriteItem({
    required FavoriteFacility facility,
    required VoidCallback onTap,
    required VoidCallback onCall,
    required VoidCallback onRate,
    required VoidCallback onRemove,
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
                // Leading avatar with star
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        color: Theme.of(Get.context!).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24.w),
                      ),
                      child: Icon(
                        facility.typeIcon,
                        size: 24.w,
                        color: Theme.of(Get.context!).primaryColor,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 14.w,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 12.w),
                // Main content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        facility.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      // Metadata row
                      Row(
                        children: [
                          Text(
                            'ID: ${facility.id}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Get.context!.isDarkMode ? Colors.white54 : TailwindColors.gray500,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Icon(
                            Icons.remove_red_eye,
                            size: 14.w,
                            color: Get.context!.isDarkMode ? Colors.white54 : TailwindColors.gray500,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            facility.formattedViews,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Get.context!.isDarkMode ? Colors.white54 : TailwindColors.gray500,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Icon(
                            Icons.star,
                            size: 14.w,
                            color: Colors.amber,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            facility.formattedRating,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Get.context!.isDarkMode ? Colors.white54 : TailwindColors.gray500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Address and last viewed
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      facility.address,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
                      ),
                    ),
                    if (facility.lastViewedAt != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        'Last viewed: ${facility.formattedLastViewed}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Get.context!.isDarkMode ? Colors.white54 : TailwindColors.gray500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            // Action buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (facility.hasPhone)
                  IconButton(
                    icon: Icon(
                      Icons.call,
                      size: 20.w,
                      color: Colors.green,
                    ),
                    onPressed: onCall,
                    tooltip: 'Call',
                  ),
                IconButton(
                  icon: Icon(
                    Icons.thumb_up,
                    size: 20.w,
                    color: Colors.blue,
                  ),
                  onPressed: onRate,
                  tooltip: 'Rate',
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    size: 20.w,
                    color: Colors.red,
                  ),
                  onPressed: onRemove,
                  tooltip: 'Remove',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build sort menu
  static Widget buildSortMenu({
    required String currentSort,
    required ValueChanged<String> onSortChanged,
  }) {
    return PopupMenuButton<String>(
      onSelected: onSortChanged,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: FavoritesConstants.sortManual,
          child: Text(FavoritesConstants.sortManualLabel),
        ),
        PopupMenuItem(
          value: FavoritesConstants.sortMostViewed,
          child: Text(FavoritesConstants.sortMostViewedLabel),
        ),
        PopupMenuItem(
          value: FavoritesConstants.sortTopRated,
          child: Text(FavoritesConstants.sortTopRatedLabel),
        ),
        PopupMenuItem(
          value: FavoritesConstants.sortRecent,
          child: Text(FavoritesConstants.sortRecentLabel),
        ),
      ],
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Icon(
          Icons.sort,
          size: 22.w,
          color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray700,
        ),
      ),
    );
  }

  /// Build rating dialog
  static Future<int?> showRatingDialog(BuildContext context) async {
    return await showDialog<int>(
      context: context,
      builder: (context) {
        int selectedRating = FavoritesConstants.defaultRating;
        
        return AlertDialog(
          title: Text(
            FavoritesConstants.rateFacilityTitle,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(FavoritesConstants.maxRating, (index) {
                  final rating = index + 1;
                  return IconButton(
                    onPressed: () => setState(() => selectedRating = rating),
                    icon: Icon(
                      rating <= selectedRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32.w,
                    ),
                  );
                }),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text(FavoritesConstants.cancelLabel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(selectedRating),
              child: Text(FavoritesConstants.submitLabel),
            ),
          ],
        );
      },
    );
  }

  /// Build empty state
  static Widget buildEmptyState({
    String message = FavoritesConstants.noFavoritesMessage,
    IconData? icon,
    String? actionLabel,
    VoidCallback? onAction,
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
              icon ?? Icons.favorite_border,
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
            'Add facilities you frequently visit to access them quickly',
            style: TextStyle(
              fontSize: 14.sp,
              color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
            ),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: Icon(Icons.add, size: 18.w),
              label: Text(actionLabel),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(Get.context!).primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
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
            'Loading favorites...',
            style: TextStyle(
              fontSize: 16.sp,
              color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
            ),
          ),
        ],
      ),
    );
  }

  /// Build error message
  static Widget buildErrorMessage(String error, {VoidCallback? onRetry}) {
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
              fontSize: 18.sp,
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
          if (onRetry != null) ...[
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh, size: 18.w),
              label: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build statistics card
  static Widget buildStatisticsCard(Map<String, dynamic> stats) {
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
            'Favorites Statistics',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total', stats['total'].toString(), Theme.of(Get.context!).primaryColor),
              _buildStatItem('Hospitals', stats['hospitals'].toString(), Colors.red),
              _buildStatItem('Pharmacies', stats['pharmacies'].toString(), Colors.green),
            ],
          ),
          if (stats['averageRating'] > 0) ...[
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Colors.amber, size: 16.w),
                SizedBox(width: 4.w),
                Text(
                  'Average Rating: ${stats['averageRating'].toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Build statistics item
  static Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
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

  /// Build spacing
  static Widget buildSpacing({double height = 16}) {
    return SizedBox(height: height.h);
  }

  /// Build section divider
  static Widget buildSectionDivider() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      height: 1.h,
      color: Get.context!.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray200,
    );
  }
}

/// Add Favorite Sheet Widget
class AddFavoriteSheet extends StatefulWidget {
  final List<FavoriteFacility>? existing;
  final Future<void> Function(FavoriteFacility) onAdd;

  const AddFavoriteSheet({
    this.existing,
    required this.onAdd,
  });

  @override
  State<AddFavoriteSheet> createState() => _AddFavoriteSheetState();
}

class _AddFavoriteSheetState extends State<AddFavoriteSheet> {
  bool _loading = true;
  String? _error;
  List<FavoriteFacility> _facilities = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadFacilities();
  }

  Future<void> _loadFacilities() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    
    try {
      final result = await FavoritesServices.searchFacilities(query: _searchQuery);
      
      if (mounted) {
        setState(() {
          if (result.isLoading) {
            _loading = true;
          } else if (result.error != null) {
            _error = result.error!;
            _loading = false;
          } else {
            _facilities = result.facilities;
            _loading = false;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to fetch facilities';
          _loading = false;
        });
      }
    }
  }

  Future<void> _handleAdd(FavoriteFacility facility) async {
    try {
      await widget.onAdd(facility);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(FavoritesConstants.addedToFavoritesMessage)),
        );
        setState(() {}); // Refresh UI
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add: $e')),
        );
      }
    }
  }

  bool _isFavorited(FavoriteFacility facility) {
    final existing = widget.existing ?? [];
    return existing.any((f) => f.id == facility.id);
  }

  List<FavoriteFacility> get _filteredFacilities {
    if (_searchQuery.isEmpty) return _facilities;
    
    return _facilities.where((facility) => facility.matchesQuery(_searchQuery)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredFacilities;

    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    FavoritesConstants.addFavoriteSheetTitle,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, size: 22.w),
                ),
              ],
            ),
            FavoritesWidgets.buildSpacing(height: 8),
            
            // Search field
            TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, size: 20.w),
                hintText: FavoritesConstants.searchHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(TailwindRadius.lg),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
                _loadFacilities(); // Reload with search
              },
            ),
            FavoritesWidgets.buildSpacing(height: 8),
            
            // Content
            Expanded(
              child: _buildContent(filtered),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(List<FavoriteFacility> filtered) {
    if (_loading) {
      return FavoritesWidgets.buildLoadingIndicator();
    }

    if (_error != null) {
      return FavoritesWidgets.buildErrorMessage(
        _error!,
        onRetry: _loadFacilities,
      );
    }

    if (filtered.isEmpty) {
      return FavoritesWidgets.buildEmptyState(
        message: 'No facilities found',
        icon: Icons.search_off,
      );
    }

    return ListView.separated(
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final facility = filtered[index];
        final isFavorited = _isFavorited(facility);

        return ListTile(
          leading: Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(
              facility.typeIcon,
              size: 20.w,
              color: Theme.of(context).primaryColor,
            ),
          ),
          title: Text(
            facility.name,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
            ),
          ),
          subtitle: Text(
            facility.address,
            style: TextStyle(
              fontSize: 13.sp,
              color: context.isDarkMode ? Colors.white70 : TailwindColors.gray600,
            ),
          ),
          trailing: IconButton(
            icon: Icon(
              isFavorited ? Icons.star : Icons.star_border,
              color: isFavorited ? Colors.amber : null,
            ),
            onPressed: isFavorited ? null : () => _handleAdd(facility),
          ),
          onTap: isFavorited ? null : () => _handleAdd(facility),
        );
      },
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
