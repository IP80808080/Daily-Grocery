import 'dart:io';

import 'package:dailygrocery/service/service_constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dailygrocery/service/auth_service.dart';
import 'package:http/http.dart';

class AddressService {
  static const String baseUrl = 'http://192.168.133.187:8000';
  final AuthService authService = AuthService();

  Future<List<Address>> getAllAddresses() async {
    final accessToken = await authService.getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }
    final url = Uri.parse(APIConstants.userAddressAPI);
    bool? isVerified = await authService.verifyToken(accessToken);

    if (isVerified != null && isVerified) {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Address.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load addresses');
      }
    }
    return [];
  }

  Future<Address?> getDeliveryAddress(int id) async {
    final accessToken = await authService.getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }
    final url = Uri.parse(APIConstants.deliverySelectedAddress(id));
    bool? isVerified = await authService.verifyToken(accessToken);

    if (isVerified != null && isVerified) {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Address.fromJson(data);
      } else {
        throw Exception('Failed to load address');
      }
    }
    return null;
  }

  Future<void> updatePrimaryAddress(int addressId, bool isPrimary) async {
    final accessToken = await authService.getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }
    bool? isVerified = await authService.verifyToken(accessToken);

    if (isVerified != null && isVerified) {
      final response = await http.patch(
        Uri.parse(APIConstants.updatePrimaryAddressAPI(addressId)),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(<String, dynamic>{
          'is_primary': isPrimary,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to update primary address: ${response.statusCode}');
      }
    }
  }

  Future<Response> saveAddress(
      String address, double latitude, double longitude) async {
    final accessToken = await authService.getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }
    bool? isVerified = await authService.verifyToken(accessToken);

    if (isVerified != null && isVerified) {
      try {
        final response = await http.post(
          Uri.parse(APIConstants.saveAddressAPI),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode(<String, dynamic>{
            'address_text': address,
            'latitude': latitude,
            'longitude': longitude,
          }),
        );
        if (response.statusCode != 200 && response.statusCode != 201) {
          throw Exception('Failed to create address: ${response.statusCode}');
        }
        return response;
      } catch (e) {
        // Handle error
        throw Exception('Failed to create address: $e');
      }
    } else {
      throw Exception('Failed to verify token');
    }
  }

  Future<http.Response> deleteAddress(int addressId) async {
    final accessToken = await authService.getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }
    bool? isVerified = await authService.verifyToken(accessToken);

    if (isVerified != null && isVerified) {
      final response = await http.delete(
        Uri.parse(APIConstants.deleteAddressAPI(addressId)),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
      );

      return response;
    } else {
      throw Exception('Failed to verify token');
    }
  }
}

class Address {
  final int id;
  final String addressText;
  final double latitude;
  final double longitude;
  final bool isPrimary;

  Address({
    required this.id,
    required this.addressText,
    required this.latitude,
    required this.longitude,
    required this.isPrimary,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    double parsedLatitude = double.tryParse(json['latitude'] ?? '0.0') ?? 0.0;
    double parsedLongitude = double.tryParse(json['longitude'] ?? '0.0') ?? 0.0;
    return Address(
      id: json['id'],
      addressText: json['address_text'],
      latitude: parsedLatitude,
      longitude: parsedLongitude,
      isPrimary: json['is_primary'],
    );
  }
}
