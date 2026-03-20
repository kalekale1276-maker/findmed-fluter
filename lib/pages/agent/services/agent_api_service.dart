import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../services/api.dart';
import '../models/agent_models.dart';

/// API service for agent operations
class AgentApiService {
  static const String _baseUrl = '/facilities';

  /// Login existing facility
  static Future<AgentFacility> loginAgent(String username, String password) async {
    final res = await Api.post('$_baseUrl/login', {
      'username': username.trim(),
      'password': password,
    });

    if (res == null) {
      throw Exception('Failed to login facility');
    }

    final facility = AgentFacility.fromResponse(res);
    await _persistAgentData(facility.id, facility.type);
    return facility;
  }

  /// Register new facility
  static Future<AgentFacility> registerAgent(AgentFacility facility) async {
    final res = await Api.post(_baseUrl, facility.toPayload());

    if (res == null) {
      throw Exception('Failed to register facility');
    }

    final facilityId = res['_id'] ?? res['id'];
    if (facilityId != null) {
      await _persistAgentData(facilityId.toString(), facility.type);
    }

    return AgentFacility.fromResponse(res);
  }

  /// Update existing facility
  static Future<AgentFacility> updateAgent(String facilityId, AgentFacility facility) async {
    final res = await Api.put('$_baseUrl/$facilityId', facility.toPayload());

    if (res == null) {
      throw Exception('Failed to update facility');
    }

    await _persistAgentData(facilityId, facility.type);
    return AgentFacility.fromResponse(res);
  }

  /// Get facility details
  static Future<AgentFacility?> getFacility(String facilityId) async {
    try {
      final res = await Api.get('$_baseUrl/$facilityId');
      if (res != null) {
        return AgentFacility.fromResponse(res);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching facility: $e');
      return null;
    }
  }

  /// Persist agent data locally
  static Future<void> _persistAgentData(String facilityId, String facilityType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('agentId', facilityId);
      await prefs.setString('agentFacilityType', facilityType);
    } catch (e) {
      debugPrint('Error persisting agent data: $e');
    }
  }

  /// Get stored agent data
  static Future<Map<String, String?>> getStoredAgentData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'agentId': prefs.getString('agentId'),
        'agentFacilityType': prefs.getString('agentFacilityType'),
      };
    } catch (e) {
      debugPrint('Error getting stored agent data: $e');
      return {'agentId': null, 'agentFacilityType': null};
    }
  }

  /// Clear stored agent data
  static Future<void> clearStoredAgentData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('agentId');
      await prefs.remove('agentFacilityType');
    } catch (e) {
      debugPrint('Error clearing stored agent data: $e');
    }
  }

  /// Validate facility data
  static String? validateFacility(AgentFacility facility) {
    // Basic validation
    if (facility.name.trim().length < 3) {
      return 'Facility name must be at least 3 characters';
    }

    if (facility.phone.trim().isEmpty) {
      return 'Contact phone is required';
    }

    // Service validation for hospitals and pharmacies
    if ((facility.type == 'hospital' || facility.type == 'pharmacy') &&
        facility.services.isEmpty) {
      return 'Please select at least one service for the selected facility type';
    }

    // Password validation for new registration
    if (facility.id == null && facility.password != null && facility.password!.length < 6) {
      return 'Password must be at least 6 characters';
    }

    // Username validation for new registration
    if (facility.id == null && facility.username != null && facility.username!.trim().length < 3) {
      return 'Username must be at least 3 characters';
    }

    return null; // No validation errors
  }

  /// Get services for facility type
  static List<String> getServicesForFacility(String facilityType, String? specificType) {
    if (facilityType == 'hospital') {
      return AgentConstants.hospitalServicesByType[specificType ?? 'General Hospitals'] ?? [];
    } else if (facilityType == 'pharmacy') {
      return AgentConstants.pharmacyServicesByType[specificType ?? 'Hospital Pharmacy'] ?? [];
    }
    return [];
  }

  /// Check if facility type requires specific type selection
  static bool requiresSpecificType(String facilityType) {
    return facilityType == 'hospital' || facilityType == 'pharmacy';
  }

  /// Get specific type options for facility type
  static List<String> getSpecificTypeOptions(String facilityType) {
    if (facilityType == 'hospital') {
      return AgentConstants.hospitalTypeOptions;
    } else if (facilityType == 'pharmacy') {
      return AgentConstants.pharmacyTypeOptions;
    }
    return [];
  }
}
