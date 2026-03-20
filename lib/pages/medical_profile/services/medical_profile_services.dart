import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../services/auth.dart';
import '../models/medical_profile_models.dart';

/// Services for medical profile functionality
class MedicalProfileServices {
  static const String _historyKey = 'medical_profile_history';
  static const String _profileKey = 'medical_profile_cache';

  /// Get current medical profile from auth service
  static Future<MedicalProfile?> getCurrentProfile() async {
    try {
      final authService = AuthService.instance;
      await authService.init();
      
      Map<String, dynamic>? userData = authService.user;
      
      // Try to fetch fresh profile data
      try {
        final fetched = await authService.fetchProfile();
        if (fetched != null) {
          userData = fetched;
        }
      } catch (e) {
        debugPrint('Error fetching profile: $e');
      }
      
      if (userData != null) {
        return MedicalProfile.fromAuthUser(userData);
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting current profile: $e');
      return null;
    }
  }

  /// Update medical profile
  static Future<MedicalProfileResult> updateProfile(MedicalProfile profile) async {
    try {
      final authService = AuthService.instance;
      await authService.init();
      
      // Update profile via auth service
      await authService.updateProfile({
        'medicalConditions': profile.medicalConditions,
        'allergies': profile.allergies,
        'medications': profile.medications,
      });
      
      // Add to history
      await _addToHistory(MedicalProfileHistory.fromProfile(profile));
      
      // Cache profile locally
      await _cacheProfile(profile);
      
      return MedicalProfileResult.success(profile: profile);
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return MedicalProfileResult.failure('Failed to update profile: $e');
    }
  }

  /// Clear medical profile
  static Future<MedicalProfileResult> clearProfile() async {
    try {
      final authService = AuthService.instance;
      await authService.init();
      
      // Clear profile via auth service
      await authService.updateProfile({
        'medicalConditions': [],
        'allergies': [],
        'medications': [],
      });
      
      // Add empty profile to history
      await _addToHistory(MedicalProfileHistory.fromProfile(MedicalProfile.empty()));
      
      // Clear local cache
      await _clearCache();
      
      return MedicalProfileResult.success(
        message: MedicalProfileConstants.profileClearedMessage,
        profile: MedicalProfile.empty(),
      );
    } catch (e) {
      debugPrint('Error clearing profile: $e');
      return MedicalProfileResult.failure('Failed to clear profile: $e');
    }
  }

  /// Load profile history
  static Future<List<MedicalProfileHistory>> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_historyKey);
      
      if (historyJson == null || historyJson.isEmpty) {
        return [];
      }
      
      final List<dynamic> historyList = jsonDecode(historyJson);
      return historyList
          .map((entry) => MedicalProfileHistory.fromJson(Map<String, dynamic>.from(entry as Map)))
          .toList();
    } catch (e) {
      debugPrint('Error loading history: $e');
      return [];
    }
  }

  /// Add entry to history
  static Future<void> _addToHistory(MedicalProfileHistory entry) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_historyKey);
      
      List<dynamic> historyList = [];
      if (historyJson != null && historyJson.isNotEmpty) {
        historyList = jsonDecode(historyJson);
      }
      
      // Add new entry at the beginning
      historyList.insert(0, entry.toJson());
      
      // Limit history size
      if (historyList.length > MedicalProfileConstants.historyMaxItems) {
        historyList = historyList.take(MedicalProfileConstants.historyMaxItems).toList();
      }
      
      await prefs.setString(_historyKey, jsonEncode(historyList));
    } catch (e) {
      debugPrint('Error adding to history: $e');
    }
  }

  /// Clear history
  static Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
    } catch (e) {
      debugPrint('Error clearing history: $e');
    }
  }

  /// Cache profile locally
  static Future<void> _cacheProfile(MedicalProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
    } catch (e) {
      debugPrint('Error caching profile: $e');
    }
  }

  /// Get cached profile
  static Future<MedicalProfile?> getCachedProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString(_profileKey);
      
      if (profileJson == null || profileJson.isEmpty) {
        return null;
      }
      
      return MedicalProfile.fromJson(jsonDecode(profileJson));
    } catch (e) {
      debugPrint('Error getting cached profile: $e');
      return null;
    }
  }

  /// Clear local cache
  static Future<void> _clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_profileKey);
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  /// Parse comma-separated list
  static List<String> parseList(String text) {
    return text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  /// Format list as comma-separated string
  static String formatList(List<String> items) {
    return items.join(', ');
  }

  /// Validate profile data
  static ValidationResult validateProfile(MedicalProfile profile) {
    return profile.validate();
  }

  /// Validate item text
  static ValidationResult validateItem(String text, {String? category}) {
    if (text.trim().isEmpty) {
      return ValidationResult.invalid('Item cannot be empty');
    }
    
    if (text.trim().length > MedicalProfileConstants.maxItemLength) {
      return ValidationResult.invalid('Item too long (max ${MedicalProfileConstants.maxItemLength} characters)');
    }
    
    return ValidationResult.valid;
  }

  /// Get profile statistics
  static Future<MedicalProfileStats> getProfileStatistics() async {
    try {
      final history = await loadHistory();
      
      if (history.isEmpty) {
        return MedicalProfileStats(
          totalProfiles: 0,
          averageConditions: 0,
          averageAllergies: 0,
          averageMedications: 0,
          lastUpdated: DateTime.now(),
          categoryCounts: {},
        );
      }
      
      int totalConditions = 0;
      int totalAllergies = 0;
      int totalMedications = 0;
      
      for (final entry in history) {
        totalConditions += entry.medicalConditions.length;
        totalAllergies += entry.allergies.length;
        totalMedications += entry.medications.length;
      }
      
      final categoryCounts = {
        'conditions': totalConditions,
        'allergies': totalAllergies,
        'medications': totalMedications,
      };
      
      return MedicalProfileStats(
        totalProfiles: history.length,
        averageConditions: (totalConditions / history.length).round(),
        averageAllergies: (totalAllergies / history.length).round(),
        averageMedications: (totalMedications / history.length).round(),
        lastUpdated: history.first.savedAt,
        categoryCounts: categoryCounts,
      );
    } catch (e) {
      debugPrint('Error getting profile statistics: $e');
      rethrow;
    }
  }

  /// Search history entries
  static List<MedicalProfileHistory> searchHistory(List<MedicalProfileHistory> history, String query) {
    if (query.trim().isEmpty) return history;
    
    final lowerQuery = query.toLowerCase();
    return history.where((entry) {
      // Search in conditions
      if (entry.medicalConditions.any((condition) => condition.toLowerCase().contains(lowerQuery))) {
        return true;
      }
      
      // Search in allergies
      if (entry.allergies.any((allergy) => allergy.toLowerCase().contains(lowerQuery))) {
        return true;
      }
      
      // Search in medications
      if (entry.medications.any((medication) => medication.toLowerCase().contains(lowerQuery))) {
        return true;
      }
      
      return false;
    }).toList();
  }

  /// Filter history by date range
  static List<MedicalProfileHistory> filterHistoryByDate(
    List<MedicalProfileHistory> history,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    if (startDate == null && endDate == null) return history;
    
    return history.where((entry) {
      final entryDate = entry.savedAt;
      
      if (startDate != null && entryDate.isBefore(startDate)) {
        return false;
      }
      
      if (endDate != null && entryDate.isAfter(endDate)) {
        return false;
      }
      
      return true;
    }).toList();
  }

  /// Export profile data
  static Future<MedicalProfileExport> exportProfile({
    MedicalProfile? profile,
    List<MedicalProfileHistory>? history,
    String format = 'json',
  }) async {
    try {
      final currentProfile = profile ?? await getCurrentProfile();
      final currentHistory = history ?? await loadHistory();
      
      return MedicalProfileExport(
        profile: currentProfile ?? MedicalProfile.empty(),
        history: currentHistory,
        exportedAt: DateTime.now(),
        format: format,
      );
    } catch (e) {
      debugPrint('Error exporting profile: $e');
      rethrow;
    }
  }

  /// Import profile data
  static Future<MedicalProfileResult> importProfile(String jsonData) async {
    try {
      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      
      // Extract profile data
      final profileData = data['profile'] as Map<String, dynamic>?;
      if (profileData == null) {
        return MedicalProfileResult.failure('No profile data found in import');
      }
      
      final profile = MedicalProfile.fromJson(profileData);
      
      // Validate imported data
      final validation = validateProfile(profile);
      if (!validation.isValid) {
        return MedicalProfileResult.failure('Invalid profile data: ${validation.errorMessage}');
      }
      
      // Update profile
      return await updateProfile(profile);
    } catch (e) {
      debugPrint('Error importing profile: $e');
      return MedicalProfileResult.failure('Failed to import profile: $e');
    }
  }

  /// Get profile suggestions based on common medical terms
  static List<String> getProfileSuggestions(String category) {
    switch (category.toLowerCase()) {
      case 'condition':
        return [
          'Hypertension',
          'Diabetes',
          'Asthma',
          'Heart Disease',
          'Arthritis',
          'Depression',
          'Anxiety',
          'Migraine',
          'Allergies',
          'High Cholesterol',
          'Thyroid Disorder',
          'Kidney Disease',
          'Liver Disease',
          'Cancer',
          'Epilepsy',
        ];
      case 'allergy':
        return [
          'Peanuts',
          'Tree Nuts',
          'Shellfish',
          'Milk',
          'Eggs',
          'Wheat',
          'Soy',
          'Fish',
          'Latex',
          'Pollen',
          'Dust Mites',
          'Pet Dander',
          'Mold',
          'Insect Stings',
          'Penicillin',
          'Aspirin',
        ];
      case 'medication':
        return [
          'Aspirin',
          'Ibuprofen',
          'Acetaminophen',
          'Lisinopril',
          'Metformin',
          'Atorvastatin',
          'Albuterol',
          'Omeprazole',
          'Sertraline',
          'Levothyroxine',
          'Amoxicillin',
          'Hydrochlorothiazide',
          'Simvastatin',
          'Metoprolol',
          'Amlodipine',
        ];
      default:
        return [];
    }
  }

  /// Check for potential drug interactions (basic implementation)
  static List<String> checkDrugInteractions(List<String> medications) {
    final interactions = <String>[];
    
    // Basic interaction checks (simplified)
    if (medications.any((m) => m.toLowerCase().contains('warfarin'))) {
      if (medications.any((m) => m.toLowerCase().contains('aspirin'))) {
        interactions.add('Warfarin and Aspirin may increase bleeding risk');
      }
    }
    
    if (medications.any((m) => m.toLowerCase().contains('lisinopril'))) {
      if (medications.any((m) => m.toLowerCase().contains('potassium'))) {
        interactions.add('ACE inhibitors and potassium supplements may cause hyperkalemia');
      }
    }
    
    if (medications.any((m) => m.toLowerCase().contains('sertraline'))) {
      if (medications.any((m) => m.toLowerCase().contains('maoi'))) {
        interactions.add('Sertraline and MAO inhibitors may cause serotonin syndrome');
      }
    }
    
    return interactions;
  }

  /// Get profile completeness score
  static double getProfileCompletenessScore(MedicalProfile profile) {
    int completedFields = 0;
    
    if (profile.medicalConditions.isNotEmpty) completedFields++;
    if (profile.allergies.isNotEmpty) completedFields++;
    if (profile.medications.isNotEmpty) completedFields++;
    
    return completedFields / 3.0;
  }

  /// Get profile health tips based on data
  static List<String> getHealthTips(MedicalProfile profile) {
    final tips = <String>[];
    
    if (profile.medicalConditions.isNotEmpty) {
      tips.add('Keep your medical conditions updated for better emergency care');
    }
    
    if (profile.allergies.isNotEmpty) {
      tips.add('Consider carrying allergy information with you at all times');
    }
    
    if (profile.medications.isNotEmpty) {
      tips.add('Keep an updated list of medications for healthcare providers');
    }
    
    if (profile.totalItems > 10) {
      tips.add('Consider organizing your medical information for easier management');
    }
    
    if (profile.isEmpty) {
      tips.add('Adding basic medical information can help in emergency situations');
    }
    
    return tips;
  }

  /// Sync profile with backend
  static Future<MedicalProfileResult> syncProfile() async {
    try {
      // Get current profile
      final currentProfile = await getCurrentProfile();
      if (currentProfile == null) {
        return MedicalProfileResult.failure('No profile to sync');
      }
      
      // Re-save to ensure backend is up to date
      return await updateProfile(currentProfile);
    } catch (e) {
      debugPrint('Error syncing profile: $e');
      return MedicalProfileResult.failure('Sync failed: $e');
    }
  }

  /// Backup profile data
  static Future<bool> backupProfile() async {
    try {
      final profile = await getCurrentProfile();
      if (profile == null) return false;
      
      final history = await loadHistory();
      
      // Create backup data
      final backupData = {
        'profile': profile.toJson(),
        'history': history.map((h) => h.toJson()).toList(),
        'backupDate': DateTime.now().toIso8601String(),
        'version': '1.0',
      };
      
      // Save backup to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('medical_profile_backup', jsonEncode(backupData));
      
      return true;
    } catch (e) {
      debugPrint('Error backing up profile: $e');
      return false;
    }
  }

  /// Restore profile from backup
  static Future<MedicalProfileResult> restoreProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final backupJson = prefs.getString('medical_profile_backup');
      
      if (backupJson == null || backupJson.isEmpty) {
        return MedicalProfileResult.failure('No backup found');
      }
      
      final backupData = jsonDecode(backupJson) as Map<String, dynamic>;
      final profileData = backupData['profile'] as Map<String, dynamic>?;
      
      if (profileData == null) {
        return MedicalProfileResult.failure('Invalid backup data');
      }
      
      final profile = MedicalProfile.fromJson(profileData);
      return await updateProfile(profile);
    } catch (e) {
      debugPrint('Error restoring profile: $e');
      return MedicalProfileResult.failure('Restore failed: $e');
    }
  }

  /// Get profile summary for sharing
  static String getProfileSummary(MedicalProfile profile) {
    final buffer = StringBuffer();
    
    buffer.writeln('Medical Profile Summary');
    buffer.writeln('=====================');
    buffer.writeln();
    
    if (profile.medicalConditions.isNotEmpty) {
      buffer.writeln('Conditions:');
      for (final condition in profile.medicalConditions) {
        buffer.writeln('  • $condition');
      }
      buffer.writeln();
    }
    
    if (profile.allergies.isNotEmpty) {
      buffer.writeln('Allergies:');
      for (final allergy in profile.allergies) {
        buffer.writeln('  • $allergy');
      }
      buffer.writeln();
    }
    
    if (profile.medications.isNotEmpty) {
      buffer.writeln('Medications:');
      for (final medication in profile.medications) {
        buffer.writeln('  • $medication');
      }
      buffer.writeln();
    }
    
    if (profile.lastUpdated != null) {
      buffer.writeln('Last Updated: ${profile.lastUpdated!.toLocal()}');
    }
    
    return buffer.toString();
  }
}
