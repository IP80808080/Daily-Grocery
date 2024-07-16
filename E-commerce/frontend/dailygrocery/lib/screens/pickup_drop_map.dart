import 'package:flutter/material.dart';
import 'package:dailygrocery/screens/pickup_drop_list_page.dart';
import 'package:dailygrocery/service/pickup_drop_service.dart';
import 'package:ionicons/ionicons.dart';

class PickupDropForm extends StatefulWidget {
  const PickupDropForm({Key? key}) : super(key: key);

  @override
  _PickupDropFormState createState() => _PickupDropFormState();
}

class _PickupDropFormState extends State<PickupDropForm> {
  final _formKey = GlobalKey<FormState>();
  final pickupDropService = PickupDropService();
  late String _pickupAddress;
  late String _dropAddress;
  bool _isLoading = false;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      bool success =
          await pickupDropService.savePickupDrop(_pickupAddress, _dropAddress);
      setState(() {
        _isLoading = false;
      });
      if (success) {
        // Data saved successfully
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pickup and drop data saved successfully'),
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => PickupDropListPage()),
        );
      } else {
        // Error occurred while saving data
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save pickup and drop data'),
          ),
        );
      }
    }
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
        title: const Center(child: Text('Pickup & Drop Form')),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Pickup Address',
                        border: OutlineInputBorder(),
                      ),
                      maxLength: 500,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter pickup address';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _pickupAddress = value!;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Drop Address',
                        border: OutlineInputBorder(),
                      ),
                      maxLength: 500,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter drop address';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _dropAddress = value!;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _submitForm();
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
                          'Submit',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // void _submitForm() {
  //   if (_formKey.currentState!.validate()) {
  //     _formKey.currentState!.save();
  //     // Now you can use _pickupAddress and _dropAddress
  //     // for further processing, like saving to database, etc.
  //   }
  // }
}
