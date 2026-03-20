import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latlong2/latlong.dart';

class FacilityDetailPage extends StatelessWidget {
  final Map<String, dynamic> facility;

  const FacilityDetailPage({super.key, required this.facility}); // Added super.key

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(facility['name'] ?? 'Unknown Facility'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      facility['name'] ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      facility['address'] ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    if (facility['phone'] != null && facility['phone'].toString().isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              facility['phone'].toString(),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (facility['email'] != null && facility['email'].toString().isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Icons.email, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              facility['email'].toString(),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (facility['website'] != null && facility['website'].toString().isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Icons.language, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: InkWell(
                              onTap: () => _launchURL(facility['website'].toString()),
                              child: Text(
                                facility['website'].toString(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (facility['openingHours'] != null && facility['openingHours'].toString().isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              facility['openingHours'].toString(),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (facility['type'] != null) ...[
                      Row(
                        children: [
                          const Icon(Icons.category, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              facility['type'].toString().toUpperCase(),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (facility['services'] != null) ...[
                      const Divider(),
                      const SizedBox(height: 8),
                      const Text(
                        'Services',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._buildServicesList(facility['services']),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: facility['phone'] != null && facility['phone'].toString().isNotEmpty
                                ? () => _callPhone(facility['phone'].toString())
                                : null,
                            icon: const Icon(Icons.phone),
                            label: const Text('Call'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _openDirections(facility, context),
                            icon: const Icon(Icons.directions),
                            label: const Text('Directions'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildServicesList(dynamic services) {
    if (services == null) return [];
    
    List<String> serviceList = [];
    if (services is List) {
      serviceList = services.map((s) => s.toString()).toList();
    } else if (services is String) {
      serviceList = services.split(',').map((s) => s.trim()).toList();
    }
    
    return serviceList.map((service) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(child: Text(service)),
        ],
      ),
    )).toList();
  }

  Future<void> _callPhone(String phone) async {
    if (phone.isEmpty) return;
    
    // Clean phone number (remove spaces, dashes, etc.)
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        debugPrint('Could not launch $uri');
      }
    } catch (e) {
      debugPrint('Error launching phone: $e');
    }
  }

  Future<void> _openDirections(Map<String, dynamic> facility, BuildContext context) async {
    final lat = facility['latitude'] as double?;
    final lng = facility['longitude'] as double?;
    
    if (lat == null || lng == null) {
      // Show error if coordinates are missing
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location coordinates not available')),
      );
      return;
    }
    
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
    final uri = Uri.parse(url);
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open maps')),
        );
      }
    } catch (e) {
      debugPrint('Error opening directions: $e');
    }
  }

  Future<void> _launchURL(String url) async {
    if (url.isEmpty) return;
    
    // Add https:// if no protocol is specified
    String cleanUrl = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      cleanUrl = 'https://$url';
    }
    
    final uri = Uri.parse(cleanUrl);
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }
}