/// Models and constants for the About page
class AboutConstants {
  static const String appName = 'FindMed';
  static const String version = '0.0.1';
  static const String description =
      'FindMed helps you locate nearby healthcare facilities, view details and contact information, save favorites, and connect with our Telegram bot for quick assistance.';
  
  // External links
  static const String website = 'https://example.com';
  static const String privacy = 'https://example.com/privacy';
  static const String terms = 'https://example.com/terms';
  static const String changelog = 'https://example.com/changelog';
  static const String roadmap = 'https://example.com/roadmap';
  static const String repo = 'https://github.com/your/repo';
  static const String supportEmail = 'support@example.com';

  // Mission and Vision
  static const String mission = 
      'To make trusted healthcare information and nearby facility access available to everyone, quickly and reliably.';
  
  static const String vision = 
      'A world where anyone can find the right care when they need it, supported by accurate data and community feedback.';

  // Key features
  static const List<String> keyFeatures = [
    'Find nearby hospitals, pharmacies and clinics',
    'Detailed facility info: contact, address, hours, services',
    'Directions and map links',
    'Save favorites and rate facilities',
    'Admin-created announcements and reminders',
    'Telegram bot integration for OTPs and quick lookup',
    'Offline caching for favorites and recent searches',
  ];

  // Planned features
  static const List<String> plannedFeatures = [
    'Per-user saved searches and alerts',
    'Rich admin content: images, pinning, scheduled display',
    'Better analytics and admin reporting',
    'In-app chat and persistent messages',
    'Improved offline map support and routing',
  ];

  // Data privacy points
  static const List<String> dataPrivacyPoints = [
    'We only collect data necessary for the app to function.',
    'Personal data: name, email, phone (optional).',
    'Usage data: searches, favorites, ratings (aggregated).',
    'Location: only when you grant permission for map and emergency features.',
    'Data retention and deletion: contact support to request deletion of your account and personal data.',
    'For full details see our Privacy Policy.',
  ];

  // Security points
  static const String securityInfo = 
      'We use standard HTTPS for all network requests. Sensitive data is stored securely and only when needed. Do not share credentials. Enable device lock for extra protection.';

  // Credits
  static const List<String> credits = [
    'Development: FindMed team',
    'UI/UX: Design team',
    'Data contributors and local partners',
    'Special thanks to the open-source community',
  ];
}

/// About section data model
class AboutSection {
  final String title;
  final String? content;
  final List<String>? bulletPoints;
  final String? externalLink;
  final bool isExpandable;

  AboutSection({
    required this.title,
    this.content,
    this.bulletPoints,
    this.externalLink,
    this.isExpandable = false,
  });
}

/// Support action model
class SupportAction {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  SupportAction({
    required this.label,
    required this.icon,
    required this.onPressed,
  });
}
