import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dailygrocery/service/service_constant.dart';
import 'package:dailygrocery/service/auth_service.dart';

class OrderService {
  final AuthService _authService = AuthService();

  Future<bool> placeOrder(addresId, distance) async {
    final accessToken = await _authService.getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }
    bool? isVerified = await _authService.verifyToken(accessToken);

    if (isVerified != null && isVerified) {
      try {
        final response = await http.post(
          Uri.parse(APIConstants.placeOrder),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({
            'address_id': addresId,
            'distance': distance,
            'payment_method': 'COD',
          }),
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          // Order successfully placed
          return true;
        } else {
          // Failed to place order
          return false;
        }
      } catch (e) {
        // Error occurred while placing order
        print('Error: $e');
        return false;
      }
    } else {
      return false;
    }
  }

  Future<List<Order>> fetchOrders() async {
    final accessToken = await _authService.getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }
    bool? isVerified = await _authService.verifyToken(accessToken);

    if (isVerified != null && isVerified) {
      final response = await http.get(
        Uri.parse(APIConstants.orders),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        return responseData.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch orders');
      }
    } else {
      return [];
    }
  }

  Future<bool> updateOrder(orderId) async {
    final accessToken = await _authService.getAccessToken();
    if (accessToken == null) {
      throw Exception('Access token not found');
    }
    bool? isVerified = await _authService.verifyToken(accessToken);

    if (isVerified != null && isVerified) {
      try {
        final response = await http.put(
          Uri.parse(APIConstants.updateOrderAPI(orderId)),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({
            'order_status': 'cancelled',
          }),
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          // Order successfully updated
          return true;
        } else {
          // Failed to update order
          return false;
        }
      } catch (e) {
        // Error occurred while updating order
        print('Error: $e');
        return false;
      }
    } else {
      return false;
    }
  }
}

class Order {
  int id;
  int user;
  String paymentMethod;
  String orderStatus;
  double orderValue;
  double orderCharges;
  double orderDiscount;
  String addressText;
  double latitude;
  double longitude;
  bool isPrimary;
  final List<OrderGrocery> orderGroceries;

  Order({
    required this.id,
    required this.user,
    required this.paymentMethod,
    required this.orderStatus,
    required this.orderValue,
    required this.orderGroceries,
    required this.orderCharges,
    required this.orderDiscount,
    required this.addressText,
    required this.latitude,
    required this.longitude,
    required this.isPrimary,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      user: json['user'],
      paymentMethod: json['payment_method'],
      orderStatus: json['order_status'],
      orderValue: double.parse(json['order_value'].toString()),
      orderCharges: double.parse(json['order_charges'].toString()),
      orderDiscount: double.parse(json['order_discount'].toString()),
      addressText: json['address_text'],
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      isPrimary: json['is_primary'],
      orderGroceries: (json['order_groceries'] as List)
          .map((grocery) => OrderGrocery.fromJson(grocery))
          .toList(),
    );
  }
}

class OrderGrocery {
  int id;
  int order;
  int product;
  double price;
  double? discountedPrice;
  String weight;
  String productType;
  int quantity;
  String productName;
  double totalPrice;

  OrderGrocery({
    required this.id,
    required this.order,
    required this.product,
    required this.price,
    this.discountedPrice,
    required this.weight,
    required this.productType,
    required this.quantity,
    required this.productName,
    required this.totalPrice,
  });

  factory OrderGrocery.fromJson(Map<String, dynamic> json) {
    return OrderGrocery(
      id: json['id'],
      order: json['order'],
      product: json['product'],
      price: double.parse(json['price'].toString()),
      discountedPrice: json['discounted_price'] != null
          ? double.parse(json['discounted_price'].toString())
          : null,
      weight: json['weight'],
      productType: json['product_type'],
      quantity: json['quantity'],
      productName: json['product_name'],
      totalPrice: double.parse(json['total_price'].toString()),
    );
  }
}
