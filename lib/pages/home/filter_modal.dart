import 'package:flutter/material.dart';

class FilterModal extends StatefulWidget {
  final String currentType;
  final bool currentOpenNow;
  final String? currentHospitalType;
  final String? currentPharmacyType;
  final String? currentHospitalOwnership;
  final String? currentPharmacyOwnership;
  final String currentOwnership;
  final int? currentRadius;
  final Function(String, bool, String?, String?, String?, String?, String, int?) onApply;

  const FilterModal({
    required this.currentType,
    required this.currentOpenNow,
    this.currentHospitalType,
    this.currentPharmacyType,
    this.currentHospitalOwnership,
    this.currentPharmacyOwnership,
    required this.currentOwnership,
    required this.currentRadius,
    required this.onApply,
  });

  @override
  _FilterModalState createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  late String _type;
  late bool _openNow;
  String? _hospitalType;
  String? _pharmacyType;
  String? _hospitalOwnership;
  String? _pharmacyOwnership;
  late String _ownership;
  int? _radiusMeters;

  @override
  void initState() {
    super.initState();
    _type = widget.currentType;
    _openNow = widget.currentOpenNow;
    _hospitalType = widget.currentHospitalType;
    _pharmacyType = widget.currentPharmacyType;
    _hospitalOwnership = widget.currentHospitalOwnership;
    _pharmacyOwnership = widget.currentPharmacyOwnership;
    _ownership = widget.currentOwnership;
    _radiusMeters = widget.currentRadius;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _type,
            decoration: const InputDecoration(
              labelText: 'Facility Type',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All')),
              DropdownMenuItem(value: 'hospital', child: Text('Hospital')),
              DropdownMenuItem(value: 'pharmacy', child: Text('Pharmacy')),
            ],
            onChanged: (value) => setState(() => _type = value!),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Open Now'),
            value: _openNow,
            onChanged: (value) => setState(() => _openNow = value),
          ),
          const SizedBox(height: 16),
          if (_type == 'hospital') ...[
            DropdownButtonFormField<String>(
              value: _hospitalType,
              decoration: const InputDecoration(
                labelText: 'Hospital Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('All')),
                DropdownMenuItem(value: 'general', child: Text('General')),
                DropdownMenuItem(value: 'specialized', child: Text('Specialized')),
              ],
              onChanged: (value) => setState(() => _hospitalType = value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _hospitalOwnership,
              decoration: const InputDecoration(
                labelText: 'Hospital Ownership',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('All')),
                DropdownMenuItem(value: 'public', child: Text('Public')),
                DropdownMenuItem(value: 'private', child: Text('Private')),
              ],
              onChanged: (value) => setState(() => _hospitalOwnership = value),
            ),
          ],
          if (_type == 'pharmacy') ...[
            DropdownButtonFormField<String>(
              value: _pharmacyType,
              decoration: const InputDecoration(
                labelText: 'Pharmacy Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('All')),
                DropdownMenuItem(value: 'retail', child: Text('Retail')),
                DropdownMenuItem(value: 'hospital', child: Text('Hospital')),
              ],
              onChanged: (value) => setState(() => _pharmacyType = value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _pharmacyOwnership,
              decoration: const InputDecoration(
                labelText: 'Pharmacy Ownership',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('All')),
                DropdownMenuItem(value: 'independent', child: Text('Independent')),
                DropdownMenuItem(value: 'chain', child: Text('Chain')),
              ],
              onChanged: (value) => setState(() => _pharmacyOwnership = value),
            ),
          ],
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _ownership,
            decoration: const InputDecoration(
              labelText: 'Ownership',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'any', child: Text('Any')),
              DropdownMenuItem(value: 'public', child: Text('Public')),
              DropdownMenuItem(value: 'private', child: Text('Private')),
            ],
            onChanged: (value) => setState(() => _ownership = value!),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            value: _radiusMeters,
            decoration: const InputDecoration(
              labelText: 'Search Radius (meters)',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 500, child: Text('500m')),
              DropdownMenuItem(value: 1000, child: Text('1km')),
              DropdownMenuItem(value: 2000, child: Text('2km')),
              DropdownMenuItem(value: 5000, child: Text('5km')),
              DropdownMenuItem(value: 10000, child: Text('10km')),
            ],
            onChanged: (value) => setState(() => _radiusMeters = value),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  widget.onApply(
                    _type,
                    _openNow,
                    _hospitalType,
                    _pharmacyType,
                    _hospitalOwnership,
                    _pharmacyOwnership,
                    _ownership,
                    _radiusMeters,
                  );
                },
                child: const Text('Apply'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
