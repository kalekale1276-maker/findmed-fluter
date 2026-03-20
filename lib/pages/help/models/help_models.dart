/// Models and constants for help functionality
import 'package:flutter/material.dart';

class HelpConstants {
  // UI labels
  static const String pageTitle = 'Help';
  static const String searchHint = 'Search help...';
  static const String searchHintText = 'Tap the search icon to quickly find help topics and FAQs.';
  static const String resultsForText = 'Showing results for "{query}"';
  static const String noResultsMessage = 'No matching help topics found.';
  
  // Section titles
  static const String faqTitle = 'Frequently Asked Questions';
  static const String contactSupportTitle = 'Contact Support';
  static const String contactSupportText = 'If you need more help, contact our support team via email, phone or Telegram.';
  static const String versionText = 'FindMed — version 0.0.1';
  
  // Contact labels
  static const String emailSupportLabel = 'Email Support';
  static const String callSupportLabel = 'Call Support';
  static const String telegramBotLabel = 'Open Telegram Bot';
  
  // Contact info
  static const String supportEmail = 'support@findmed.example';
  static const String supportPhone = '+251900000000';
  static const String telegramBotUrl = 'https://t.me/FindMedBot';
  
  // Animation durations
  static const int animationDurationMs = 300;
  
  // Search settings
  static const int titleMatchScore = 2;
  static const int contentMatchScore = 1;
  static const int noMatchScore = 0;
}

/// Help section model
class HelpSection {
  final String id;
  final String title;
  final List<String> content;
  final String category;
  final IconData? icon;
  final Color? color;

  HelpSection({
    required this.id,
    required this.title,
    required this.content,
    this.category = 'general',
    this.icon,
    this.color,
  });

  factory HelpSection.fromJson(Map<String, dynamic> json) {
    return HelpSection(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: (json['content'] as List<dynamic>?)
          ?.map((c) => c.toString())
          .toList() ?? [],
      category: json['category']?.toString() ?? 'general',
      icon: _getIconFromString(json['icon'] as String?),
      color: _getColorFromString(json['color'] as String?),
    );
  }

  /// Check if section matches search query
  bool matchesQuery(String query) {
    if (query.trim().isEmpty) return true;
    
    final lowerQuery = query.toLowerCase();
    
    // Check title match
    if (title.toLowerCase().contains(lowerQuery)) return true;
    
    // Check content match
    for (final contentItem in content) {
      if (contentItem.toLowerCase().contains(lowerQuery)) return true;
    }
    
    return false;
  }

  /// Get match score for sorting
  int getMatchScore(String query) {
    final lowerQuery = query.trim().toLowerCase();
    if (lowerQuery.isEmpty) return HelpConstants.noMatchScore;
    
    // Title match gets higher score
    if (title.toLowerCase().contains(lowerQuery)) {
      return HelpConstants.titleMatchScore;
    }
    
    // Content match gets lower score
    for (final contentItem in content) {
      if (contentItem.toLowerCase().contains(lowerQuery)) {
        return HelpConstants.contentMatchScore;
      }
    }
    
    return HelpConstants.noMatchScore;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'icon': icon?.toString(),
      'color': color?.toString(),
    };
  }

  /// Get icon from string
  static IconData? _getIconFromString(String? iconString) {
    switch (iconString) {
      case 'search':
        return Icons.search;
      case 'person':
        return Icons.person;
      case 'lock':
        return Icons.lock;
      case 'message':
        return Icons.message;
      case 'business':
        return Icons.business;
      case 'map':
        return Icons.map;
      case 'feedback':
        return Icons.feedback;
      case 'star':
        return Icons.star;
      case 'emergency':
        return Icons.emergency;
      case 'settings':
        return Icons.settings;
      default:
        return null;
    }
  }

  /// Get color from string
  static Color? _getColorFromString(String? colorString) {
    switch (colorString) {
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'red':
        return Colors.red;
      case 'purple':
        return Colors.purple;
      case 'grey':
        return Colors.grey;
      default:
        return null;
    }
  }
}

/// FAQ model
class FAQ {
  final String id;
  final String question;
  final String answer;
  final String category;
  final int viewCount;
  final DateTime? lastViewed;

  FAQ({
    required this.id,
    required this.question,
    required this.answer,
    this.category = 'general',
    this.viewCount = 0,
    this.lastViewed,
  });

  factory FAQ.fromJson(Map<String, dynamic> json) {
    return FAQ(
      id: json['id']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      answer: json['answer']?.toString() ?? '',
      category: json['category']?.toString() ?? 'general',
      viewCount: json['viewCount'] as int? ?? 0,
      lastViewed: json['lastViewed'] != null 
          ? DateTime.tryParse(json['lastViewed'].toString())
          : null,
    );
  }

  /// Check if FAQ matches search query
  bool matchesQuery(String query) {
    if (query.trim().isEmpty) return true;
    
    final lowerQuery = query.toLowerCase();
    
    return question.toLowerCase().contains(lowerQuery) ||
           answer.toLowerCase().contains(lowerQuery);
  }

  /// Record view
  FAQ recordView() {
    return FAQ(
      id: id,
      question: question,
      answer: answer,
      category: category,
      viewCount: viewCount + 1,
      lastViewed: DateTime.now(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'category': category,
      'viewCount': viewCount,
      'lastViewed': lastViewed?.toIso8601String(),
    };
  }
}

/// Help category model
class HelpCategory {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  HelpCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });

  /// Get all help categories
  static List<HelpCategory> getAllCategories() {
    return [
      HelpCategory(
        id: 'getting_started',
        name: 'Getting Started',
        description: 'Basic app usage and setup',
        icon: Icons.play_arrow,
        color: Colors.blue,
      ),
      HelpCategory(
        id: 'account',
        name: 'Account & Login',
        description: 'Registration, login, and profile management',
        icon: Icons.person,
        color: Colors.green,
      ),
      HelpCategory(
        id: 'features',
        name: 'Features',
        description: 'Search, map, filters, and app features',
        icon: Icons.star,
        color: Colors.orange,
      ),
      HelpCategory(
        id: 'agents',
        name: 'Agents & Facilities',
        description: 'Agent registration and facility management',
        icon: Icons.business,
        color: Colors.purple,
      ),
      HelpCategory(
        id: 'troubleshooting',
        name: 'Troubleshooting',
        description: 'Common issues and solutions',
        icon: Icons.build,
        color: Colors.red,
      ),
      HelpCategory(
        id: 'technical',
        name: 'Technical',
        description: 'Setup, backend, and development',
        icon: Icons.code,
        color: Colors.grey,
      ),
    ];
  }
}

/// Contact method model
class ContactMethod {
  final String id;
  final String name;
  final String url;
  final IconData icon;
  final Color color;
  final String description;

  ContactMethod({
    required this.id,
    required this.name,
    required this.url,
    required this.icon,
    required this.color,
    this.description = '',
  });

  /// Get all contact methods
  static List<ContactMethod> getAllContactMethods() {
    return [
      ContactMethod(
        id: 'email',
        name: HelpConstants.emailSupportLabel,
        url: 'mailto:${HelpConstants.supportEmail}',
        icon: Icons.email,
        color: Colors.blue,
        description: 'Send us an email',
      ),
      ContactMethod(
        id: 'phone',
        name: HelpConstants.callSupportLabel,
        url: 'tel:${HelpConstants.supportPhone}',
        icon: Icons.phone,
        color: Colors.green,
        description: 'Call our support line',
      ),
      ContactMethod(
        id: 'telegram',
        name: HelpConstants.telegramBotLabel,
        url: HelpConstants.telegramBotUrl,
        icon: Icons.send,
        color: Colors.blue,
        description: 'Chat with our bot',
      ),
    ];
  }
}

/// Help search result model
class HelpSearchResult {
  final List<HelpSection> sections;
  final List<FAQ> faqs;
  final String query;

  HelpSearchResult({
    required this.sections,
    required this.faqs,
    required this.query,
  });

  /// Check if has any results
  bool get hasResults => sections.isNotEmpty || faqs.isNotEmpty;

  /// Get total results count
  int get totalResults => sections.length + faqs.length;
}

/// Help state model
class HelpState {
  final bool isSearching;
  final String searchQuery;
  final HelpSearchResult? searchResult;
  final String? selectedCategory;
  final Set<String> expandedSections;

  const HelpState({
    this.isSearching = false,
    this.searchQuery = '',
    this.searchResult,
    this.selectedCategory,
    this.expandedSections = const {},
  });

  HelpState copyWith({
    bool? isSearching,
    String? searchQuery,
    HelpSearchResult? searchResult,
    String? selectedCategory,
    Set<String>? expandedSections,
  }) {
    return HelpState(
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
      searchResult: searchResult ?? this.searchResult,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      expandedSections: expandedSections ?? this.expandedSections,
    );
  }

  /// Toggle search mode
  HelpState toggleSearch() {
    return copyWith(
      isSearching: !isSearching,
      searchQuery: !isSearching ? '' : searchQuery,
      searchResult: !isSearching ? null : searchResult,
    );
  }

  /// Update search query
  HelpState updateSearchQuery(String query, HelpSearchResult result) {
    return copyWith(searchQuery: query, searchResult: result);
  }

  /// Toggle section expansion
  HelpState toggleSectionExpansion(String sectionId) {
    final newExpanded = Set<String>.from(expandedSections);
    if (newExpanded.contains(sectionId)) {
      newExpanded.remove(sectionId);
    } else {
      newExpanded.add(sectionId);
    }
    return copyWith(expandedSections: newExpanded);
  }

  /// Clear search
  HelpState clearSearch() {
    return copyWith(
      isSearching: false,
      searchQuery: '',
      searchResult: null,
    );
  }
}

/// Help analytics model
class HelpAnalytics {
  final int totalViews;
  final int searchQueries;
  final int contactClicks;
  final Map<String, int> categoryViews;
  final Map<String, int> sectionViews;
  final DateTime lastUpdated;

  HelpAnalytics({
    required this.totalViews,
    required this.searchQueries,
    required this.contactClicks,
    required this.categoryViews,
    required this.sectionViews,
    required this.lastUpdated,
  });

  factory HelpAnalytics.fromJson(Map<String, dynamic> json) {
    return HelpAnalytics(
      totalViews: json['totalViews'] as int? ?? 0,
      searchQueries: json['searchQueries'] as int? ?? 0,
      contactClicks: json['contactClicks'] as int? ?? 0,
      categoryViews: Map<String, int>.from(json['categoryViews'] as Map? ?? {}),
      sectionViews: Map<String, int>.from(json['sectionViews'] as Map? ?? {}),
      lastUpdated: DateTime.tryParse(json['lastUpdated'].toString()) ?? DateTime.now(),
    );
  }

  /// Get most viewed category
  String? getMostViewedCategory() {
    if (categoryViews.isEmpty) return null;
    
    return categoryViews.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Get most viewed section
  String? getMostViewedSection() {
    if (sectionViews.isEmpty) return null;
    
    return sectionViews.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}
