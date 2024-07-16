import 'dart:convert';
import 'package:dailygrocery/service/service_constant.dart';
import 'package:http/http.dart' as http;
import 'package:dailygrocery/service/auth_service.dart';

class CategoryService {
  final AuthService authService = AuthService();

  Future<List<Category>> fetchHomeCategories() async {
    final accessToken = await authService.getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }

    bool? isVerified = await authService.verifyToken(accessToken);

    if (isVerified != null && isVerified) {
      final response = await http.get(
        Uri.parse(APIConstants.fetchHomeCategoriesAPI),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded",
          'Authorization': 'Bearer $accessToken',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((category) => Category.fromJson(category)).toList();
      } else {
        throw Exception('Failed to load categories');
      }
    }
    // Return an empty list if verification fails
    return [];
  }
  Future<List<Category>> fetchAllCategories() async {
    final accessToken = await authService.getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }

    bool? isVerified = await authService.verifyToken(accessToken);

    if (isVerified != null && isVerified) {
      final response = await http.get(
        Uri.parse(APIConstants.fetchAllCategoriesAPI),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded",
          'Authorization': 'Bearer $accessToken',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((category) => Category.fromJson(category)).toList();
      } else {
        throw Exception('Failed to load categories');
      }
    }
    // Return an empty list if verification fails
    return [];
  }
}

class Category {
  final int id;
  final String name;
  final String image;

  Category({required this.id, required this.name, required this.image});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      image: json['image'],
    );
  }
}
