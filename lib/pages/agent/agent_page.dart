import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'models/agent_models.dart';
import 'services/agent_api_service.dart';
import 'state/agent_state_manager.dart';
import 'widgets/agent_widgets.dart';

/// Main Agent Page - Healthcare Facility Registration and Management
class AgentPage extends StatefulWidget {
  const AgentPage({super.key});
  
  @override
  State<AgentPage> createState() => _AgentPageState();
}

class _AgentPageState extends State<AgentPage> with TickerProviderStateMixin {
  late AgentStateManager _stateManager;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _stateManager = AgentStateManager();
    _initializeAnimations();
    _loadStoredData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    
    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _loadStoredData() async {
    await _stateManager.loadStoredAgentData();
  }

  void _resetAnimations() {
    _fadeController.reset();
    _slideController.reset();
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _disposeAnimations();
    _stateManager.dispose();
    super.dispose();
  }

  void _disposeAnimations() {
    _fadeController.dispose();
    _slideController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.isDarkMode ? TailwindColors.gray900 : TailwindColors.gray50,
      appBar: AgentWidgets.buildAppBar(context, _stateManager),
      body: AnimatedBuilder(
        animation: _stateManager,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildBody(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(context.responsivePadding),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 
                      MediaQuery.of(context).padding.top - 
                      MediaQuery.of(context).padding.bottom - 
                      kToolbarHeight,
          ),
          child: IntrinsicHeight(
            child: _buildMainContent(),
          ),
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() {});
  }

  Widget _buildMainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AgentWidgets.buildHeaderSection(context),
        SizedBox(height: context.responsiveGapLg),
        _buildCurrentView(),
      ],
    );
  }

  Widget _buildCurrentView() {
    switch (_stateManager.mode) {
      case 'choice':
        return _buildChoiceView();
      case 'login':
        return _buildLoginForm();
      case 'form':
        return _buildFacilityForm();
      default:
        return _buildChoiceView();
    }
  }

  Widget _buildChoiceView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AgentWidgets.buildChoiceCard(
          context: context,
          title: 'New Facility',
          subtitle: 'Register a new healthcare facility',
          icon: Icons.add_business,
          onTap: () {
            _stateManager.setMode('form');
            _resetAnimations();
          },
          isPrimary: true,
        ),
        SizedBox(height: context.responsiveGap),
        AgentWidgets.buildChoiceCard(
          context: context,
          title: 'Existing Facility',
          subtitle: 'Login to manage your facility',
          icon: Icons.login,
          onTap: () {
            _stateManager.setMode('login');
            _resetAnimations();
          },
          isPrimary: false,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Container(
      constraints: BoxConstraints(maxWidth: context.isMobile ? 400.w : 500.w),
      child: AgentWidgets.buildFormCard(
        context: context,
        title: 'Facility Login',
        subtitle: 'Enter your credentials to access your facility',
        child: Form(
          key: _stateManager.formKey,
          child: Column(
            children: [
              AgentWidgets.buildTextFormField(
                context: context,
                controller: _stateManager.username,
                label: 'Username',
                icon: Icons.person,
                validator: (v) =>
                    v != null && v.trim().isNotEmpty ? null : 'Enter username',
              ),
              SizedBox(height: context.responsiveGap),
              AgentWidgets.buildTextFormField(
                context: context,
                controller: _stateManager.password,
                label: 'Password',
                icon: Icons.lock,
                obscureText: true,
                validator: (v) =>
                    v != null && v.length >= 6 ? null : 'Min 6 chars',
              ),
              SizedBox(height: context.responsiveGapLg),
              AgentWidgets.buildSubmitButton(
                context: context,
                text: 'Login',
                onPressed: _stateManager.loading ? null : _stateManager.loginAgent,
                isLoading: _stateManager.loading,
              ),
              SizedBox(height: context.responsiveGap),
              AgentWidgets.buildBackButton(
                context: context,
                onPressed: () {
                  _stateManager.setMode('choice');
                  _resetAnimations();
                },
              ),
              if (_stateManager.message != null) ...[
                SizedBox(height: context.responsiveGap),
                AgentWidgets.buildMessageWidget(
                  context: context,
                  message: _stateManager.message!,
                  isError: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFacilityForm() {
    return Container(
      constraints: BoxConstraints(maxWidth: context.isMobile ? 600.w : 800.w),
      child: AgentWidgets.buildFormCard(
        context: context,
        title: _stateManager.facilityId != null ? 'Update Facility' : 'Register Facility',
        subtitle: _stateManager.facilityId != null 
            ? 'Update your facility information'
            : 'Register your healthcare facility with FindMed',
        child: Form(
          key: _stateManager.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFacilityTypeSection(),
              SizedBox(height: context.responsiveGap),
              _buildAccountSection(),
              SizedBox(height: context.responsiveGap),
              _buildBasicInfoSection(),
              SizedBox(height: context.responsiveGap),
              _buildFacilitySpecificSection(),
              SizedBox(height: context.responsiveGap),
              _buildOwnershipSection(),
              SizedBox(height: context.responsiveGap),
              _buildServicesSection(),
              SizedBox(height: context.responsiveGap),
              _buildContactSection(),
              SizedBox(height: context.responsiveGap),
              _buildPharmacySpecificSection(),
              SizedBox(height: context.responsiveGap),
              _buildEmailSection(),
              SizedBox(height: context.responsiveGap),
              _buildOpeningHoursSection(),
              SizedBox(height: context.responsiveGap),
              _buildEmergencySection(),
              SizedBox(height: context.responsiveGap),
              _buildLocationSection(),
              SizedBox(height: context.responsiveGap),
              _buildNotesSection(),
              SizedBox(height: context.responsiveGapLg),
              AgentWidgets.buildSubmitButton(
                context: context,
                text: _stateManager.facilityId != null ? 'Save Changes' : 'Register Facility',
                onPressed: _stateManager.loading 
                    ? null 
                    : (_stateManager.facilityId != null ? _stateManager.updateAgent : _stateManager.registerAgent),
                isLoading: _stateManager.loading,
              ),
              SizedBox(height: context.responsiveGap),
              AgentWidgets.buildBackButton(
                context: context,
                onPressed: () {
                  _stateManager.setMode('choice');
                  _resetAnimations();
                },
              ),
              if (_stateManager.message != null) ...[
                SizedBox(height: context.responsiveGap),
                AgentWidgets.buildMessageWidget(
                  context: context,
                  message: _stateManager.message!,
                  isError: false,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFacilityTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Facility Type',
          style: TextStyle(
            fontSize: context.responsiveTextLg,
            fontWeight: FontWeight.w600,
            color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
          ),
        ),
        SizedBox(height: context.responsiveGapSm),
        Text(
          'Select the type of healthcare facility',
          style: TextStyle(
            fontSize: context.responsiveTextSm,
            color: context.isDarkMode ? Colors.white70 : TailwindColors.gray600,
          ),
        ),
        SizedBox(height: context.responsiveGap),
        Row(
          children: [
            Expanded(
              child: AgentWidgets.buildChoiceChip(
                context: context,
                label: 'Hospital',
                selected: _stateManager.facilityType == 'hospital',
                onSelected: (_) => _stateManager.setFacilityType('hospital'),
                icon: Icons.local_hospital,
              ),
            ),
            SizedBox(width: context.responsiveGap),
            Expanded(
              child: AgentWidgets.buildChoiceChip(
                context: context,
                label: 'Pharmacy',
                selected: _stateManager.facilityType == 'pharmacy',
                onSelected: (_) => _stateManager.setFacilityType('pharmacy'),
                icon: Icons.local_pharmacy,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Information',
          style: TextStyle(
            fontSize: context.responsiveTextLg,
            fontWeight: FontWeight.w600,
            color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
          ),
        ),
        SizedBox(height: context.responsiveGapSm),
        Text(
          'Create login credentials for your facility',
          style: TextStyle(
            fontSize: context.responsiveTextSm,
            color: context.isDarkMode ? Colors.white70 : TailwindColors.gray600,
          ),
        ),
        SizedBox(height: context.responsiveGap),
        AgentWidgets.buildTextFormField(
          context: context,
          controller: _stateManager.username,
          label: 'Username',
          icon: Icons.person,
          validator: (v) =>
              v != null && v.trim().length >= 3 ? null : 'Enter username (min 3 chars)',
        ),
        SizedBox(height: context.responsiveGap),
        AgentWidgets.buildTextFormField(
          context: context,
          controller: _stateManager.password,
          label: 'Password',
          icon: Icons.lock,
          obscureText: true,
          validator: (v) {
            if (_stateManager.facilityId != null) return null; // password optional when updating
            return v != null && v.length >= 6 ? null : 'Min 6 characters';
          },
        ),
        SizedBox(height: context.responsiveGap),
        AgentWidgets.buildTextFormField(
          context: context,
          controller: _stateManager.confirm,
          label: 'Confirm Password',
          icon: Icons.lock_outline,
          obscureText: true,
          validator: (v) {
            if (_stateManager.password.text.isEmpty) return null;
            return v != null && v == _stateManager.password.text
                ? null
                : 'Passwords do not match';
          },
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic Information',
          style: TextStyle(
            fontSize: context.responsiveTextLg,
            fontWeight: FontWeight.w600,
            color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
          ),
        ),
        SizedBox(height: context.responsiveGapSm),
        Text(
          'Provide basic details about your facility',
          style: TextStyle(
            fontSize: context.responsiveTextSm,
            color: context.isDarkMode ? Colors.white70 : TailwindColors.gray600,
          ),
        ),
        SizedBox(height: context.responsiveGap),
        AgentWidgets.buildTextFormField(
          context: context,
          controller: _stateManager.name,
          label: 'Facility Name',
          icon: Icons.business,
          validator: (v) => v != null && v.trim().length >= 3
              ? null
              : 'Enter facility name (min 3 chars)',
        ),
      ],
    );
  }

  Widget _buildFacilitySpecificSection() {
    if (_stateManager.facilityType == 'hospital') {
      return _buildHospitalTypeSection();
    } else if (_stateManager.facilityType == 'pharmacy') {
      return _buildPharmacyTypeSection();
    }
    return const SizedBox.shrink();
  }

  Widget _buildHospitalTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hospital Type',
          style: TextStyle(
            fontSize: context.responsiveTextLg,
            fontWeight: FontWeight.w600,
            color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
          ),
        ),
        SizedBox(height: context.responsiveGapSm),
        Text(
          'Select the type of hospital',
          style: TextStyle(
            fontSize: context.responsiveTextSm,
            color: context.isDarkMode ? Colors.white70 : TailwindColors.gray600,
          ),
        ),
        SizedBox(height: context.responsiveGap),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TailwindRadius.lg),
            border: Border.all(
              color: context.isDarkMode ? TailwindColors.gray600 : TailwindColors.gray300,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: _stateManager.hospitalType,
            items: AgentConstants.hospitalTypeOptions
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) {
              _stateManager.setHospitalType(v ?? 'General Hospitals');
            },
            decoration: InputDecoration(
              labelText: 'Hospital Type',
              prefixIcon: Icon(
                Icons.local_hospital,
                size: context.isMobile ? 20.w : 22.w,
                color: context.isDarkMode ? Colors.white70 : TailwindColors.gray500,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(context.responsivePadding),
            ),
            style: TextStyle(
              fontSize: context.responsiveText,
              color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPharmacyTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pharmacy Type',
          style: TextStyle(
            fontSize: context.responsiveTextLg,
            fontWeight: FontWeight.w600,
            color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
          ),
        ),
        SizedBox(height: context.responsiveGapSm),
        Text(
          'Select the type of pharmacy',
          style: TextStyle(
            fontSize: context.responsiveTextSm,
            color: context.isDarkMode ? Colors.white70 : TailwindColors.gray600,
          ),
        ),
        SizedBox(height: context.responsiveGap),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TailwindRadius.lg),
            border: Border.all(
              color: context.isDarkMode ? TailwindColors.gray600 : TailwindColors.gray300,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: _stateManager.pharmacyType,
            items: AgentConstants.pharmacyTypeOptions
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) {
              _stateManager.setPharmacyType(v ?? 'Hospital Pharmacy');
            },
            decoration: InputDecoration(
              labelText: 'Pharmacy Type',
              prefixIcon: Icon(
                Icons.local_pharmacy,
                size: context.isMobile ? 20.w : 22.w,
                color: context.isDarkMode ? Colors.white70 : TailwindColors.gray500,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(context.responsivePadding),
            ),
            style: TextStyle(
              fontSize: context.responsiveText,
              color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOwnershipSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ownership',
          style: TextStyle(
            fontSize: context.responsiveTextLg,
            fontWeight: FontWeight.w600,
            color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
          ),
        ),
        SizedBox(height: context.responsiveGapSm),
        Text(
          'Select the ownership type',
          style: TextStyle(
            fontSize: context.responsiveTextSm,
            color: context.isDarkMode ? Colors.white70 : TailwindColors.gray600,
          ),
        ),
        SizedBox(height: context.responsiveGap),
        Row(
          children: [
            Expanded(
              child: AgentWidgets.buildChoiceChip(
                context: context,
                label: 'Private',
                selected: _stateManager.ownership.toLowerCase() == 'private',
                onSelected: (_) => _stateManager.setOwnership('Private'),
                icon: Icons.business,
              ),
            ),
            SizedBox(width: context.responsiveGap),
            Expanded(
              child: AgentWidgets.buildChoiceChip(
                context: context,
                label: 'Public',
                selected: _stateManager.ownership.toLowerCase() == 'public',
                onSelected: (_) => _stateManager.setOwnership('Public'),
                icon: Icons.account_balance,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Services Offered',
          style: TextStyle(
            fontSize: context.responsiveTextLg,
            fontWeight: FontWeight.w600,
            color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
          ),
        ),
        SizedBox(height: context.responsiveGapSm),
        Text(
          'Select the services your facility provides',
          style: TextStyle(
            fontSize: context.responsiveTextSm,
            color: context.isDarkMode ? Colors.white70 : TailwindColors.gray600,
          ),
        ),
        SizedBox(height: context.responsiveGap),
        Wrap(
          spacing: context.responsiveGapSm,
          runSpacing: context.responsiveGapSm,
          children: _stateManager.currentServices.map((service) {
            final selected = _stateManager.selectedServices.contains(service);
            return FilterChip(
              label: Text(
                service,
                style: TextStyle(
                  fontSize: context.responsiveTextXs,
                  color: selected
                      ? Colors.white
                      : context.isDarkMode
                          ? Colors.white70
                          : TailwindColors.gray700,
                ),
              ),
              selected: selected,
              onSelected: (v) => _stateManager.toggleService(service),
              backgroundColor: context.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray100,
              selectedColor: Theme.of(context).primaryColor,
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(TailwindRadius.md),
                side: BorderSide(
                  color: selected
                      ? Theme.of(context).primaryColor
                      : context.isDarkMode
                          ? TailwindColors.gray600
                          : TailwindColors.gray300,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Information',
          style: TextStyle(
            fontSize: context.responsiveTextLg,
            fontWeight: FontWeight.w600,
            color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
          ),
        ),
        SizedBox(height: context.responsiveGapSm),
        Text(
          'Provide contact details for your facility',
          style: TextStyle(
            fontSize: context.responsiveTextSm,
            color: context.isDarkMode ? Colors.white70 : TailwindColors.gray600,
          ),
        ),
        SizedBox(height: context.responsiveGap),
        AgentWidgets.buildTextFormField(
          context: context,
          controller: _stateManager.phone,
          label: 'Primary Phone',
          icon: Icons.phone,
          validator: (v) =>
              v != null && v.trim().isNotEmpty ? null : 'Enter contact phone',
        ),
        SizedBox(height: context.responsiveGap),
        AgentWidgets.buildTextFormField(
          context: context,
          controller: _stateManager.altPhone,
          label: 'Additional Phone (Optional)',
          icon: Icons.phone_android,
        ),
      ],
    );
  }

  Widget _buildPharmacySpecificSection() {
    if (_stateManager.facilityType != 'pharmacy') return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pharmacy Details',
          style: TextStyle(
            fontSize: context.responsiveTextLg,
            fontWeight: FontWeight.w600,
            color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
          ),
        ),
        SizedBox(height: context.responsiveGapSm),
        Text(
          'Additional pharmacy-specific information',
          style: TextStyle(
            fontSize: context.responsiveTextSm,
            color: context.isDarkMode ? Colors.white70 : TailwindColors.gray600,
          ),
        ),
        SizedBox(height: context.responsiveGap),
        Container(
          padding: EdgeInsets.all(context.responsivePadding),
          decoration: BoxDecoration(
            color: context.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray50,
            borderRadius: BorderRadius.circular(TailwindRadius.lg),
            border: Border.all(
              color: context.isDarkMode ? TailwindColors.gray600 : TailwindColors.gray200,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.access_time,
                size: context.isMobile ? 20.w : 22.w,
                color: context.isDarkMode ? Colors.white70 : TailwindColors.gray500,
              ),
              SizedBox(width: context.responsiveGap),
              Text(
                '24-hour Service',
                style: TextStyle(
                  fontSize: context.responsiveText,
                  color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
                ),
              ),
              const Spacer(),
              Switch(
                value: _stateManager.twentyFour,
                onChanged: _stateManager.setTwentyFour,
                activeColor: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
        SizedBox(height: context.responsiveGap),
        AgentWidgets.buildTextFormField(
          context: context,
          controller: _stateManager.medicineAvailability,
          label: 'Medicine Availability (Optional)',
          icon: Icons.medication,
        ),
      ],
    );
  }

  Widget _buildEmailSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
          style: TextStyle(
            fontSize: context.responsiveTextLg,
            fontWeight: FontWeight.w600,
            color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
          ),
        ),
        SizedBox(height: context.responsiveGapSm),
        Text(
          'Optional email contact for your facility',
          style: TextStyle(
            fontSize: context.responsiveTextSm,
            color: context.isDarkMode ? Colors.white70 : TailwindColors.gray600,
          ),
        ),
        SizedBox(height: context.responsiveGap),
        AgentWidgets.buildTextFormField(
          context: context,
          controller: _stateManager.email,
          label: 'Email (Optional)',
          icon: Icons.email,
        ),
      ],
    );
  }

  Widget _buildOpeningHoursSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Opening Hours',
          style: TextStyle(
            fontSize: context.responsiveTextLg,
            fontWeight: FontWeight.w600,
            color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
          ),
        ),
        SizedBox(height: context.responsiveGapSm),
        Text(
          'Specify your facility operating hours',
          style: TextStyle(
            fontSize: context.responsiveTextSm,
            color: context.isDarkMode ? Colors.white70 : TailwindColors.gray600,
          ),
        ),
        SizedBox(height: context.responsiveGap),
        Row(
          children: [
            Expanded(
              child: AgentWidgets.buildChoiceChip(
                context: context,
                label: '24/7',
                selected: _stateManager.opening == '24/7',
                onSelected: (_) => _stateManager.setOpening('24/7'),
                icon: Icons.all_inclusive,
              ),
            ),
            SizedBox(width: context.responsiveGap),
            Expanded(
              child: AgentWidgets.buildChoiceChip(
                context: context,
                label: 'Custom',
                selected: _stateManager.opening == 'custom',
                onSelected: (_) => _stateManager.setOpening('custom'),
                icon: Icons.schedule,
              ),
            ),
          ],
        ),
        if (_stateManager.opening == 'custom') ...[
          SizedBox(height: context.responsiveGap),
          AgentWidgets.buildTextFormField(
            context: context,
            controller: _stateManager.openingCustom,
            label: 'Custom Opening Hours',
            icon: Icons.access_time,
          ),
        ],
      ],
    );
  }

  Widget _buildEmergencySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Emergency Services',
          style: TextStyle(
            fontSize: context.responsiveTextLg,
            fontWeight: FontWeight.w600,
            color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
          ),
        ),
        SizedBox(height: context.responsiveGapSm),
        Text(
          'Indicate if emergency services are available',
          style: TextStyle(
            fontSize: context.responsiveTextSm,
            color: context.isDarkMode ? Colors.white70 : TailwindColors.gray600,
          ),
        ),
        SizedBox(height: context.responsiveGap),
        Container(
          padding: EdgeInsets.all(context.responsivePadding),
          decoration: BoxDecoration(
            color: context.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray50,
            borderRadius: BorderRadius.circular(TailwindRadius.lg),
            border: Border.all(
              color: context.isDarkMode ? TailwindColors.gray600 : TailwindColors.gray200,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.emergency,
                size: context.isMobile ? 20.w : 22.w,
                color: context.isDarkMode ? Colors.white70 : TailwindColors.gray500,
              ),
              SizedBox(width: context.responsiveGap),
              Text(
                'Emergency Available',
                style: TextStyle(
                  fontSize: context.responsiveText,
                  color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
                ),
              ),
              const Spacer(),
              Switch(
                value: _stateManager.isEmergency,
                onChanged: _stateManager.setEmergency,
                activeColor: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: TextStyle(
            fontSize: context.responsiveTextLg,
            fontWeight: FontWeight.w600,
            color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
          ),
        ),
        SizedBox(height: context.responsiveGapSm),
        Text(
          'Share your facility location',
          style: TextStyle(
            fontSize: context.responsiveTextSm,
            color: context.isDarkMode ? Colors.white70 : TailwindColors.gray600,
          ),
        ),
        SizedBox(height: context.responsiveGap),
        Container(
          padding: EdgeInsets.all(context.responsivePadding),
          decoration: BoxDecoration(
            color: context.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray50,
            borderRadius: BorderRadius.circular(TailwindRadius.lg),
            border: Border.all(
              color: context.isDarkMode ? TailwindColors.gray600 : TailwindColors.gray200,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: context.isMobile ? 20.w : 22.w,
                    color: context.isDarkMode ? Colors.white70 : TailwindColors.gray500,
                  ),
                  SizedBox(width: context.responsiveGap),
                  Text(
                    'Current Location',
                    style: TextStyle(
                      fontSize: context.responsiveText,
                      color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _stateManager.pickLocation,
                    icon: Icon(
                      Icons.gps_fixed,
                      size: context.isMobile ? 16.w : 18.w,
                    ),
                    label: Text('Get Location'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: context.responsivePadding,
                        vertical: context.responsivePaddingSm,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(TailwindRadius.md),
                      ),
                    ),
                  ),
                ],
              ),
              if (_stateManager.locLat != null) ...[
                SizedBox(height: context.responsiveGap),
                Container(
                  padding: EdgeInsets.all(context.responsivePaddingSm),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(TailwindRadius.md),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: context.isMobile ? 16.w : 18.w,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(width: context.responsiveGapSm),
                      Text(
                        'Lat: ${_stateManager.locLat!.toStringAsFixed(4)}, Lng: ${_stateManager.locLng!.toStringAsFixed(4)}',
                        style: TextStyle(
                          fontSize: context.responsiveTextXs,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Information',
          style: TextStyle(
            fontSize: context.responsiveTextLg,
            fontWeight: FontWeight.w600,
            color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
          ),
        ),
        SizedBox(height: context.responsiveGapSm),
        Text(
          'Any additional notes about your facility (Optional)',
          style: TextStyle(
            fontSize: context.responsiveTextSm,
            color: context.isDarkMode ? Colors.white70 : TailwindColors.gray600,
          ),
        ),
        SizedBox(height: context.responsiveGap),
        TextFormField(
          controller: _stateManager.notes,
          maxLines: 3,
          style: TextStyle(
            fontSize: context.responsiveText,
            color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
          ),
          decoration: InputDecoration(
            labelText: 'Additional Notes',
            hintText: 'Enter any additional information...',
            hintStyle: TextStyle(
              fontSize: context.responsiveTextSm,
              color: context.isDarkMode ? Colors.white54 : TailwindColors.gray400,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(TailwindRadius.lg),
              borderSide: BorderSide(
                color: context.isDarkMode ? TailwindColors.gray600 : TailwindColors.gray300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(TailwindRadius.lg),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: context.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray50,
            contentPadding: EdgeInsets.all(context.responsivePadding),
          ),
        ),
      ],
    );
  }
}
