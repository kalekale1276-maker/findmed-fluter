import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../services/auth.dart';
import '../../../../services/api.dart';
import '../../../../widgets/app_drawer.dart';
import 'models/favorites_models.dart';
import 'services/favorites_services.dart';
import 'widgets/favorites_widgets.dart';

/// Favorites Page - User's saved facilities
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // State
  FavoritesState _state = const FavoritesState();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeData();
    _setupAuthListener();
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

  void _initializeData() async {
    await _loadFavorites();
  }

  void _setupAuthListener() {
    final authService = AuthService.instance;
    authService.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    AuthService.instance.removeListener(_onAuthChanged);
    FavoritesWidgets.clearContext();
    super.dispose();
  }

  void _onAuthChanged() {
    _loadFavorites();
  }

  // State management
  void _updateState(FavoritesState newState) {
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
  Future<void> _loadFavorites() async {
    _setLoading(true);
    
    try {
      final favorites = await FavoritesServices.loadFavorites();
      _updateState(_state.copyWith(favorites: favorites));
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // Favorite operations
  Future<void> _removeFavorite(FavoriteFacility facility) async {
    try {
      final result = await FavoritesServices.removeFavorite(facility);
      
      if (result.success) {
        _showSuccessMessage(result.message!);
        await _loadFavorites(); // Reload list
      } else {
        _showErrorMessage(result.message!);
      }
    } catch (e) {
      _showErrorMessage('Failed to remove favorite: $e');
    }
  }

  Future<void> _addFavorite(FavoriteFacility facility) async {
    try {
      final result = await FavoritesServices.addFavorite(facility.rawData);
      
      if (result.success) {
        _showSuccessMessage(result.message!);
        await _loadFavorites(); // Reload list
      } else {
        _showErrorMessage(result.message!);
      }
    } catch (e) {
      _showErrorMessage('Failed to add favorite: $e');
    }
  }

  // Facility interactions
  Future<void> _onCall(FavoriteFacility facility) async {
    if (!facility.hasPhone) return;
    
    try {
      final success = await FavoritesServices.makePhoneCall(facility.phone);
      if (!success) {
        _showErrorMessage('Unable to make phone call');
      }
    } catch (e) {
      _showErrorMessage('Error making call: $e');
    }
  }

  Future<void> _onRate(FavoriteFacility facility) async {
    final rating = await FavoritesWidgets.showRatingDialog(context);
    
    if (rating != null) {
      try {
        final result = await FavoritesServices.rateFacility(facility.id, rating);
        
        if (result.success) {
          // Update facility with new rating
          final updatedFacility = FavoriteFacility(
            id: facility.id,
            name: facility.name,
            address: facility.address,
            phone: facility.phone,
            type: facility.type,
            viewsTotal: facility.viewsTotal,
            averageRating: result.newAverageRating ?? facility.averageRating,
            ratingCount: result.newRatingCount ?? facility.ratingCount,
            lastViewedAt: facility.lastViewedAt,
            rawData: facility.rawData,
          );
          
          // Update in state
          final updatedFavorites = _state.favorites.map((f) => 
            f.id == facility.id ? updatedFacility : f
          ).toList();
          
          _updateState(_state.copyWith(favorites: updatedFavorites));
          _showSuccessMessage('Rating submitted successfully');
        } else {
          _showErrorMessage(result.message!);
        }
      } catch (e) {
        _showErrorMessage('Failed to submit rating: $e');
      }
    }
  }

  Future<void> _onTap(FavoriteFacility facility) async {
    try {
      // Record facility view for analytics
      await FavoritesServices.recordFacilityView(facility.id);
      
      // Open in maps
      final success = await FavoritesServices.openInMaps(facility);
      if (!success) {
        _showErrorMessage('Unable to open maps');
      }
    } catch (e) {
      _showErrorMessage('Error opening maps: $e');
    }
  }

  // Sort and search
  void _onSortChanged(String sortOption) {
    _updateState(_state.updateSortOption(sortOption));
  }

  void _onSearchChanged(String query) {
    _updateState(_state.updateSearchQuery(query));
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
    FavoritesWidgets.setContext(context);
    
    return Scaffold(
      backgroundColor: context.isDarkMode ? TailwindColors.gray900 : TailwindColors.gray50,
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.add, size: 20.w),
        label: Text(FavoritesConstants.addFavoriteLabel),
        onPressed: _openAddFavoriteSheet,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadFavorites,
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            children: [
              _buildHeader(),
              FavoritesWidgets.buildSpacing(height: 8),
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            FavoritesConstants.pageTitle,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
            ),
          ),
        ),
        FavoritesWidgets.buildSortMenu(
          currentSort: _state.sortOption,
          onSortChanged: _onSortChanged,
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_state.isLoading) {
      return FavoritesWidgets.buildLoadingIndicator();
    }

    if (_state.error != null) {
      return FavoritesWidgets.buildErrorMessage(
        _state.error!,
        onRetry: _loadFavorites,
      );
    }

    final sortedFavorites = _state.sortedFavorites;

    if (sortedFavorites.isEmpty) {
      return FavoritesWidgets.buildEmptyState(
        message: FavoritesConstants.noFavoritesMessage,
        icon: Icons.favorite_border,
        actionLabel: 'Add Your First Favorite',
        onAction: _openAddFavoriteSheet,
      );
    }

    return Column(
      children: [
        // Statistics card
        if (_state.hasFavorites) ...[
          final stats = FavoritesServices.getFavoriteStatistics(_state.favorites);
          FavoritesWidgets.buildStatisticsCard(stats),
          FavoritesWidgets.buildSectionDivider(),
        ],
        
        // Favorites list
        Expanded(
          child: ListView.separated(
            itemCount: sortedFavorites.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final facility = sortedFavorites[index];
              
              return FavoritesWidgets.buildFavoriteItem(
                facility: facility,
                onTap: () => _onTap(facility),
                onCall: () => _onCall(facility),
                onRate: () => _onRate(facility),
                onRemove: () => _removeFavorite(facility),
              );
            },
          ),
        ),
      ],
    );
  }

  void _openAddFavoriteSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddFavoriteSheet(
        existing: _state.favorites,
        onAdd: (facility) async {
          await _addFavorite(facility);
        },
      ),
    );
  }
}
