import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dailygrocery/service/auth_service.dart';
import 'package:dailygrocery/service/service_constant.dart';

class ProductService {
  final AuthService authService = AuthService();

  Future<List<Product>> fetchProducts(
      String action, String query, int limit, int offSet) async {
    final accessToken = await authService.getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }

    bool? isVerified = await authService.verifyToken(accessToken);
    if (isVerified != null && isVerified) {
      final response = await http.get(
          Uri.parse(
              '${APIConstants.fetchAllProductsAPI(action, query)}&limit=$limit&offset=$offSet'),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/x-www-form-urlencoded",
            'Authorization':
                'Bearer $accessToken', // Include access token in request headers
          });
      if (response.statusCode == 200) {
        List<Product> products = (json.decode(response.body)['results'] as List)
            .map((data) => Product.fromJson(data))
            .toList();
        return products;
      } else {
        throw Exception('Failed to fetch products');
      }
    }
    return [];
  }

  Future<List<Product>> fetchHomeProducts() async {
    final accessToken = await authService.getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }

    bool? isVerified = await authService.verifyToken(accessToken);
    if (isVerified != null && isVerified) {
      final response = await http
          .get(Uri.parse(APIConstants.fetchHomeProductsAPI), headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
        'Authorization':
            'Bearer $accessToken', // Include access token in request headers
      });
      if (response.statusCode == 200) {
        final List<dynamic> data = (json.decode(response.body));
        return data.map((data) => Product.fromJson(data)).toList();
      } else {
        throw Exception('Failed to fetch products');
      }
    }
    return [];
  }

  Future<Product> getProduct(int productId) async {
    final accessToken = await authService.getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }
    bool? isVerified = await authService.verifyToken(accessToken);
    if (isVerified != null && isVerified) {
      final response = await http.get(
          Uri.parse(APIConstants.fetchProductDetailsAPI(productId)),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/x-www-form-urlencoded",
            'Authorization':
                'Bearer $accessToken', // Include access token in request headers
          });
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);
        return Product.fromJson(jsonData);
      } else {
        throw Exception('Failed to fetch product details');
      }
    } else {
      throw Exception('Token verification failed');
    }
  }
}

class Product {
  final int id;
  final String name;
  final String details;
  final List<ProductImage> productImages;
  final List<ProductPrice> productPrices;
  final int category;
  final String productType;

  Product({
    required this.id,
    required this.name,
    required this.details,
    required this.productImages,
    required this.productPrices,
    required this.category,
    required this.productType,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      details: json['details'],
      category: json['category'],
      productImages: (json['product_image'] as List)
          .map((image) => ProductImage.fromJson(image))
          .toList(),
      productPrices: (json['product_prices'] as List)
          .map((price) => ProductPrice.fromJson(price))
          .toList(),
      productType: json['product_type'] ?? '',
    );
  }
}

class ProductImage {
  final int id;
  final String image;

  ProductImage({
    required this.id,
    required this.image,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'],
      image: json['image'],
    );
  }
}

class ProductPrice {
  final int id;
  final double price;
  final double? discountedPrice;
  final String weight;

  ProductPrice({
    required this.id,
    required this.price,
    required this.discountedPrice,
    required this.weight,
  });

  factory ProductPrice.fromJson(Map<String, dynamic> json) {
    double parsedPrice = double.tryParse(json['price'] ?? '0.0') ?? 0.0;
    double? parsedDiscountedPrice = json['discounted_price'] != null
        ? double.tryParse(json['discounted_price'] ?? '0.0')
        : null;

    return ProductPrice(
      id: json['id'],
      price: parsedPrice,
      discountedPrice: parsedDiscountedPrice,
      weight: json['weight'] ?? '',
    );
  }
}
