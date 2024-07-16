import 'dart:convert';
import 'package:dailygrocery/screens/all_categories.dart';
import 'package:dailygrocery/screens/cart_page.dart';
import 'package:dailygrocery/screens/product_details.dart';
import 'package:dailygrocery/service/cart_service.dart';
import 'package:dailygrocery/utils/cart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dailygrocery/screens/login_page.dart';
import 'package:dailygrocery/screens/category_products_page.dart';
import 'package:dailygrocery/screens/product_search_result.dart';
import 'package:dailygrocery/service/category_service.dart';
import 'package:dailygrocery/service/product_service.dart';
import 'package:dailygrocery/service/address_service.dart';
import 'package:dailygrocery/screens/profile_page.dart';
import 'package:dailygrocery/screens/order_page.dart';
import 'package:dailygrocery/components/navbar.dart';

import 'package:ionicons/ionicons.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../components/drawer.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final storage = const FlutterSecureStorage();
  final productSearch = ProductService();
  final TextEditingController _searchController = TextEditingController();
  List<Category> categories = [];
  List<Product> _products = [];
  List<CartQuantity> _cartQuantity = [];
  List<Address> _addresses = [];
  CategoryService categoryService = CategoryService();
  ProductService productService = ProductService();
  final CartService cartService = CartService();
  final Map<String, ValueNotifier<int>> _counters = {};

  String _errorMessage = '';
  bool _isLoading = false;
  int _selectedIndex = 0;
  int pageSize = 10;
  int offSet = 0;
  int limit = 10;

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        //Home
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
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyDrawer()),
        );
        break;
    }
  }

  void _handleSearch() async {
    setState(() {
      _isLoading = true;
    });

    String query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
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
        );
        _searchController.clear(); // to clear the search field after attempt
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      setState(() {
        _errorMessage = "failed to fetch products";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchHomeCategories();
    _fetchHomeProducts();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    try {
      final addressService = AddressService();
      final addresses = await addressService.getAllAddresses();
      setState(() {
        _addresses = addresses;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching addresses: $e');
      _isLoading = false;
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
      print('Error fetching cart quantity: $e');
    }
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

  Future<void> _fetchHomeCategories() async {
    try {
      List<Category> fetchedCategories =
          await categoryService.fetchHomeCategories();
      setState(() {
        categories = fetchedCategories;
      });
    } catch (e) {
      print("Exception occured while fetching home category $e");
    }
  }

  Future<void> _fetchHomeProducts() async {
    try {
      List<Product> fetchedProducts = await productService.fetchHomeProducts();
      setState(() {
        _products = fetchedProducts;
      });
      _fetchCartQuantity();
    } catch (e) {
      print("Exception occured while fetching home products $e");
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
      print('Error fetching cart quantity: $e');
    }
  }

  Future<void> _deleteToken() async {
    try {
      // Logout: Remove tokens from storage and navigate to login page
      await storage.delete(key: 'accessToken');
      await storage.delete(key: 'refreshToken');
      await storage.delete(key: 'loggedIn');
      await storage.delete(key: 'mobileNumber');
      await storage.delete(key: 'email');
      await storage.delete(key: 'fullName');
    } catch (e) {
      print('Failed to delete storage tokens: $e');
    }
  }
  // Future<String> _getSpokenWord() async {
  //   final speech = SpeechToText();
  //   bool hasPermission = await speech.requestSpeechRecognitionPermission(
  //     prompt: "This app needs access to the microphone for speech recognition.",
  //   );
  //   if (!hasPermission) {
  //     return 'Microphone permission denied. Please enable it in app settings.';
  //   }

  //   try {
  //     final result = await speech.listen(
  //       listenFor: const Duration(seconds: 5),
  //       partialResults: true,
  //     );
  //     return result.recognizedWords;
  //   } catch (e) {

  //     return 'Error: $e';
  //   } finally {

  //     await speech.stop();
  //   }
  // }

  List sliderimageList = [
    {"id": 1, "image_path": 'assets/images/cup1.jpg'},
    {"id": 2, "image_path": 'assets/images/cup2.jpg'}
  ];
  final CarouselController carouselController = CarouselController();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 8,
            right: 8,
            top: 35,
          ),
          child: AppBar(
            automaticallyImplyLeading: false,
            forceMaterialTransparency: true,
            backgroundColor: const Color(0xFFfefaff),
            flexibleSpace: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: CircleAvatar(
                    child: Icon(
                      Ionicons.location,
                      color: Color(0xFFe64830),
                    ),
                    backgroundColor: Color(0xFFfbe4e2),
                  ),
                ),
                const SizedBox(width: 15),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Delivery Address",
                      style: TextStyle(
                          fontSize: 12,
                          color: Color.fromARGB(255, 126, 126, 126)),
                    ),
                    _addresses.isNotEmpty
                        ? Text(
                            _addresses.first.addressText.length > 15
                                ? '${_addresses.first.addressText.substring(0, 15)}...'
                                : _addresses.first.addressText,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          )
                        : const Text('No address'),
                  ],
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfilePage()),
                    );
                  },
                  icon: const Icon(Ionicons.chevron_down),
                ),
                const Spacer(),
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: ElevatedButton(
                    onPressed: () async {
                      _deleteToken();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(8),
                      minimumSize: const Size(50, 50),
                    ),
                    child: const Icon(
                      Ionicons.log_out_outline,
                      color: Colors.black,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SizedBox(
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.black12)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Ionicons.search_outline),
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
                                            _handleSearch();
                                          });
                                        }
                                      },
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 265,
                                child: TextField(
                                  maxLines: 1,
                                  controller: _searchController,
                                  decoration: const InputDecoration(
                                    hintText: 'Search Your Products',
                                    border: InputBorder.none,
                                  ),
                                  onSubmitted: _isLoading
                                      ? null
                                      : (value) {
                                          if (value.isEmpty) {
                                            Fluttertoast.showToast(
                                              msg: 'Please Enter Something...',
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white,
                                              gravity: ToastGravity.CENTER,
                                            );
                                          } else {
                                            setState(() {
                                              _handleSearch();
                                            });
                                          }
                                        },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12.0,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Explore Category',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                fontFamily: 'Roboto'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AllCategories(),
                                ),
                              );
                            },
                            child: const Text(
                              'View All',
                              style:
                                  TextStyle(fontSize: 14, fontFamily: 'Roboto'),
                            ),
                          )
                        ],
                      ),
                    ),
                    categories.isEmpty
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : SingleChildScrollView(
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 2,
                              ),
                              itemCount: categories.length,
                              itemBuilder: (BuildContext context, int index) {
                                Color cardColor = _getRandomColor();

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CategoryProductsPage(
                                          categoryName: categories[index].name,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    child: Card(
                                      elevation: 1,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: BorderSide(
                                          color: cardColor,
                                          width: 1,
                                        ),
                                      ),
                                      color: cardColor,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 6.0,
                                                  horizontal: 4.0,
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  utf8.decode(categories[index]
                                                      .name
                                                      .runes
                                                      .toList()),
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            SizedBox(
                                              width: 70,
                                              height: 70,
                                              child: ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  topRight: Radius.circular(10),
                                                  bottomLeft:
                                                      Radius.circular(10),
                                                  bottomRight:
                                                      Radius.circular(10),
                                                ),
                                                child: AspectRatio(
                                                  aspectRatio: 1,
                                                  child: Image.network(
                                                    categories[index].image,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                    // const SizedBox(
                    //   height: 12,
                    // ),
                    // Column(
                    //   children: [
                    //     const Padding(
                    //       padding: EdgeInsets.symmetric(
                    //           vertical: 10, horizontal: 12),
                    //       child: Row(
                    //         mainAxisAlignment: MainAxisAlignment.start,
                    //         children: [
                    //           Text(
                    //             'Daily Deals',
                    //             style: TextStyle(
                    //                 fontWeight: FontWeight.bold,
                    //                 fontSize: 21,
                    //                 fontFamily: 'Roboto'),
                    //           )
                    //         ],
                    //       ),
                    //     ),
                    //     Padding(
                    //       padding: const EdgeInsets.symmetric(horizontal: 10),
                    //       child: Stack(
                    //         children: [
                    //           ClipRRect(
                    //             borderRadius: BorderRadius.circular(8),
                    //             child: InkWell(
                    //               onTap: () {
                    //                 print(currentIndex);
                    //               },
                    //               child: CarouselSlider(
                    //                 items: sliderimageList
                    //                     .map((item) => Image.asset(
                    //                           item['image_path'],
                    //                           fit: BoxFit.cover,
                    //                           width: double.infinity,
                    //                         ))
                    //                     .toList(),
                    //                 carouselController: carouselController,
                    //                 options: CarouselOptions(
                    //                     scrollPhysics:
                    //                         const BouncingScrollPhysics(),
                    //                     autoPlay: true,
                    //                     aspectRatio: 2,
                    //                     viewportFraction: 1,
                    //                     enableInfiniteScroll: true,
                    //                     autoPlayInterval:
                    //                         const Duration(seconds: 2),
                    //                     autoPlayAnimationDuration:
                    //                         const Duration(milliseconds: 800),
                    //                     autoPlayCurve: Curves.fastOutSlowIn,
                    //                     scrollDirection: Axis.horizontal,
                    //                     reverse: false,
                    //                     onPageChanged: ((index, reason) => {
                    //                           setState(() {
                    //                             currentIndex = index;
                    //                           })
                    //                         })),
                    //               ),
                    //             ),
                    //           ),
                    //           Positioned(
                    //             bottom: 10,
                    //             left: 0,
                    //             right: 0,
                    //             child: Row(
                    //               mainAxisAlignment: MainAxisAlignment.center,
                    //               children: sliderimageList
                    //                   .asMap()
                    //                   .entries
                    //                   .map((entry) {
                    //                 return GestureDetector(
                    //                   onTap: () => carouselController
                    //                       .animateToPage(entry.key),
                    //                   child: Container(
                    //                     width:
                    //                         currentIndex == entry.key ? 17 : 7,
                    //                     height: 7.0,
                    //                     margin: const EdgeInsets.symmetric(
                    //                       horizontal: 3.0,
                    //                     ),
                    //                     decoration: BoxDecoration(
                    //                         borderRadius:
                    //                             BorderRadius.circular(10),
                    //                         color: currentIndex == entry.key
                    //                             ? Colors.red
                    //                             : Colors.white),
                    //                   ),
                    //                 );
                    //               }).toList(),
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     )
                    //   ],
                    // ),
                    const SizedBox(
                      height: 6,
                    ),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Latest Products',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                fontFamily: 'Roboto'),
                          )
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 1,
                                  crossAxisSpacing: 1,
                                  childAspectRatio: 0.73,
                                ),
                                itemCount: _products.length,
                                itemBuilder: (BuildContext context, int index) {
                                  Product product = _products[index];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ProductDetailsPage(
                                            productId: product.id,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Card(
                                      elevation: 1,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                      color: const Color.fromRGBO(
                                          255, 245, 237, 1),
                                      margin: const EdgeInsets.all(8),
                                      child: Stack(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 3),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(10),
                                                      topRight:
                                                          Radius.circular(10),
                                                    ),
                                                    child: AspectRatio(
                                                      aspectRatio: 1,
                                                      child: product
                                                              .productImages
                                                              .isNotEmpty
                                                          ? Stack(
                                                              children: [
                                                                CarouselSlider(
                                                                  items: product
                                                                      .productImages
                                                                      .map(
                                                                        (image) =>
                                                                            Image.network(
                                                                          image
                                                                              .image,
                                                                          fit: BoxFit
                                                                              .cover,
                                                                          width:
                                                                              double.infinity,
                                                                        ),
                                                                      )
                                                                      .toList(),
                                                                  carouselController:
                                                                      carouselController,
                                                                  options: CarouselOptions(
                                                                      autoPlay: product.productImages.length > 1,
                                                                      aspectRatio: 1,
                                                                      autoPlayInterval: const Duration(seconds: 2),
                                                                      autoPlayAnimationDuration: const Duration(milliseconds: 800),
                                                                      viewportFraction: 1,
                                                                      onPageChanged: ((index, reason) => {
                                                                            setState(() {
                                                                              currentIndex = index;
                                                                            })
                                                                          })),
                                                                ),
                                                                if (product
                                                                        .productImages
                                                                        .length >
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
                                                                          .map(
                                                                              (entry) {
                                                                        return GestureDetector(
                                                                          onTap: () =>
                                                                              carouselController.animateToPage(entry.key),
                                                                          child:
                                                                              Container(
                                                                            width: currentIndex == entry.key
                                                                                ? 17
                                                                                : 7,
                                                                            height:
                                                                                7.0,
                                                                            margin:
                                                                                const EdgeInsets.symmetric(
                                                                              horizontal: 3.0,
                                                                            ),
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(10),
                                                                              color: currentIndex == entry.key ? Colors.red : Colors.white,
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
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    left: 8,
                                                    right: 2,
                                                    top: 5,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            utf8
                                                                        .decode(product
                                                                            .name
                                                                            .runes
                                                                            .toList())
                                                                        .length >
                                                                    10
                                                                ? '${utf8.decode(product.name.runes.toList()).substring(0, 10)}...'
                                                                : utf8.decode(
                                                                    product.name
                                                                        .runes
                                                                        .toList()),
                                                            style: const TextStyle(
                                                                fontSize: 16,
                                                                fontFamily:
                                                                    'TiroDevanagariMarathi',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                          const SizedBox(
                                                              height: 3),
                                                          Text(
                                                            'Type: ${product.productType.length > 16 ? '${product.productType.substring(0, 16)}...' : product.productType}',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 12,
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
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
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                bool
                                                                    isLoadingBottomodesheet =
                                                                    false;
                                                                return StatefulBuilder(
                                                                  builder: (context,
                                                                      setState) {
                                                                    return Container(
                                                                      child: isLoadingBottomodesheet
                                                                          ? const Center(
                                                                              child: CircularProgressIndicator(),
                                                                            )
                                                                          : ListView.builder(
                                                                              itemCount: product.productPrices.length,
                                                                              itemBuilder: (context, index) {
                                                                                int quantity = 0;
                                                                                final price = product.productPrices[index];
                                                                                String priceKey = '${product.id}_${price.price}_${price.discountedPrice ?? price.price}';
                                                                                int initialQuantity = 0;
                                                                                for (var cartItem in _cartQuantity) {
                                                                                  if (cartItem.productId == product.id && cartItem.price == price.price && cartItem.price == (price.discountedPrice ?? price.price)) {
                                                                                    initialQuantity = cartItem.quantity;
                                                                                    break;
                                                                                  }
                                                                                }

                                                                                if (!_counters.containsKey(priceKey)) {
                                                                                  _counters[priceKey] = ValueNotifier<int>(initialQuantity);
                                                                                }
                                                                                // Iterate over _cartQuantity to find the corresponding item
                                                                                for (var cartItem in _cartQuantity) {
                                                                                  if (cartItem.productId == product.id && cartItem.price == price.price) {
                                                                                    quantity = cartItem.quantity;
                                                                                    break; // Exit loop once item is found
                                                                                  }
                                                                                }

                                                                                return Padding(
                                                                                  padding: const EdgeInsets.fromLTRB(12, 5, 12, 5),
                                                                                  child: Card(
                                                                                    child: ListTile(
                                                                                      title: Row(
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
                                                                                      subtitle: Text(
                                                                                        price.weight,
                                                                                        style: const TextStyle(fontFamily: 'Roboto', fontSize: 14),
                                                                                      ),
                                                                                      trailing: Card(
                                                                                        elevation: 1,
                                                                                        shape: RoundedRectangleBorder(
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
                                                            Ionicons
                                                                .add_circle_outline,
                                                            color: Color(
                                                                0xFFfc5d01),
                                                          ),
                                                        ),
                                                      )
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
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
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

// Horizontal Scroll Sizebox


                    // SizedBox(
                    //         height: 110,
                    //         child: Padding(
                    //           padding: const EdgeInsets.only(left: 3),
                    //           child: ListView.builder(
                    //             scrollDirection: Axis.horizontal,
                    //             itemCount: categories.length,
                    //             itemBuilder: (BuildContext context, int index) {
                    //               return GestureDetector(
                    //                 onTap: () {
                    //                   // Handle category tap
                    //                   Navigator.push(
                    //                     context,
                    //                     MaterialPageRoute(
                    //                       builder: (context) =>
                    //                           CategoryProductsPage(
                    //                         categoryName:
                    //                             categories[index].name,
                    //                       ),
                    //                     ),
                    //                   );
                    //                 },
                    //                 child: Container(
                    //                   // padding: const EdgeInsets.all(8.0),
                    //                   margin: const EdgeInsets.symmetric(
                    //                       horizontal: 1),
                    //                   child: Card(
                    //                     elevation: 1,
                    //                     shape: RoundedRectangleBorder(
                    //                       borderRadius:
                    //                           BorderRadius.circular(10),
                    //                     ),
                    //                     child: Column(
                    //                       children: [
                    //                         const SizedBox(
                    //                           height: 6,
                    //                         ),
                    //                         SizedBox(
                    //                           height: 64,
                    //                           width: 64,
                    //                           child: ClipRRect(
                    //                             borderRadius:
                    //                                 const BorderRadius.only(
                    //                               topLeft: Radius.circular(10),
                    //                               topRight: Radius.circular(10),
                    //                             ),
                    //                             child: AspectRatio(
                    //                               aspectRatio: 1,
                    //                               child: Image.network(
                    //                                 categories[index].image,
                    //                                 fit: BoxFit.cover,
                    //                               ),
                    //                             ),
                    //                           ),
                    //                         ),
                    //                         Container(
                    //                           padding:
                    //                               const EdgeInsets.symmetric(
                    //                                   vertical: 6.0,
                    //                                   horizontal: 8.0),
                    //                           alignment: Alignment.center,
                    //                           child: Text(
                    //                             utf8.decode(categories[index]
                    //                                 .name
                    //                                 .runes
                    //                                 .toList()),
                    //                             textAlign: TextAlign.center,
                    //                             style: const TextStyle(
                    //                               backgroundColor:
                    //                                   Colors.transparent,
                    //                             ),
                    //                           ),
                    //                         ),
                    //                       ],
                    //                     ),
                    //                   ),
                    //                 ),
                    //               );
                    //             },
                    //           ),
                    //         ),
                    //       ),