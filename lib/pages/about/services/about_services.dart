import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/about_models.dart';

/// Services for the About page functionality
class AboutServices {
  /// Open external link
  static Future<void> openLink(String url) async {
    final uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch URL: $url');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  /// Send email
  static Future<void> sendEmail(
    String to, {
    String subject = '',
    String body = '',
  }) async {
    final uri = Uri(
      scheme: 'mailto',
      path: to,
      queryParameters: {
        if (subject.isNotEmpty) 'subject': subject,
        if (body.isNotEmpty) 'body': body,
      },
    );
    await openLink(uri.toString());
  }

  /// Get all about sections
  static List<AboutSection> getAboutSections() {
    return [
      AboutSection(
        title: 'Mission',
        content: AboutConstants.mission,
        isExpandable: true,
      ),
      AboutSection(
        title: 'Vision',
        content: AboutConstants.vision,
        isExpandable: true,
      ),
      AboutSection(
        title: 'Roadmap & Upcoming features',
        content: 'See planned features and upcoming developments.',
        bulletPoints: AboutConstants.plannedFeatures,
        externalLink: AboutConstants.roadmap,
        isExpandable: true,
      ),
      AboutSection(
        title: 'Changelog',
        content: 'See recent releases and notable changes.',
        externalLink: AboutConstants.changelog,
        isExpandable: true,
      ),
      AboutSection(
        title: 'Data & Privacy',
        bulletPoints: AboutConstants.dataPrivacyPoints,
        externalLink: AboutConstants.privacy,
        isExpandable: true,
      ),
      AboutSection(
        title: 'Security & Safety',
        content: AboutConstants.securityInfo,
        isExpandable: true,
      ),
      AboutSection(
        title: 'Contribute / Report issues',
        content: 'Found a bug or want to contribute?',
        bulletPoints: [
          'Open an issue or pull request on the project repository.',
        ],
        externalLink: AboutConstants.repo,
        isExpandable: true,
      ),
    ];
  }

  /// Get support actions
  static List<SupportAction> getSupportActions() {
    return [
      SupportAction(
        label: 'Email Support',
        icon: Icons.email,
        onPressed: () => sendEmail(
          AboutConstants.supportEmail,
          subject: 'FindMed support',
        ),
      ),
      SupportAction(
        label: 'Website',
        icon: Icons.web,
        onPressed: () => openLink(AboutConstants.website),
      ),
      SupportAction(
        label: 'Privacy policy',
        icon: Icons.book,
        onPressed: () => openLink(AboutConstants.privacy),
      ),
    ];
  }

  /// Send bug report email
  static Future<void> sendBugReport() async {
    await sendEmail(
      AboutConstants.supportEmail,
      subject: 'Bug report / feature request',
    );
  }

  /// Open repository
  static Future<void> openRepository() async {
    await openLink(AboutConstants.repo);
  }

  /// Open roadmap
  static Future<void> openRoadmap() async {
    await openLink(AboutConstants.roadmap);
  }

  /// Open changelog
  static Future<void> openChangelog() async {
    await openLink(AboutConstants.changelog);
  }

  /// Open privacy policy
  static Future<void> openPrivacyPolicy() async {
    await openLink(AboutConstants.privacy);
  }

  /// Open website
  static Future<void> openWebsite() async {
    await openLink(AboutConstants.website);
  }
}
