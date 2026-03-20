import 'package:equatable/equatable.dart';

class Facility extends Equatable {
  final String id;
  final String name;
  final String type;
  final String distance;
  final double rating;
  final String address;
  final String phone;
  final bool isOpen;
  final double latitude;
  final double longitude;
  final List<String> services;
  final List<String> doctors;

  const Facility({
    required this.id,
    required this.name,
    required this.type,
    required this.distance,
    required this.rating,
    required this.address,
    required this.phone,
    required this.isOpen,
    required this.latitude,
    required this.longitude,
    this.services = const [],
    this.doctors = const [],
  });

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        distance,
        rating,
        address,
        phone,
        isOpen,
        latitude,
        longitude,
        services,
        doctors,
      ];

  Facility copyWith({
    String? id,
    String? name,
    String? type,
    String? distance,
    double? rating,
    String? address,
    String? phone,
    bool? isOpen,
    double? latitude,
    double? longitude,
    List<String>? services,
    List<String>? doctors,
  }) {
    return Facility(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      distance: distance ?? this.distance,
      rating: rating ?? this.rating,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      isOpen: isOpen ?? this.isOpen,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      services: services ?? this.services,
      doctors: doctors ?? this.doctors,
    );
  }
}
