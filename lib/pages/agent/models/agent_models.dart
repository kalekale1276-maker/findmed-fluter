/// Models and constants for the agent functionality
class AgentConstants {
  // Hospital types and services
  static const List<String> hospitalTypeOptions = [
    'General Hospitals',
    'Specialized Hospitals',
    'Internal / Medical Hospitals',
    'Surgical Hospitals',
    'Maternal & Child Hospitals',
    'Teaching & Referral Hospitals',
    'Clinics & Primary Care Facilities'
  ];

  static const Map<String, List<String>> hospitalServicesByType = {
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

  // Pharmacy types and services
  static const List<String> pharmacyTypeOptions = [
    'Hospital Pharmacy',
    'Community (Retail) Pharmacy',
    'Clinical Pharmacy',
    'Industrial Pharmacy',
    'Wholesale / Distribution Pharmacy',
    'Compounding Pharmacy',
    'Regulatory / Public Health Pharmacy'
  ];

  static const Map<String, List<String>> pharmacyServicesByType = {
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
}

/// Agent facility data model
class AgentFacility {
  String? id;
  String name;
  String type; // 'hospital' | 'pharmacy'
  String? hospitalType;
  String? pharmacyType;
  String ownership;
  List<String> services;
  String phone;
  String? altPhone;
  String? email;
  String openingHours;
  bool isEmergency;
  String notes;
  String? username;
  String? password;
  bool? twentyFour;
  String? medicineAvailability;
  double? lat;
  double? lng;

  AgentFacility({
    this.id,
    required this.name,
    required this.type,
    this.hospitalType,
    this.pharmacyType,
    required this.ownership,
    required this.services,
    required this.phone,
    this.altPhone,
    this.email,
    required this.openingHours,
    required this.isEmergency,
    required this.notes,
    this.username,
    this.password,
    this.twentyFour,
    this.medicineAvailability,
    this.lat,
    this.lng,
  });

  Map<String, dynamic> toPayload() {
    final payload = <String, dynamic>{
      'name': name.trim(),
      'type': type,
      'hospitalType': type == 'hospital' ? hospitalType : null,
      'pharmacyType': type == 'pharmacy' ? pharmacyType : null,
      'ownership': ownership.toString().toLowerCase(),
      'services': services,
      'phone': phone.trim(),
      'altPhone': altPhone?.trim(),
      'email': email?.trim(),
      'openingHours': openingHours,
      'isEmergency': isEmergency,
      'notes': notes.trim(),
    };

    if (type == 'pharmacy') {
      payload['twentyFour'] = twentyFour;
      payload['medicineAvailability'] = medicineAvailability?.trim();
    }

    if (lat != null && lng != null) {
      payload['location'] = {
        'type': 'Point',
        'coordinates': [lng, lat]
      };
    }

    if (password?.isNotEmpty == true) payload['password'] = password;
    if (username?.trim().isNotEmpty == true && password?.isNotEmpty == true) {
      payload['username'] = username?.trim();
      payload['password'] = password;
    }

    return payload;
  }

  static AgentFacility fromResponse(Map<String, dynamic> res) {
    return AgentFacility(
      id: res['_id'] ?? res['id'],
      name: (res['name'] ?? '') as String,
      type: (res['type'] ?? 'hospital') as String,
      hospitalType: (res['hospitalType']) as String?,
      pharmacyType: (res['pharmacyType']) as String?,
      ownership: (res['ownership'] ?? res['ownershipType'] ?? 'private') as String,
      services: res['services'] is List 
          ? (res['services'] as List).map((s) => s.toString()).toList()
          : [],
      phone: (res['phone'] ?? '') as String,
      altPhone: _getAltPhoneFromResponse(res),
      email: (res['email'] ?? '') as String,
      openingHours: (res['openingHours'] ?? '24/7') as String,
      isEmergency: (res['isEmergency'] ?? false) as bool,
      notes: (res['notes'] ?? '') as String,
      twentyFour: (res['twentyFour'] ?? false) as bool,
      medicineAvailability: (res['medicineAvailability'] ?? '') as String,
      lat: _getLatFromResponse(res),
      lng: _getLngFromResponse(res),
    );
  }

  static String _getAltPhoneFromResponse(Map<String, dynamic> res) {
    if (res['altPhone'] is List && (res['altPhone'] as List).isNotEmpty) {
      return (res['altPhone'][0] ?? '') as String;
    }
    return (res['altPhone'] ?? '') as String;
  }

  static double? _getLatFromResponse(Map<String, dynamic> res) {
    if (res['location'] != null && res['location']['coordinates'] is List) {
      final coords = res['location']['coordinates'];
      if (coords.length >= 2) {
        return (coords[1] as num).toDouble();
      }
    }
    return null;
  }

  static double? _getLngFromResponse(Map<String, dynamic> res) {
    if (res['location'] != null && res['location']['coordinates'] is List) {
      final coords = res['location']['coordinates'];
      if (coords.length >= 2) {
        return (coords[0] as num).toDouble();
      }
    }
    return null;
  }
}
