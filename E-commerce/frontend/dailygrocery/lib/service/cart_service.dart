import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dailygrocery/service/service_constant.dart';
import 'package:dailygrocery/service/auth_service.dart';

class CartService {
  final AuthService authService = AuthService();

  Future<bool> addToCart({
    required int productId,
    required int quantity,
    required int productPricesId,
    required double price,
    required double discountedPrice,
    required String weight,
    required String productType,
    required String productName,
  }) async {
    final accessToken = await authService.getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }
    bool? isVerified = await authService.verifyToken(accessToken);

    if (isVerified != null && isVerified) {
      try {
        final response = await http.post(Uri.parse(APIConstants.addToCart),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $accessToken',
            },
            body: jsonEncode({
              'product': productId,
              'quantity': quantity,
              'price': price,
              'product_prices': productPricesId,
              'discounted_price': discountedPrice,
              'weight': weight,
              'product_type': productType,
              'total_price': discountedPrice != 0
                  ? quantity * discountedPrice
                  : quantity * price,
              'product_name': productName
            }));
        if (response.statusCode == 200 || response.statusCode == 201) {
          // Product successfully added to cart
          return true;
        } else {
          // Failed to add product to cart
          return false;
        }
      } catch (e) {
        // Error occurred while adding product to cart
        print('Error: $e');
        return false;
      }
    } else {
      return false;
    }
  }

  Future<CartItem?> findProductInCart(
      int productId, double price, double discountedPrice) async {
    final accessToken = await authService.getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }
    bool? isVerified = await authService.verifyToken(accessToken);

    if (isVerified != null && isVerified) {
      final response = await http.get(
        Uri.parse(APIConstants.productInCartExistsAPI(
            productId, price.toString(), discountedPrice.toString())),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return CartItem.fromJson(
            responseData); // Deserialize response data into CartItem object
      }
    } else {
      throw Exception('Token verification failed');
    }
    return null;
  }

  Future<void> updateCartItem(
      int cartItemId, int quantity, double totalPrice) async {
    final url = Uri.parse(APIConstants.updateCartAPI(cartItemId, quantity));
    final accessToken = await authService.getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }
    bool? isVerified = await authService.verifyToken(accessToken);

    if (isVerified != null && isVerified) {
      try {
        final response = await http.put(
          url,
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({
            'id': cartItemId,
            'quantity': quantity,
            'total_price': totalPrice
          }),
        );

        if (response.statusCode == 200) {
          // Cart item updated successfully
          print('Cart item updated successfully');
        } else {
          // Handle error
          throw Exception('Failed to update cart item');
        }
      } catch (e) {
        // Handle error
        throw Exception('Failed to update cart item: $e');
      }
    } else {
      throw Exception('Token verification failed');
    }
  }

  Future<void> removeFromCart(int cartItemId) async {
    final accessToken = await authService.getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }
    bool? isVerified = await authService.verifyToken(accessToken);

    if (isVerified != null && isVerified) {
      try {
        // Make API request to delete cart item
        final response = await http.delete(
          Uri.parse(APIConstants.removeFromCartAPI(cartItemId)),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json",
            'Authorization': 'Bearer $accessToken',
          },
        );

        if (response.statusCode == 200 || response.statusCode == 204) {
          // Cart item updated successfully
          print('Cart item Deleted successfully');
        } else {
          // Handle error
          throw Exception('Failed to remove cart item');
        }
      } catch (e) {
        // Handle errors
        print('Error removing item from cart: $e');
        throw Exception('Failed to remove item from cart');
      }
    }
  }

  Future<List<CartItem>> getCartItems() async {
    final String? accessToken = await authService.getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }

    final bool? isVerified = await authService.verifyToken(accessToken);
    if (isVerified != null && isVerified) {
      final Uri url = Uri.parse(APIConstants.cartAPI);
      final http.Response response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        return responseData.map((data) => CartItem.fromJson(data)).toList();
      } else {
        throw Exception('Failed to fetch cart items');
      }
    } else {
      throw Exception('Token verification failed');
    }
  }

  Future<List<CartQuantity>> getCartQuantityItems() async {
    final String? accessToken = await authService.getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }

    final bool? isVerified = await authService.verifyToken(accessToken);
    if (isVerified != null && isVerified) {
      final Uri url = Uri.parse(APIConstants.cartQuantity);
      final http.Response response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        return responseData.map((data) => CartQuantity.fromJson(data)).toList();
      } else {
        throw Exception('Failed to fetch cart items');
      }
    } else {
      throw Exception('Token verification failed');
    }
  }

  Future getTotalCart() async {
    final String? accessToken = await authService.getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }

    final bool? isVerified = await authService.verifyToken(accessToken);
    if (isVerified != null && isVerified) {
      final Uri url = Uri.parse(APIConstants.totalCartQuantity);
      final http.Response response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        int totalItems = data['total_items'];
        return totalItems;
      } else {
        throw Exception('Failed to fetch cart items');
      }
    } else {
      throw Exception('Token verification failed');
    }
  }

  Future<bool> verifyCartProductPrices() async {
    final String? accessToken = await authService.getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }

    final bool? isVerified = await authService.verifyToken(accessToken);
    if (isVerified != null && isVerified) {
      final Uri url = Uri.parse(APIConstants.verifyCartProductPrices);
      final http.Response response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        bool valid = data['valid'];
        return valid;
      } else {
        throw Exception('Failed to verify cart items');
      }
    } else {
      throw Exception('Token verification failed');
    }
  }
}

class CartQuantity {
  final int productId;
  final int quantity;
  final double price;

  CartQuantity({
    required this.productId,
    required this.quantity,
    required this.price,
  });
  factory CartQuantity.fromJson(Map<String, dynamic> json) {
    return CartQuantity(
      productId: json['product'],
      quantity: json['quantity'],
      price:
          json['price'] != null ? double.parse(json['price'].toString()) : 0.0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      'price': price,
    };
  }
}

class CartItem {
  final int id;
  final String userId;
  final int productId;
  final int productPricesId;
  int quantity;
  final double price;
  final double discountedPrice;
  final String weight;
  final String productName;
  final String productType;
  double totalPrice;

  CartItem({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productPricesId,
    required this.quantity,
    required this.price,
    required this.discountedPrice,
    required this.weight,
    required this.productName,
    required this.productType,
    required this.totalPrice,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      userId: json['user'] as String,
      productId: json['product'],
      productPricesId: json['product_prices'],
      productName: json['product_name'],
      quantity: json['quantity'],
      price:
          json['price'] != null ? double.parse(json['price'].toString()) : 0.0,
      discountedPrice: json['discounted_price'] != null
          ? double.parse(json['discounted_price'].toString())
          : 0.0,
      weight: json['weight'],
      productType: json['product_type'],
      totalPrice: json['total_price'] != null
          ? double.parse(json['total_price'].toString())
          : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'productId': productId,
      'quantity': quantity,
      'price': price,
      'discountedPrice': discountedPrice,
      'weight': weight,
      'productType': productType,
    };
  }
}
