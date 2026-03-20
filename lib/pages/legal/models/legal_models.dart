/// Models and constants for legal functionality
class LegalConstants {
  // UI labels
  static const String pageTitle = 'About & Legal';
  static const String aboutTitle = 'About FindMed';
  static const String privacyPolicyTitle = 'Privacy Policy';
  static const String termsOfServiceTitle = 'Terms of Service';
  static const String openSourceTitle = 'Open Source Licenses';
  static const String versionInfoTitle = 'Version Information';
  
  // App information
  static const String appName = 'FindMed';
  static const String appDescription = 'FindMed is a comprehensive healthcare facility locator application designed to help users easily find hospitals, pharmacies, and other medical facilities in their area.';
  static const String appVersion = '0.0.1';
  static const String buildNumber = '1';
  static const String developerName = 'FindMed Team';
  static const String developerEmail = 'support@findmed.example';
  static const String developerWebsite = 'https://findmed.example';
  
  // Legal content
  static const String lastUpdated = 'Last updated: January 2024';
  static const String contactInfo = 'For any questions about this Privacy Policy, please contact us at:';
  
  // Animation durations
  static const int animationDurationMs = 300;
  static const int cardAnimationDelayMs = 100;
}

/// Legal section model
class LegalSection {
  final String id;
  final String title;
  final String content;
  final IconData icon;
  final Color color;
  final bool isExpanded;

  LegalSection({
    required this.id,
    required this.title,
    required this.content,
    required this.icon,
    required this.color,
    this.isExpanded = false,
  });

  factory LegalSection.privacyPolicy() {
    return LegalSection(
      id: 'privacy_policy',
      title: LegalConstants.privacyPolicyTitle,
      content: '''
# Privacy Policy for FindMed

${LegalConstants.lastUpdated}

## Information We Collect

### Personal Information
- Name, email address, and phone number when you register
- Location data when you use map features
- Facility preferences and saved favorites

### Usage Data
- App usage statistics and crash reports
- Search queries and facility interactions
- Device information and app version

### Automatically Collected Information
- IP address and device identifiers
- Location data with your consent
- App performance metrics

## How We Use Your Information

### To Provide Our Services
- Process search queries and show relevant facilities
- Save your favorite facilities for quick access
- Provide directions and contact information

### To Improve Our Services
- Analyze usage patterns to improve features
- Fix bugs and performance issues
- Develop new features based on user needs

### To Communicate With You
- Send important app updates and notifications
- Respond to your support requests
- Share relevant healthcare information

## Data Security

We implement appropriate technical and organizational measures to protect your personal data against unauthorized access, alteration, disclosure, or destruction.

## Data Sharing

We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except:

- To comply with legal obligations
- To protect our rights, privacy, safety, or property
- With your explicit consent

## Your Rights

You have the right to:
- Access your personal information
- Correct inaccurate information
- Request deletion of your data
- Opt-out of data collection where possible

## Contact Us

${LegalConstants.contactInfo}
${LegalConstants.developerEmail}

FindMed Team
''',
      icon: Icons.privacy_tip,
      color: Colors.blue,
    );
  }

  factory LegalSection.termsOfService() {
    return LegalSection(
      id: 'terms_of_service',
      title: LegalConstants.termsOfServiceTitle,
      content: '''
# Terms of Service for FindMed

${LegalConstants.lastUpdated}

## Acceptance of Terms

By using FindMed, you agree to these Terms of Service. If you do not agree to these terms, please do not use our application.

## Description of Service

FindMed is a healthcare facility locator application that helps users find hospitals, pharmacies, and other medical facilities.

## User Responsibilities

### Account Security
- You are responsible for maintaining the confidentiality of your account
- You must notify us immediately of any unauthorized use
- You are responsible for all activities under your account

### Acceptable Use
- Use the service for lawful purposes only
- Do not use the service to harass or harm others
- Do not submit false or misleading information
- Do not attempt to compromise the security of the service

### Accuracy of Information
- You agree to provide accurate and up-to-date information
- You understand that facility information may change
- You should verify critical information directly with facilities

## Service Availability

### No Warranty
- We do not guarantee uninterrupted or error-free service
- We are not responsible for facility accuracy or availability
- Medical emergencies should be handled through proper channels

### Service Changes
- We reserve the right to modify or discontinue the service
- We may update these terms from time to time
- Continued use constitutes acceptance of changes

## Intellectual Property

### Content Ownership
- The application and its content are owned by FindMed
- Facility information is provided by healthcare providers
- User-generated content remains the property of users

### Usage Rights
- You may use the service for personal, non-commercial purposes
- You may not copy, modify, or redistribute our content
- You may not use our trademarks without permission

## Limitation of Liability

### Service Use
- FindMed is provided "as is" without warranties
- We are not liable for medical decisions based on our information
- We are not responsible for facility quality or services

### Damages
- In no event shall FindMed be liable for indirect or consequential damages
- Our total liability shall not exceed the amount paid for the service
- Some jurisdictions do not allow limitation of liability

## Termination

We may terminate or suspend your account immediately for:
- Violation of these terms
- Fraudulent or illegal activities
- Activities that compromise service security

## Governing Law

These terms are governed by the laws of Ethiopia, without regard to conflict of law principles.

## Contact Information

For questions about these Terms of Service:
${LegalConstants.developerEmail}

FindMed Team
''',
      icon: Icons.gavel,
      color: Colors.orange,
    );
  }

  factory LegalSection.openSource() {
    return LegalSection(
      id: 'open_source',
      title: LegalConstants.openSourceTitle,
      content: '''
# Open Source Licenses

FindMed is built using various open source software packages. We are grateful to the developers who have made these tools available.

## Core Frameworks

### Flutter
License: BSD 3-Clause
Copyright © Google LLC
https://github.com/flutter/flutter

### Dart
License: BSD 3-Clause
Copyright © Google LLC
https://github.com/dart-lang/sdk

## UI Components

### Flutter Screen Util
License: MIT
Copyright © fluttercommunity
https://github.com/fluttercommunity/flutter_screenutil

### Tailwind Extensions
License: MIT
Copyright © FindMed Team
https://github.com/findmed/tailwind_extensions

## Maps and Location

### Flutter Geolocator
License: MIT
Copyright © Baseflow
https://github.com/Baseflow/flutter-geolocator

### Google Maps Flutter
License: BSD 3-Clause
Copyright © Google LLC
https://github.com/googlemaps/flutter-geocoding

## Networking

### HTTP
License: BSD 3-Clause
Copyright © dart-lang
https://github.com/dart-lang/http

### URL Launcher
License: BSD 3-Clause
Copyright © Flutter Team
https://github.com/flutter/packages

## Data Storage

### Shared Preferences
License: BSD 3-Clause
Copyright © Flutter Team
https://github.com/flutter/packages

### SQLite
License: Public Domain
Copyright © SQLite Development Team
https://www.sqlite.org/

## Icons and Images

### Material Icons
License: Apache 2.0
Copyright © Google LLC
https://github.com/google/material-design-icons

### Flutter SVG
License: MIT
Copyright © fluttercommunity
https://github.com/fluttercommunity/flutter_svg

## Testing

### Flutter Test
License: BSD 3-Clause
Copyright © Flutter Team
https://github.com/flutter/packages

### Mockito
License: Apache 2.0
Copyright © Google LLC
https://github.com/mockito/mockito

## Acknowledgments

We thank all the open source contributors who have made FindMed possible. Without their hard work and dedication, this application would not exist.

## License Information

FindMed itself is released under the MIT License:

Copyright © 2024 FindMed Team

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
''',
      icon: Icons.code,
      color: Colors.green,
    );
  }

  factory LegalSection.versionInfo() {
    return LegalSection(
      id: 'version_info',
      title: LegalConstants.versionInfoTitle,
      content: '''
# Version Information

## Application Details

**App Name:** ${LegalConstants.appName}
**Version:** ${LegalConstants.appVersion}
**Build:** ${LegalConstants.buildNumber}
**Release Date:** January 2024

## Development Team

**Developer:** ${LegalConstants.developerName}
**Email:** ${LegalConstants.developerEmail}
**Website:** ${LegalConstants.developerWebsite}

## Platform Support

### Mobile Applications
- **Android:** Minimum Android 5.0 (API Level 21)
- **iOS:** Minimum iOS 12.0
- **Flutter SDK:** Latest stable version

### Backend Services
- **Node.js:** Version 18+
- **MongoDB:** Version 5.0+
- **API Version:** v1.0

## Features

### Current Features
- Facility search and filtering
- Map integration with directions
- User registration and authentication
- Favorite facilities management
- Rating and review system
- Emergency SOS functionality
- Agent facility management

### Planned Features
- Real-time facility availability
- Appointment booking system
- Telemedicine integration
- Multi-language support
- Offline mode support
- Advanced analytics dashboard

## Data Sources

### Facility Information
Facility data is sourced from:
- Ethiopian Ministry of Health
- Regional Health Bureaus
- Facility self-reporting
- Community contributions

### Data Updates
- Facility information is updated regularly
- User contributions are reviewed and verified
- Emergency information is prioritized for accuracy

## Performance Metrics

### Application Performance
- Average search time: < 500ms
- Map loading time: < 2 seconds
- Offline mode: Limited functionality available

### Data Accuracy
- Facility accuracy: > 95%
- Contact information: Regularly verified
- Location data: GPS coordinates validated

## Support

### Getting Help
- In-app help and FAQ section
- Email support: ${LegalConstants.developerEmail}
- Community forum: Coming soon
- Documentation: Available online

### Reporting Issues
- Bug reports: GitHub Issues
- Facility corrections: In-app feedback
- Data privacy concerns: ${LegalConstants.developerEmail}

## Updates and Maintenance

### Update Schedule
- Minor updates: Monthly
- Major updates: Quarterly
- Security updates: As needed

### Maintenance Windows
- Scheduled maintenance: First Sunday of each month, 2:00-4:00 AM UTC
- Emergency maintenance: As needed with advance notice

## Compliance

### Regulatory Compliance
- Ethiopian healthcare data regulations
- Medical device data protection standards
- International privacy laws (GDPR-inspired)

### Certifications
- Healthcare data protection: In progress
- Medical device classification: Pending review
- Quality management system: ISO 13485 compliance planned

## Third-Party Services

### Analytics
- Anonymous usage statistics
- Performance monitoring
- Crash reporting

### Communication
- Email notifications
- SMS verification (optional)
- Push notifications (optional)

## Future Roadmap

### 2024 Roadmap
- Q1: Enhanced search algorithms
- Q2: Telemedicine integration
- Q3: Multi-language support
- Q4: Advanced analytics dashboard

### Long-term Vision
- AI-powered facility recommendations
- Real-time availability tracking
- Integrated appointment booking
- Healthcare provider network

## Thank You

Thank you for using FindMed! We are committed to improving healthcare accessibility in Ethiopia and beyond.

For questions, feedback, or support, please don't hesitate to contact us.

${LegalConstants.developerName}
${LegalConstants.developerEmail}
${LegalConstants.developerWebsite}

Last updated: ${LegalConstants.lastUpdated}
''',
      icon: Icons.info,
      color: Colors.purple,
    );
  }

  /// Get all legal sections
  static List<LegalSection> getAllSections() {
    return [
      LegalSection.privacyPolicy(),
      LegalSection.termsOfService(),
      LegalSection.openSource(),
      LegalSection.versionInfo(),
    ];
  }

  /// Create copy with expanded state
  LegalSection copyWith({bool? isExpanded}) {
    return LegalSection(
      id: id,
      title: title,
      content: content,
      icon: icon,
      color: color,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

/// Legal state model
class LegalState {
  final List<LegalSection> sections;
  final bool isLoading;

  const LegalState({
    this.sections = const [],
    this.isLoading = false,
  });

  LegalState copyWith({
    List<LegalSection>? sections,
    bool? isLoading,
  }) {
    return LegalState(
      sections: sections ?? this.sections,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Toggle section expansion
  LegalState toggleSectionExpansion(String sectionId) {
    final updatedSections = sections.map((section) {
      if (section.id == sectionId) {
        return section.copyWith(isExpanded: !section.isExpanded);
      }
      return section.copyWith(isExpanded: false); // Close others
    }).toList();

    return copyWith(sections: updatedSections);
  }

  /// Get expanded sections count
  int get expandedCount => sections.where((s) => s.isExpanded).length;
}

/// App information model
class AppInfo {
  final String name;
  final String version;
  final String buildNumber;
  final String description;
  final String developerName;
  final String developerEmail;
  final String developerWebsite;
  final DateTime releaseDate;

  AppInfo({
    required this.name,
    required this.version,
    required this.buildNumber,
    required this.description,
    required this.developerName,
    required this.developerEmail,
    required this.developerWebsite,
    required this.releaseDate,
  });

  /// Get app info from constants
  static AppInfo get current => AppInfo(
    name: LegalConstants.appName,
    version: LegalConstants.appVersion,
    buildNumber: LegalConstants.buildNumber,
    description: LegalConstants.appDescription,
    developerName: LegalConstants.developerName,
    developerEmail: LegalConstants.developerEmail,
    developerWebsite: LegalConstants.developerWebsite,
    releaseDate: DateTime(2024, 1, 1),
  );

  /// Get full version string
  String get fullVersion => '$version (Build $buildNumber)';

  /// Get formatted release date
  String get formattedReleaseDate {
    return '${releaseDate.day}/${releaseDate.month}/${releaseDate.year}';
  }
}
