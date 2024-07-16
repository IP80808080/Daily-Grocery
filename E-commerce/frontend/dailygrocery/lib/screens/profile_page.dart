import 'package:dailygrocery/components/drawer.dart';
import 'package:dailygrocery/screens/cart_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dailygrocery/screens/home_page.dart';
import 'package:dailygrocery/screens/order_page.dart';
import 'package:dailygrocery/components/navbar.dart';
import 'package:dailygrocery/service/address_service.dart';
import 'package:dailygrocery/screens/map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ionicons/ionicons.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final storage = const FlutterSecureStorage();
  final addressService = AddressService();
  bool _isLoading = false;
  bool _isSaving = false;
  int _selectedIndex = 2;
  String _email = '';
  String _fullName = '';
  String _mobileNumber = '';
  List<Address> _addresses = [];
  int? _selectedAddressIndex;
  bool _isSaveEnabled = false;

  @override
  void initState() {
    super.initState();
    _getUserInfo();
    _fetchAddresses();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _selectedAddressIndex =
            _addresses.indexWhere((address) => address.isPrimary);
      });
    });
  }

  void _getUserInfo() async {
    final email = await storage.read(key: 'email');
    final fullName = await storage.read(key: 'fullName');
    final mobileNumber = await storage.read(key: 'mobileNumber');
    setState(() {
      _email = email ?? '';
      _fullName = fullName ?? '';
      _mobileNumber = mobileNumber ?? '';
    });
  }

  void _fetchAddresses() async {
    setState(() {
      _isLoading = true;
    });
    try {
      List<Address> addresses = await addressService.getAllAddresses();
      setState(() {
        _addresses = addresses;
        _selectedAddressIndex =
            _addresses.indexWhere((address) => address.isPrimary);
        _isLoading = false;
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OrderPage()),
        );
        break;
      case 2:
        // ProfilePage
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

  void _handleRadioValueChanged(int? index) {
    setState(() {
      _selectedAddressIndex = index;
      _isSaveEnabled = _selectedAddressIndex != null &&
          _selectedAddressIndex !=
              _addresses.indexWhere((address) => address.isPrimary);
    });
  }

  void _openMapScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapScreen()),
    ).then((value) => {_fetchAddresses()});
  }

  void handleSave(int addressId, bool isPrimary) async {
    setState(() {
      _isSaving = true;
    });
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
          _isSaving = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        forceMaterialTransparency: true,
        title: const Center(child: Text('Profile')),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.only(
                  right: 16, left: 16, top: 16, bottom: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 13),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _fullName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Email",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(7)),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 14, right: 14, top: 12, bottom: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    _email,
                                    style:
                                        const TextStyle(color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Mobile Number",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(7)),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 14, right: 14, top: 12, bottom: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    _mobileNumber,
                                    style:
                                        const TextStyle(color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'My Addresses:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
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
                        const SizedBox(
                          height: 8,
                        )
                      ],
                    ),
                  ),
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : _addresses.isEmpty
                          ? Column(
                              children: [
                                const Center(child: Text('No addresses found')),
                                Container(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey,
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      child: const Icon(Icons.add),
                                    ),
                                    onPressed: () {
                                      _openMapScreen();
                                    },
                                  ),
                                ),
                              ],
                            )
                          : Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 14, right: 14, bottom: 7),
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
                                                Address address =
                                                    _addresses[index];

                                                return Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: RadioListTile<
                                                              int>(
                                                            value: index,
                                                            groupValue:
                                                                _selectedAddressIndex,
                                                            title: Text(address
                                                                .addressText),
                                                            onChanged:
                                                                _handleRadioValueChanged,
                                                            secondary: address
                                                                    .isPrimary
                                                                ? const Icon(
                                                                    Icons.star,
                                                                    color: Color(
                                                                        0xFFfc5d01))
                                                                : null,
                                                            selected: address
                                                                .isPrimary,
                                                          ),
                                                        ),
                                                        IconButton(
                                                          icon: const Icon(
                                                            Icons
                                                                .delete_outline,
                                                          ),
                                                          onPressed: () =>
                                                              _showDeleteConfirmationDialog(
                                                                  context,
                                                                  address),
                                                        ),
                                                      ],
                                                    ),
                                                    if (index !=
                                                        _addresses.length - 1)
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
                                  ],
                                ),
                              ),
                            ),
                  ElevatedButton(
                    onPressed: _isSaving
                        ? null
                        : () async {
                            setState(() {
                              _isLoading = true;
                            });
                            try {
                              _isSaveEnabled && _selectedAddressIndex != -1
                                  ? handleSave(
                                      _addresses[_selectedAddressIndex ?? 0].id,
                                      true)
                                  : null;
                            } finally {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.only(
                        left: 95,
                        right: 95,
                      ),
                      child: Text(
                        'Save',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
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
}
