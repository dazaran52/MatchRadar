import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class User {
  final int id;
  final String name;
  final String photoUrl;
  final double latitude;
  final double longitude;

  User({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.latitude,
    required this.longitude,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      photoUrl: json['photo_url'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}

class ApiService {
  Future<List<User>> scanRadar(int myId, double lat, double lng) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/update-location'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": myId,
          "latitude": lat,
          "longitude": lng,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> usersJson = data['nearby_users'];
        return usersJson.map((json) => User.fromJson(json)).toList();
      } else {
        print("Error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Net Error: $e");
      return [];
    }
  }

  Future<bool> likeUser(int fromId, int toId) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/like'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "from_user_id": fromId,
          "to_user_id": toId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['match'] == true;
      }
      return false;
    } catch (e) {
      print("Like Error: $e");
      return false;
    }
  }
}
