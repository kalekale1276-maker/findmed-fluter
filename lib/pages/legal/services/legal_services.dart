import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/legal_models.dart';

/// Services for legal functionality
class LegalServices {
  /// Get all legal sections
  static List<LegalSection> getAllLegalSections() {
    return LegalSection.getAllSections();
  }

  /// Get legal section by ID
  static LegalSection? getSectionById(String id) {
    final sections = getAllLegalSections();
    try {
      return sections.firstWhere((section) => section.id == id);
    } catch (e) {
      debugPrint('Error getting section by ID: $e');
      return null;
    }
  }

  /// Get app information
  static AppInfo getAppInfo() {
    return AppInfo.current;
  }

  /// Launch URL safely
  static Future<bool> launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      return await launchUrl(uri);
    } catch (e) {
      debugPrint('Error launching URL: $e');
      return false;
    }
  }

  /// Send email to developer
  static Future<bool> sendEmailToDeveloper({
    String subject = 'FindMed Support',
    String body = '',
  }) async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: LegalConstants.developerEmail,
      query: 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );
    
    try {
      return await launchUrl(emailUri.toString());
    } catch (e) {
      debugPrint('Error sending email: $e');
      return false;
    }
  }

  /// Open developer website
  static Future<bool> openDeveloperWebsite() async {
    return await launchUrl(LegalConstants.developerWebsite);
  }

  /// Format markdown content for display
  static String formatMarkdownContent(String content) {
    // Simple markdown formatting for display
    return content
        .replaceAll(RegExp(r'^# (.+)$'), (match) => '**${match.group(1)}**')  // Headers
        .replaceAll(RegExp(r'^\*\* (.+)$'), (match) => '*${match.group(1)}*') // Bold
        .replaceAll(RegExp(r'^\* (.+)$'), (match) => '*${match.group(1)}*')   // Italic
        .replaceAll(RegExp(r'^- (.+)$'), (match) => '• ${match.group(1)}')   // Bullet points
        .replaceAll(RegExp(r'\*\*(.+?)\*\*'), (match) => '**${match.group(1)}**') // Inline bold
        .replaceAll(RegExp(r'\*(.+?)\*'), (match) => '*${match.group(1)}*');      // Inline italic
  }

  /// Search legal content
  static List<LegalSection> searchLegalContent(String query) {
    if (query.trim().isEmpty) {
      return getAllLegalSections();
    }

    final sections = getAllLegalSections();
    final lowerQuery = query.toLowerCase();

    return sections.where((section) {
      // Search in title
      if (section.title.toLowerCase().contains(lowerQuery)) {
        return true;
      }

      // Search in content
      if (section.content.toLowerCase().contains(lowerQuery)) {
        return true;
      }

      return false;
    }).toList();
  }

  /// Get legal content statistics
  static Map<String, dynamic> getLegalContentStats() {
    final sections = getAllLegalSections();
    
    int totalWords = 0;
    int totalCharacters = 0;
    Map<String, int> sectionStats = {};
    
    for (final section in sections) {
      final words = section.content.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
      final chars = section.content.length;
      
      totalWords += words;
      totalCharacters += chars;
      sectionStats[section.id] = words;
    }

    return {
      'totalSections': sections.length,
      'totalWords': totalWords,
      'totalCharacters': totalCharacters,
      'averageWordsPerSection': totalWords / sections.length,
      'sectionStats': sectionStats,
      'lastUpdated': LegalConstants.lastUpdated,
    };
  }

  /// Validate legal content
  static bool validateLegalContent() {
    try {
      final sections = getAllLegalSections();
      
      // Check for required sections
      final requiredIds = ['privacy_policy', 'terms_of_service', 'open_source', 'version_info'];
      final sectionIds = sections.map((s) => s.id).toSet();
      
      for (final requiredId in requiredIds) {
        if (!sectionIds.contains(requiredId)) {
          debugPrint('Missing required section: $requiredId');
          return false;
        }
      }
      
      // Check for empty content
      for (final section in sections) {
        if (section.title.isEmpty || section.content.isEmpty) {
          debugPrint('Empty section found: ${section.id}');
          return false;
        }
      }
      
      // Check for required content in key sections
      final privacyPolicy = getSectionById('privacy_policy');
      if (privacyPolicy != null && !privacyPolicy.content.contains('Privacy Policy')) {
        debugPrint('Privacy policy content appears invalid');
        return false;
      }
      
      final termsOfService = getSectionById('terms_of_service');
      if (termsOfService != null && !termsOfService.content.contains('Terms of Service')) {
        debugPrint('Terms of service content appears invalid');
        return false;
      }
      
      return true;
    } catch (e) {
      debugPrint('Error validating legal content: $e');
      return false;
    }
  }

  /// Export legal content to JSON
  static String exportLegalContent() {
    final sections = getAllLegalSections();
    final appInfo = getAppInfo();
    
    final exportData = {
      'appInfo': {
        'name': appInfo.name,
        'version': appInfo.version,
        'buildNumber': appInfo.buildNumber,
        'description': appInfo.description,
        'developerName': appInfo.developerName,
        'developerEmail': appInfo.developerEmail,
        'developerWebsite': appInfo.developerWebsite,
        'releaseDate': appInfo.releaseDate.toIso8601String(),
      },
      'sections': sections.map((section) => {
        'id': section.id,
        'title': section.title,
        'content': section.content,
        'icon': section.icon.toString(),
        'color': section.color.value.toString(),
      }).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
      'lastUpdated': LegalConstants.lastUpdated,
    };
    
    return _encodeJson(exportData);
  }

  /// Simple JSON encoder (avoiding dart:convert dependency)
  static String _encodeJson(Map<String, dynamic> data) {
    // This is a simplified JSON encoder for demonstration
    // In a real app, you would use dart:convert
    return '{\n'
        '  "appInfo": {\n'
        '    "name": "${data['appInfo']['name']}",\n'
        '    "version": "${data['appInfo']['version']}",\n'
        '    "buildNumber": "${data['appInfo']['buildNumber']}",\n'
        '    "description": "${data['appInfo']['description']}",\n'
        '    "developerName": "${data['appInfo']['developerName']}",\n'
        '    "developerEmail": "${data['appInfo']['developerEmail']}",\n'
        '    "developerWebsite": "${data['appInfo']['developerWebsite']}",\n'
        '    "releaseDate": "${data['appInfo']['releaseDate']}"\n'
        '  },\n'
        '  "sections": [\n'
        '    // Section data would be serialized here\n'
        '  ],\n'
        '  "exportedAt": "${data['exportedAt']}",\n'
        '  "lastUpdated": "${data['lastUpdated']}"\n'
        '}';
  }

  /// Get legal content summary
  static Map<String, dynamic> getLegalContentSummary() {
    final sections = getAllLegalSections();
    final stats = getLegalContentStats();
    
    return {
      'totalSections': sections.length,
      'sectionTitles': sections.map((s) => s.title).toList(),
      'hasPrivacyPolicy': sections.any((s) => s.id == 'privacy_policy'),
      'hasTermsOfService': sections.any((s) => s.id == 'terms_of_service'),
      'hasOpenSource': sections.any((s) => s.id == 'open_source'),
      'hasVersionInfo': sections.any((s) => s.id == 'version_info'),
      'contentStats': stats,
      'lastUpdated': LegalConstants.lastUpdated,
    };
  }

  /// Check if legal content is up to date
  static bool isContentUpToDate() {
    // This would typically check against a remote version
    // For now, return true as mock implementation
    return true;
  }

  /// Get content update status
  static Future<Map<String, dynamic>> getContentUpdateStatus() async {
    try {
      // This would typically check for updates from a remote server
      // For now, return mock data
      await Future.delayed(const Duration(milliseconds: 500));
      
      return {
        'isUpToDate': true,
        'lastChecked': DateTime.now().toIso8601String(),
        'nextCheck': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        'availableUpdate': null,
      };
    } catch (e) {
      debugPrint('Error checking update status: $e');
      return {
        'isUpToDate': true,
        'lastChecked': DateTime.now().toIso8601String(),
        'nextCheck': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        'availableUpdate': null,
        'error': e.toString(),
      };
    }
  }

  /// Record legal content view (for analytics)
  static Future<void> recordContentView(String sectionId) async {
    try {
      // This would typically send analytics to backend
      debugPrint('Legal content view recorded: $sectionId');
      
      // Mock API call
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      debugPrint('Error recording content view: $e');
    }
  }

  /// Get legal content analytics (mock implementation)
  static Future<Map<String, dynamic>> getLegalContentAnalytics() async {
    try {
      // This would typically fetch analytics from backend
      // For now, return mock data
      await Future.delayed(const Duration(milliseconds: 300));
      
      return {
        'totalViews': 1250,
        'sectionViews': {
          'privacy_policy': 450,
          'terms_of_service': 320,
          'open_source': 280,
          'version_info': 200,
        },
        'averageTimeSpent': '3.5 minutes',
        'mostViewedSection': 'privacy_policy',
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('Error getting legal analytics: $e');
      return {};
    }
  }

  /// Generate legal content report
  static String generateReport() {
    final sections = getAllLegalSections();
    final appInfo = getAppInfo();
    final stats = getLegalContentStats();
    
    final buffer = StringBuffer();
    
    buffer.writeln('# Legal Content Report');
    buffer.writeln();
    buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
    buffer.writeln();
    
    buffer.writeln('## Application Information');
    buffer.writeln('Name: ${appInfo.name}');
    buffer.writeln('Version: ${appInfo.fullVersion}');
    buffer.writeln('Developer: ${appInfo.developerName}');
    buffer.writeln('Email: ${appInfo.developerEmail}');
    buffer.writeln();
    
    buffer.writeln('## Content Statistics');
    buffer.writeln('Total Sections: ${stats['totalSections']}');
    buffer.writeln('Total Words: ${stats['totalWords']}');
    buffer.writeln('Total Characters: ${stats['totalCharacters']}');
    buffer.writeln('Average Words per Section: ${stats['averageWordsPerSection'].toStringAsFixed(1)}');
    buffer.writeln();
    
    buffer.writeln('## Sections');
    for (final section in sections) {
      buffer.writeln('### ${section.title}');
      buffer.writeln('ID: ${section.id}');
      buffer.writeln('Words: ${stats['sectionStats'][section.id]}');
      buffer.writeln('Characters: ${section.content.length}');
      buffer.writeln();
    }
    
    buffer.writeln('## Validation Status');
    buffer.writeln('Content Valid: ${validateLegalContent()}');
    buffer.writeln('Up to Date: ${isContentUpToDate()}');
    buffer.writeln('Last Updated: ${LegalConstants.lastUpdated}');
    
    return buffer.toString();
  }
}
