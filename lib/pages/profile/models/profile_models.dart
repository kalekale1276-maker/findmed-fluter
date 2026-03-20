/// Models and constants for profile functionality
class ProfileConstants {
  // UI labels
  static const String pageTitle = 'Profile';
  static const String personalInfoTitle = 'Personal Information';
  static const String medicalProfileTitle = 'Medical Profile';
  static const String savedFacilitiesTitle = 'Saved facilities';
  static const String changePasswordTitle = 'Change password';
  static const String connectTelegramTitle = 'Connect Telegram Bot';
  
  // Form labels
  static const String fullNameLabel = 'Full name';
  static const String emailLabel = 'Email';
  static const String phoneLabel = 'Phone';
  static const String ageLabel = 'Age';
  static const String conditionsLabel = 'Conditions';
  static const String allergiesLabel = 'Allergies';
  static const String medicationsLabel = 'Medications';
  
  // Button labels
  static const String saveLabel = 'Save';
  static const String editLabel = 'Edit';
  static const String logoutLabel = 'Logout';
  static const String cancelLabel = 'Cancel';
  static const String connectLabel = 'Connect';
  static const String linkedLabel = 'Linked';
  
  // Messages
  static const String profileSavedMessage = 'Profile saved';
  static const String noMedicalProfileMessage = 'No medical profile set.';
  static const String agentIdLabel = 'Agent ID: ';
  static const String telegramConnectedMessage = 'Telegram connected correctly';
  static const String telegramConfirmationMessage = 'Confirmation sent to Telegram (check your messages)';
  static const String telegramLinkedMessage = 'Telegram linked and verified';
  static const String phoneMismatchMessage = 'Phone mismatch or not shared';
  static const String sharePhoneMessage = 'Please share your phone with the bot in Telegram first, then press Connect.';
  
  // Telegram dialog
  static const String telegramInstructions = 'To link Telegram, open the FindMed bot in Telegram and press the "Share my phone number" button. After sharing, you can enter the chat id below (optional) or just press Connect to have the app verify the link.';
  static const String telegramChatIdLabel = 'Telegram chat id (optional) or username';
  static const String alreadyConnectedMessage = 'Already connected: ';
  
  // Validation messages
  static const String nameRequiredMessage = 'Enter name';
  static const String nameMinLengthMessage = 'Name must be at least 2 characters';
  static const String ageInvalidMessage = 'Enter valid age';
  
  // Animation durations
  static const int animationDurationMs = 300;
  static const int httpTimeoutSeconds = 60;
  
  // Bot settings
  static const String defaultBotPort = '3001';
  static const String androidBotHost = 'http://10.0.2.2';
  static const String iosBotHost = 'http://127.0.0.1';
  
  // Phone formatting
  static const String ethiopiaCountryCode = '+251';
  static const int ethiopiaPhoneLength = 10;
  static const int ethiopiaMobilePrefix = 9;
  static const int ethiopiaMobileLength = 9;
}

/// User profile model
class UserProfile {
  final String id;
  final String? fullName;
  final String? email;
  final String? phone;
  final int? age;
  final List<String> medicalConditions;
  final List<String> allergies;
  final List<String> medications;
  final String? telegramUsername;
  final String? telegramChatId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? agentId;
  final String? agentFacilityType;

  UserProfile({
    required this.id,
    this.fullName,
    this.email,
    this.phone,
    this.age,
    this.medicalConditions = const [],
    this.allergies = const [],
    this.medications = const [],
    this.telegramUsername,
    this.telegramChatId,
    this.createdAt,
    this.updatedAt,
    this.agentId,
    this.agentFacilityType,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? json['name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      age: _toInt(json['age']),
      medicalConditions: _parseList(json['medicalConditions']),
      allergies: _parseList(json['allergies']),
      medications: _parseList(json['medications']),
      telegramUsername: json['telegramUsername']?.toString(),
      telegramChatId: json['telegramChatId']?.toString(),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      agentId: json['agentId']?.toString(),
      agentFacilityType: json['agentFacilityType']?.toString(),
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

  /// Parse int
  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Parse date time
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (e) {
      return null;
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'age': age,
      'medicalConditions': medicalConditions,
      'allergies': allergies,
      'medications': medications,
      'telegramUsername': telegramUsername,
      'telegramChatId': telegramChatId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'agentId': agentId,
      'agentFacilityType': agentFacilityType,
    };
  }

  /// Create copy with updated fields
  UserProfile copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    int? age,
    List<String>? medicalConditions,
    List<String>? allergies,
    List<String>? medications,
    String? telegramUsername,
    String? telegramChatId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? agentId,
    String? agentFacilityType,
  }) {
    return UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      allergies: allergies ?? this.allergies,
      medications: medications ?? this.medications,
      telegramUsername: telegramUsername ?? this.telegramUsername,
      telegramChatId: telegramChatId ?? this.telegramChatId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      agentId: agentId ?? this.agentId,
      agentFacilityType: agentFacilityType ?? this.agentFacilityType,
    );
  }

  /// Check if has medical profile
  bool get hasMedicalProfile => 
      medicalConditions.isNotEmpty || allergies.isNotEmpty || medications.isNotEmpty;

  /// Check if is agent
  bool get isAgent => agentId != null && agentId!.isNotEmpty;

  /// Check if telegram is linked
  bool get isTelegramLinked => 
      (telegramUsername?.isNotEmpty == true) || (telegramChatId?.isNotEmpty == true);

  /// Get display name
  String get displayName => fullName?.isNotEmpty == true ? fullName! : 'User';

  /// Get initials
  String get initials {
    if (fullName?.isNotEmpty == true) {
      final names = fullName!.split(' ');
      if (names.length >= 2) {
        return '${names[0][0]}${names[1][0]}'.toUpperCase();
      }
      return fullName![0].toUpperCase();
    }
    return 'U';
  }

  /// Get formatted medical conditions
  String get formattedConditions => medicalConditions.join(', ');

  /// Get formatted allergies
  String get formattedAllergies => allergies.join(', ');

  /// Get formatted medications
  String get formattedMedications => medications.join(', ');

  /// Get telegram display name
  String get telegramDisplayName {
    if (telegramUsername?.isNotEmpty == true) return telegramUsername!;
    if (telegramChatId?.isNotEmpty == true) return telegramChatId!;
    return '';
  }

  /// Get agent facility icon
  String get agentFacilityIcon {
    if (agentFacilityType?.toLowerCase() == 'pharmacy') {
      return 'local_pharmacy';
    }
    return 'medical_services';
  }
}

/// Profile form data model
class ProfileFormData {
  final String fullName;
  final String phone;
  final int? age;
  final List<String> medicalConditions;
  final List<String> allergies;
  final List<String> medications;

  ProfileFormData({
    required this.fullName,
    required this.phone,
    this.age,
    this.medicalConditions = const [],
    this.allergies = const [],
    this.medications = const [],
  });

  /// Create from user profile
  factory ProfileFormData.fromProfile(UserProfile profile) {
    return ProfileFormData(
      fullName: profile.fullName ?? '',
      phone: profile.phone ?? '',
      age: profile.age,
      medicalConditions: profile.medicalConditions,
      allergies: profile.allergies,
      medications: profile.medications,
    );
  }

  /// Validate form data
  ValidationResult validate() {
    final errors = <String>[];
    
    if (fullName.trim().isEmpty) {
      errors.add(ProfileConstants.nameRequiredMessage);
    } else if (fullName.trim().length < 2) {
      errors.add(ProfileConstants.nameMinLengthMessage);
    }
    
    if (age != null && (age! < 0 || age! > 150)) {
      errors.add(ProfileConstants.ageInvalidMessage);
    }
    
    return errors.isEmpty 
        ? ValidationResult.valid 
        : ValidationResult.invalid(errors.join(', '));
  }

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'fullName': fullName.trim(),
      'phone': _normalizePhone(phone),
      'medicalConditions': medicalConditions,
      'allergies': allergies,
      'medications': medications,
    };
    
    if (age != null) {
      data['age'] = age;
    }
    
    return data;
  }

  /// Normalize phone number
  static String _normalizePhone(String raw) {
    if (raw.isEmpty) return '';
    
    String p = raw.trim();
    p = p.replaceAll(RegExp(r'[^0-9+]'), '');
    
    // Handle Ethiopian phone numbers
    if (p.startsWith('0') && p.length == ProfileConstants.ethiopiaPhoneLength) {
      return '${ProfileConstants.ethiopiaCountryCode}${p.substring(1)}';
    }
    
    if (p.startsWith(ProfileConstants.ethiopiaMobilePrefix.toString()) && 
        p.length == ProfileConstants.ethiopiaMobileLength) {
      return '${ProfileConstants.ethiopiaCountryCode}$p';
    }
    
    return p;
  }

  /// Check if form is dirty (has been modified)
  bool get isDirty => fullName.isNotEmpty || phone.isNotEmpty || age != null;
}

/// Profile state model
class ProfileState {
  final UserProfile? profile;
  final bool isLoading;
  final bool isSaving;
  final bool isEditing;
  final String? error;
  final ProfileFormData? formData;

  ProfileState({
    this.profile,
    this.isLoading = false,
    this.isSaving = false,
    this.isEditing = false,
    this.error,
    this.formData,
  });

  ProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    bool? isSaving,
    bool? isEditing,
    String? error,
    ProfileFormData? formData,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isEditing: isEditing ?? this.isEditing,
      error: error ?? this.error,
      formData: formData ?? this.formData,
    );
  }

  /// Clear error
  ProfileState clearError() => copyWith(error: null);

  /// Set loading
  ProfileState setLoading(bool loading) => copyWith(isLoading: loading, error: null);

  /// Set saving
  ProfileState setSaving(bool saving) => copyWith(isSaving: saving, error: null);

  /// Set error
  ProfileState setError(String error) => copyWith(isLoading: false, isSaving: false, error: error);

  /// Set editing mode
  ProfileState setEditing(bool editing) => copyWith(isEditing: editing);

  /// Update profile
  ProfileState updateProfile(UserProfile newProfile) {
    return copyWith(profile: newProfile);
  }

  /// Update form data
  ProfileState updateFormData(ProfileFormData newFormData) {
    return copyWith(formData: newFormData);
  }

  /// Check if has error
  bool get hasError => error != null;

  /// Check if is loading
  bool get isAnyLoading => isLoading || isSaving;

  /// Check if can save
  bool get canSave => !isLoading && !isSaving && isEditing;

  /// Check if has profile
  bool get hasProfile => profile != null;
}

/// Telegram connection model
class TelegramConnection {
  final String chatId;
  final String? username;
  final bool isLinked;
  final bool isVerified;
  final String? message;

  TelegramConnection({
    required this.chatId,
    this.username,
    this.isLinked = false,
    this.isVerified = false,
    this.message,
  });

  factory TelegramConnection.fromJson(Map<String, dynamic> json) {
    return TelegramConnection(
      chatId: json['chatId']?.toString() ?? '',
      username: json['username']?.toString(),
      isLinked: json['linked'] == true,
      isVerified: json['ok'] == true,
      message: json['message']?.toString(),
    );
  }

  /// Get display name
  String get displayName => username?.isNotEmpty == true ? username! : chatId;

  /// Get connection status
  String get status {
    if (isVerified) return 'Verified';
    if (isLinked) return 'Linked';
    return 'Not connected';
  }
}

/// Profile action result
class ProfileResult {
  final bool success;
  final String? message;
  final UserProfile? profile;

  ProfileResult({
    required this.success,
    this.message,
    this.profile,
  });

  factory ProfileResult.success({
    String? message,
    UserProfile? profile,
  }) {
    return ProfileResult(
      success: true,
      message: message ?? ProfileConstants.profileSavedMessage,
      profile: profile,
    );
  }

  factory ProfileResult.failure(String message) {
    return ProfileResult(
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

/// Profile statistics
class ProfileStatistics {
  final int totalProfiles;
  final int agentProfiles;
  final int telegramLinkedProfiles;
  final double averageAge;
  final Map<String, int> facilityTypes;
  final DateTime lastUpdated;

  ProfileStatistics({
    required this.totalProfiles,
    required this.agentProfiles,
    required this.telegramLinkedProfiles,
    required this.averageAge,
    required this.facilityTypes,
    required this.lastUpdated,
  });

  /// Get agent percentage
  double get agentPercentage {
    if (totalProfiles == 0) return 0.0;
    return agentProfiles / totalProfiles;
  }

  /// Get telegram linked percentage
  double get telegramLinkedPercentage {
    if (totalProfiles == 0) return 0.0;
    return telegramLinkedProfiles / totalProfiles;
  }

  /// Get most common facility type
  String? get mostCommonFacilityType {
    if (facilityTypes.isEmpty) return null;
    
    return facilityTypes.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Check if has data
  bool get hasData => totalProfiles > 0;
}

/// Profile export data
class ProfileExport {
  final UserProfile profile;
  final DateTime exportedAt;
  final String format;

  ProfileExport({
    required this.profile,
    required this.exportedAt,
    this.format = 'json',
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'profile': profile.toJson(),
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
    buffer.writeln('Field,Value');
    
    // Profile data
    buffer.writeln('Full Name,"${profile.fullName ?? ''}"');
    buffer.writeln('Email,"${profile.email ?? ''}"');
    buffer.writeln('Phone,"${profile.phone ?? ''}"');
    buffer.writeln('Age,"${profile.age ?? ''}"');
    buffer.writeln('Medical Conditions,"${profile.formattedConditions}"');
    buffer.writeln('Allergies,"${profile.formattedAllergies}"');
    buffer.writeln('Medications,"${profile.formattedMedications}"');
    buffer.writeln('Telegram Username,"${profile.telegramUsername ?? ''}"');
    buffer.writeln('Telegram Chat ID,"${profile.telegramChatId ?? ''}"');
    buffer.writeln('Agent ID,"${profile.agentId ?? ''}"');
    buffer.writeln('Agent Facility Type,"${profile.agentFacilityType ?? ''}"');
    buffer.writeln('Created At,"${profile.createdAt?.toIso8601String() ?? ''}"');
    buffer.writeln('Updated At,"${profile.updatedAt?.toIso8601String() ?? ''}"');
    
    return buffer.toString();
  }
}
