import 'package:dailygrocery/components/navbar.dart';
import 'package:dailygrocery/screens/cart_page.dart';
import 'package:dailygrocery/screens/home_page.dart';
import 'package:dailygrocery/screens/order_page.dart';
import 'package:dailygrocery/screens/pickup_drop_list_page.dart';
import 'package:dailygrocery/screens/profile_page.dart';
import 'package:dailygrocery/service/service_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ionicons/ionicons.dart';
import 'package:url_launcher/url_launcher.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  final storage = const FlutterSecureStorage();
  String _email = '';
  String _fullName = '';
  int _selectedIndex = 4;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  void _getUserInfo() async {
    final email = await storage.read(key: 'email');
    final fullName = await storage.read(key: 'fullName');
    setState(() {
      _email = email ?? '';
      _fullName = fullName ?? '';
    });
  }

  Future<void> _launchUrl(String policy) async {
    final Uri url = Uri.parse(policy);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
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
      case 4:
        //drawer
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                child: ClipOval(
                  child: Image.asset('assets/images/splash.png'),
                ),
              ),
              accountName: Text(
                _fullName,
                style: const TextStyle(color: Colors.white),
              ),
              accountEmail: Text(
                _email,
                style: const TextStyle(color: Colors.white),
              ),
              decoration: const BoxDecoration(color: Color(0xFFfc5d01)),
            ),
            // ListTile(
            //   leading: const Icon(
            //     Ionicons.bag_handle_outline,
            //     color: Color(0xFFfc5d01),
            //   ),
            //   title: const Text(
            //     'Ordered Grocery Info',
            //     style: TextStyle(color: Colors.black),
            //   ),
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => const OrderPage()),
            //     );
            //   },
            // ),
            const SizedBox(
              height: 8,
            ),
            ListTile(
              leading: const Icon(
                Icons.local_shipping_outlined,
                color: Color(0xFFfc5d01),
              ),
              title: const Text(
                'Pickup & Drop',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PickupDropListPage()),
                );
              },
            ),
            const SizedBox(
              height: 8,
            ),
            ListTile(
              leading: const Icon(
                Icons.policy_outlined,
                color: Color(0xFFfc5d01),
              ),
              title: const Text(
                'Policy',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                _launchUrl(APIConstants.policyAPI);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.policy_outlined,
                color: Color(0xFFfc5d01),
              ),
              title: const Text(
                'Terms of Use',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                _launchUrl(APIConstants.termsofUseAPI);
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
