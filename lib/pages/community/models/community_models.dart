/// Models and constants for community functionality
class CommunityConstants {
  // UI labels
  static const String pageTitle = 'Community & Crowdsourcing';
  static const String communityFeaturesTitle = 'Community Features';
  static const String submitFacilityLabel = 'Submit New Facility';
  static const String updateFacilityLabel = 'Update Facility Information';
  static const String communityForumLabel = 'Community Forum / Reviews';
  static const String crowdsourcedUpdatesLabel = 'Crowdsourced Updates';
  
  // Feature descriptions
  static const String submitFacilityDescription = 'Add new healthcare facilities to our database';
  static const String updateFacilityDescription = 'Help keep facility information up-to-date';
  static const String communityForumDescription = 'Share experiences and read reviews';
  static const String crowdsourcedUpdatesDescription = 'Contribute real-time facility status updates';
  
  // Action labels
  static const String getStartedLabel = 'Get Started';
  static const String learnMoreLabel = 'Learn More';
  static const String contributeLabel = 'Contribute';
  static const String joinCommunityLabel = 'Join Community';
  
  // Section titles
  static const String howItWorksTitle = 'How It Works';
  static const String benefitsTitle = 'Benefits';
  static const String guidelinesTitle = 'Community Guidelines';
  static const String recentActivityTitle = 'Recent Activity';
  
  // Status labels
  static const String pendingStatus = 'Pending Review';
  static const String approvedStatus = 'Approved';
  static const String rejectedStatus = 'Rejected';
  static const String draftStatus = 'Draft';
}

/// Community feature model
class CommunityFeature {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final String route;
  final bool isActive;
  final int contributionCount;

  CommunityFeature({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
    this.isActive = true,
    this.contributionCount = 0,
  });

  factory CommunityFeature.submitFacility() {
    return CommunityFeature(
      id: 'submit_facility',
      title: CommunityConstants.submitFacilityLabel,
      description: CommunityConstants.submitFacilityDescription,
      icon: Icons.add_location,
      route: '/submit-facility',
    );
  }

  factory CommunityFeature.updateFacility() {
    return CommunityFeature(
      id: 'update_facility',
      title: CommunityConstants.updateFacilityLabel,
      description: CommunityConstants.updateFacilityDescription,
      icon: Icons.edit_location,
      route: '/update-facility',
    );
  }

  factory CommunityFeature.communityForum() {
    return CommunityFeature(
      id: 'community_forum',
      title: CommunityConstants.communityForumLabel,
      description: CommunityConstants.communityForumDescription,
      icon: Icons.forum,
      route: '/community-forum',
    );
  }

  factory CommunityFeature.crowdsourcedUpdates() {
    return CommunityFeature(
      id: 'crowdsourced_updates',
      title: CommunityConstants.crowdsourcedUpdatesLabel,
      description: CommunityConstants.crowdsourcedUpdatesDescription,
      icon: Icons.update,
      route: '/crowdsourced-updates',
    );
  }

  /// Get all community features
  static List<CommunityFeature> getAllFeatures() {
    return [
      CommunityFeature.submitFacility(),
      CommunityFeature.updateFacility(),
      CommunityFeature.communityForum(),
      CommunityFeature.crowdsourcedUpdates(),
    ];
  }
}

/// Community contribution model
class CommunityContribution {
  final String id;
  final String userId;
  final String userName;
  final String featureId;
  final String featureTitle;
  final String contributionType;
  final String content;
  final DateTime createdAt;
  final String status;
  final int? upvotes;
  final int? comments;

  CommunityContribution({
    required this.id,
    required this.userId,
    required this.userName,
    required this.featureId,
    required this.featureTitle,
    required this.contributionType,
    required this.content,
    required this.createdAt,
    required this.status,
    this.upvotes,
    this.comments,
  });

  factory CommunityContribution.fromJson(Map<String, dynamic> json) {
    return CommunityContribution(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? json['user_name'] ?? 'Anonymous',
      featureId: json['featureId'] ?? '',
      featureTitle: json['featureTitle'] ?? '',
      contributionType: json['contributionType'] ?? '',
      content: json['content'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? json['created_at'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? CommunityConstants.pendingStatus,
      upvotes: json['upvotes'] as int?,
      comments: json['comments'] as int?,
    );
  }

  /// Get formatted date
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  /// Get status color
  Color get statusColor {
    switch (status) {
      case CommunityConstants.approvedStatus:
        return Colors.green;
      case CommunityConstants.rejectedStatus:
        return Colors.red;
      case CommunityConstants.pendingStatus:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

/// Community statistics model
class CommunityStats {
  final int totalContributions;
  final int activeContributors;
  final int facilitiesAdded;
  final int facilitiesUpdated;
  final int forumPosts;
  final int pendingReviews;

  CommunityStats({
    required this.totalContributions,
    required this.activeContributors,
    required this.facilitiesAdded,
    required this.facilitiesUpdated,
    required this.forumPosts,
    required this.pendingReviews,
  });

  factory CommunityStats.fromJson(Map<String, dynamic> json) {
    return CommunityStats(
      totalContributions: json['totalContributions'] ?? 0,
      activeContributors: json['activeContributors'] ?? 0,
      facilitiesAdded: json['facilitiesAdded'] ?? 0,
      facilitiesUpdated: json['facilitiesUpdated'] ?? 0,
      forumPosts: json['forumPosts'] ?? 0,
      pendingReviews: json['pendingReviews'] ?? 0,
    );
  }

  /// Get mock stats for demo
  static CommunityStats get mockStats => CommunityStats(
    totalContributions: 1247,
    activeContributors: 342,
    facilitiesAdded: 156,
    facilitiesUpdated: 89,
    forumPosts: 423,
    pendingReviews: 28,
  );
}

/// Community guideline model
class CommunityGuideline {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool isImportant;

  CommunityGuideline({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isImportant = false,
  });

  /// Get all community guidelines
  static List<CommunityGuideline> getAllGuidelines() {
    return [
      CommunityGuideline(
        id: 'accuracy',
        title: 'Accuracy First',
        description: 'Ensure all information submitted is accurate and verifiable',
        icon: Icons.verified,
        isImportant: true,
      ),
      CommunityGuideline(
        id: 'respect',
        title: 'Be Respectful',
        description: 'Treat all community members with respect and kindness',
        icon: Icons.favorite,
        isImportant: true,
      ),
      CommunityGuideline(
        id: 'constructive',
        title: 'Constructive Feedback',
        description: 'Provide helpful and constructive feedback and reviews',
        icon: Icons.feedback,
      ),
      CommunityGuideline(
        id: 'privacy',
        title: 'Privacy Protection',
        description: 'Respect privacy and do not share personal information',
        icon: Icons.lock,
        isImportant: true,
      ),
      CommunityGuideline(
        id: 'spam',
        title: 'No Spam',
        description: 'Do not submit spam or irrelevant content',
        icon: Icons.block,
      ),
    ];
  }
}

/// Community activity model
class CommunityActivity {
  final String id;
  final String userId;
  final String userName;
  final String action;
  final String target;
  final DateTime timestamp;
  final String? details;

  CommunityActivity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.action,
    required this.target,
    required this.timestamp,
    this.details,
  });

  factory CommunityActivity.fromJson(Map<String, dynamic> json) {
    return CommunityActivity(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? json['user_name'] ?? 'Anonymous',
      action: json['action'] ?? '',
      target: json['target'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? json['created_at'] ?? '') ?? DateTime.now(),
      details: json['details'],
    );
  }

  /// Get formatted activity text
  String get formattedActivity {
    return '$userName $action $target';
  }

  /// Get formatted time
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  /// Get mock activities for demo
  static List<CommunityActivity> get mockActivities => [
    CommunityActivity(
      id: '1',
      userId: 'user1',
      userName: 'John Doe',
      action: 'submitted a new',
      target: 'hospital',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    CommunityActivity(
      id: '2',
      userId: 'user2',
      userName: 'Jane Smith',
      action: 'updated information for',
      target: 'City Pharmacy',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    CommunityActivity(
      id: '3',
      userId: 'user3',
      userName: 'Mike Johnson',
      action: 'posted a review about',
      target: 'General Hospital',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];
}
