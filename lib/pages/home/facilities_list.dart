import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'facility_detail_page.dart'; // Added missing import

class FacilitiesList extends StatelessWidget {
  final List<Map<String, dynamic>> facilities;
  final Future<void> Function()? onLoadMore;
  final LatLng? currentLocation;

  const FacilitiesList({
    super.key, // Added super.key
    required this.facilities,
    this.onLoadMore,
    this.currentLocation,
  });

  @override
  Widget build(BuildContext context) {
    final displayed = facilities.take(20).toList();
    final extra = facilities.length - displayed.length;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: ScrollController(),
            itemCount: displayed.length + (extra > 0 ? 1 : 0),
            itemBuilder: (ctx, i) {
              if (i < displayed.length) {
                final f = displayed[i];
                final dist = (f['distanceKm'] as double?)?.toStringAsFixed(2) ?? '-';
                final type = (f['type'] ?? '').toString();
                final isOpen = _isOpen(f);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: InkWell(
                      onTap: () => _showDetail(f, context),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: type.toLowerCase() == 'hospital'
                                      ? Colors.redAccent
                                      : Colors.blueAccent,
                                  child: Icon(
                                    type.toLowerCase() == 'hospital'
                                        ? Icons.local_hospital
                                        : Icons.local_pharmacy,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                if ((f['contactPerson'] ?? f['owner'] ?? '').toString().isNotEmpty)
                                  Container(
                                    width: 18,
                                    height: 18,
                                    margin: const EdgeInsets.only(right: 2, bottom: 2),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 1.5),
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    f['name'] ?? 'Unknown',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${f['address'] ?? ''} • $dist km',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  isOpen ? 'Open' : 'Closed',
                                  style: TextStyle(
                                    color: isOpen ? Colors.green : Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                IconButton(
                                  onPressed: () => _openDirections(f, context),
                                  icon: const Icon(Icons.directions),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              } else if (i == displayed.length && extra > 0) {
                return Center(
                  child: TextButton(
                    onPressed: () {
                      if (onLoadMore != null) {
                        onLoadMore!();
                      }
                    },
                    child: const Text('More facilities'),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  bool _isOpen(Map<String, dynamic> f) {
    try {
      final open = f['openingHours'] as String? ?? '';
      if (open.isEmpty) return false;
      final now = DateTime.now();
      final day = now.weekday;
      final lines = open.split(';');
      if (day < 1 || day > 7) return false;
      final today = lines[day - 1];
      final parts = today.split('-');
      if (parts.length != 2) return false;
      final openTime = parts[0].trim();
      final closeTime = parts[1].trim();
      final current = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      return _isTimeInRange(current, openTime, closeTime);
    } catch (e) {
      return false;
    }
  }

  bool _isTimeInRange(String current, String open, String close) {
    final format = RegExp(r'^([0-9]{1,2}):([0-9]{1,2})\s*([APap]{0,2})$');
    final curMatch = format.firstMatch(current);
    final openMatch = format.firstMatch(open);
    final closeMatch = format.firstMatch(close);
    if (curMatch != null && openMatch != null && closeMatch != null) {
      final curHour = int.parse(curMatch.group(1)!);
      final curMin = int.parse(curMatch.group(2)!);
      final curPeriod = curMatch.group(3)?.toLowerCase() ?? '';
      final openHour = int.parse(openMatch.group(1)!);
      final openMin = int.parse(openMatch.group(2)!);
      final openPeriod = openMatch.group(3)?.toLowerCase() ?? '';
      final closeHour = int.parse(closeMatch.group(1)!);
      final closeMin = int.parse(closeMatch.group(2)!);
      final closePeriod = closeMatch.group(3)?.toLowerCase() ?? '';
      
      final curTotal = curHour * 60 + curMin;
      final openTotal = openHour * 60 + openMin;
      final closeTotal = closeHour * 60 + closeMin;
      
      if (curPeriod == closePeriod) {
        return curTotal >= openTotal && curTotal <= closeTotal;
      }
      
      if (curPeriod == 'am' && closePeriod == 'pm') {
        return curTotal >= openTotal || curTotal <= closeTotal;
      }
      
      if (curPeriod == 'pm' && closePeriod == 'am') {
        return false;
      }
      
      return curTotal >= openTotal && curTotal < closeTotal;
    }
    return false;
  }

  void _showDetail(Map<String, dynamic> f, BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => FacilityDetailPage(facility: f)),
    );
  }

  Future<void> _openDirections(Map<String, dynamic> f, BuildContext context) async {
    final lat = f['latitude'] as double?;
    final lng = f['longitude'] as double?;
    if (lat == null || lng == null) return;
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}