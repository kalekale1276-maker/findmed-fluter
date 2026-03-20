import 'package:equatable/equatable.dart';

class Booking extends Equatable {
  final String id;
  final String facilityId;
  final String facilityName;
  final String doctorName;
  final String specialty;
  final DateTime date;
  final String time;
  final String status;
  final String notes;

  const Booking({
    required this.id,
    required this.facilityId,
    required this.facilityName,
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.time,
    required this.status,
    required this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        facilityId,
        facilityName,
        doctorName,
        specialty,
        date,
        time,
        status,
        notes,
      ];

  Booking copyWith({
    String? id,
    String? facilityId,
    String? facilityName,
    String? doctorName,
    String? specialty,
    DateTime? date,
    String? time,
    String? status,
    String? notes,
  }) {
    return Booking(
      id: id ?? this.id,
      facilityId: facilityId ?? this.facilityId,
      facilityName: facilityName ?? this.facilityName,
      doctorName: doctorName ?? this.doctorName,
      specialty: specialty ?? this.specialty,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}
