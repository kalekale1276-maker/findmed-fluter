import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/agent_models.dart';
import '../services/agent_api_service.dart';

/// State management for agent functionality
class AgentStateManager extends ChangeNotifier {
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
  AgentFacility? _currentFacility;
  
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

  // Getters
  String get mode => _mode;
  GlobalKey<FormState> get formKey => _formKey;
  bool get loading => _loading;
  String? get message => _message;
  String? get facilityId => _facilityId;
  AgentFacility? get currentFacility => _currentFacility;
  
  // Form controllers getters
  TextEditingController get email => _email;
  TextEditingController get username => _username;
  TextEditingController get password => _password;
  TextEditingController get name => _name;
  TextEditingController get phone => _phone;
  TextEditingController get confirm => _confirm;
  TextEditingController get altPhone => _altPhone;
  TextEditingController get openingCustom => _openingCustom;
  TextEditingController get notes => _notes;
  TextEditingController get medicineAvailability => _medicineAvailability;
  
  // Facility configuration getters
  String get facilityType => _facilityType;
  String get hospitalType => _hospitalType;
  String get pharmacyType => _pharmacyType;
  String get ownership => _ownership;
  String get opening => _opening;
  bool get isEmergency => _isEmergency;
  bool get twentyFour => _twentyFour;
  double? get locLat => _locLat;
  double? get locLng => _locLng;
  Set<String> get selectedServices => Set.from(_selectedServices);

  // Getters for current services
  List<String> get currentServices => AgentApiService.getServicesForFacility(
    _facilityType,
    _facilityType == 'hospital' ? _hospitalType : _pharmacyType,
  );

  // State setters
  void setLoading(bool loading) {
    if (_loading != loading) {
      _loading = loading;
      notifyListeners();
    }
  }

  void setMessage(String? message) {
    if (_message != message) {
      _message = message;
      notifyListeners();
    }
  }

  void setMode(String mode) {
    if (_mode != mode) {
      _mode = mode;
      notifyListeners();
    }
  }

  void setFacilityType(String type) {
    if (_facilityType != type) {
      _facilityType = type;
      _updateServicesForTypeChange();
      notifyListeners();
    }
  }

  void setHospitalType(String type) {
    if (_hospitalType != type) {
      _hospitalType = type;
      _updateServicesForTypeChange();
      notifyListeners();
    }
  }

  void setPharmacyType(String type) {
    if (_pharmacyType != type) {
      _pharmacyType = type;
      _updateServicesForTypeChange();
      notifyListeners();
    }
  }

  void setOwnership(String ownership) {
    if (_ownership != ownership) {
      _ownership = ownership;
      notifyListeners();
    }
  }

  void setOpening(String opening) {
    if (_opening != opening) {
      _opening = opening;
      notifyListeners();
    }
  }

  void setEmergency(bool emergency) {
    if (_isEmergency != emergency) {
      _isEmergency = emergency;
      notifyListeners();
    }
  }

  void setTwentyFour(bool twentyFour) {
    if (_twentyFour != twentyFour) {
      _twentyFour = twentyFour;
      notifyListeners();
    }
  }

  void setLocation(double lat, double lng) {
    if (_locLat != lat || _locLng != lng) {
      _locLat = lat;
      _locLng = lng;
      notifyListeners();
    }
  }

  void toggleService(String service) {
    if (_selectedServices.contains(service)) {
      _selectedServices.remove(service);
    } else {
      _selectedServices.add(service);
    }
    notifyListeners();
  }

  void _updateServicesForTypeChange() {
    final availableServices = currentServices;
    _selectedServices.removeWhere((service) => !availableServices.contains(service));
  }

  // Form operations
  void populateFormFromFacility(AgentFacility facility) {
    _currentFacility = facility;
    _facilityId = facility.id;
    _name.text = facility.name;
    _email.text = facility.email ?? '';
    _phone.text = facility.phone;
    _altPhone.text = facility.altPhone ?? '';
    _facilityType = facility.type;
    _hospitalType = facility.hospitalType ?? 'General Hospitals';
    _pharmacyType = facility.pharmacyType ?? 'Hospital Pharmacy';
    _opening = facility.openingHours;
    _ownership = facility.ownership;
    _isEmergency = facility.isEmergency;
    _twentyFour = facility.twentyFour ?? false;
    _medicineAvailability.text = facility.medicineAvailability ?? '';
    _locLat = facility.lat;
    _locLng = facility.lng;
    
    _selectedServices.clear();
    _selectedServices.addAll(facility.services);
    
    notifyListeners();
  }

  void clearForm() {
    _formKey.currentState?.reset();
    _email.clear();
    _username.clear();
    _password.clear();
    _name.clear();
    _phone.clear();
    _confirm.clear();
    _altPhone.clear();
    _openingCustom.clear();
    _notes.clear();
    _medicineAvailability.clear();
    
    _facilityId = null;
    _currentFacility = null;
    _facilityType = 'hospital';
    _hospitalType = 'General Hospitals';
    _pharmacyType = 'Hospital Pharmacy';
    _ownership = 'Private';
    _opening = '24/7';
    _isEmergency = false;
    _twentyFour = false;
    _locLat = null;
    _locLng = null;
    _selectedServices.clear();
    
    notifyListeners();
  }

  AgentFacility buildFacilityFromForm() {
    return AgentFacility(
      id: _facilityId,
      name: _name.text.trim(),
      type: _facilityType,
      hospitalType: _facilityType == 'hospital' ? _hospitalType : null,
      pharmacyType: _facilityType == 'pharmacy' ? _pharmacyType : null,
      ownership: _ownership,
      services: _selectedServices.toList(),
      phone: _phone.text.trim(),
      altPhone: _altPhone.text.trim(),
      email: _email.text.trim(),
      openingHours: _opening == '24/7' ? '24/7' : _openingCustom.text.trim(),
      isEmergency: _isEmergency,
      notes: _notes.text.trim(),
      username: _username.text.trim(),
      password: _password.text,
      twentyFour: _twentyFour,
      medicineAvailability: _medicineAvailability.text.trim(),
      lat: _locLat,
      lng: _locLng,
    );
  }

  // API operations
  Future<void> loginAgent() async {
    if (!_formKey.currentState!.validate()) return;
    
    setLoading(true);
    setMessage(null);

    try {
      final facility = await AgentApiService.loginAgent(
        _username.text.trim(),
        _password.text,
      );
      
      populateFormFromFacility(facility);
      setMessage('Facility loaded successfully');
      setMode('form');
    } catch (e) {
      setMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setLoading(false);
    }
  }

  Future<void> registerAgent() async {
    if (!_formKey.currentState!.validate()) return;
    
    final facility = buildFacilityFromForm();
    final validationError = AgentApiService.validateFacility(facility);
    if (validationError != null) {
      setMessage(validationError);
      return;
    }
    
    setLoading(true);
    setMessage(null);

    try {
      final registeredFacility = await AgentApiService.registerAgent(facility);
      populateFormFromFacility(registeredFacility);
      setMessage('Agent registration successful');
    } catch (e) {
      setMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setLoading(false);
    }
  }

  Future<void> updateAgent() async {
    if (_facilityId == null) return;
    if (!_formKey.currentState!.validate()) return;
    
    final facility = buildFacilityFromForm();
    final validationError = AgentApiService.validateFacility(facility);
    if (validationError != null) {
      setMessage(validationError);
      return;
    }
    
    setLoading(true);
    setMessage(null);

    try {
      final updatedFacility = await AgentApiService.updateAgent(_facilityId!, facility);
      populateFormFromFacility(updatedFacility);
      setMessage('Facility updated successfully');
    } catch (e) {
      setMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setLoading(false);
    }
  }

  // Location services
  Future<void> pickLocation() async {
    try {
      final status = await Geolocator.checkPermission();
      if (status == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setLocation(position.latitude, position.longitude);
      setMessage('Location captured successfully');
    } catch (e) {
      setMessage('Failed to get location: ${e.toString()}');
    }
  }

  // Load stored agent data
  Future<void> loadStoredAgentData() async {
    try {
      final storedData = await AgentApiService.getStoredAgentData();
      final agentId = storedData['agentId'];
      
      if (agentId != null && agentId.isNotEmpty) {
        final facility = await AgentApiService.getFacility(agentId);
        if (facility != null) {
          populateFormFromFacility(facility);
          setMode('form');
        }
      }
    } catch (e) {
      debugPrint('Error loading stored agent data: $e');
    }
  }

  // Dispose
  void disposeControllers() {
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

  @override
  void dispose() {
    disposeControllers();
    super.dispose();
  }
}
