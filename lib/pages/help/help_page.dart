import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'models/help_models.dart';
import 'services/help_services.dart';
import 'widgets/help_widgets.dart';

/// Help Page - Comprehensive help and support
class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // State
  HelpState _state = const HelpState();
  final TextEditingController _searchController = TextEditingController();
  
  // Data
  late List<HelpSection> _allSections;
  late List<FAQ> _allFAQs;
  late List<HelpCategory> _categories;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeData();
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

  void _initializeData() {
    _allSections = HelpServices.getAllHelpSections();
    _allFAQs = HelpServices.getAllFAQs();
    _categories = HelpServices.getHelpCategories();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _searchController.dispose();
    HelpWidgets.clearContext();
    super.dispose();
  }

  // State management
  void _updateState(HelpState newState) {
    setState(() {
      _state = newState;
    });
  }

  // Search functionality
  void _toggleSearch() {
    final newState = _state.toggleSearch();
    _updateState(newState);
    
    if (!newState.isSearching) {
      _searchController.clear();
    }
  }

  void _onSearchChanged(String query) {
    final searchResult = HelpServices.searchHelpContent(query);
    _updateState(_state.updateSearchQuery(query, searchResult));
    
    // Record search analytics
    if (query.isNotEmpty) {
      HelpServices.recordSearchQuery(query);
    }
  }

  // Category filtering
  void _onCategorySelected(String? categoryId) {
    _updateState(_state.copyWith(selectedCategory: categoryId));
    
    // Record category view analytics
    if (categoryId != null) {
      HelpServices.recordHelpView(categoryId: categoryId);
    }
  }

  // Section expansion
  void _onSectionExpansionChanged(String sectionId) {
    final newState = _state.toggleSectionExpansion(sectionId);
    _updateState(newState);
    
    // Record section view analytics
    if (newState.expandedSections.contains(sectionId)) {
      HelpServices.recordHelpView(sectionId: sectionId);
    }
  }

  // FAQ interaction
  void _onFAQTap(FAQ faq) {
    // Record FAQ view analytics
    HelpServices.recordHelpView(faqId: faq.id);
    
    // Show FAQ details (could navigate to detail page or show dialog)
    _showFAQDialog(faq);
  }

  // Contact methods
  Future<void> _onContactTap(ContactMethod method) async {
    // Record contact click analytics
    HelpServices.recordContactClick(method.id);
    
    // Launch contact method
    final success = await HelpServices.launchUrl(method.url);
    if (!success) {
      _showErrorMessage('Could not open ${method.name}');
    }
  }

  // UI helpers
  void _showFAQDialog(FAQ faq) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(faq.question),
        content: SingleChildScrollView(
          child: Text(faq.answer),
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
    HelpWidgets.setContext(context);
    
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
      title: HelpWidgets.buildSearchBar(
        controller: _searchController,
        isSearching: _state.isSearching,
        onToggleSearch: _toggleSearch,
        onSearchChanged: _onSearchChanged,
      ),
      backgroundColor: context.isDarkMode ? TailwindColors.gray800 : Colors.white,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(
        color: context.isDarkMode ? Colors.white : TailwindColors.gray700,
        size: context.isMobile ? 22.w : 24.w,
      ),
      actions: [
        IconButton(
          icon: Icon(_state.isSearching ? Icons.close : Icons.search),
          onPressed: _toggleSearch,
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
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HelpWidgets.buildSpacing(height: 8),
          
          // Search hint
          HelpWidgets.buildSearchHint(_state.searchQuery),
          
          // Category selector
          HelpWidgets.buildCategorySelector(
            categories: _categories,
            selectedCategory: _state.selectedCategory,
            onCategorySelected: _onCategorySelected,
          ),
          
          HelpWidgets.buildSpacing(height: 16),
          
          // Main content
          Expanded(
            child: _buildContent(),
          ),
          
          HelpWidgets.buildSpacing(height: 12),
          
          // Contact section
          HelpWidgets.buildContactSection(),
          
          HelpWidgets.buildSpacing(height: 16),
          
          // Version info
          HelpWidgets.buildVersionInfo(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    // Get filtered content
    final searchResult = _state.searchResult;
    final filteredSections = _getFilteredSections();
    final filteredFAQs = _getFilteredFAQs();
    
    if (searchResult != null && !searchResult.hasResults) {
      return HelpWidgets.buildEmptyState();
    }
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Help sections
          if (filteredSections.isNotEmpty) ...[
            HelpWidgets.buildSectionHeader(
              title: 'Help Topics',
              subtitle: 'Browse through our comprehensive help guides',
            ),
            ...filteredSections.map((section) => 
              HelpWidgets.buildHelpSectionTile(
                section: section,
                isExpanded: _state.expandedSections.contains(section.id),
                onExpansionChanged: () => _onSectionExpansionChanged(section.id),
                searchQuery: _state.searchQuery,
              ),
            ),
            HelpWidgets.buildSectionDivider(),
          ],
          
          // FAQs
          HelpWidgets.buildSectionHeader(
            title: HelpConstants.faqTitle,
            subtitle: 'Frequently asked questions',
          ),
          if (filteredFAQs.isNotEmpty) ...[
            ...filteredFAQs.map((faq) => 
              HelpWidgets.buildFAQTile(
                faq: faq,
                onTap: () => _onFAQTap(faq),
                searchQuery: _state.searchQuery,
              ),
            ),
          ] else ...[
            HelpWidgets.buildEmptyState(
              message: 'No FAQs found',
              icon: Icons.question_answer,
            ),
          ],
        ],
      ),
    );
  }

  List<HelpSection> _getFilteredSections() {
    List<HelpSection> sections = _allSections;
    
    // Filter by category if selected
    if (_state.selectedCategory != null) {
      sections = sections.where((section) => section.category == _state.selectedCategory).toList();
    }
    
    // Filter by search query
    if (_state.searchResult != null) {
      sections = _state.searchResult!.sections;
    }
    
    return sections;
  }

  List<FAQ> _getFilteredFAQs() {
    List<FAQ> faqs = _allFAQs;
    
    // Filter by category if selected
    if (_state.selectedCategory != null) {
      faqs = faqs.where((faq) => faq.category == _state.selectedCategory).toList();
    }
    
    // Filter by search query
    if (_state.searchResult != null) {
      faqs = _state.searchResult!.faqs;
    }
    
    return faqs;
  }
}
