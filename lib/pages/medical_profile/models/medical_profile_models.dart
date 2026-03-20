/// Models and constants for medical profile functionality
class MedicalProfileConstants {
  // UI labels
  static const String pageTitle = 'Medical Profile';
  static const String profileTab = 'Profile';
  static const String historyTab = 'History';
  static const String savedProfileTitle = 'Saved Profile';
  static const String medicalConditionsTitle = 'Medical Conditions';
  static const String allergiesTitle = 'Allergies';
  static const String medicationsTitle = 'Medications';
  static const String editLabel = 'Edit';
  static const String deleteLabel = 'Delete';
  static const String saveLabel = 'Save';
  static const String cancelLabel = 'Cancel';
  static const String addLabel = 'Add';
  
  // Add item dialogs
  static const String addConditionTitle = 'Add condition';
  static const String addAllergyTitle = 'Add allergy';
  static const String addMedicationTitle = 'Add medication';
  static const String conditionLabel = 'Condition';
  static const String allergyLabel = 'Allergy';
  static const String medicationLabel = 'Medication';
  
  // Messages
  static const String profileSavedMessage = 'Medical profile saved';
  static const String profileClearedMessage = 'Profile cleared';
  static const String deleteProfileTitle = 'Delete profile data';
  static const String deleteProfileMessage = 'This will remove your saved medical profile (conditions, allergies, medications). Continue?';
  static const String deleteFailedMessage = 'Failed to delete: ';
  static const String noHistoryMessage = 'No history';
  static const String savedProfileLabel = 'Saved profile';
  
  // Hints
  static const String commaSeparatedHint = 'Comma separated';
  static const String conditionsHint = 'Enter your medical conditions';
  static const String allergiesHint = 'Enter your allergies';
  static const String medicationsHint = 'Enter your medications';
  
  // Animation durations
  static const int animationDurationMs = 300;
  static const int historyMaxItems = 50;
  
  // Validation
  static const int maxItemLength = 100;
  static const int maxTotalItems = 50;
}

/// Medical profile data model
class MedicalProfile {
  final List<String> medicalConditions;
  final List<String> allergies;
  final List<String> medications;
  final DateTime? lastUpdated;
  final String? userId;

  MedicalProfile({
    required this.medicalConditions,
    required this.allergies,
    required this.medications,
    this.lastUpdated,
    this.userId,
  });

  factory MedicalProfile.empty() {
    return MedicalProfile(
      medicalConditions: [],
      allergies: [],
      medications: [],
      lastUpdated: DateTime.now(),
    );
  }

  factory MedicalProfile.fromJson(Map<String, dynamic> json) {
    return MedicalProfile(
      medicalConditions: _parseList(json['medicalConditions']),
      allergies: _parseList(json['allergies']),
      medications: _parseList(json['medications']),
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.tryParse(json['lastUpdated'].toString())
          : null,
      userId: json['userId']?.toString(),
    );
  }

  factory MedicalProfile.fromAuthUser(Map<String, dynamic> user) {
    return MedicalProfile(
      medicalConditions: _parseList(user['medicalConditions']),
      allergies: _parseList(user['allergies']),
      medications: _parseList(user['medications']),
      lastUpdated: DateTime.now(),
      userId: user['id']?.toString() ?? user['_id']?.toString(),
    );
  }

  /// Parse list from various formats
  static List<String> _parseList(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
    }
    if (data is String) {
      return data.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return [];
  }

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'medicalConditions': medicalConditions,
      'allergies': allergies,
      'medications': medications,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'userId': userId,
    };
  }

  /// Create copy with updated fields
  MedicalProfile copyWith({
    List<String>? medicalConditions,
    List<String>? allergies,
    List<String>? medications,
    DateTime? lastUpdated,
    String? userId,
  }) {
    return MedicalProfile(
      medicalConditions: medicalConditions ?? this.medicalConditions,
      allergies: allergies ?? this.allergies,
      medications: medications ?? this.medications,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      userId: userId ?? this.userId,
    );
  }

  /// Check if profile is empty
  bool get isEmpty => medicalConditions.isEmpty && allergies.isEmpty && medications.isEmpty;

  /// Check if profile has data
  bool get hasData => !isEmpty;

  /// Get total number of items
  int get totalItems => medicalConditions.length + allergies.length + medications.length;

  /// Get formatted medical conditions string
  String get formattedConditions => medicalConditions.join(', ');

  /// Get formatted allergies string
  String get formattedAllergies => allergies.join(', ');

  /// Get formatted medications string
  String get formattedMedications => medications.join(', ');

  /// Validate profile data
  ValidationResult validate() {
    final errors = <String>[];
    
    // Check total items limit
    if (totalItems > MedicalProfileConstants.maxTotalItems) {
      errors.add('Too many items (max ${MedicalProfileConstants.maxTotalItems})');
    }
    
    // Check individual item lengths
    for (final condition in medicalConditions) {
      if (condition.length > MedicalProfileConstants.maxItemLength) {
        errors.add('Condition too long: ${condition.substring(0, 20)}...');
      }
    }
    
    for (final allergy in allergies) {
      if (allergy.length > MedicalProfileConstants.maxItemLength) {
        errors.add('Allergy too long: ${allergy.substring(0, 20)}...');
      }
    }
    
    for (final medication in medications) {
      if (medication.length > MedicalProfileConstants.maxItemLength) {
        errors.add('Medication too long: ${medication.substring(0, 20)}...');
      }
    }
    
    return errors.isEmpty 
        ? ValidationResult.valid 
        : ValidationResult.invalid(errors.join(', '));
  }

  /// Add item to specific category
  MedicalProfile addItem(String category, String item) {
    final trimmedItem = item.trim();
    if (trimmedItem.isEmpty) return this;
    
    switch (category.toLowerCase()) {
      case 'condition':
        return copyWith(medicalConditions: [...medicalConditions, trimmedItem]);
      case 'allergy':
        return copyWith(allergies: [...allergies, trimmedItem]);
      case 'medication':
        return copyWith(medications: [...medications, trimmedItem]);
      default:
        return this;
    }
  }

  /// Remove item from specific category
  MedicalProfile removeItem(String category, String item) {
    final trimmedItem = item.trim();
    
    switch (category.toLowerCase()) {
      case 'condition':
        return copyWith(medicalConditions: medicalConditions.where((c) => c != trimmedItem).toList());
      case 'allergy':
        return copyWith(allergies: allergies.where((a) => a != trimmedItem).toList());
      case 'medication':
        return copyWith(medications: medications.where((m) => m != trimmedItem).toList());
      default:
        return this;
    }
  }

  /// Clear all data
  MedicalProfile clear() {
    return MedicalProfile.empty();
  }
}

/// Medical profile history entry
class MedicalProfileHistory {
  final List<String> medicalConditions;
  final List<String> allergies;
  final List<String> medications;
  final DateTime savedAt;
  final String? userId;

  MedicalProfileHistory({
    required this.medicalConditions,
    required this.allergies,
    required this.medications,
    required this.savedAt,
    this.userId,
  });

  factory MedicalProfileHistory.fromJson(Map<String, dynamic> json) {
    return MedicalProfileHistory(
      medicalConditions: MedicalProfile._parseList(json['medicalConditions']),
      allergies: MedicalProfile._parseList(json['allergies']),
      medications: MedicalProfile._parseList(json['medications']),
      savedAt: DateTime.tryParse(json['savedAt'].toString()) ?? DateTime.now(),
      userId: json['userId']?.toString(),
    );
  }

  factory MedicalProfileHistory.fromProfile(MedicalProfile profile) {
    return MedicalProfileHistory(
      medicalConditions: profile.medicalConditions,
      allergies: profile.allergies,
      medications: profile.medications,
      savedAt: DateTime.now(),
      userId: profile.userId,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'medicalConditions': medicalConditions,
      'allergies': allergies,
      'medications': medications,
      'savedAt': savedAt.toIso8601String(),
      'userId': userId,
    };
  }

  /// Get formatted date
  String get formattedDate {
    return '${savedAt.day}/${savedAt.month}/${savedAt.year} ${savedAt.hour.toString().padLeft(2, '0')}:${savedAt.minute.toString().padLeft(2, '0')}';
  }

  /// Get formatted date for display
  String get displayDate {
    final now = DateTime.now();
    final difference = now.difference(savedAt);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return formattedDate;
    }
  }

  /// Get formatted conditions
  String get formattedConditions => medicalConditions.join(', ');

  /// Get formatted allergies
  String get formattedAllergies => allergies.join(', ');

  /// Get formatted medications
  String get formattedMedications => medications.join(', ');

  /// Check if entry is empty
  bool get isEmpty => medicalConditions.isEmpty && allergies.isEmpty && medications.isEmpty;

  /// Check if entry has data
  bool get hasData => !isEmpty;

  /// Get total items
  int get totalItems => medicalConditions.length + allergies.length + medications.length;
}

/// Medical profile state model
class MedicalProfileState {
  final MedicalProfile profile;
  final List<MedicalProfileHistory> history;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final bool isEditing;

  const MedicalProfileState({
    required this.profile,
    this.history = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.isEditing = false,
  });

  MedicalProfileState copyWith({
    MedicalProfile? profile,
    List<MedicalProfileHistory>? history,
    bool? isLoading,
    bool? isSaving,
    String? error,
    bool? isEditing,
  }) {
    return MedicalProfileState(
      profile: profile ?? this.profile,
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error ?? this.error,
      isEditing: isEditing ?? this.isEditing,
    );
  }

  /// Clear error
  MedicalProfileState clearError() => copyWith(error: null);

  /// Set loading
  MedicalProfileState setLoading(bool loading) => copyWith(isLoading: loading, error: null);

  /// Set saving
  MedicalProfileState setSaving(bool saving) => copyWith(isSaving: saving, error: null);

  /// Set error
  MedicalProfileState setError(String error) => copyWith(isLoading: false, isSaving: false, error: error);

  /// Set editing mode
  MedicalProfileState setEditing(bool editing) => copyWith(isEditing: editing);

  /// Update profile
  MedicalProfileState updateProfile(MedicalProfile newProfile) {
    return copyWith(profile: newProfile);
  }

  /// Add history entry
  MedicalProfileState addHistory(MedicalProfileHistory entry) {
    final newHistory = [entry, ...history];
    if (newHistory.length > MedicalProfileConstants.historyMaxItems) {
      return copyWith(history: newHistory.take(MedicalProfileConstants.historyMaxItems).toList());
    }
    return copyWith(history: newHistory);
  }

  /// Check if has error
  bool get hasError => error != null;

  /// Check if can save
  bool get canSave => !isLoading && !isSaving && !isEditing;

  /// Check if has profile data
  bool get hasProfileData => profile.hasData;

  /// Check if has history
  bool get hasHistory => history.isNotEmpty;
}

/// Medical profile action result
class MedicalProfileResult {
  final bool success;
  final String? message;
  final MedicalProfile? profile;

  MedicalProfileResult({
    required this.success,
    this.message,
    this.profile,
  });

  factory MedicalProfileResult.success({
    String? message,
    MedicalProfile? profile,
  }) {
    return MedicalProfileResult(
      success: true,
      message: message ?? MedicalProfileConstants.profileSavedMessage,
      profile: profile,
    );
  }

  factory MedicalProfileResult.failure(String message) {
    return MedicalProfileResult(
      success: false,
      message: message,
    );
  }
}

/// Validation result
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult({required this.isValid, this.errorMessage});

  static const ValidationResult valid = ValidationResult(isValid: true);
  
  ValidationResult.invalid(String message) 
      : isValid = false, errorMessage = message;
}

/// Medical profile statistics
class MedicalProfileStats {
  final int totalProfiles;
  final int averageConditions;
  final int averageAllergies;
  final int averageMedications;
  final DateTime lastUpdated;
  final Map<String, int> categoryCounts;

  MedicalProfileStats({
    required this.totalProfiles,
    required this.averageConditions,
    required this.averageAllergies,
    required this.averageMedications,
    required this.lastUpdated,
    required this.categoryCounts,
  });

  /// Get most common category
  String? get mostCommonCategory {
    if (categoryCounts.isEmpty) return null;
    
    return categoryCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Get total items across all profiles
  int get totalItems => averageConditions + averageAllergies + averageMedications;

  /// Check if has data
  bool get hasData => totalProfiles > 0;
}

/// Medical profile export data
class MedicalProfileExport {
  final MedicalProfile profile;
  final List<MedicalProfileHistory> history;
  final DateTime exportedAt;
  final String format;

  MedicalProfileExport({
    required this.profile,
    required this.history,
    required this.exportedAt,
    this.format = 'json',
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'profile': profile.toJson(),
      'history': history.map((h) => h.toJson()).toList(),
      'exportedAt': exportedAt.toIso8601String(),
      'format': format,
      'version': '1.0',
    };
  }

  /// Export to JSON string
  String toJsonString() {
    return '''
{
  "profile": ${profile.toJson()},
  "history": ${history.map((h) => h.toJson()).toList()},
  "exportedAt": "${exportedAt.toIso8601String()}",
  "format": "$format",
  "version": "1.0"
}
''';
  }

  /// Export to CSV format
  String toCsvString() {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('Category,Item,Saved At');
    
    // Profile data
    for (final condition in profile.medicalConditions) {
      buffer.writeln('Condition,"$condition","${profile.lastUpdated?.toIso8601String() ?? ''}"');
    }
    
    for (final allergy in profile.allergies) {
      buffer.writeln('Allergy,"$allergy","${profile.lastUpdated?.toIso8601String() ?? ''}"');
    }
    
    for (final medication in profile.medications) {
      buffer.writeln('Medication,"$medication","${profile.lastUpdated?.toIso8601String() ?? ''}"');
    }
    
    // History data
    for (final entry in history) {
      for (final condition in entry.medicalConditions) {
        buffer.writeln('Condition,"$condition","${entry.savedAt.toIso8601String()}"');
      }
      
      for (final allergy in entry.allergies) {
        buffer.writeln('Allergy,"$allergy","${entry.savedAt.toIso8601String()}"');
      }
      
      for (final medication in entry.medications) {
        buffer.writeln('Medication,"$medication","${entry.savedAt.toIso8601String()}"');
      }
    }
    
    return buffer.toString();
  }
}
