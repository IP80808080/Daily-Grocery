import 'dart:convert';
import 'package:dailygrocery/service/service_constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final storage = const FlutterSecureStorage();

  Future<String?> signUp(String email, String password, String firstName,
      String lastName, String mobileNumber) async {
    try {
      final response = await http.post(
        Uri.parse(APIConstants.createAccountAPI),
        body: {
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
          'mobile_number': mobileNumber
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Write into storage
        await storage.write(key: 'loginEmail', value: email);
        await storage.write(key: 'loginPassword', value: password);

        // Signup successful, automatically login
        return login(email, password);
      } else {
        final data = jsonDecode(response.body);
        final emailErrors = data['email'] ?? List<String>.from(data['email']);
        final emailMessage = emailErrors.join(', ');
        return emailMessage;
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(APIConstants.tokenAPI),
        body: {'email': email, 'password': password},
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final accessToken = data['access'];
        final refreshToken = data['refresh'];
        final email = data['email'];
        final fullName = data['full_name'];
        final mobileNumber = data['mobile_number'];
        const loggedIn = 'true';

        // Store tokens securely
        await storage.write(key: 'accessToken', value: accessToken);
        await storage.write(key: 'refreshToken', value: refreshToken);
        await storage.write(key: 'email', value: email);
        await storage.write(key: 'fullName', value: fullName);
        await storage.write(key: 'mobileNumber', value: mobileNumber);
        await storage.write(key: 'loggedIn', value: loggedIn);

        final isLoginEmail = await storage.containsKey(key: 'loginEmail');
        final isPassword = await storage.containsKey(key: 'loginPassword');
        if (!isPassword && !isLoginEmail) {
          // Write into storage
          await storage.write(key: 'loginEmail', value: email);
          await storage.write(key: 'loginPassword', value: password);
        }

        return "LOGIN"; // No error, login successful
      } else {
        final error = data['detail'];
        return error ?? 'Login failed';
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<String?> getAccessToken() async {
    return await storage.read(key: 'accessToken');
  }

  Future<String?> getRefreshToken() async {
    return await storage.read(key: 'refreshToken');
  }

  Future<bool> verifyUserLoggedIn() async {
    final accessToken = await storage.read(key: 'accessToken');
    final refreshToken = await storage.read(key: 'refreshToken');
    final loggedIn = await storage.read(key: 'loggedIn');

    if (accessToken != null && refreshToken != null && loggedIn == 'true') {
      return true;
    } else {
      return false;
    }
  }

  Future<bool?> verifyToken(String accessToken) async {
    final response = await http.post(
      Uri.parse(APIConstants.verifyTokenAPI),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {'token': accessToken},
    );
    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 401) {
      // Token is invalid, try refreshing it
      final isRefreshAndVerify = await refreshAndVerifyToken();
      if (isRefreshAndVerify != null) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<bool?> refreshAndVerifyToken() async {
    final refreshToken = await getRefreshToken();
    final response = await http.post(
      Uri.parse(APIConstants.refreshTokenAPI),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({'refresh': refreshToken}), // Encode body as JSON
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final newAccessToken = responseData['access'];
      final newRefreshToken = responseData['refresh'];
      // Now re-verify the new token
      final isVerified = await verifyToken(newAccessToken);
      if (isVerified != null) {
        await storage.write(key: 'accessToken', value: newAccessToken);
        await storage.write(key: 'refreshToken', value: newRefreshToken);
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<AdminDetails?> adminDetails() async {
    final String? accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }

    final bool? isVerified = await verifyToken(accessToken);
    if (isVerified != null && isVerified) {
      try {
        final response = await http.get(
          Uri.parse(APIConstants.adminDetailsAPI),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $accessToken',
          },
        );

        if (response.statusCode == 200) {
          final List<dynamic> responseData = json.decode(response.body);
          if (responseData.isNotEmpty) {
            final Map<String, dynamic> firstData = responseData.first;
            return AdminDetails.fromJson(firstData);
          } else {
            print("No data found");
            return null;
          }
        } else {
          print("Error Fetching Admin Details: ${response.statusCode}");
          return null;
        }
      } catch (e) {
        throw Exception('Error: $e');
      }
    }
    return null;
  }
}

class AdminDetails {
  final int id;
  final String pickupNumber;
  final String orderSupport;

  AdminDetails({
    required this.id,
    required this.pickupNumber,
    required this.orderSupport,
  });

  factory AdminDetails.fromJson(Map<String, dynamic> json) {
    return AdminDetails(
        id: json['id'],
        pickupNumber: json['pickup_number'],
        orderSupport: json['order_support']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': pickupNumber,
      'productId': orderSupport,
    };
  }
}
