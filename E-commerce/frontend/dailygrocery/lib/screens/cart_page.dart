import 'package:dailygrocery/components/drawer.dart';
import 'package:dailygrocery/utils/cart.dart';
import 'package:dailygrocery/screens/order_page.dart';
import 'package:dailygrocery/screens/profile_page.dart';
import 'package:dailygrocery/screens/home_page.dart';
import 'package:dailygrocery/screens/select_address.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dailygrocery/components/navbar.dart';
import 'package:dailygrocery/service/cart_service.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:ionicons/ionicons.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartService _cartService = CartService();
  bool _isLoading = false;
  int _selectedIndex = 3;
  late List<CartItem> _cartItems = [];

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
      bool valid = await _cartService.verifyCartProductPrices();
      setState(() {
        _isLoading = false;
      });
      if (!valid) {
        Fluttertoast.showToast(
          msg: "Cart Items are updated. please check again.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
        );
        _fetchCartItems();
      } else {
        _fetchCartItems();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
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
      // Handle error
      print('Error fetching cart items: $e');
    }
  }

  void _onItemTapped(int index) {
    // Handle bottom navigation bar item taps
    setState(() {
      _selectedIndex = index;
    });

    // Handle navigation logic
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OrderPage()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
        break;
      case 3:
        // CartPage
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyDrawer()),
        );
        break;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        forceMaterialTransparency: true,
        title: const Center(child: Text('Cart')),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cartItems.isEmpty
              ? const Center(
                  child: Text(
                  'No cart Item found',
                ))
              : Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 4),
                          decoration: BoxDecoration(
                              color: const Color(0xFFfff8f3),
                              border:
                                  Border.all(color: const Color(0xFFf3a52e)),
                              borderRadius: BorderRadius.circular(5)),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              children: [
                                Icon(
                                  Ionicons.alert_circle,
                                  color: Color(0xFFf3a52e),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: Text(
                                    "For New Customers we are offering free Cakkli",
                                    style: TextStyle(color: Color(0xFFf3a52e)),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 14,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "My Cart",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: const SizedBox(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Icon(
                                      Icons.rocket_launch_rounded,
                                      color: Color(0xFFfc5d01),
                                      size: 18,
                                    ),
                                    SizedBox(
                                      width: 4,
                                    ),
                                    Text(
                                      "Express Delivery",
                                      style: TextStyle(
                                          color: Color(0xFFfc5d01),
                                          fontSize: 13),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 14,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 4, right: 4, top: 4, bottom: 4),
                          child: _buildCartListView(),
                        ),
                      ),
                      if (_cartItems
                          .isNotEmpty) // Only show if cart is not empty
                        Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: const Color(0xFFfc5d01),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Total: (₹) ${_calculateOverallTotal().toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontFamily: 'Roboto',
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: SizedBox(
                                height: 40,
                                child: Card(
                                  color: Colors.white,
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(6)),
                                  ),
                                  child: Padding(
                                    padding:
                                        EdgeInsets.only(left: 10, right: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(Icons.check_circle_outline,
                                            color: Colors.green),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Text(
                                          "Delivery fee is Reduced to ₹ 200 from ₹ 250",
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontFamily: 'Roboto',
                                            fontSize: 12,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 15, right: 15),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SelectAddress(),
                                    ),
                                  ).then((value) => {_fetchCartItems});
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  side: const BorderSide(
                                    color: Color(0xFFfc5d01),
                                  ),
                                  backgroundColor: const Color(0xFFfc5d01),
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(top: 6, bottom: 6),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: const Color(0xFFfc5d01),
                                          border: Border.all(
                                              color: Colors.white, width: 2),
                                        ),
                                        child: const CircleAvatar(
                                          backgroundColor: Colors.transparent,
                                          child: Icon(
                                            Icons.shopping_cart,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      Text(
                                        "Review Address",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Roboto',
                                          fontSize: 18,
                                        ),
                                      ),
                                      Spacer(),
                                      SizedBox(
                                        width: 24,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        )
                    ],
                  ),
                ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        loader: _isLoading ? const CircularProgressIndicator() : null,
      ),
    );
  }

  double _calculateOverallTotal() {
    double overallTotal = 0;
    for (var cartItem in _cartItems) {
      overallTotal += cartItem.totalPrice;
    }
    return overallTotal;
  }

  void _handleQuantityChange(CartItem cartItem, int change) async {
    setState(() {
      cartItem.quantity += change;
      cartItem.totalPrice = (cartItem.discountedPrice != 0.0
              ? cartItem.discountedPrice
              : cartItem.price) *
          cartItem.quantity;
      (cartItem.price - cartItem.discountedPrice) *
          cartItem.quantity; // Update total price
      if (cartItem.quantity <= 0) {
        _cartItems.remove(cartItem);
      }
    });
  }

  Widget _buildCartListView() {
    return _cartItems.isNotEmpty
        ? ListView.builder(
            itemCount: _cartItems.length,
            itemBuilder: (context, index) {
              final cartItem = _cartItems[index];
              _decodeUtf8(cartItem.productName);
              return SingleChildScrollView(
                child: Column(children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(
                            height: 34,
                            width: 34,
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10)),
                              child: AspectRatio(
                                  aspectRatio: 1, child: Text("data")),
                            ),
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _decodeUtf8(cartItem.productName),
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text(
                                    'Weight: ${cartItem.weight}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'Roboto',
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 6,
                                  ),
                                  Text(
                                    'Type: ${cartItem.productType}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'Roboto',
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Total Price: (₹) ${cartItem.totalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 12,
                                  color: Color(0xFFfc5d01),
                                ),
                              ),
                            ],
                          ),
                          Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Stack(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.remove_circle_outline,
                                        color: cartItem.quantity > 0
                                            ? const Color(0xFFfc5d01)
                                            : Colors.grey,
                                        size: 25,
                                      ),
                                      onPressed: () async {
                                        setState(() {
                                          _isLoading = true;
                                        });
                                        try {
                                          bool requestSuccess =
                                              await CartFunctionHandler(
                                            context: context,
                                            cartService: _cartService,
                                          ).subtractQuantity(
                                            cartItem.productId,
                                            cartItem.price,
                                            cartItem.discountedPrice,
                                          );
                                          if (requestSuccess) {
                                            _handleQuantityChange(cartItem, -1);
                                          }
                                        } finally {
                                          setState(() {
                                            _isLoading = false;
                                          });
                                        }
                                      },
                                    ),
                                    if (_isLoading) // Show loader if loading
                                      const Positioned.fill(
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${cartItem.quantity}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Roboto',
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Stack(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                        color: Color(0xFFfc5d01),
                                        size: 25,
                                      ),
                                      onPressed: () async {
                                        setState(() {
                                          _isLoading = true;
                                        });
                                        try {
                                          bool requestSuccess =
                                              await CartFunctionHandler(
                                            context: context,
                                            cartService: _cartService,
                                          ).addQuantity(
                                            null,
                                            cartItem.productId,
                                            cartItem.productPricesId,
                                            cartItem.price,
                                            cartItem.discountedPrice,
                                            cartItem.weight,
                                          );
                                          if (requestSuccess) {
                                            _handleQuantityChange(cartItem, 1);
                                          }
                                        } finally {
                                          setState(() {
                                            _isLoading = false;
                                          });
                                        }
                                      },
                                    ),
                                    if (_isLoading) // Show loader if loading
                                      const Positioned.fill(
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
              );
            },
          )
        : const Center(
            child: Text(
            'No cart item found',
          ));
  }
}
