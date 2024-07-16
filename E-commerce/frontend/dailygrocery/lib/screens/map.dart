import 'package:dailygrocery/screens/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:dailygrocery/service/address_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

import 'package:ionicons/ionicons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_settings/app_settings.dart';


class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class LocationPermissionDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enable Location'),
          content: const Text(
              'Please enable location for this app in your device settings to use this feature.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                AppSettings.openAppSettings();
                Navigator.of(context).pop();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  String searchAddress = '';
  LatLng? selectedLocation;
  bool isLoading = false;
  List<Location> searchResults = [];
  final AddressService addressService = AddressService();
  final Geolocator _geolocator = Geolocator();
  Position? _currentPosition;
  Marker? mapMarker;
  bool isLocationInPolygon = false; // Reset the flag initially

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  _getCurrentLocation() async {
    setState(() {
      isLoading = true;
    });
    try {
      bool serviceEnabled;
      LocationPermission permission;
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled.');
      }
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            isLoading = false;
          });
          LocationPermissionDialog.show(context);
          // Permissions are denied, handle this case
          return Future.error('Location permissions are denied');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          isLoading = false;
        });
        LocationPermissionDialog.show(context);
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }
      _currentPosition = await Geolocator.getCurrentPosition();
      for (var polygon in _buildPolygons()) {
        if (_checkIfValidMarker(
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            polygon.points)) {
          // Update the search text field with the obtained address
          _updateMapAndAddress(_currentPosition!);
          setState(() {
            isLocationInPolygon = true;
            isLoading = false;
            selectedLocation =
                LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
            mapMarker = Marker(
              markerId: const MarkerId('current_location'),
              position: selectedLocation!,
            );
            _getAddressFromLatLng(_currentPosition!);
          });
          break;
        }
      }
      // If location is not within any polygon, show toast message
      if (!isLocationInPolygon) {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(
          msg:
              'Delivery address out of range. Please reselect within polygons.',
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false; // Hide loader
      });
    }
  }

  void _updateMapAndAddress(Position position) async {
    try {
      await _getAddressFromLatLng(position);

      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 15.0,
          ),
        ),
      );

      setState(() {
        selectedLocation = LatLng(position.latitude, position.longitude);
        mapMarker = Marker(
          markerId: const MarkerId('current_location'),
          position: selectedLocation!,
        );
      });
    } catch (e) {
      print('Error updating map and address: $e');
    }
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final address = placemarks.first;
        final addressText =
            '${address.street}, ${address.locality}, ${address.postalCode}';

        setState(() {
          searchAddress = addressText;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(20.4646988, 77.3392684), // India
    zoom: 12.0,
  );

  // Future<bool> _handleLocationPermission() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;

  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     Fluttertoast.showToast(
  //       msg: "Location services are disabled. Please enable them.",
  //       toastLength: Toast.LENGTH_LONG,
  //       gravity: ToastGravity.CENTER,
  //     );
  //     return false;
  //   }

  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       Fluttertoast.showToast(
  //         msg: "Location permissions are denied.",
  //         toastLength: Toast.LENGTH_LONG,
  //         gravity: ToastGravity.CENTER,
  //       );
  //       return false;
  //     }
  //   }

  //   if (permission == LocationPermission.deniedForever) {
  //     Fluttertoast.showToast(
  //       msg:
  //           "Location permissions are permanently denied. Cannot request permissions.",
  //       toastLength: Toast.LENGTH_LONG,
  //       gravity: ToastGravity.CENTER,
  //     );
  //     return false;
  //   }

  //   return true;
  // }

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
        title: const Center(child: Text('Select Location')),
        actions: [
          Visibility(
            visible: isLocationInPolygon,
            child: IconButton(
              icon: const Icon(Ionicons.save),
              onPressed: () {
                _saveLocation(selectedLocation, searchAddress);
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: _initialCameraPosition,
            polygons: _buildPolygons(),
            markers: selectedLocation != null
                ? {
                    Marker(
                      markerId: const MarkerId('selected_location'),
                      position: selectedLocation!,
                    ),
                  }
                : {},
            onTap: isLoading ? null : _onMapTap, // Disable tap if loading
            zoomControlsEnabled: false,
          ),
          if (isLoading)
            const Positioned.fill(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: TextField(
                  controller: TextEditingController(
                      text: searchAddress.isNotEmpty
                          ? 'Address: $searchAddress '
                          : 'Tap to select address'),
                  decoration: const InputDecoration(
                    hintText: 'Search location',
                    suffixIcon: Icon(Ionicons.search_outline),
                  ),
                  onChanged: (value) {},
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () {
                _getCurrentLocation();
              },
              elevation: 2,
              backgroundColor: Colors.orange,
              child: const Icon(
                Icons.location_on,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              onPressed: () {
                mapController.animateCamera(
                  CameraUpdate.zoomIn(),
                );
              },
              heroTag: 'zoom_in',
              backgroundColor: Colors.white,
              child: const Icon(
                Icons.add,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              onPressed: () {
                mapController.animateCamera(
                  CameraUpdate.zoomOut(),
                );
              },
              heroTag: 'zoom_out',
              backgroundColor: Colors.white,
              child: const Icon(
                Icons.remove,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveLocation(LatLng? location, searchAddress) async {
    setState(() {
      isLoading = true;
    });
    try {
      if (location != null) {
        final double roundedLat =
            double.parse(location.latitude.toStringAsFixed(6));
        final double roundedLng =
            double.parse(location.longitude.toStringAsFixed(6));
        final address = searchAddress;
        var response =
            await addressService.saveAddress(address, roundedLat, roundedLng);
        if (response.statusCode == 200 || response.statusCode == 201) {
          setState(() {
            isLoading = false;
          });
          // If successful, navigate to respective previous page
          Navigator.pop(context, true);
        } else {
          throw Exception('Failed to create address: ${response.statusCode}');
        }
      } else {
        Fluttertoast.showToast(
          msg: 'No location selected',
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      // If failed, show Toast and prompt user to check details
      Fluttertoast.showToast(
        msg:
            'Failed to create address. Please check the details and try again.',
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  void _onMapTap(LatLng latLng) async {
    setState(() {
      isLoading = true;
      isLocationInPolygon = false;
    });

    // Perform reverse geocoding to get the address from the tapped coordinates
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        // Check if the tapped location falls within any of the polygons
        for (var polygon in _buildPolygons()) {
          if (_checkIfValidMarker(latLng, polygon.points)) {
            // Update the search text field with the obtained address
            setState(() {
              searchAddress = getAddressFromPlacemark(placemark);
              isLocationInPolygon = true;
              selectedLocation = latLng;
              isLoading = false;
            });
            mapController.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: latLng,
                  zoom: 16.0,
                ),
              ),
            );
            break;
          }
        }
        // If location is not within any polygon, show toast message
        if (!isLocationInPolygon) {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(
            msg:
                'Delivery address out of range. Please reselect within polygons.',
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      }
    } catch (e) {
      print('Error getting address from coordinates: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  bool _checkIfValidMarker(LatLng tap, List<LatLng> vertices) {
    int intersectCount = 0;
    for (int j = 0; j < vertices.length - 1; j++) {
      if (rayCastIntersect(tap, vertices[j], vertices[j + 1])) {
        intersectCount++;
      }
    }
    return ((intersectCount % 2) == 1); // odd = inside, even = outside;
  }

  bool rayCastIntersect(LatLng tap, LatLng vertA, LatLng vertB) {
    double aY = vertA.latitude;
    double bY = vertB.latitude;
    double aX = vertA.longitude;
    double bX = vertB.longitude;
    double pY = tap.latitude;
    double pX = tap.longitude;

    if ((aY > pY && bY > pY) || (aY < pY && bY < pY) || (aX < pX && bX < pX)) {
      return false; // a and b can't both be above or below pt.y, and a or
      // b must be east of pt.x
    }

    double m = (aY - bY) / (aX - bX); // Rise over run
    double bee = (-aX) * m + aY; // y = mx + b
    double x = (pY - bee) / m; // algebra is neat!

    return x > pX;
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  Set<Polygon> _buildPolygons() {
    Set<Polygon> polygons = {};
    // Karanja Side
    List<LatLng> polygonCoords1 = [
      const LatLng(20.5065297, 77.5268602),
      const LatLng(20.4610174, 77.5496578),
      const LatLng(20.4217839, 77.4736253),
      const LatLng(20.4130192, 77.3206937),
      const LatLng(20.4966033, 77.4009033),
      const LatLng(20.545219, 77.4271553),
    ];
    polygons.add(Polygon(
      polygonId: const PolygonId('deliverable_area'),
      points: polygonCoords1,
      strokeWidth: 2,
      strokeColor: Colors.blue,
      fillColor: Colors.blue.withOpacity(0.3),
    ));
    // Shelubazar Side
    List<LatLng> polygonCoords2 = [
      const LatLng(20.3462448, 77.1791953), // Chorad
      const LatLng(20.3772965, 77.2011349), //Pur
      const LatLng(20.4066517, 77.2225785), //Vanoja
      // const LatLng(20.3746548, 77.2490152), // Nagi
      const LatLng(20.3932772, 77.2891939), // Tarhala
      const LatLng(20.3396149, 77.2991203), //Hisai
      const LatLng(20.331659, 77.2141204), // Kherda
    ];
    polygons.add(
      Polygon(
        polygonId: const PolygonId('polygon_2'),
        points: polygonCoords2,
        strokeWidth: 2,
        strokeColor: Colors.red,
        fillColor: Colors.red.withOpacity(0.3),
      ),
    );
    return polygons;
  }

  String getAddressFromPlacemark(Placemark placemark) {
    String address = '';

    // Concatenate relevant fields to form the address
    if (placemark.thoroughfare != null && placemark.thoroughfare!.isNotEmpty) {
      address += '${placemark.thoroughfare}, ';
    }
    if (placemark.subThoroughfare != null &&
        placemark.subThoroughfare!.isNotEmpty) {
      address += '${placemark.subThoroughfare}, ';
    }
    if (placemark.locality != null && placemark.locality!.isNotEmpty) {
      address += '${placemark.locality}, ';
    }
    if (placemark.subLocality != null && placemark.subLocality!.isNotEmpty) {
      address += '${placemark.subLocality}, ';
    }
    if (placemark.subAdministrativeArea != null &&
        placemark.subAdministrativeArea!.isNotEmpty) {
      address += '${placemark.subAdministrativeArea}, ';
    }
    if (placemark.administrativeArea != null &&
        placemark.administrativeArea!.isNotEmpty) {
      address += '${placemark.administrativeArea}, ';
    }
    if (placemark.country != null && placemark.country!.isNotEmpty) {
      address += '${placemark.country}, ';
    }
    if (placemark.postalCode != null && placemark.postalCode!.isNotEmpty) {
      address += placemark.postalCode!;
    }

    // Remove trailing comma and space
    address = address.trimRight().replaceAll(RegExp(r', $'), '');

    return address;
  }
}
