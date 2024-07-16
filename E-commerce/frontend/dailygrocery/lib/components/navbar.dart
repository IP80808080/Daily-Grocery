import 'package:dailygrocery/service/cart_service.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class BottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final Widget? loader;

  const BottomNavBar({
    required this.selectedIndex,
    required this.onItemTapped,
    required this.loader,
    Key? key,
  }) : super(key: key);

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final CartService cartService = CartService();
  int _cartItemCount = 0; // State to hold cart item count

  @override
  void initState() {
    super.initState();
    _loadTotalCart(); // Load total cart count when widget initializes
  }

  Future<void> _loadTotalCart() async {
    try {
      final count = await cartService.getTotalCart();
      setState(() {
        _cartItemCount = count; // Update the cart item count state
      });
    } catch (e) {
      print('Failed to fetch total cart quantity: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Ionicons.reorder_four_outline),
        label: 'Orders',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Ionicons.person_outline),
        label: 'Profile',
      ),
      BottomNavigationBarItem(
        icon: Stack(
          children: [
            const Icon(Ionicons.cart_outline),
            if (_cartItemCount > 0) // Show item count if greater than 0
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 10,
                    minHeight: 10,
                  ),
                  // child: Text(
                  //   '$_cartItemCount',
                  //   style: const TextStyle(
                  //     color: Colors.white,
                  //     fontSize: 10,
                  //   ),
                  //   textAlign: TextAlign.center,
                  // ),
                ),
              ),
          ],
        ),
        label: 'Cart',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Ionicons.grid_outline),
        label: 'More',
      ),
    ];

    if (widget.loader != null) {
      items.add(BottomNavigationBarItem(
        icon: widget.loader!,
        label: '',
      ));
    }

    return BottomNavigationBar(
      items: items,
      currentIndex: widget.selectedIndex,
      selectedItemColor: Colors.orange,
      unselectedItemColor: Colors.black,
      backgroundColor: Colors.white,
      onTap: widget.onItemTapped,
      selectedIconTheme: const IconThemeData(color: Colors.orange),
      showSelectedLabels: true,
      showUnselectedLabels: true,
    );
  }
}
