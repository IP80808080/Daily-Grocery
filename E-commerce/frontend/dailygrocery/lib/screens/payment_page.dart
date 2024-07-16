import 'package:dailygrocery/screens/cart_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';

import 'package:dailygrocery/screens/order_page.dart';
import 'package:dailygrocery/service/address_service.dart';
import 'package:dailygrocery/service/cart_service.dart';
import 'package:dailygrocery/service/order_service.dart';
import 'package:ionicons/ionicons.dart';

class PaymentPage extends StatefulWidget {
  final int selectedAddressId;
  const PaymentPage({Key? key, required this.selectedAddressId})
      : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isPlacingOrder = false;
  bool _isInitialLoading = true;
  final OrderService orderPage = OrderService();
  final AddressService addressService = AddressService();
  late String _address;
  final CartService _cartService = CartService();
  late List<CartItem> _cartItems = [];
  bool _isLoading = false;
  double _distance = 0;
  double _deliveryCharge = 0;

  @override
  void initState() {
    super.initState();
    _verifyCartItems();
  }

  Future<void> _verifyCartItems() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final valid = await _cartService.verifyCartProductPrices();
      setState(() {
        _isLoading = false;
      });
      if (!valid) {
        Fluttertoast.showToast(
          msg: "Cart Items are updated. please check again.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CartPage()),
        );
      } else {
        _fetchCartItems();
        _fetchDeliveryAddress();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _fetchDeliveryAddress() async {
    setState(() {
      _isLoading = true;
    });
    try {
      Address? address =
          await addressService.getDeliveryAddress(widget.selectedAddressId);

      Map<String, dynamic> distanceAndCharges =
          await calculateDistanceAndDeliveryCharges(
              address?.latitude ?? 0, address?.longitude ?? 0);
      double distance = (distanceAndCharges['distance'] as double?) ?? 0;
      double deliveryCharge =
          (distanceAndCharges['deliveryCharge'] as double?) ?? 0;

      setState(() {
        _address = address?.addressText ?? "No address available";
        _distance = distance;
        _deliveryCharge = deliveryCharge;
        _isLoading = false;
        _isInitialLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isInitialLoading = false;
      });
      print('Error fetching delivery address: $e');
    }
  }

  Future<void> _fetchCartItems() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final cartItems = await _cartService.getCartItems();
      setState(() {
        _cartItems = cartItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching cart items: $e');
    }
  }

  void _placeOrder() async {
    setState(() {
      _isPlacingOrder = true;
    });

    bool success =
        await orderPage.placeOrder(widget.selectedAddressId, _distance);

    setState(() {
      _isPlacingOrder = false;
    });
    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const OrderPage(),
        ),
      );
    } else {
      Fluttertoast.showToast(
        msg: 'Failed to place order, try again',
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  String _decodeUtf8(String str) {
    try {
      return utf8.decode(latin1.encode(utf8.decode(str.runes.toList())));
    } catch (e) {
      try {
        return utf8.decode(str.runes.toList());
      } catch (e) {
        return str;
      }
    }
  }

  Future<Map<String, num>> calculateDistanceAndDeliveryCharges(
      double userLat, double userLng) async {
    try {
      double distanceInMetersKaranja =
          Geolocator.distanceBetween(userLat, userLng, 20.4819746, 77.4821257);
      double distanceInMetersShelubazar =
          Geolocator.distanceBetween(userLat, userLng, 20.3710062, 77.2507813);

      double distanceInKmKaranja = distanceInMetersKaranja / 1000;
      double distanceInKmShelubazar = distanceInMetersShelubazar / 1000;
      // Compare the distances and assign the lesser one to a variable
      double distanceInKm = distanceInKmKaranja < distanceInKmShelubazar
          ? distanceInKmKaranja
          : distanceInKmShelubazar;
      double deliveryCharge = 0;
      if (distanceInKm <= 3) {
        deliveryCharge = 20;
      } else if (distanceInKm > 3 && distanceInKm <= 5) {
        deliveryCharge = 25;
      } else {
        deliveryCharge = 25 + (distanceInKm - 5) * 5;
      }
      Map<String, num> result = {
        'distance': distanceInKm,
        'deliveryCharge': deliveryCharge,
      };

      return result;
    } catch (e) {
      print("Error calculating distance: $e");
      return {'distance': -1, 'deliveryCharge': -1};
    }
  }

  @override
  Widget build(BuildContext context) {
    double overallTotal = _deliveryCharge;
    double overallDiscount = 0;
    double cartTotal = 0;
    for (var cartItem in _cartItems) {
      overallTotal += cartItem.totalPrice;
      if (cartItem.discountedPrice != 0.0) {
        overallDiscount +=
            (cartItem.price - cartItem.discountedPrice) * cartItem.quantity;
      }
    }
    if (overallDiscount <= 0) {
      overallDiscount = 0;
    }
    cartTotal = overallTotal - _deliveryCharge;
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        leading: Card(
          shape: const CircleBorder(),
          child: IconButton(
            icon: const Icon(
              Ionicons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: SafeArea(
        child: _isInitialLoading
            ? const Center(child: CircularProgressIndicator())
            : _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _isPlacingOrder
                    ? const Center(child: CircularProgressIndicator())
                    : _cartItems.isEmpty
                        ? const Center(
                            child: Text("No Cart Items Found."),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(
                                left: 12, right: 12, bottom: 12),
                            child: Column(
                              children: [
                                const SizedBox(
                                  child: Column(
                                    children: [
                                      Text("Make Payment ",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.green)),
                                      SizedBox(height: 5),
                                      Text("Order Details",
                                          style: TextStyle(
                                              fontSize: 24,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    const SizedBox(height: 14),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(7),
                                          border:
                                              Border.all(color: Colors.grey)),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        child: Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: DataTable(
                                            columns: const [
                                              DataColumn(
                                                  label: Text(
                                                "Products",
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )),
                                              DataColumn(
                                                  label: Text(
                                                "Weight",
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )),
                                              DataColumn(
                                                  label: Text(
                                                "Quantity",
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )),
                                            ],
                                            rows: _cartItems
                                                .map((cartItem) => DataRow(
                                                      cells: [
                                                        DataCell(Text(
                                                          _decodeUtf8(cartItem
                                                              .productName),
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 15,
                                                            color: Colors.black,
                                                          ),
                                                        )),
                                                        DataCell(Text(
                                                          cartItem.weight,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 15,
                                                            color: Colors.black,
                                                          ),
                                                        )),
                                                        DataCell(Text(
                                                          cartItem.quantity
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 15,
                                                            color: Colors.black,
                                                          ),
                                                        )),
                                                      ],
                                                    ))
                                                .toList(),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    Container(
                                                      width: 70,
                                                      height: 70,
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .grey.shade300,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        image:
                                                            const DecorationImage(
                                                          image: AssetImage(
                                                              'assets/images/mapbg.jpg'),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      child: const Icon(
                                                        Icons.location_on,
                                                        color: Colors.red,
                                                        size: 30,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        'Delivery to',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        _address,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.black,
                                                        ),
                                                        softWrap: true,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            const Divider(
                                                color: Colors.black,
                                                thickness: 0.2),
                                            const SizedBox(height: 8),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8, right: 8),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      const Text(
                                                        "Delivery Distance",
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      Text(
                                                        "${_distance.toStringAsFixed(2)} KM",
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      const Text(
                                                        "Delivery Charge",
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      Text(
                                                        "₹ ${_deliveryCharge.toStringAsFixed(2)}",
                                                        style: const TextStyle(
                                                            fontSize: 15,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      const Text("Discount",
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .black)),
                                                      Text("₹ $overallDiscount",
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                      .black)),
                                                    ],
                                                  ),
                                                  const Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text("Payment Type",
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .black)),
                                                      Text("Cash on Delivery",
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .black)),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      const Text("Cart Total",
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      Text(
                                                          '₹ ${cartTotal.toStringAsFixed(2)}',
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .green)),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      const Text(
                                                          "Total Payable",
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      Text(
                                                          '₹ ${overallTotal.toStringAsFixed(2)}',
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .green)),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              side: const BorderSide(
                                                  color: Color(0xFFfc5d01)),
                                              backgroundColor:
                                                  const Color(0xFFfc5d01),
                                              minimumSize: const Size(25, 45),
                                            ),
                                            onPressed: _placeOrder,
                                            child: Text(
                                              'Place Order of ₹ ${overallTotal.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                  ],
                                ),
                              ],
                            ),
                          ),
      ),
    );
  }
}
