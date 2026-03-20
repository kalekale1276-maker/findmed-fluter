import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth.dart';
import '../../services/api.dart';
import '../../../core/utils/tailwind_extensions.dart';

class AgentPage extends StatefulWidget {
  const AgentPage({super.key});
  
  @override
  State<AgentPage> createState() => _AgentPageState();
}

class _AgentPageState extends State<AgentPage> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Mode management
  String _mode = 'choice'; // 'choice' | 'login' | 'register' | 'form'
  
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _confirm = TextEditingController();
  final _altPhone = TextEditingController();
  final _openingCustom = TextEditingController();
  final _notes = TextEditingController();
  final _medicineAvailability = TextEditingController();
  
  // State variables
  bool _loading = false;
  String? _message;
  String? _facilityId;
  final AuthService _auth = AuthService.instance;
  
  // Facility configuration
  String _facilityType = 'hospital';
  String _hospitalType = 'General Hospitals';
  String _pharmacyType = 'Hospital Pharmacy';
  String _ownership = 'Private';
  String _opening = '24/7';
  bool _isEmergency = false;
  bool _twentyFour = false;
  double? _locLat;
  double? _locLng;
  final Set<String> _selectedServices = {};

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
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

  @override
  void dispose() {
    _disposeControllers();
    _disposeAnimations();
    super.dispose();
  }

  void _disposeControllers() {
    _email.dispose();
    _username.dispose();
    _password.dispose();
    _name.dispose();
    _phone.dispose();
    _confirm.dispose();
    _altPhone.dispose();
    _openingCustom.dispose();
    _notes.dispose();
    _medicineAvailability.dispose();
  }

  void _disposeAnimations() {
    _fadeController.dispose();
    _slideController.dispose();
  }

  // Static data
  static const List<String> _hospitalTypeOptions = [
    'General Hospitals',
    'Specialized Hospitals',
    'Internal / Medical Hospitals',
    'Surgical Hospitals',
    'Maternal & Child Hospitals',
    'Teaching & Referral Hospitals',
    'Clinics & Primary Care Facilities'
  ];

  static const Map<String, List<String>> _hospitalServicesByType = {
    'General Hospitals': [
      'Outpatient services (OPD)',
      'Inpatient services (admission)',
      'Emergency services',
      'General surgery',
      'Internal medicine care',
      'Laboratory services',
      'Pharmacy services',
      'Radiology (X-ray, ultrasound)',
      'Minor procedures',
      'Referral to specialized hospitals'
    ],
    'Specialized Hospitals': [
      'Specialized diagnosis',
      'Advanced medical treatment',
      'Specialized surgery',
      'Disease-specific care (cancer, heart, eye, etc.)',
      'Advanced imaging services',
      'Specialized laboratory tests',
      'Long-term treatment plans',
      'Specialist consultation',
      'Follow-up care',
      'Patient education for specific diseases'
    ],
    'Internal / Medical Hospitals': [
      'Internal medicine consultation',
      'Diagnosis of chronic diseases',
      'Treatment of infectious diseases',
      'Management of diabetes',
      'Management of hypertension',
      'Mental health treatment',
      'Medication management',
      'Medical monitoring',
      'Health counseling',
      'Referral to surgical or specialty care'
    ],
    'Surgical Hospitals': [
      'Major surgical operations',
      'Minor surgical procedures',
      'Emergency surgery',
      'Trauma care',
      'Pre-surgical assessment',
      'Post-surgical care',
      'Anesthesia services',
      'Operation theater services',
      'Wound care',
      'Surgical follow-up'
    ],
    'Maternal & Child Hospitals': [
      'Antenatal care (ANC)',
      'Delivery services',
      'Cesarean section',
      'Postnatal care',
      'Child health services',
      'Immunization services',
      'Family planning',
      'Neonatal care',
      'Growth monitoring',
      'Nutrition counseling'
    ],
    'Teaching & Referral Hospitals': [
      'Specialized medical services',
      'Referral services from lower facilities',
      'Advanced diagnosis',
      'Complex surgeries',
      'Medical education and training',
      'Internship and residency programs',
      'Research activities',
      'Specialist consultation',
      'Advanced laboratory services',
      'Emergency and critical care'
    ],
    'Clinics & Primary Care Facilities': [
      'Basic medical consultation',
      'Outpatient services',
      'First aid services',
      'Treatment of minor illnesses',
      'Health screening',
      'Maternal health services',
      'Child health services',
      'Vaccination services',
      'Basic laboratory tests',
      'Referral to hospitals'
    ]
  };

  static const List<String> _pharmacyTypeOptions = [
    'Hospital Pharmacy',
    'Community (Retail) Pharmacy',
    'Clinical Pharmacy',
    'Industrial Pharmacy',
    'Wholesale / Distribution Pharmacy',
    'Compounding Pharmacy',
    'Regulatory / Public Health Pharmacy'
  ];

  static const Map<String, List<String>> _pharmacyServicesByType = {
    'Hospital Pharmacy': [
      'Dispensing prescribed medicines',
      'Inpatient medication supply',
      'Outpatient medication supply',
      'Medication storage and management',
      'Clinical pharmacy services',
      'Drug interaction checking',
      'Patient medication counseling',
      'Emergency drug supply',
      'Inventory control',
      'Support for doctors and nurses'
    ],
    'Community (Retail) Pharmacy': [
      'Dispensing prescription medicines',
      'Selling over-the-counter (OTC) drugs',
      'Patient counseling',
      'Health advice for minor illnesses',
      'Blood pressure checking',
      'Blood sugar testing',
      'First aid supplies',
      'Family planning products',
      'Referral to health facilities',
      'Health education'
    ],
    'Clinical Pharmacy': [
      'Medication therapy management',
      'Drug review and evaluation',
      'Monitoring drug effectiveness',
      'Preventing drug interactions',
      'Adjusting drug doses',
      'Patient counseling',
      'Supporting medical teams',
      'Adverse drug reaction monitoring',
      'Chronic disease medication support',
      'Medication safety services'
    ],
    'Industrial Pharmacy': [
      'Drug manufacturing',
      'Quality control testing',
      'Drug formulation',
      'Packaging and labeling',
      'Research and development',
      'Production planning',
      'Regulatory compliance',
      'Storage of finished products',
      'Distribution preparation',
      'Pharmacovigilance support'
    ],
    'Wholesale / Distribution Pharmacy': [
      'Bulk purchase of medicines',
      'Drug storage and warehousing',
      'Distribution to pharmacies and hospitals',
      'Cold chain management',
      'Inventory management',
      'Order processing',
      'Transportation coordination',
      'Stock monitoring',
      'Quality assurance',
      'Supply chain management'
    ],
    'Compounding Pharmacy': [
      'Preparing customized medicines',
      'Mixing special drug formulas',
      'Pediatric dose preparation',
      'Geriatric dose preparation',
      'Allergy-free medication preparation',
      'Topical preparations (creams, ointments)',
      'Liquid medicine preparation',
      'Patient-specific labeling',
      'Doctor consultation support',
      'Safe packaging'
    ],
    'Regulatory / Public Health Pharmacy': [
      'Drug regulation and control',
      'Drug inspection',
      'Licensing of pharmacies',
      'Quality assurance',
      'Pharmacovigilance',
      'Monitoring illegal drugs',
      'Public health drug programs',
      'Policy implementation',
      'Drug information services',
      'Training and supervision'
    ]
  };

  // Getters for current services
  List<String> get _currentServices => _facilityType == 'hospital'
      ? (_hospitalServicesByType[_hospitalType] ?? [])
      : (_pharmacyServicesByType[_pharmacyType] ?? []);

  // State management methods
  void _setLoading(bool loading) => setState(() => _loading = loading);
  void _setMessage(String? message) => setState(() => _message = message);
  void _setMode(String mode) {
    setState(() => _mode = mode);
    _resetAnimations();
  }

  void _resetAnimations() {
    _fadeController.reset();
    _slideController.reset();
    _fadeController.forward();
    _slideController.forward();
  }

  void _setFacilityType(String type) => setState(() => _facilityType = type);
  void _setHospitalType(String type) => setState(() => _hospitalType = type);
  void _setPharmacyType(String type) => setState(() => _pharmacyType = type);
  void _setOwnership(String ownership) => setState(() => _ownership = ownership);
  void _setOpening(String opening) => setState(() => _opening = opening);
  void _setEmergency(bool emergency) => setState(() => _isEmergency = emergency);
  void _setTwentyFour(bool twentyFour) => setState(() => _twentyFour = twentyFour);
  void _setLocation(double lat, double lng) {
    setState(() {
      _locLat = lat;
      _locLng = lng;
    });
  }

  void _toggleService(String service) {
    setState(() {
      if (_selectedServices.contains(service)) {
        _selectedServices.remove(service);
      } else {
        _selectedServices.add(service);
      }
    });
  }

  void _updateServicesForTypeChange() {
    final availableServices = _currentServices;
    _selectedServices.removeWhere((service) => !availableServices.contains(service));
  }

  // API Methods
  Future<void> _loginAgent() async {
    if (!_formKey.currentState!.validate()) return;
    _setLoading(true);
    _setMessage(null);

    try {
      final res = await Api.post('/facilities/login',
          {'username': _username.text.trim(), 'password': _password.text});
      
      await _populateFormFromResponse(res);
      await _persistAgentData();
      _setMessage('Facility loaded');
      _setMode('form');
    } catch (e) {
      _setMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _populateFormFromResponse(Map<String, dynamic> res) async {
    setState(() {
      _facilityId = res['_id'] ?? res['id'];
      _name.text = (res['name'] ?? '') as String;
      _email.text = (res['email'] ?? '') as String;
      _phone.text = (res['phone'] ?? '') as String;
      _altPhone.text = _getAltPhoneFromResponse(res);
      _populateServicesFromResponse(res);
      _facilityType = (res['type'] ?? 'hospital') as String;
      _hospitalType = (res['hospitalType'] ?? _hospitalType) as String;
      _pharmacyType = (res['pharmacyType'] ?? _pharmacyType) as String;
      _opening = (res['openingHours'] ?? _opening) as String;
      _ownership = (res['ownership'] ?? res['ownershipType'] ?? _ownership) as String;
      _isEmergency = (res['isEmergency'] ?? false) as bool;
      _twentyFour = (res['twentyFour'] ?? false) as bool;
      _medicineAvailability.text = (res['medicineAvailability'] ?? '') as String;
      _populateLocationFromResponse(res);
    });
  }

  String _getAltPhoneFromResponse(Map<String, dynamic> res) {
    if (res['altPhone'] is List && (res['altPhone'] as List).isNotEmpty) {
      return (res['altPhone'][0] ?? '') as String;
    }
    return (res['altPhone'] ?? '') as String;
  }

  void _populateServicesFromResponse(Map<String, dynamic> res) {
    _selectedServices.clear();
    if (res['services'] is List) {
      for (var s in (res['services'] as List)) {
        _selectedServices.add(s.toString());
      }
    }
  }

  void _populateLocationFromResponse(Map<String, dynamic> res) {
    if (res['location'] != null && res['location']['coordinates'] is List) {
      final coords = res['location']['coordinates'];
      if (coords.length >= 2) {
        _locLng = (coords[0] as num).toDouble();
        _locLat = (coords[1] as num).toDouble();
      }
    }
  }

  Future<void> _persistAgentData() async {
    if (_facilityId != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('agentId', _facilityId!);
      await prefs.setString('agentFacilityType', _facilityType);
    }
  }

  Future<void> _updateAgent() async {
    if (_facilityId == null) return;
    if (!_formKey.currentState!.validate()) return;
    
    if (!_validateServices()) return;
    
    _setLoading(true);
    _setMessage(null);

    try {
      final payload = _buildFacilityPayload();
      final res = await Api.put('/facilities/$_facilityId', payload);
      _setMessage('Facility updated');
      await _persistAgentData();
    } catch (e) {
      _setMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _registerAgent() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_validateServices()) return;
    
    _setLoading(true);
    _setMessage(null);

    try {
      final payload = _buildFacilityPayload();
      final res = await Api.post('/facilities', payload);
      final facilityId = res['_id'] ?? res['id'];
      
      await _handleRegistrationSuccess(facilityId);
      _setMessage('Agent registration successful.');
      
      if (mounted) {
        await _showRegistrationDialog(facilityId);
        Navigator.of(context).pop();
      }
    } catch (e) {
      _setMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  bool _validateServices() {
    if ((_facilityType == 'hospital' || _facilityType == 'pharmacy') &&
        _selectedServices.isEmpty) {
      _setLoading(false);
      _setMessage('Please select at least one service for the selected facility type.');
      return false;
    }
    return true;
  }

  Map<String, dynamic> _buildFacilityPayload() {
    final payload = <String, dynamic>{
      'name': _name.text.trim(),
      'type': _facilityType,
      'hospitalType': _facilityType == 'hospital' ? _hospitalType : null,
      'pharmacyType': _facilityType == 'pharmacy' ? _pharmacyType : null,
      'ownership': _ownership.toString().toLowerCase(),
      'services': _selectedServices.toList(),
      'phone': _phone.text.trim(),
      'altPhone': _altPhone.text.trim(),
      'email': _email.text.trim(),
      'openingHours': _opening == '24/7' ? '24/7' : _openingCustom.text.trim(),
      'isEmergency': _isEmergency,
      'notes': _notes.text.trim(),
    };

    if (_facilityType == 'pharmacy') {
      payload['twentyFour'] = _twentyFour;
      payload['medicineAvailability'] = _medicineAvailability.text.trim();
    }

    if (_locLat != null && _locLng != null) {
      payload['location'] = {
        'type': 'Point',
        'coordinates': [_locLng, _locLat]
      };
    }

    if (_password.text.isNotEmpty) payload['password'] = _password.text;
    if (_username.text.trim().isNotEmpty && _password.text.isNotEmpty) {
      payload['username'] = _username.text.trim();
      payload['password'] = _password.text;
    }

    return payload;
  }

  Future<void> _handleRegistrationSuccess(dynamic facilityId) async {
    if (facilityId != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('agentId', facilityId.toString());
      await prefs.setString('agentFacilityType', _facilityType);
    }
  }

  Future<void> _showRegistrationDialog(dynamic facilityId) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Agent registered'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Agent ID: ${facilityId ?? 'unknown'}'),
            const SizedBox(height: 8),
            SelectableText('${facilityId ?? ''}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (facilityId != null) {
                await Clipboard.setData(ClipboardData(text: facilityId.toString()));
              }
              Navigator.of(context).pop();
            },
            child: const Text('Copy ID'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  // Location Services
  Future<void> _pickLocation() async {
    try {
      final status = await Geolocator.checkPermission();
      if (status == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      final p = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _setLocation(p.latitude, p.longitude);
    } catch (e) {
      _setMessage('Failed to get location: ${e.toString()}');
    }
  }

  // UI Widget Builders
  Widget _buildChoiceView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => _setMode('form'),
          child: const Text('New Agent'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => _setMode('login'),
          child: const Text('Existing Agent'),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _username,
            decoration: const InputDecoration(labelText: 'Username'),
            validator: (v) =>
                v != null && v.trim().isNotEmpty ? null : 'Enter username',
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _password,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            validator: (v) =>
                v != null && v.length >= 6 ? null : 'Min 6 chars',
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _loading ? null : _loginAgent,
            child: _loading
                ? const CircularProgressIndicator()
                : const Text('Login'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => _setMode('choice'),
            child: const Text('Back'),
          ),
          if (_message != null) ...[
            const SizedBox(height: 8),
            Text(_message!, style: const TextStyle(color: Colors.red)),
          ]
        ],
      ),
    );
  }

  Widget _buildFacilityForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildFacilityIdSection(),
          _buildFacilityTypeSection(),
          _buildAccountSection(),
          _buildBasicInfoSection(),
          _buildFacilitySpecificSection(),
          _buildOwnershipSection(),
          _buildServicesSection(),
          _buildContactSection(),
          _buildPharmacySpecificSection(),
          _buildEmailSection(),
          _buildOpeningHoursSection(),
          _buildEmergencySection(),
          _buildLocationSection(),
          _buildNotesSection(),
          _buildSubmitSection(),
          _buildBackButton(),
          _buildMessageSection(),
        ],
      ),
    );
  }

  Widget _buildFacilityIdSection() {
    if (_facilityId == null) return const SizedBox.shrink();
    
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.badge, size: 18),
            const SizedBox(width: 8),
            Text('Agent ID: $_facilityId'),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildFacilityTypeSection() {
    return Column(
      children: [
        Row(
          children: [
            const Text('Facility type:'),
            const SizedBox(width: 12),
            ChoiceChip(
              label: const Text('Hospital'),
              selected: _facilityType == 'hospital',
              onSelected: (_) => _setFacilityType('hospital'),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Pharmacy'),
              selected: _facilityType == 'pharmacy',
              onSelected: (_) => _setFacilityType('pharmacy'),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildAccountSection() {
    return Column(
      children: [
        TextFormField(
          controller: _username,
          decoration: const InputDecoration(labelText: 'Username'),
          validator: (v) =>
              v != null && v.trim().length >= 3 ? null : 'Enter username',
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _password,
          decoration: const InputDecoration(labelText: 'Password'),
          obscureText: true,
          validator: (v) {
            if (_facilityId != null) return null; // password optional when updating
            return v != null && v.length >= 6 ? null : 'Min 6 chars';
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _confirm,
          decoration: const InputDecoration(labelText: 'Confirm password'),
          obscureText: true,
          validator: (v) {
            if (_password.text.isEmpty) return null;
            return v != null && v == _password.text
                ? null
                : 'Passwords do not match';
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      children: [
        TextFormField(
          controller: _name,
          decoration: const InputDecoration(labelText: 'Facility name'),
          validator: (v) => v != null && v.trim().length >= 3
              ? null
              : 'Enter facility name',
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildFacilitySpecificSection() {
    if (_facilityType == 'hospital') {
      return _buildHospitalTypeSection();
    } else if (_facilityType == 'pharmacy') {
      return _buildPharmacyTypeSection();
    }
    return const SizedBox.shrink();
  }

  Widget _buildHospitalTypeSection() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          initialValue: _hospitalType,
          items: (_hospitalTypeOptions.contains(_hospitalType)
                  ? _hospitalTypeOptions
                  : [..._hospitalTypeOptions, _hospitalType])
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (v) {
            _setHospitalType(v ?? 'General Hospitals');
            _updateServicesForTypeChange();
          },
          decoration: const InputDecoration(labelText: 'Hospital type'),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildPharmacyTypeSection() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          initialValue: _pharmacyType,
          items: (_pharmacyTypeOptions.contains(_pharmacyType)
                  ? _pharmacyTypeOptions
                  : [..._pharmacyTypeOptions, _pharmacyType])
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (v) {
            _setPharmacyType(v ?? 'Hospital Pharmacy');
            _updateServicesForTypeChange();
          },
          decoration: const InputDecoration(labelText: 'Pharmacy type'),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildOwnershipSection() {
    return Column(
      children: [
        Row(
          children: [
            const Text('Ownership:'),
            const SizedBox(width: 12),
            ChoiceChip(
              label: const Text('Private'),
              selected: _ownership.toLowerCase() == 'private',
              onSelected: (_) => _setOwnership('Private'),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Public'),
              selected: _ownership.toLowerCase() == 'public',
              onSelected: (_) => _setOwnership('Public'),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildServicesSection() {
    return Column(
      children: [
        const Align(alignment: Alignment.centerLeft, child: Text('Services')),
        Wrap(
          spacing: 6,
          children: _currentServices.map((service) {
            final selected = _selectedServices.contains(service);
            return FilterChip(
              label: Text(service),
              selected: selected,
              onSelected: (v) => _toggleService(service),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      children: [
        TextFormField(
          controller: _phone,
          decoration: const InputDecoration(labelText: 'Contact phone'),
          validator: (v) =>
              v != null && v.trim().isNotEmpty ? null : 'Enter contact phone',
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _altPhone,
          decoration: const InputDecoration(labelText: 'Additional phone (optional)'),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildPharmacySpecificSection() {
    if (_facilityType != 'pharmacy') return const SizedBox.shrink();
    
    return Column(
      children: [
        Row(
          children: [
            const Text('24-hour service:'),
            const SizedBox(width: 12),
            Switch(
              value: _twentyFour,
              onChanged: _setTwentyFour,
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _medicineAvailability,
          decoration: const InputDecoration(
              labelText: 'Medicine availability (optional)'),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildEmailSection() {
    return Column(
      children: [
        TextFormField(
          controller: _email,
          decoration: const InputDecoration(labelText: 'Email (optional)'),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildOpeningHoursSection() {
    return Column(
      children: [
        Row(
          children: [
            const Text('Opening hours:'),
            const SizedBox(width: 12),
            ChoiceChip(
              label: const Text('24/7'),
              selected: _opening == '24/7',
              onSelected: (_) => _setOpening('24/7'),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Custom'),
              selected: _opening == 'custom',
              onSelected: (_) => _setOpening('custom'),
            ),
          ],
        ),
        if (_opening == 'custom')
          TextFormField(
            controller: _openingCustom,
            decoration: const InputDecoration(labelText: 'Custom opening hours'),
          ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildEmergencySection() {
    return Column(
      children: [
        Row(
          children: [
            const Text('Emergency available:'),
            const SizedBox(width: 12),
            Switch(
              value: _isEmergency,
              onChanged: _setEmergency,
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      children: [
        Row(
          children: [
            ElevatedButton(
              onPressed: _pickLocation,
              child: const Text('Share Location'),
            ),
            const SizedBox(width: 12),
            if (_locLat != null)
              Text(
                  'Lat: ${_locLat!.toStringAsFixed(4)}, Lng: ${_locLng!.toStringAsFixed(4)}'),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      children: [
        TextFormField(
          controller: _notes,
          decoration: const InputDecoration(labelText: 'Additional notes (optional)'),
          maxLines: 3,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSubmitSection() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _loading
                ? null
                : (_facilityId != null ? _updateAgent : _registerAgent),
            child: _loading
                ? const CircularProgressIndicator()
                : Text(_facilityId != null ? 'Save changes' : 'Register Facility'),
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton() {
    return TextButton(
      onPressed: () => _setMode('choice'),
      child: const Text('Back'),
    );
  }

  Widget _buildMessageSection() {
    if (_message == null) return const SizedBox.shrink();
    
    return Column(
      children: [
        const SizedBox(height: 8),
        Text(_message!, style: const TextStyle(color: Colors.green)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
        'Agent Portal',
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
        if (_facilityId != null)
          Container(
            margin: EdgeInsets.only(right: context.responsivePadding),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.badge,
                  size: context.isMobile ? 18.w : 20.w,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(width: context.responsiveGapSm),
                Text(
                  'ID: $_facilityId',
                  style: TextStyle(
                    fontSize: context.responsiveTextSm,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
      ],
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
    // Simulate refresh
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() {});
  }

  Widget _buildMainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeaderSection(),
        SizedBox(height: context.responsiveGapLg),
        _buildCurrentView(),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: EdgeInsets.all(context.responsivePadding),
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
        children: [
          Icon(
            Icons.local_hospital,
            size: context.isMobile ? 48.w : 56.w,
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(height: context.responsiveGap),
          Text(
            'Healthcare Facility Portal',
            style: TextStyle(
              fontSize: context.responsiveTextXl,
              fontWeight: FontWeight.bold,
              color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.responsiveGapSm),
          Text(
            'Register or manage your healthcare facility',
            style: TextStyle(
              fontSize: context.responsiveText,
              color: context.isDarkMode ? Colors.white70 : TailwindColors.gray600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _getCurrentView() {
    switch (_mode) {
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
        _buildChoiceCard(
          title: 'New Facility',
          subtitle: 'Register a new healthcare facility',
          icon: Icons.add_business,
          onTap: () => _setMode('form'),
          isPrimary: true,
        ),
        SizedBox(height: context.responsiveGap),
        _buildChoiceCard(
          title: 'Existing Facility',
          subtitle: 'Login to manage your facility',
          icon: Icons.login,
          onTap: () => _setMode('login'),
          isPrimary: false,
        ),
      ],
    );
  }

  Widget _buildChoiceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: context.isMobile ? 400.w : 500.w),
      child: Material(
        elevation: TailwindShadows.md[0],
        borderRadius: BorderRadius.circular(TailwindRadius.xl),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TailwindRadius.xl),
          child: Container(
            padding: EdgeInsets.all(context.responsivePaddingLg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(TailwindRadius.xl),
              gradient: isPrimary
                  ? LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isPrimary
                  ? null
                  : context.isDarkMode
                      ? TailwindColors.gray800
                      : Colors.white,
              border: Border.all(
                color: isPrimary
                    ? Colors.transparent
                    : context.isDarkMode
                        ? TailwindColors.gray700
                        : TailwindColors.gray200,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(context.responsivePadding),
                  decoration: BoxDecoration(
                    color: isPrimary
                        ? Colors.white.withOpacity(0.2)
                        : Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(TailwindRadius.lg),
                  ),
                  child: Icon(
                    icon,
                    size: context.isMobile ? 32.w : 40.w,
                    color: isPrimary
                        ? Colors.white
                        : Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: context.responsiveGap),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: context.responsiveTextLg,
                    fontWeight: FontWeight.bold,
                    color: isPrimary
                        ? Colors.white
                        : context.isDarkMode
                            ? Colors.white
                            : TailwindColors.gray900,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: context.responsiveGapSm),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: context.responsiveTextSm,
                    color: isPrimary
                        ? Colors.white70
                        : context.isDarkMode
                            ? Colors.white70
                            : TailwindColors.gray600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Container(
      constraints: BoxConstraints(maxWidth: context.isMobile ? 400.w : 500.w),
      child: _buildFormCard(
        title: 'Facility Login',
        subtitle: 'Enter your credentials to access your facility',
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextFormField(
                controller: _username,
                label: 'Username',
                icon: Icons.person,
                validator: (v) =>
                    v != null && v.trim().isNotEmpty ? null : 'Enter username',
              ),
              SizedBox(height: context.responsiveGap),
              _buildTextFormField(
                controller: _password,
                label: 'Password',
                icon: Icons.lock,
                obscureText: true,
                validator: (v) =>
                    v != null && v.length >= 6 ? null : 'Min 6 chars',
              ),
              SizedBox(height: context.responsiveGapLg),
              _buildSubmitButton(
                text: 'Login',
                onPressed: _loading ? null : _loginAgent,
                isLoading: _loading,
              ),
              SizedBox(height: context.responsiveGap),
              _buildBackButton(),
              if (_message != null) ...[
                SizedBox(height: context.responsiveGap),
                _buildMessageWidget(_message!, isError: true),
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
      child: _buildFormCard(
        title: _facilityId != null ? 'Update Facility' : 'Register Facility',
        subtitle: _facilityId != null 
            ? 'Update your facility information'
            : 'Register your healthcare facility with FindMed',
        child: Form(
          key: _formKey,
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
              _buildSubmitButton(
                text: _facilityId != null ? 'Save Changes' : 'Register Facility',
                onPressed: _loading ? null : (_facilityId != null ? _updateAgent : _registerAgent),
                isLoading: _loading,
              ),
              SizedBox(height: context.responsiveGap),
              _buildBackButton(),
              if (_message != null) ...[
                SizedBox(height: context.responsiveGap),
                _buildMessageWidget(_message!, isError: false),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.responsivePaddingLg),
      decoration: BoxDecoration(
        color: context.isDarkMode ? TailwindColors.gray800 : Colors.white,
        borderRadius: BorderRadius.circular(TailwindRadius.xl),
        boxShadow: [TailwindShadows.lg],
        border: Border.all(
          color: context.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: context.responsiveTextXl,
              fontWeight: FontWeight.bold,
              color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
            ),
          ),
          SizedBox(height: context.responsiveGapSm),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: context.responsiveTextSm,
              color: context.isDarkMode ? Colors.white70 : TailwindColors.gray600,
            ),
          ),
          SizedBox(height: context.responsiveGapLg),
          child,
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: TextStyle(
        fontSize: context.responsiveText,
        color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          size: context.isMobile ? 20.w : 22.w,
          color: context.isDarkMode ? Colors.white70 : TailwindColors.gray500,
        ),
        labelStyle: TextStyle(
          fontSize: context.responsiveTextSm,
          color: context.isDarkMode ? Colors.white70 : TailwindColors.gray500,
        ),
        enabledBorder: OutlineInputBorder(
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TailwindRadius.lg),
          borderSide: BorderSide(color: TailwindColors.red500),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TailwindRadius.lg),
          borderSide: BorderSide(color: TailwindColors.red500, width: 2),
        ),
        filled: true,
        fillColor: context.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray50,
      ),
    );
  }

  Widget _buildSubmitButton({
    required String text,
    required VoidCallback? onPressed,
    required bool isLoading,
  }) {
    return Container(
      height: context.isMobile ? 48.h : 56.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(TailwindRadius.lg),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: context.isMobile ? 20.w : 24.w,
                    height: context.isMobile ? 20.w : 24.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    text,
                    style: TextStyle(
                      fontSize: context.responsiveText,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return TextButton(
      onPressed: () => _setMode('choice'),
      child: Text(
        '← Back',
        style: TextStyle(
          fontSize: context.responsiveText,
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMessageWidget(String message, {required bool isError}) {
    return Container(
      padding: EdgeInsets.all(context.responsivePadding),
      decoration: BoxDecoration(
        color: isError 
            ? TailwindColors.red50 
            : TailwindColors.green50,
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
        border: Border.all(
          color: isError 
              ? TailwindColors.red200 
              : TailwindColors.green200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            size: context.isMobile ? 18.w : 20.w,
            color: isError 
                ? TailwindColors.red600 
                : TailwindColors.green600,
          ),
          SizedBox(width: context.responsiveGapSm),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: context.responsiveTextSm,
                color: isError 
                    ? TailwindColors.red800 
                    : TailwindColors.green800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Form Section Builders
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
              child: _buildChoiceChip(
                label: 'Hospital',
                selected: _facilityType == 'hospital',
                onSelected: (_) => _setFacilityType('hospital'),
                icon: Icons.local_hospital,
              ),
            ),
            SizedBox(width: context.responsiveGap),
            Expanded(
              child: _buildChoiceChip(
                label: 'Pharmacy',
                selected: _facilityType == 'pharmacy',
                onSelected: (_) => _setFacilityType('pharmacy'),
                icon: Icons.local_pharmacy,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () => onSelected(!selected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: context.responsivePadding,
          vertical: context.responsivePaddingSm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).primaryColor
              : context.isDarkMode
                  ? TailwindColors.gray700
                  : TailwindColors.gray100,
          borderRadius: BorderRadius.circular(TailwindRadius.lg),
          border: Border.all(
            color: selected
                ? Theme.of(context).primaryColor
                : context.isDarkMode
                    ? TailwindColors.gray600
                    : TailwindColors.gray300,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: context.isMobile ? 18.w : 20.w,
              color: selected
                  ? Colors.white
                  : context.isDarkMode
                      ? Colors.white70
                      : TailwindColors.gray600,
            ),
            SizedBox(width: context.responsiveGapSm),
            Text(
              label,
              style: TextStyle(
                fontSize: context.responsiveTextSm,
                fontWeight: FontWeight.w600,
                color: selected
                    ? Colors.white
                    : context.isDarkMode
                        ? Colors.white70
                        : TailwindColors.gray700,
              ),
            ),
          ],
        ),
      ),
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
        _buildTextFormField(
          controller: _username,
          label: 'Username',
          icon: Icons.person,
          validator: (v) =>
              v != null && v.trim().length >= 3 ? null : 'Enter username (min 3 chars)',
        ),
        SizedBox(height: context.responsiveGap),
        _buildTextFormField(
          controller: _password,
          label: 'Password',
          icon: Icons.lock,
          obscureText: true,
          validator: (v) {
            if (_facilityId != null) return null; // password optional when updating
            return v != null && v.length >= 6 ? null : 'Min 6 characters';
          },
        ),
        SizedBox(height: context.responsiveGap),
        _buildTextFormField(
          controller: _confirm,
          label: 'Confirm Password',
          icon: Icons.lock_outline,
          obscureText: true,
          validator: (v) {
            if (_password.text.isEmpty) return null;
            return v != null && v == _password.text
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
        _buildTextFormField(
          controller: _name,
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
    if (_facilityType == 'hospital') {
      return _buildHospitalTypeSection();
    } else if (_facilityType == 'pharmacy') {
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
            value: _hospitalType,
            items: (_hospitalTypeOptions.contains(_hospitalType)
                    ? _hospitalTypeOptions
                    : [..._hospitalTypeOptions, _hospitalType])
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) {
              _setHospitalType(v ?? 'General Hospitals');
              _updateServicesForTypeChange();
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
            value: _pharmacyType,
            items: (_pharmacyTypeOptions.contains(_pharmacyType)
                    ? _pharmacyTypeOptions
                    : [..._pharmacyTypeOptions, _pharmacyType])
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) {
              _setPharmacyType(v ?? 'Hospital Pharmacy');
              _updateServicesForTypeChange();
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
              child: _buildChoiceChip(
                label: 'Private',
                selected: _ownership.toLowerCase() == 'private',
                onSelected: (_) => _setOwnership('Private'),
                icon: Icons.business,
              ),
            ),
            SizedBox(width: context.responsiveGap),
            Expanded(
              child: _buildChoiceChip(
                label: 'Public',
                selected: _ownership.toLowerCase() == 'public',
                onSelected: (_) => _setOwnership('Public'),
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
          children: _currentServices.map((service) {
            final selected = _selectedServices.contains(service);
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
              onSelected: (v) => _toggleService(service),
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
        _buildTextFormField(
          controller: _phone,
          label: 'Primary Phone',
          icon: Icons.phone,
          validator: (v) =>
              v != null && v.trim().isNotEmpty ? null : 'Enter contact phone',
        ),
        SizedBox(height: context.responsiveGap),
        _buildTextFormField(
          controller: _altPhone,
          label: 'Additional Phone (Optional)',
          icon: Icons.phone_android,
        ),
      ],
    );
  }

  Widget _buildPharmacySpecificSection() {
    if (_facilityType != 'pharmacy') return const SizedBox.shrink();
    
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
                value: _twentyFour,
                onChanged: _setTwentyFour,
                activeColor: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
        SizedBox(height: context.responsiveGap),
        _buildTextFormField(
          controller: _medicineAvailability,
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
        _buildTextFormField(
          controller: _email,
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
              child: _buildChoiceChip(
                label: '24/7',
                selected: _opening == '24/7',
                onSelected: (_) => _setOpening('24/7'),
                icon: Icons.all_inclusive,
              ),
            ),
            SizedBox(width: context.responsiveGap),
            Expanded(
              child: _buildChoiceChip(
                label: 'Custom',
                selected: _opening == 'custom',
                onSelected: (_) => _setOpening('custom'),
                icon: Icons.schedule,
              ),
            ),
          ],
        ),
        if (_opening == 'custom') ...[
          SizedBox(height: context.responsiveGap),
          _buildTextFormField(
            controller: _openingCustom,
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
                value: _isEmergency,
                onChanged: _setEmergency,
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
                    onPressed: _pickLocation,
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
              if (_locLat != null) ...[
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
                        'Lat: ${_locLat!.toStringAsFixed(4)}, Lng: ${_locLng!.toStringAsFixed(4)}',
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
          controller: _notes,
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
