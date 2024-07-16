import 'dart:math';

import 'package:dailygrocery/utils/cart.dart';
import 'package:dailygrocery/screens/cart_page.dart';
import 'package:dailygrocery/screens/order_page.dart';
import 'package:dailygrocery/screens/profile_page.dart';
import 'package:dailygrocery/screens/home_page.dart';
import 'package:dailygrocery/service/cart_service.dart';
import 'package:flutter/material.dart';
import 'package:dailygrocery/service/product_service.dart';
import 'package:dailygrocery/screens/product_details.dart'; // Import ProductDetailsPage
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ionicons/ionicons.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:async';
import '../components/navbar.dart';

class SearchResultsPage extends StatefulWidget {
  final List<Product> searchResults;
  final String searchKeyword;

  const SearchResultsPage({
    Key? key,
    required this.searchResults,
    required this.searchKeyword,
  }) : super(key: key);

  @override
  _SearchResultsPageState createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  final CartService cartService = CartService();
  final TextEditingController _searchController = TextEditingController();
  final CarouselController carouselController = CarouselController();
  final Map<String, ValueNotifier<int>> _counters = {};
  List<CartQuantity> _cartQuantity = [];
  int quantity = 1;
  bool _isLoading = false;
  bool _isSearching = false;
  String _errorMessage = '';
  int _selectedIndex = 0;
  int offSet = 0;
  int limit = 10;
  bool hasMoreData = true;
  late final ScrollController _scrollController;
  final productSearch = ProductService();
  int currentIndex = 0;

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    super.initState();
    _fetchCartQuantity();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _fetchNextPage();
    }
  }

  final _random = Random();
  final _colors = [
    const Color.fromRGBO(238, 247, 242, 1),
    const Color.fromRGBO(255, 245, 237, 1),
    const Color.fromRGBO(245, 235, 249, 1),
    const Color.fromRGBO(252, 232, 228, 1),
    const Color.fromRGBO(239, 247, 253, 1),
  ];

  Color _getRandomColor() {
    return _colors[_random.nextInt(_colors.length)];
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

  Future<void> _fetchNextPage() async {
    if (hasMoreData) {
      setState(() {
        offSet += limit;
      });
      try {
        List<Product> newProducts = await productSearch.fetchProducts(
            "search-products", widget.searchKeyword, limit, offSet);

        if (newProducts.isNotEmpty) {
          List<Product> remainingProducts = newProducts
              .where((product) => !widget.searchResults.contains(product))
              .toList();

          if (remainingProducts.isNotEmpty) {
            setState(() {
              widget.searchResults.addAll(remainingProducts);
            });
          } else {
            setState(() {
              hasMoreData = false;
            });
          }
        } else {
          setState(() {
            hasMoreData = false;
          });
        }
      } catch (e) {
        print('Error fetching next page: $e');
      }
    }
  }

  void _handleSearch(String query) async {
    setState(() {
      _isLoading = true;
    });

    query = query.trim();
    if (query.isEmpty) {
      setState(() {
        Fluttertoast.showToast(
          msg: 'Please Enter Something...',
          backgroundColor: Colors.red,
          textColor: Colors.white,
          gravity: ToastGravity.CENTER,
        );
        _errorMessage = 'Please enter a search query';
        _isLoading = false;
      });
      return;
    }
    try {
      List<Product> searchResults = await productSearch.fetchProducts(
          "search-products", query, limit, offSet);
      if (searchResults.isEmpty) {
        setState(() {
          _errorMessage = 'No result found';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = ''; // Clear errorMessage
          _isLoading = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SearchResultsPage(
                  searchResults: searchResults, searchKeyword: query)),
        ).then((value) => {_fetchCartQuantity()});
        _searchController.clear(); // to clear the search field after attempt
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CartPage()),
        );
        break;
    }
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
        title: GestureDetector(
          onTap: () {
            setState(() {
              _isSearching = !_isSearching;
            });
          },
          child: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Search for products...',
                    border: UnderlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                  onSubmitted: (query) => _handleSearch(query),
                  style: const TextStyle(color: Colors.black),
                )
              : Text(
                  'Search Results for ${utf8.decode(widget.searchKeyword.runes.toList())}'),
        ),
        actions: !_isSearching
            ? [
                IconButton(
                  icon: const Icon(Ionicons.search),
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                      if (_isSearching) {
                        _searchController.clear();
                      }
                    });
                    if (_isSearching && _searchController.text.isNotEmpty) {
                      _handleSearch(_searchController.text);
                    }
                  },
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Ionicons.search),
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (_searchController.text.isEmpty) {
                            Fluttertoast.showToast(
                              msg: 'Please Enter Something...',
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              gravity: ToastGravity.CENTER,
                            );
                          } else {
                            setState(() {
                              _handleSearch(_searchController.text);
                            });
                          }
                        },
                ),
              ],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 1,
                  crossAxisSpacing: 1,
                  childAspectRatio: 0.73),
              itemCount: widget.searchResults.length,
              itemBuilder: (context, index) {
                Product product = widget.searchResults[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailsPage(
                          productId: product.id,
                        ),
                      ),
                    ).then((value) => {_fetchCartQuantity()});
                  },
                  child: Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    color: const Color.fromRGBO(255, 245, 237, 1),
                    margin: const EdgeInsets.all(8),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image on the left
                              SizedBox(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: product.productImages.isNotEmpty
                                        ? Stack(
                                            children: [
                                              CarouselSlider(
                                                items: product.productImages
                                                    .map(
                                                      (image) => Image.network(
                                                        image.image,
                                                        fit: BoxFit.cover,
                                                        width: double.infinity,
                                                      ),
                                                    )
                                                    .toList(),
                                                carouselController:
                                                    carouselController,
                                                options: CarouselOptions(
                                                    autoPlay: product
                                                            .productImages
                                                            .length >
                                                        1,
                                                    aspectRatio: 1,
                                                    autoPlayInterval:
                                                        const Duration(
                                                            seconds: 2),
                                                    autoPlayAnimationDuration:
                                                        const Duration(
                                                            milliseconds: 800),
                                                    viewportFraction: 1,
                                                    onPageChanged:
                                                        ((index, reason) => {
                                                              setState(() {
                                                                currentIndex =
                                                                    index;
                                                              })
                                                            })),
                                              ),
                                              if (product.productImages.length >
                                                  1)
                                                Positioned(
                                                  bottom: 10,
                                                  left: 0,
                                                  right: 0,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: product
                                                        .productImages
                                                        .asMap()
                                                        .entries
                                                        .map((entry) {
                                                      return GestureDetector(
                                                        onTap: () =>
                                                            carouselController
                                                                .animateToPage(
                                                                    entry.key),
                                                        child: Container(
                                                          width: currentIndex ==
                                                                  entry.key
                                                              ? 17
                                                              : 7,
                                                          height: 7.0,
                                                          margin:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 3.0,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            color:
                                                                currentIndex ==
                                                                        entry
                                                                            .key
                                                                    ? Colors.red
                                                                    : Colors
                                                                        .white,
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
                                                ),
                                            ],
                                          )
                                        : const SizedBox(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Text on the right
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 8,
                                  right: 2,
                                  top: 5,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          utf8
                                                      .decode(product.name.runes
                                                          .toList())
                                                      .length >
                                                  10
                                              ? '${utf8.decode(product.name.runes.toList()).substring(0, 10)}...'
                                              : utf8.decode(
                                                  product.name.runes.toList()),
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              fontFamily:
                                                  'TiroDevanagariMarathi'),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          'Type: ${product.productType.length > 16 ? '${product.productType.substring(0, 16)}...' : product.productType}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      child: IconButton(
                                          iconSize: 43,
                                          onPressed: () {
                                            showModalBottomSheet(
                                              context: context,
                                              builder: (BuildContext context) {
                                                bool isLoadingBottomodesheet =
                                                    false;
                                                return StatefulBuilder(
                                                  builder: (context, setState) {
                                                    return Container(
                                                      child:
                                                          isLoadingBottomodesheet
                                                              ? const Center(
                                                                  child:
                                                                      CircularProgressIndicator(),
                                                                )
                                                              : ListView
                                                                  .builder(
                                                                  itemCount: product
                                                                      .productPrices
                                                                      .length,
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    int quantity =
                                                                        0;
                                                                    final price =
                                                                        product.productPrices[
                                                                            index];
                                                                    String
                                                                        priceKey =
                                                                        '${product.id}_${price.price}_${price.discountedPrice ?? price.price}';
                                                                    int initialQuantity =
                                                                        0;
                                                                    for (var cartItem
                                                                        in _cartQuantity) {
                                                                      if (cartItem.productId == product.id &&
                                                                          cartItem.price ==
                                                                              price
                                                                                  .price &&
                                                                          cartItem.price ==
                                                                              (price.discountedPrice ?? price.price)) {
                                                                        initialQuantity =
                                                                            cartItem.quantity;
                                                                        break;
                                                                      }
                                                                    }

                                                                    if (!_counters
                                                                        .containsKey(
                                                                            priceKey)) {
                                                                      _counters[
                                                                          priceKey] = ValueNotifier<
                                                                              int>(
                                                                          initialQuantity);
                                                                    }
                                                                    // Iterate over _cartQuantity to find the corresponding item
                                                                    for (var cartItem
                                                                        in _cartQuantity) {
                                                                      if (cartItem.productId ==
                                                                              product
                                                                                  .id &&
                                                                          cartItem.price ==
                                                                              price.price) {
                                                                        quantity =
                                                                            cartItem.quantity;
                                                                        break; // Exit loop once item is found
                                                                      }
                                                                    }

                                                                    return Padding(
                                                                      padding: const EdgeInsets
                                                                          .fromLTRB(
                                                                          12,
                                                                          5,
                                                                          12,
                                                                          5),
                                                                      child:
                                                                          Card(
                                                                        child:
                                                                            ListTile(
                                                                          title:
                                                                              Row(
                                                                            children: [
                                                                              Text(
                                                                                '₹ ${price.discountedPrice ?? price.price}',
                                                                                style: const TextStyle(
                                                                                  fontWeight: FontWeight.bold,
                                                                                  fontFamily: 'Roboto',
                                                                                  fontSize: 16,
                                                                                  color: Color(0xFFfc5d01),
                                                                                ),
                                                                              ),
                                                                              const SizedBox(width: 11),
                                                                              if (price.discountedPrice != null)
                                                                                Text(
                                                                                  '₹ ${price.price}',
                                                                                  style: const TextStyle(
                                                                                    fontFamily: 'Roboto',
                                                                                    fontSize: 14,
                                                                                    decoration: TextDecoration.lineThrough,
                                                                                  ),
                                                                                ),
                                                                            ],
                                                                          ),
                                                                          subtitle:
                                                                              Text(
                                                                            price.weight,
                                                                            style:
                                                                                const TextStyle(fontFamily: 'Roboto', fontSize: 14),
                                                                          ),
                                                                          trailing:
                                                                              Card(
                                                                            elevation:
                                                                                1,
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(40),
                                                                            ),
                                                                            child: ValueListenableBuilder<int>(
                                                                                valueListenable: _counters[priceKey]!,
                                                                                builder: (context, value, child) {
                                                                                  return Row(
                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                    children: [
                                                                                      IconButton(
                                                                                        icon: Icon(
                                                                                          Icons.remove_circle_outline,
                                                                                          color: quantity > 0 ? const Color(0xFFfc5d01) : Colors.grey,
                                                                                          size: 30,
                                                                                        ),
                                                                                        onPressed: quantity > 0
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
                                                                                      const SizedBox(width: 11),
                                                                                      Text(
                                                                                        '$quantity',
                                                                                        style: const TextStyle(
                                                                                          fontSize: 16,
                                                                                          fontFamily: 'Roboto',
                                                                                          color: Colors.black,
                                                                                          fontWeight: FontWeight.bold,
                                                                                        ),
                                                                                      ),
                                                                                      const SizedBox(width: 11),
                                                                                      IconButton(
                                                                                        icon: const Icon(
                                                                                          Icons.add_circle_outline,
                                                                                          color: Color(0xFFfc5d01),
                                                                                          size: 30,
                                                                                        ),
                                                                                        onPressed: () async {
                                                                                          setState(() {
                                                                                            isLoadingBottomodesheet = true;
                                                                                          });
                                                                                          try {
                                                                                            await CartFunctionHandler(context: context, cartService: cartService).addQuantity(product, product.id, price.id, price.price, price.discountedPrice, price.weight);
                                                                                            await _fetchCartQuantity2();
                                                                                          } finally {
                                                                                            setState(() {
                                                                                              isLoadingBottomodesheet = false;
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
                                          icon: const Icon(
                                            Ionicons.add_circle_outline,
                                            color: Color(0xFFfc5d01),
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        onItemTapped: _onItemTapped,
        selectedIndex: _selectedIndex,
        loader: _isLoading ? const CircularProgressIndicator() : null,
      ),
      resizeToAvoidBottomInset: true,
    );
  }
}
