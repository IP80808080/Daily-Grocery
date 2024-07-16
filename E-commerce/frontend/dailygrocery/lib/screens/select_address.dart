import 'package:dailygrocery/components/navbar.dart';
import 'package:dailygrocery/screens/cart_page.dart';
import 'package:dailygrocery/screens/order_page.dart';
import 'package:dailygrocery/screens/profile_page.dart';
import 'package:dailygrocery/screens/home_page.dart';
import 'package:dailygrocery/screens/login_page.dart';
import 'package:dailygrocery/screens/payment_page.dart';
import 'package:dailygrocery/service/cart_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dailygrocery/service/address_service.dart';
import 'package:dailygrocery/screens/map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ionicons/ionicons.dart';

class SelectAddress extends StatefulWidget {
  const SelectAddress({Key? key}) : super(key: key);

  @override
  State<SelectAddress> createState() => _SelectAddressState();
}

class _SelectAddressState extends State<SelectAddress> {
  final storage = const FlutterSecureStorage();
  final CartService _cartService = CartService();
  final addressService = AddressService();
  bool _isLoading = false;
  List<Address> _addresses = [];
  int? _selectedAddressIndex;
  int? _selectedAddressId;
  int _selectedIndex = 0;
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
        _fetchAddresses();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _fetchAddresses() async {
    setState(() {
      _isLoading = true;
    });
    try {
      List<Address> addresses = await addressService.getAllAddresses();
      setState(() {
        _addresses = addresses;
        _isLoading = false;
      });
    } catch (e) {
      // Handle error
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  void _handleRadioValueChanged(int? index) {
    setState(() {
      _selectedAddressIndex = index;
      if (_selectedAddressIndex != null) {
        _selectedAddressId = _addresses[_selectedAddressIndex!].id;
      }
    });
  }

  void _openMapScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapScreen()),
    ).then((value) => {_fetchAddresses()});
  }

  void _openPaymentScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              PaymentPage(selectedAddressId: _selectedAddressId!)),
    );
  }

  void handleSave(int addressId, bool isPrimary) async {
    // Update the primary address in the backend
    if (_selectedAddressIndex != null) {
      try {
        // Assuming there's a method to update the primary address in the addressService
        await addressService.updatePrimaryAddress(addressId, isPrimary);
        // Refresh the address list after updating the primary address
        _fetchAddresses();
        Fluttertoast.showToast(
          msg: 'Primary address updated successfully.',
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } catch (e) {
        // Handle error
        print('Failed to update primary address: $e');
        Fluttertoast.showToast(
          msg: 'Failed to update primary address. Please try again later.',
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, Address address) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this address?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _deleteAddress(address);
                Navigator.pop(context);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _deleteAddress(Address address) async {
    // Add logic to delete the address from your data source
    // Show loader
    setState(() {
      _isLoading = true;
    });
    try {
      // Call the delete address API with the address ID
      var response = await addressService.deleteAddress(address.id);

      // Check if the API call was successful
      if (response.statusCode == 200 || response.statusCode == 204) {
        // Remove the deleted address from the local list
        setState(() {
          _addresses.remove(address);
          _isLoading = false; // Hide loader
        });
        Fluttertoast.showToast(
          msg: 'Address deleted successfully.',
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        // If the API call failed, show an error message
        setState(() {
          _isLoading = false; // Hide loader
        });
        Fluttertoast.showToast(
          msg: 'Failed to delete address: ${response.statusCode}',
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      // If an error occurs, hide the loader and show an error message
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(
        msg: 'An error occurred while deleting the address',
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      print('Error deleting address: $e');
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
        title: const Center(child: Text('Select Address')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Saved Addresses:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(
                    width: 45,
                    height: 45,
                    child: Card(
                      color: Colors.orange,
                      elevation: 1,
                      shape: const CircleBorder(),
                      child: IconButton(
                        padding: const EdgeInsets.all(7),
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          _openMapScreen();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _addresses.isEmpty
                    ? const Center(child: Text('No addresses found'))
                    : Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: _addresses.length,
                                      itemBuilder: (context, index) {
                                        Address address = _addresses[index];
                                        bool isPrimaryAddress =
                                            address.isPrimary;
                                        return Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: RadioListTile<int>(
                                                    value: index,
                                                    groupValue:
                                                        _selectedAddressIndex,
                                                    title: Text(
                                                        address.addressText),
                                                    onChanged:
                                                        _handleRadioValueChanged,
                                                    secondary: isPrimaryAddress
                                                        ? const Icon(
                                                            Icons.star,
                                                            color: Color(
                                                                0xFFfc5d01),
                                                          )
                                                        : null,
                                                    selected: isPrimaryAddress,
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.delete_outline,
                                                  ),
                                                  onPressed: () =>
                                                      _showDeleteConfirmationDialog(
                                                          context, address),
                                                ),
                                              ],
                                            ),
                                            if (index != _addresses.length - 1)
                                              const Divider(
                                                thickness: 1,
                                                color: Colors.black,
                                              ),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _addresses.isNotEmpty &&
                                      _selectedAddressId != null
                                  ? () {
                                      _openPaymentScreen();
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                backgroundColor: const Color(0xFFfc5d01),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.only(
                                  bottom: 10,
                                  top: 10,
                                  left: 75,
                                  right: 75,
                                ),
                                child: Text(
                                  'Goto Payment',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
