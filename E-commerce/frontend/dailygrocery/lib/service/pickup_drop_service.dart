import 'package:dailygrocery/service/auth_service.dart';
import 'package:dailygrocery/service/service_constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PickupDropService {
  final AuthService authService = AuthService();

  Future<bool> savePickupDrop(String pickup, String drop) async {
    // Assuming _authService is available in this class
    final accessToken = await authService.getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }
    bool? isVerified = await authService.verifyToken(accessToken);

    if (isVerified != null && isVerified) {
      try {
        var response = await http.post(
          Uri.parse(APIConstants.createPickupDrop),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({
            'pickup': pickup,
            'drop': drop,
          }),
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          // Data saved successfully
          return true;
        } else {
          // Error occurred
          return false;
        }
      } catch (e) {
        // Error occurred while saving data
        print('Error: $e');
        return false;
      }
    } else {
      return false;
    }
  }

  Future<List<PickupDrop>> fetchPickupDrop() async {
    final accessToken = await authService.getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }
    bool? isVerified = await authService.verifyToken(accessToken);

    if (isVerified != null && isVerified) {
      final response = await http.get(
        Uri.parse(
            APIConstants.listPickupDrop),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> responseData =
            json.decode(response.body);
        return responseData.map((json) => PickupDrop.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch pickdrop');
      }
    } else {
      return [];
    }
  }
}

class PickupDrop {
  final int id;
  final String pickup;
  final String drop;
  final String adminNumber;
  final String status;

  PickupDrop({
    required this.id,
    required this.pickup,
    required this.drop,
    required this.adminNumber,
    required this.status,
  });

  factory PickupDrop.fromJson(Map<String, dynamic> json) {
    return PickupDrop(
      id: json['id'],
      pickup: json['pickup'],
      drop: json['drop'],
      adminNumber: json['admin_number'],
      status: json['status'],
    );
  }
}
