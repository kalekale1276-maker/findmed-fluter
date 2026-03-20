import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/utils/tailwind_extensions.dart';
import '../widgets/branding_widgets.dart';

/// Favorites Page - User's favorite facilities
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BrandingWidgets.buildBrandHeader(
        title: 'Favorites',
        subtitle: 'Your saved healthcare facilities',
        showBackButton: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: Center(
        child: BrandingWidgets.buildEmptyState(
          message: 'No Favorites Yet',
          subtitle: 'Start adding healthcare facilities to your favorites',
          icon: Icons.favorite_border,
          actionText: 'Browse Facilities',
          onAction: () {
            // Navigate to home page
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
