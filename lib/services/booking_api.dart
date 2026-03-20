import 'dart:convert';
import 'package:http/http.dart' as http;
import './api.dart';
import './auth.dart';

class BookingApi {
  static Future<List<dynamic>> getBookings() async {
    final headers = AuthService.instance.token != null ? {'Authorization': 'Bearer ${AuthService.instance.token}'} : null;
    final res = await Api.get('/bookings', headers: headers);
    return res['bookings'] ?? [];
  }

  static Future<Map<String, dynamic>> createBooking(String facilityId, String date, String time, {String? notes}) async {
    final headers = AuthService.instance.token != null ? {'Authorization': 'Bearer ${AuthService.instance.token}'} : null;
    final body = {
      'facilityId': facilityId,
      'date': date,
      'time': time,
      if (notes != null) 'notes': notes,
    };
    final res = await Api.post('/bookings', body, headers: headers);
    return res;
  }

  static Future<Map<String, dynamic>> updateBooking(String id, Map<String, dynamic> updates) async {
    final headers = AuthService.instance.token != null ? {'Authorization': 'Bearer ${AuthService.instance.token}'} : null;
    final res = await Api.put('/bookings/$id', updates, headers: headers);
    return res;
  }

  static Future<Map<String, dynamic>> cancelBooking(String id) async {
    final headers = AuthService.instance.token != null ? {'Authorization': 'Bearer ${AuthService.instance.token}'} : null;
    final res = await Api.delete('/bookings/$id', headers: headers);
    return res;
  }

  // Check if business mode is enabled
  static Future<bool> isBusinessModeEnabled() async {
    try {
      final res = await Api.get('/settings');
      return res['businessMode'] == true;
    } catch (e) {
      return false;
    }
  }
}