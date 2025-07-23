import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/delivery_model.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000/api';  static Future<List<Delivery>> getDeliveries({
    String? date,
    String? location,
    String? timeSlot,
  }) async {
    try {
      String url = '$baseUrl/deliveries';
      List<String> queryParams = [];

      if (date != null) queryParams.add('date=$date');
      if (location != null) queryParams.add('location=${Uri.encodeComponent(location)}');
      if (timeSlot != null) queryParams.add('timeSlot=${Uri.encodeComponent(timeSlot)}');

      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          List<dynamic> deliveriesJson = data['data'];
          return deliveriesJson.map((json) => Delivery.fromJson(json)).toList();
        }
      }

      throw Exception('Failed to load deliveries');
    } catch (e) {
      throw Exception('Error fetching deliveries: $e');
    }
  }


  static Future<List<String>> getTimeSlots({String? date}) async {
    try {
      String url = '$baseUrl/time-slots';
      if (date != null) {
        url += '?date=$date';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return List<String>.from(data['data']);
        }
      }

      throw Exception('Failed to load time slots');
    } catch (e) {
      throw Exception('Error fetching time slots: $e');
    }
  }

  static Future<List<Location>> getLocations() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/locations'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          List<dynamic> locationsJson = data['data'];
          return locationsJson.map((json) => Location.fromJson(json)).toList();
        }
      }

      throw Exception('Failed to load locations');
    } catch (e) {
      throw Exception('Error fetching locations: $e');
    }
  }

  static Future<List<Delivery>> rescheduleDeliveries({
    required String date,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/deliveries/reschedule'), // Removed extra /api
        body: jsonEncode({'date': date}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success']) { // Added success check
          return (jsonResponse['data'] as List)
              .map((json) => Delivery.fromJson(json))
              .toList();
        } else {
          throw Exception(jsonResponse['message'] ?? 'Failed to reschedule');
        }
      } else {
        throw Exception('Failed to reschedule: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error rescheduling: $e');
    }
  }

  static Future<Delivery> skipDelivery(String deliveryId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/deliveries/$deliveryId/skip'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return Delivery.fromJson(data['data']);
        }
      }

      throw Exception('Failed to skip delivery');
    } catch (e) {
      throw Exception('Error skipping delivery: $e');
    }
  }

  static Future<List<Delivery>> swapDelivery(String deliveryId, String targetId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/deliveries/$deliveryId/swap'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'targetId': targetId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          List<dynamic> deliveriesJson = data['data'];
          return deliveriesJson.map((json) => Delivery.fromJson(json)).toList();
        }
      }

      throw Exception('Failed to swap delivery');
    } catch (e) {
      throw Exception('Error swapping delivery: $e');
    }
  }

  static Future<List<Delivery>> moveDelivery(String deliveryId, String direction) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/deliveries/$deliveryId/move'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'direction': direction}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          List<dynamic> deliveriesJson = data['data'];
          return deliveriesJson.map((json) => Delivery.fromJson(json)).toList();
        }
      }

      throw Exception('Failed to move delivery');
    } catch (e) {
      throw Exception('Error moving delivery: $e');
    }
  }
}