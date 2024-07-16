import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dailygrocery/service/cart_service.dart';
import 'package:dailygrocery/utils/cart.dart';
import 'package:dailygrocery/service/product_service.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/widgets.dart';
import 'package:ionicons/ionicons.dart';
import 'dart:convert';
import 'dart:async';

class ProductDetailsPage extends StatefulWidget {
  final int productId;

  const ProductDetailsPage({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  final ProductService _productService = ProductService();
  final CartService cartService = CartService();
  final Map<String, ValueNotifier<int>> _counters = {};
  List<CartQuantity> _cartQuantity = [];

  late Future<Product> _productFuture;
  int counter = 0;
  int _currentImageIndex = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _productFuture = _productService.getProduct(widget.productId);
    _fetchCartQuantity();
  }

  Map<int, Map<int, int>> formatCartQuantity(
      List<CartQuantity> cartQuantities) {
    Map<int, Map<int, int>> formattedData = {};

    for (var cartQuantity in cartQuantities) {
      if (!formattedData.containsKey(cartQuantity.productId)) {
        formattedData[cartQuantity.productId] = {};
      }

      int priceInt = cartQuantity.price.toInt();

      formattedData[cartQuantity.productId]![priceInt] = cartQuantity.quantity;
    }

    return formattedData;
  }

  Future<void> _fetchCartQuantity() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<CartQuantity> cartQuantityItems =
          await cartService.getCartQuantityItems();
      setState(() {
        _cartQuantity = cartQuantityItems;
        _isLoading = false;
      });
      Map<int, Map<int, int>> formattedData =
          formatCartQuantity(cartQuantityItems);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching category products: $e');
    }
  }

  Future<void> _fetchCartQuantity2() async {
    try {
      List<CartQuantity> cartQuantityItems =
          await cartService.getCartQuantityItems();
      setState(() {
        _cartQuantity = cartQuantityItems;
        _isLoading = false;
      });
      Map<int, Map<int, int>> formattedData =
          formatCartQuantity(cartQuantityItems);
    } catch (e) {
      print('Error fetching category products: $e');
    }
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              width: 10,
              padding: const EdgeInsets.only(
                top: 4,
                bottom: 4,
              ),
              child: Text(
                value,
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        title: const Center(child: Text('Product Details')),
      ),
      body: FutureBuilder<Product>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            Product product = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image Slider
                Stack(
                  children: [
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 220,
                        enableInfiniteScroll: product.productImages.length > 1,
                        autoPlay: product.productImages.length > 1,
                        enlargeCenterPage: true,
                        viewportFraction: 1,
                        autoPlayInterval: const Duration(seconds: 2),
                        autoPlayAnimationDuration:
                            const Duration(milliseconds: 800),
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentImageIndex = index;
                          });
                        },
                      ),
                      items: product.productImages.map((image) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Image.network(
                              image.image,
                              fit: BoxFit.cover,
                            );
                          },
                        );
                      }).toList(),
                    ),
                    Positioned(
                      top: 190,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: product.productImages.map((image) {
                          int index = product.productImages.indexOf(image);
                          return Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImageIndex == index
                                  ? const Color(0xFFfc5d01)
                                  : const Color.fromARGB(255, 255, 255, 255),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const Positioned(
                      top: 190,
                      left: 10,
                      child: Icon(
                        Icons.more_horiz,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                        top: 10, bottom: 12, left: 12, right: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      utf8.decode(product.name.runes.toList()),
                                      style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'Available',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Roboto',
                                          color: Colors.green),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  width: 350,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          utf8.decode(
                                              product.details.runes.toList()),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                              color: const Color(0xFFfef2c7),
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 10, 10, 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Ionicons.lock_closed,
                                        color: Color(0xFFfc5d01),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        child: const Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Free Delivery',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'Roboto',
                                                color: Color(0xFFfc5d01),
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'within 3 Hours',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontFamily: 'Roboto',
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    child: const Text(
                                      'Choose',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Roboto',
                                        color: Color(0xFFfc5d01),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Product Information',
                          style: TextStyle(
                              fontSize: 17,
                              fontFamily: 'Roboto',
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Table(
                          columnWidths: {
                            0: FlexColumnWidth(1),
                            1: FlexColumnWidth(2),
                          },
                          children: [
                            _buildTableRow('Weight: ',
                                '${product.productPrices.isNotEmpty ? product.productPrices[0].weight : ''}'),
                            _buildTableRow(
                                'Product Type: ', '${product.productType}'),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
      bottomNavigationBar: FutureBuilder<Product>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            Product product = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
              child: SizedBox(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      side: const BorderSide(
                        color: Color(0xFFfc5d01),
                      ),
                      backgroundColor: const Color(0xFFfc5d01),
                      minimumSize: const Size(25, 45)),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        bool isLoadingBottomodesheet = false;
                        return StatefulBuilder(
                          builder: (context, setState) {
                            return Container(
                              child: isLoadingBottomodesheet
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : ListView.builder(
                                      itemCount: product.productPrices.length,
                                      itemBuilder: (context, index) {
                                        int quantity = 0;
                                        final price =
                                            product.productPrices[index];
                                        String priceKey =
                                            '${product.id}_${price.price}_${price.discountedPrice ?? price.price}';
                                        int initialQuantity = 0;
                                        for (var cartItem in _cartQuantity) {
                                          if (cartItem.productId ==
                                                  product.id &&
                                              cartItem.price == price.price &&
                                              cartItem.price ==
                                                  (price.discountedPrice ??
                                                      price.price)) {
                                            initialQuantity = cartItem.quantity;
                                            break;
                                          }
                                        }

                                        if (!_counters.containsKey(priceKey)) {
                                          _counters[priceKey] =
                                              ValueNotifier<int>(
                                                  initialQuantity);
                                        }
                                        // Iterate over _cartQuantity to find the corresponding item
                                        for (var cartItem in _cartQuantity) {
                                          if (cartItem.productId ==
                                                  product.id &&
                                              cartItem.price == price.price) {
                                            quantity = cartItem.quantity;
                                            break; // Exit loop once item is found
                                          }
                                        }

                                        return Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              12, 5, 12, 5),
                                          child: Card(
                                            child: ListTile(
                                              title: Row(
                                                children: [
                                                  Text(
                                                    '₹ ${price.discountedPrice ?? price.price}',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: 'Roboto',
                                                      fontSize: 16,
                                                      color: Color(0xFFfc5d01),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 11),
                                                  if (price.discountedPrice !=
                                                      null)
                                                    Text(
                                                      '₹ ${price.price}',
                                                      style: const TextStyle(
                                                        fontFamily: 'Roboto',
                                                        fontSize: 14,
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              subtitle: Text(
                                                price.weight,
                                                style: const TextStyle(
                                                    fontFamily: 'Roboto',
                                                    fontSize: 14),
                                              ),
                                              trailing: Card(
                                                elevation: 1,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(40),
                                                ),
                                                child:
                                                    ValueListenableBuilder<int>(
                                                        valueListenable:
                                                            _counters[
                                                                priceKey]!,
                                                        builder: (context,
                                                            value, child) {
                                                          return Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              IconButton(
                                                                icon: Icon(
                                                                  Icons
                                                                      .remove_circle_outline,
                                                                  color: quantity >
                                                                          0
                                                                      ? const Color(
                                                                          0xFFfc5d01)
                                                                      : Colors
                                                                          .grey,
                                                                  size: 30,
                                                                ),
                                                                onPressed:
                                                                    quantity > 0
                                                                        ? () async {
                                                                            setState(() {
                                                                              isLoadingBottomodesheet = true;
                                                                            });
                                                                            try {
                                                                              await CartFunctionHandler(context: context, cartService: cartService).subtractQuantity(product.id, price.price, price.discountedPrice);
                                                                              await _fetchCartQuantity2();
                                                                            } finally {
                                                                              setState(() {
                                                                                isLoadingBottomodesheet = false;
                                                                              });
                                                                            }
                                                                          }
                                                                        : null,
                                                              ),
                                                              const SizedBox(
                                                                  width: 11),
                                                              Text(
                                                                '$quantity',
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 16,
                                                                  fontFamily:
                                                                      'Roboto',
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 11),
                                                              IconButton(
                                                                icon:
                                                                    const Icon(
                                                                  Icons
                                                                      .add_circle_outline,
                                                                  color: Color(
                                                                      0xFFfc5d01),
                                                                  size: 30,
                                                                ),
                                                                onPressed:
                                                                    () async {
                                                                  setState(() {
                                                                    isLoadingBottomodesheet =
                                                                        true;
                                                                  });
                                                                  try {
                                                                    await CartFunctionHandler(context: context, cartService: cartService).addQuantity(
                                                                        product,
                                                                        product
                                                                            .id,
                                                                        price
                                                                            .id,
                                                                        price
                                                                            .price,
                                                                        price
                                                                            .discountedPrice,
                                                                        price
                                                                            .weight);
                                                                    await _fetchCartQuantity2();
                                                                  } finally {
                                                                    setState(
                                                                        () {
                                                                      isLoadingBottomodesheet =
                                                                          false;
                                                                    });
                                                                  }
                                                                },
                                                              ),
                                                            ],
                                                          );
                                                        }),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            );
                          },
                        );
                      },
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Ionicons.bag_handle_outline,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Text(
                        "Add to Cart",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
