import 'package:dailygrocery/components/navbar.dart';
import 'package:dailygrocery/screens/cart_page.dart';
import 'package:dailygrocery/screens/home_page.dart';
import 'package:dailygrocery/screens/order_page.dart';
import 'package:dailygrocery/screens/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:dailygrocery/screens/category_products_page.dart';
import 'package:dailygrocery/service/category_service.dart';
import 'dart:math';
import 'dart:convert';

import 'package:ionicons/ionicons.dart';

class AllCategories extends StatefulWidget {
  const AllCategories({Key? key}) : super(key: key);

  @override
  State<AllCategories> createState() => _AllCategoriesState();
}

class _AllCategoriesState extends State<AllCategories> {
  CategoryService categoryService = CategoryService();
  bool _isLoading = true; // Initially set to true to show loader
  List<Category> categories = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchAllCategories();
  }

  Future<void> _fetchAllCategories() async {
    try {
      List<Category> fetchedCategories =
          await categoryService.fetchAllCategories();
      setState(() {
        categories = fetchedCategories;
        _isLoading =
            false; // Set isLoading to false after categories are loaded
        _errorMessage =
            ''; // Clear error message if categories are fetched successfully
      });
    } catch (e) {
      setState(() {
        _isLoading = false; // Set isLoading to false in case of error
        _errorMessage = 'Error fetching categories';
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          forceMaterialTransparency: true,
          leading: Container(
            margin: const EdgeInsets.only(left: 8),
            child: ElevatedButton(
              onPressed: () async {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(8),
              ),
              child: const Icon(
                Ionicons.arrow_back,
                color: Colors.black,
              ),
            ),
          ),
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text('All Categories')],
          )),
      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(), // Show loader while loading categories
            )
          : categories.isEmpty
              ? const Center(
                  child: Text(
                      'No categories found'), // Display message if no categories are found
                )
              : _errorMessage.isNotEmpty
                  ? Center(
                      child: Text(
                          _errorMessage), // Display error message if there's an error
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
                                  builder: (context) => CategoryProductsPage(
                                    categoryName: categories[index].name,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
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
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
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
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      SizedBox(
                                        width: 70,
                                        height: 70,
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10),
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
    );
  }
}
