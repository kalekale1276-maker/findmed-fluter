import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'models/legal_models.dart';
import 'services/legal_services.dart';
import 'widgets/legal_widgets.dart';

/// Legal Page - About & Legal information
class LegalPage extends StatefulWidget {
  const LegalPage({super.key});

  @override
  State<LegalPage> createState() => _LegalPageState();
}

class _LegalPageState extends State<LegalPage> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // State
  LegalState _state = LegalState(sections: LegalServices.getAllLegalSections());

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
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
    LegalWidgets.clearContext();
    super.dispose();
  }

  // State management
  void _updateState(LegalState newState) {
    setState(() {
      _state = newState;
    });
  }

  // Section expansion
  void _onSectionTap(LegalSection section) {
    // Record analytics
    LegalServices.recordContentView(section.id);
    
    // Toggle expansion
    final newState = _state.toggleSectionExpansion(section.id);
    _updateState(newState);
  }

  // Contact actions
  Future<void> _onEmailTap() async {
    final success = await LegalServices.sendEmailToDeveloper();
    if (!success) {
      _showErrorMessage('Could not open email app');
    }
  }

  Future<void> _onWebsiteTap() async {
    final success = await LegalServices.openDeveloperWebsite();
    if (!success) {
      _showErrorMessage('Could not open website');
    }
  }

  // UI helpers
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
    LegalWidgets.setContext(context);
    
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
        LegalConstants.pageTitle,
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
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App header
          LegalWidgets.buildAppHeader(),
          LegalWidgets.buildSpacing(height: 24),
          
          // Legal sections
          ..._state.sections.map((section) => 
            AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: _slideAnimation.value,
                  child: LegalWidgets.buildLegalSectionCard(
                    section: section,
                    isExpanded: section.isExpanded,
                    onTap: () => _onSectionTap(section),
                  ),
                );
              },
            ),
          ),
          
          LegalWidgets.buildSpacing(height: 24),
          
          // Version info card
          LegalWidgets.buildVersionInfoCard(),
          
          LegalWidgets.buildSpacing(height: 24),
          
          // Contact section
          LegalWidgets.buildContactSection(),
          
          LegalWidgets.buildSpacing(height: 32),
        ],
      ),
    );
  }
}
