import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/help_models.dart';

/// Services for help functionality
class HelpServices {
  /// Get all help sections
  static List<HelpSection> getAllHelpSections() {
    return [
      HelpSection(
        id: 'search_facilities',
        title: 'Search for facilities',
        content: [
          '1) Open the Home or Map tab.',
          '2) Use the search box to enter a facility name, service, or address.',
          '3) Use filters (type, ownership, distance) to narrow results.',
          '4) Tap a list item or map marker to view details and actions (call, navigate, save).',
        ],
        category: 'features',
        icon: Icons.search,
        color: Colors.blue,
      ),
      HelpSection(
        id: 'register_user',
        title: 'Register a new user',
        content: [
          '1) Open the drawer and tap Register.',
          '2) Fill your full name, email, phone and a secure password.',
          '3) Submit the form; verify your email or OTP if prompted.',
          '4) After verification you can log in and save favorites.',
        ],
        category: 'account',
        icon: Icons.person,
        color: Colors.green,
      ),
      HelpSection(
        id: 'login_password',
        title: 'Login & Password Reset',
        content: [
          'Login: Open drawer → Login and enter your credentials.',
          'Password reset: On the Login screen tap Forgot password and follow instructions to receive a reset link or OTP.',
        ],
        category: 'account',
        icon: Icons.lock,
        color: Colors.green,
      ),
      HelpSection(
        id: 'connect_telegram',
        title: 'Connect to Telegram bot',
        content: [
          '1) Open Profile → Connect Telegram.',
          '2) Follow the on-screen steps to open the FindMed bot in Telegram and confirm the link.',
          '3) Once linked, you can receive OTPs and notifications via Telegram.',
        ],
        category: 'features',
        icon: Icons.message,
        color: Colors.blue,
      ),
      HelpSection(
        id: 'agent_register',
        title: 'Register / Login as an Agent (facility)',
        content: [
          'Register agent: Open Agent in the drawer → New Agent. Fill facility name, type and contact details.',
          'Optionally set a username and password to manage the facility.',
          'Agent login & update: Use the Agent page to log in with your credentials and update facility details from the admin area in-app.',
        ],
        category: 'agents',
        icon: Icons.business,
        color: Colors.purple,
      ),
      HelpSection(
        id: 'map_filters',
        title: 'Map usage & Filters',
        content: [
          'Pan and zoom the map to explore nearby facilities.',
          'Use filter controls to select facility type, services, ownership, and search radius.',
          'Tap a marker to open quick actions like call, directions, save to favorites.',
        ],
        category: 'features',
        icon: Icons.map,
        color: Colors.orange,
      ),
      HelpSection(
        id: 'feedback_reporting',
        title: 'Feedback & Reporting issues',
        content: [
          'Open Send Feedback from the drawer, enter your message, attach screenshots if needed, and submit.',
          'Support will respond via email or Telegram if you linked it.',
        ],
        category: 'features',
        icon: Icons.feedback,
        color: Colors.blue,
      ),
      HelpSection(
        id: 'favorites_ratings',
        title: 'Favorites and Ratings',
        content: [
          'Tap the star icon on a facility to save it to Favorites.',
          'Open Favorites from the drawer to see saved items.',
          'Use the Rate button on a favorite to submit a rating; ratings help other users find trusted facilities.',
        ],
        category: 'features',
        icon: Icons.star,
        color: Colors.orange,
      ),
      HelpSection(
        id: 'emergency_sos',
        title: 'Emergency / SOS',
        content: [
          'Open Emergency from the drawer and press SOS / Panic.',
          'The app will ask to share your location with emergency contacts and provide quick call/navigation actions to nearby hospitals.',
        ],
        category: 'features',
        icon: Icons.emergency,
        color: Colors.red,
      ),
      HelpSection(
        id: 'settings_customization',
        title: 'Settings & Customization',
        content: [
          'Open Settings from the drawer to change theme (light/dark), map provider, and notification preferences.',
          'Use the Backend Host setting only if you need to override the default server address (advanced).',
        ],
        category: 'features',
        icon: Icons.settings,
        color: Colors.grey,
      ),
      HelpSection(
        id: 'setup_prerequisites',
        title: 'Setup & Prerequisites',
        content: [
          'Prerequisites:',
          '- Node.js (16+), npm',
          '- MongoDB (if using DB)',
          '- Flutter SDK for mobile',
        ],
        category: 'technical',
        icon: Icons.build,
        color: Colors.grey,
      ),
      HelpSection(
        id: 'run_backend',
        title: 'Run Backend (step-by-step)',
        content: [
          '1) Install dependencies',
          'cd backend\\nnpm install',
          '2) Start server',
          'npm start',
          'Notes:',
          '- Backend runs on port 5000 by default.',
          '- Android emulator should use 10.0.2.2 to reach host.',
        ],
        category: 'technical',
        icon: Icons.code,
        color: Colors.grey,
      ),
      HelpSection(
        id: 'run_admin_ui',
        title: 'Run Admin UI (step-by-step)',
        content: [
          'cd frontend/admin\\nnpm install\\nnpm run dev',
          'The admin UI is usually available at http://localhost:3000',
        ],
        category: 'technical',
        icon: Icons.code,
        color: Colors.grey,
      ),
      HelpSection(
        id: 'run_mobile',
        title: 'Run Mobile (Flutter)',
        content: [
          'cd mobile\\nflutter pub get\\nflutter run',
          '- Use AppConfig host override to set backend host.',
          '- Android emulator: use 10.0.2.2:5000',
        ],
        category: 'technical',
        icon: Icons.code,
        color: Colors.grey,
      ),
    ];
  }

  /// Get all FAQs
  static List<FAQ> getAllFAQs() {
    return [
      FAQ(
        id: 'faq_search_facility',
        question: 'How do I search for a facility?',
        answer: 'Open Home/Map, use the search box to enter a name or service, or use the map controls to pan and zoom. Tap a result to see details.',
        category: 'features',
      ),
      FAQ(
        id: 'faq_register_user',
        question: 'How do I register a new user?',
        answer: 'Open the drawer → Register. Fill name, email, phone and password then submit. Verify email if prompted.',
        category: 'account',
      ),
      FAQ(
        id: 'faq_login',
        question: 'How do I log in?',
        answer: 'Open drawer → Login, enter email and password and press Login. Once logged in you can save favorites and submit feedback.',
        category: 'account',
      ),
      FAQ(
        id: 'faq_reset_password',
        question: 'How to reset my password?',
        answer: 'On the Login screen tap "Forgot password" and follow the steps (email or OTP via Telegram if enabled).',
        category: 'account',
      ),
      FAQ(
        id: 'faq_connect_telegram',
        question: 'How do I connect to the Telegram bot?',
        answer: 'Open Profile → Connect Telegram and follow on-screen instructions to open the FindMed bot and confirm the link.',
        category: 'features',
      ),
      FAQ(
        id: 'faq_register_agent',
        question: 'How do I register as an agent (facility)?',
        answer: 'Open Agent from the drawer → New Agent, fill facility details and optionally set a username/password for agent access.',
        category: 'agents',
      ),
      FAQ(
        id: 'faq_agent_login',
        question: 'How do agents log in and update facility info?',
        answer: 'Agents use the Agent page to log in with their username/password. After login use the Edit actions to update facility details.',
        category: 'agents',
      ),
      FAQ(
        id: 'faq_map_filters',
        question: 'How to use the map and filters?',
        answer: 'Use the Map tab to view nearby facilities. Use filter controls to restrict by type (hospital/pharmacy), services, ownership and distance.',
        category: 'features',
      ),
      FAQ(
        id: 'faq_feedback',
        question: 'How do I send feedback or report an issue?',
        answer: 'Open Send Feedback from the drawer, enter your message and optional attachments, and submit. Support will reply via email or Telegram if linked.',
        category: 'features',
      ),
      FAQ(
        id: 'faq_favorites_ratings',
        question: 'How do I save favorites and rate facilities?',
        answer: 'Tap the star icon on a facility to add to Favorites. Open Favorites to rate a facility using the Rate button.',
        category: 'features',
      ),
      FAQ(
        id: 'faq_emergency',
        question: 'What is the emergency (SOS) button?',
        answer: 'Open Emergency from the drawer and press SOS/Panic to share your location with emergency contacts configured in the app.',
        category: 'features',
      ),
      FAQ(
        id: 'faq_settings',
        question: 'How do I customize settings?',
        answer: 'Open Settings from the drawer to change App theme, map provider, notification preferences, and backend host override.',
        category: 'features',
      ),
    ];
  }

  /// Search help content
  static HelpSearchResult searchHelpContent(String query) {
    final allSections = getAllHelpSections();
    final allFAQs = getAllFAQs();
    
    // Filter sections
    final filteredSections = allSections
        .where((section) => section.matchesQuery(query))
        .toList();
    
    // Sort sections by match score
    if (query.isNotEmpty) {
      filteredSections.sort((a, b) => b.getMatchScore(query).compareTo(a.getMatchScore(query)));
    }
    
    // Filter FAQs
    final filteredFAQs = allFAQs
        .where((faq) => faq.matchesQuery(query))
        .toList();
    
    return HelpSearchResult(
      sections: filteredSections,
      faqs: filteredFAQs,
      query: query,
    );
  }

  /// Get help sections by category
  static List<HelpSection> getSectionsByCategory(String categoryId) {
    final allSections = getAllHelpSections();
    return allSections.where((section) => section.category == categoryId).toList();
  }

  /// Get FAQs by category
  static List<FAQ> getFAQsByCategory(String categoryId) {
    final allFAQs = getAllFAQs();
    return allFAQs.where((faq) => faq.category == categoryId).toList();
  }

  /// Launch URL
  static Future<bool> launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      return await launchUrl(uri);
    } catch (e) {
      debugPrint('Error launching URL: $e');
      return false;
    }
  }

  /// Get contact methods
  static List<ContactMethod> getContactMethods() {
    return ContactMethod.getAllContactMethods();
  }

  /// Get help categories
  static List<HelpCategory> getHelpCategories() {
    return HelpCategory.getAllCategories();
  }

  /// Record help view (mock implementation)
  static Future<void> recordHelpView({
    String? sectionId,
    String? categoryId,
    String? faqId,
  }) async {
    try {
      // This would typically send analytics to backend
      // For now, just log the view
      debugPrint('Help view recorded: section=$sectionId, category=$categoryId, faq=$faqId');
      
      // Mock API call
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      debugPrint('Error recording help view: $e');
    }
  }

  /// Record search query (mock implementation)
  static Future<void> recordSearchQuery(String query) async {
    try {
      // This would typically send search analytics to backend
      debugPrint('Search query recorded: $query');
      
      // Mock API call
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      debugPrint('Error recording search query: $e');
    }
  }

  /// Record contact click (mock implementation)
  static Future<void> recordContactClick(String contactMethodId) async {
    try {
      // This would typically send contact analytics to backend
      debugPrint('Contact click recorded: $contactMethodId');
      
      // Mock API call
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      debugPrint('Error recording contact click: $e');
    }
  }

  /// Get help analytics (mock implementation)
  static Future<HelpAnalytics> getHelpAnalytics() async {
    try {
      // This would typically fetch analytics from backend
      // For now, return mock data
      await Future.delayed(const Duration(milliseconds: 300));
      
      return HelpAnalytics(
        totalViews: 1250,
        searchQueries: 340,
        contactClicks: 89,
        categoryViews: {
          'getting_started': 450,
          'account': 320,
          'features': 280,
          'agents': 120,
          'troubleshooting': 60,
          'technical': 20,
        },
        sectionViews: {
          'search_facilities': 180,
          'register_user': 150,
          'login_password': 120,
          'connect_telegram': 90,
          'map_filters': 85,
          'feedback_reporting': 75,
          'favorites_ratings': 70,
          'emergency_sos': 65,
          'settings_customization': 45,
          'agent_register': 35,
        },
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error getting help analytics: $e');
      rethrow;
    }
  }

  /// Export help content to JSON
  static String exportHelpContent() {
    final sections = getAllHelpSections().map((s) => s.toJson()).toList();
    final faqs = getAllFAQs().map((f) => f.toJson()).toList();
    
    return '''
{
  "sections": ${sections.map((s) => s.toString()).toList()},
  "faqs": ${faqs.map((f) => f.toString()).toList()},
  "categories": ${getHelpCategories().map((c) => c.toString()).toList()},
  "exported_at": "${DateTime.now().toIso8601String()}"
}
''';
  }

  /// Validate help content
  static bool validateHelpContent() {
    try {
      final sections = getAllHelpSections();
      final faqs = getAllFAQs();
      
      // Check for duplicate IDs
      final sectionIds = sections.map((s) => s.id).toSet();
      final faqIds = faqs.map((f) => f.id).toSet();
      
      if (sectionIds.length != sections.length) {
        debugPrint('Duplicate section IDs found');
        return false;
      }
      
      if (faqIds.length != faqs.length) {
        debugPrint('Duplicate FAQ IDs found');
        return false;
      }
      
      // Check for empty content
      for (final section in sections) {
        if (section.title.isEmpty || section.content.isEmpty) {
          debugPrint('Empty section found: ${section.id}');
          return false;
        }
      }
      
      for (final faq in faqs) {
        if (faq.question.isEmpty || faq.answer.isEmpty) {
          debugPrint('Empty FAQ found: ${faq.id}');
          return false;
        }
      }
      
      return true;
    } catch (e) {
      debugPrint('Error validating help content: $e');
      return false;
    }
  }

  /// Get popular help topics
  static List<HelpSection> getPopularTopics() {
    // This would typically be based on analytics
    // For now, return a curated list
    return getAllHelpSections().take(5).toList();
  }

  /// Get quick help for common issues
  static List<FAQ> getQuickHelp() {
    // This would typically be based on analytics
    // For now, return a curated list
    return getAllFAQs().take(5).toList();
  }

  /// Generate help summary
  static Map<String, dynamic> generateHelpSummary() {
    final sections = getAllHelpSections();
    final faqs = getAllFAQs();
    final categories = getHelpCategories();
    
    return {
      'totalSections': sections.length,
      'totalFAQs': faqs.length,
      'totalCategories': categories.length,
      'sectionsByCategory': categories.map((cat) => 
        MapEntry(cat.name, getSectionsByCategory(cat.id).length)
      ).toMap(),
      'faqsByCategory': categories.map((cat) => 
        MapEntry(cat.name, getFAQsByCategory(cat.id).length)
      ).toMap(),
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }
}
