import 'package:dailygrocery/screens/pickup_drop_map.dart';
import 'package:dailygrocery/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:dailygrocery/service/pickup_drop_service.dart';
import 'package:ionicons/ionicons.dart';
import 'package:url_launcher/url_launcher.dart';

class PickupDropListPage extends StatefulWidget {
  const PickupDropListPage({super.key});

  @override
  _PickupDropListPageState createState() => _PickupDropListPageState();
}

class _PickupDropListPageState extends State<PickupDropListPage> {
  late List<PickupDrop> _pickupDrops = [];
  final PickupDropService _pickupDropService = PickupDropService();
  final AuthService _adminDetailsService = AuthService();
  late AdminDetails _adminDetails;

  bool _isLoading = false;
  bool hasMoreData = true;
  @override
  void initState() {
    super.initState();

    // Fetch pickup drop data from API
    _fetchPickupDrops();
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
      // Handle error
    }
  }

  Future<void> _fetchPickupDrops() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final List<PickupDrop> pickupDrops =
          await _pickupDropService.fetchPickupDrop();
      setState(() {
        _pickupDrops = pickupDrops;
        _isLoading = false;
      });
    } catch (e) {
      print('Failed to fetch pickup drops: $e');
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }

  Future<void> _launchUrl(String adminNumber) async {
    final Uri _url = Uri.parse('tel:$adminNumber');
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  void _navigateToPickupDropForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PickupDropForm()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        forceMaterialTransparency: true,
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
        title: const Center(child: Text('Pickup & Drop List')),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _pickupDrops.isEmpty
              ? const Center(
                  child: Text('No pickup drops scheduled'),
                )
              : ListView.builder(
                  itemCount: _pickupDrops.length,
                  padding: const EdgeInsets.only(bottom: 80.0),
                  itemBuilder: (context, index) {
                    Color backgroundColor;
                    final pickupDrop = _pickupDrops[index];
                    Color textColor;
                    switch (pickupDrop.status) {
                      case 'completed':
                        backgroundColor = const Color(0xFFCFE2FF);
                        textColor =
                            Colors.black; // Change the text color as needed
                        break;
                      case 'progress':
                        backgroundColor = const Color(0xFFD1E7DD);
                        textColor =
                            Colors.black; // Change the text color as needed
                        break;
                      case 'pending':
                        backgroundColor = const Color(0xFFFFF3CD);
                        textColor =
                            Colors.black; // Change the text color as needed
                        break;
                      case 'cancelled':
                        backgroundColor = const Color(0xFFE2E3E5);
                        textColor =
                            Colors.black; // Change the text color as needed
                        break;
                      default:
                        backgroundColor = Colors.transparent;
                        textColor = Colors.black;
                    }
                    return Column(
                      children: [
                        ListTile(
                          title: Text('Pickup: ${pickupDrop.pickup}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Drop: ${pickupDrop.drop}',
                                style: TextStyle(color: textColor),
                              ),
                              Text('Status: ${pickupDrop.status.toUpperCase()}',
                                  style: TextStyle(
                                      color: textColor,
                                      backgroundColor: backgroundColor)),
                            ],
                          ),
                          trailing: pickupDrop.status != 'cancelled'
                              ? (pickupDrop.status != 'completed'
                                  ? IconButton(
                                      icon: const Icon(Icons.phone),
                                      onPressed: () => _launchUrl(
                                          _adminDetails.pickupNumber),
                                    )
                                  : null)
                              : null,
                        ),
                        const Divider(height: 0),
                      ],
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToPickupDropForm,
        backgroundColor: Colors.orange,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
