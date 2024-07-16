import 'package:dailygrocery/components/drawer.dart';
import 'package:dailygrocery/service/auth_service.dart';
import 'package:dailygrocery/service/order_service.dart';
import 'package:flutter/material.dart';
import 'package:dailygrocery/screens/home_page.dart';
import 'package:dailygrocery/screens/profile_page.dart';
import 'package:dailygrocery/screens/cart_page.dart';
import 'package:dailygrocery/components/navbar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foldable_list/foldable_list.dart';
import 'package:foldable_list/resources/arrays.dart';
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  bool _isLoading = false;
  int _selectedIndex = 1;
  late List<Widget> simpleWidgetList;
  late List<Widget> expandedWidgetList;
  final OrderService _orderService = OrderService();
  final AuthService _adminDetailsService = AuthService();
  late AdminDetails _adminDetails;

  List<Order> _orders = [];
  @override
  void initState() {
    super.initState();
    _fetchOrders();
    _fetchAdminDetails();
  }

  Future<void> _fetchAdminDetails() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final adminDetails = await _adminDetailsService.adminDetails();
      setState(() {
        _adminDetails = adminDetails!;
        _isLoading = false;
      });
    } catch (e) {
      print('Failed to fetch admin details: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateOrder(int orderId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final updated = await _orderService.updateOrder(orderId);
      if (updated) {
        Fluttertoast.showToast(
          msg: "Order has been cancelled.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
        );

        _fetchOrders();
        await _fetchAdminDetails();
      } else {
        Fluttertoast.showToast(
          msg: "Failed to cancel order.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
        );
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to cancel order.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _fetchOrders() async {
    setState(() {
      _isLoading = true;
    });
    try {
      List<Order> orders = await _orderService.fetchOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
        initList(_orders);
      });
    } catch (e) {
      // Handle error
      setState(() {
        _isLoading = false;
      });
      print('Error fetching addresses: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        break;
      case 1:
        //OrderPage
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CartPage()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyDrawer()),
        );
        break;
    }
  }

  Future<void> _launchUrl(String adminNumber) async {
    final Uri _url = Uri.parse('tel:$adminNumber');
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          forceMaterialTransparency: true,
          title: const Center(child: Text("Orders")),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _orders.isEmpty
                ? const Center(
                    child: Text(
                      'Empty Order',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  )
                : Container(
                    child: FoldableList(
                      animationType: AnimationType.none,
                      foldableItems: expandedWidgetList,
                      items: simpleWidgetList,
                    ),
                  ),
        bottomNavigationBar: BottomNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
          loader: _isLoading ? const CircularProgressIndicator() : null,
        ),
      ),
    );
  }

  initList(List<Order> orders) {
    simpleWidgetList = [];
    expandedWidgetList = [];
    Color backgroundColor;
    Color textColor;

    for (var order in orders) {
      switch (order.orderStatus) {
        case 'Assigned':
          backgroundColor = const Color(0xFFCFE2FF);
          textColor = Colors.black; // Change the text color as needed
          break;
        case 'Delivered':
          backgroundColor = const Color(0xFFD1E7DD);
          textColor = Colors.black; // Change the text color as needed
          break;
        case 'Placed':
          backgroundColor = const Color(0xFFFFF3CD);
          textColor = Colors.black; // Change the text color as needed
          break;
        case 'Order Cancelled':
          backgroundColor = const Color(0xFFE2E3E5);
          textColor = Colors.black; // Change the text color as needed
          break;
        default:
          backgroundColor = const Color.fromARGB(255, 154, 198, 177);
          textColor = Colors.black;
      }
      simpleWidgetList
          .add(renderSimpleWidget(order, backgroundColor, textColor));
      expandedWidgetList
          .add(renderExpandedWidget(order, backgroundColor, textColor));
    }
  }

  Widget renderSimpleWidget(Order order, backgroundColor, textColor) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 1,
      child: Padding(
        padding:
            const EdgeInsets.only(left: 12, right: 12, top: 14, bottom: 14),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange,
                  radius: 20,
                  child: Text(
                    '${order.id}',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(
                  width: 14,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Address: ",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Flexible(
                            child: Text(
                              order.addressText,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(
                            child: Row(
                          children: [
                            const Text(
                              "Payment-Method:",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              order.paymentMethod,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 13),
                            ),
                          ],
                        )),
                      ]),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text(
                            "Order Status:",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            order.orderStatus,
                            style: TextStyle(
                                color: textColor,
                                backgroundColor: backgroundColor,
                                fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (order.orderStatus == 'Placed' ||
                        order.orderStatus == 'Assigned' ||
                        order.orderStatus == 'Picked Up')
                      IconButton(
                        icon: const Icon(Icons.call),
                        onPressed: () {
                          _launchUrl(_adminDetails.orderSupport);
                          // Add the functionality to call the address here
                        },
                      ),
                    if (order.orderStatus == 'Placed' ||
                        order.orderStatus == 'Assigned')
                      IconButton(
                        icon: const Icon(
                            Icons.cancel), // Icon for cancelling the order
                        onPressed: () async {
                          await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirm Cancel'),
                              content: const Text(
                                  'Are you sure you want to cancel this order?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    _updateOrder(order.id);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Yes'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('No'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 8,
                bottom: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildOrderDetailItem(
                      "Chargers: ", Colors.orange, '${order.orderCharges}'),
                  const Spacer(),
                  _buildOrderDetailItem(
                      "Discount: ", Colors.orange, "${order.orderDiscount}"),
                  const Spacer(),
                  _buildOrderDetailItem(
                      "Total: ", Colors.orange, '${order.orderValue}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget renderExpandedWidget(Order order, backgroundColor, textColor) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8, top: 14, bottom: 14),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Colors.orange,
                radius: 20,
                child: Text(
                  '${order.id}',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              const SizedBox(
                width: 14,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Address: ",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Flexible(
                          child: Text(
                            order.addressText,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(children: [
                      Expanded(
                          child: Row(
                        children: [
                          const Text(
                            "Payment-Method:",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            order.paymentMethod,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 13),
                          ),
                        ],
                      )),
                    ]),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text(
                          "Order Status:",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          order.orderStatus,
                          style: TextStyle(
                              color: textColor,
                              backgroundColor: backgroundColor,
                              fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (order.orderStatus == 'Placed' ||
                      order.orderStatus == 'Assigned' ||
                      order.orderStatus == 'Picked Up')
                    IconButton(
                      icon: const Icon(Icons.call),
                      onPressed: () {
                        _launchUrl(_adminDetails.orderSupport);
                        // Add the functionality to call the address here
                      },
                    ),
                  if (order.orderStatus == 'Placed' ||
                      order.orderStatus == 'Assigned')
                    IconButton(
                      icon: const Icon(
                          Icons.cancel), // Icon for cancelling the order
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm Cancel'),
                            content: const Text(
                                'Are you sure you want to cancel this order?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  _updateOrder(order.id);
                                  Navigator.pop(context);
                                },
                                child: const Text('Yes'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('No'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 8,
              bottom: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildOrderDetailItem(
                    "Chargers: ", Colors.orange, '${order.orderCharges}'),
                const Spacer(),
                _buildOrderDetailItem(
                    "Discount: ", Colors.orange, "${order.orderDiscount}"),
                const Spacer(),
                _buildOrderDetailItem(
                    "Total: ", Colors.orange, '${order.orderValue}'),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(7)),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Items",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SizedBox(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(7)),
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 8, bottom: 4, left: 4, right: 4),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          child: Column(
                            children: order.orderGroceries.map((grocery) {
                              int index = order.orderGroceries.indexOf(grocery);
                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildProductDetailItem(
                                            "Product: ",
                                            Colors.black,
                                            utf8.decode(grocery
                                                .productName.runes
                                                .toList()),
                                          ),
                                          const SizedBox(height: 8),
                                          _buildProductDetailItem(
                                            "Weight: ",
                                            Colors.black,
                                            grocery.weight,
                                          ),
                                          const SizedBox(height: 8),
                                          _buildProductDetailItem(
                                            "Discount: ",
                                            Colors.black,
                                            "${grocery.discountedPrice}",
                                          ),
                                          const SizedBox(height: 8),
                                        ],
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildProductDetailItem(
                                            "Type: ",
                                            Colors.black,
                                            grocery.productType,
                                          ),
                                          const SizedBox(height: 8),
                                          _buildProductDetailItem(
                                            "Quantity: ",
                                            Colors.black,
                                            "${grocery.quantity}",
                                          ),
                                          const SizedBox(height: 8),
                                          _buildProductDetailItem(
                                            "Price: ",
                                            Colors.black,
                                            "${grocery.price}",
                                          ),
                                          const SizedBox(height: 8),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  if (index != order.orderGroceries.length - 1)
                                    const Divider(
                                      thickness: 0.4,
                                      height: 1,
                                      color: Colors.black,
                                    ),
                                  const SizedBox(height: 10),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }

  Widget _buildOrderDetailItem(String label, Color color, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
          const SizedBox(width: 8),
          Text(answer,
              style: const TextStyle(color: Colors.orange, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildProductDetailItem(
    String label,
    Color color,
    String answer,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
          const SizedBox(width: 8),
          Text(answer,
              style: const TextStyle(color: Colors.black, fontSize: 13)),
        ],
      ),
    );
  }
}
