import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'models/community_models.dart';
import 'services/community_services.dart';
import 'widgets/community_widgets.dart';

/// Community Page - Community & Crowdsourcing features
class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // State
  bool _isLoading = true;
  CommunityStats? _stats;
  List<CommunityActivity> _recentActivity = [];
  List<CommunityFeature> _features = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadData();
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

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    CommunityWidgets.clearContext();
    super.dispose();
  }

  // Data loading
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load data in parallel
      final futures = await Future.wait([
        CommunityServices.getCommunityStats(),
        CommunityServices.getRecentActivity(),
      ]);
      
      _stats = futures[0] as CommunityStats;
      _recentActivity = futures[1] as List<CommunityActivity>;
      _features = CommunityServices.getCommunityFeatures();
      
    } catch (e) {
      debugPrint('Error loading community data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Navigation handlers
  void _navigateToFeature(CommunityFeature feature) {
    // This would navigate to the specific feature page
    // For now, show a placeholder dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature.title),
        content: Text('Navigate to ${feature.route}\n\nThis would open the ${feature.title.toLowerCase()} page.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showGuidelines() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Community Guidelines'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please follow our community guidelines:'),
              const SizedBox(height: 16),
              ...CommunityServices.getCommunityGuidelines().map((guideline) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(guideline.icon, size: 20, color: guideline.isImportant ? Colors.red : null),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            guideline.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(guideline.description),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showAllStats() {
    if (_stats == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detailed Statistics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailedStatItem('Total Contributions', _stats!.totalContributions),
            _buildDetailedStatItem('Active Contributors', _stats!.activeContributors),
            _buildDetailedStatItem('Facilities Added', _stats!.facilitiesAdded),
            _buildDetailedStatItem('Facilities Updated', _stats!.facilitiesUpdated),
            _buildDetailedStatItem('Forum Posts', _stats!.forumPosts),
            _buildDetailedStatItem('Pending Reviews', _stats!.pendingReviews),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStatItem(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    CommunityWidgets.setContext(context);
    
    return Scaffold(
      backgroundColor: context.isDarkMode ? TailwindColors.gray900 : TailwindColors.gray50,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _buildBody(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        CommunityConstants.pageTitle,
        style: TextStyle(
          fontSize: context.responsiveTextLg,
          fontWeight: FontWeight.bold,
          color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
        ),
      ),
      backgroundColor: context.isDarkMode ? TailwindColors.gray800 : Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(
        color: context.isDarkMode ? Colors.white : TailwindColors.gray700,
        size: context.isMobile ? 22.w : 24.w,
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.help_outline,
            size: context.isMobile ? 20.w : 22.w,
          ),
          onPressed: _showGuidelines,
          tooltip: 'Community Guidelines',
        ),
      ],
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.transparent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommunityWidgets.buildSpacing(height: 8),
            _buildHeaderSection(),
            CommunityWidgets.buildSpacing(height: 24),
            if (_stats != null) ...[
              CommunityWidgets.buildStatsCard(_stats!),
              CommunityWidgets.buildSpacing(height: 8),
            ],
            CommunityWidgets.buildSectionHeader(
              title: CommunityConstants.communityFeaturesTitle,
              subtitle: 'Choose how you\'d like to contribute to the community',
              onAction: _showAllStats,
              actionLabel: 'View Stats',
            ),
            CommunityWidgets.buildSpacing(height: 8),
            _buildFeaturesList(),
            CommunityWidgets.buildSpacing(height: 24),
            CommunityWidgets.buildSectionHeader(
              title: CommunityConstants.recentActivityTitle,
              subtitle: 'See what\'s happening in the community',
            ),
            CommunityWidgets.buildSpacing(height: 8),
            _buildRecentActivity(),
            CommunityWidgets.buildSpacing(height: 24),
            CommunityWidgets.buildGuidelinesSection(),
            CommunityWidgets.buildSpacing(height: 24),
            CommunityWidgets.buildActionButton(
              label: CommunityConstants.joinCommunityLabel,
              onPressed: () {
                // Navigate to community registration or onboarding
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Community features coming soon!')),
                );
              },
              icon: Icons.group_add,
            ),
            CommunityWidgets.buildSpacing(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(24.w),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.people,
            size: 48.w,
            color: Theme.of(context).primaryColor,
          ),
          CommunityWidgets.buildSpacing(height: 16),
          Text(
            'Welcome to FindMed Community',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
            ),
          ),
          CommunityWidgets.buildSpacing(height: 8),
          Text(
            'Help us build the most comprehensive healthcare database by contributing your knowledge and experiences.',
            style: TextStyle(
              fontSize: 16.sp,
              color: context.isDarkMode ? Colors.white90 : TailwindColors.gray700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList() {
    if (_isLoading) {
      return CommunityWidgets.buildLoadingIndicator();
    }

    return Column(
      children: _features.map((feature) => 
        CommunityWidgets.buildFeatureCard(
          feature: feature,
          onTap: () => _navigateToFeature(feature),
        )
      ).toList(),
    );
  }

  Widget _buildRecentActivity() {
    if (_isLoading) {
      return CommunityWidgets.buildLoadingIndicator();
    }

    if (_recentActivity.isEmpty) {
      return CommunityWidgets.buildEmptyState(
        title: 'No Recent Activity',
        subtitle: 'Be the first to contribute to the community!',
        icon: Icons.history,
      );
    }

    return Column(
      children: _recentActivity.map((activity) => 
        CommunityWidgets.buildActivityItem(activity)
      ).toList(),
    );
  }
}
