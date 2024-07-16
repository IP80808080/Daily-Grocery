import 'package:flutter/material.dart';
import 'package:dailygrocery/service/auth_service.dart';
import 'package:dailygrocery/screens/home_page.dart';
import 'package:dailygrocery/screens/login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final AuthService authService = AuthService();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController emailController =
      TextEditingController();
  final TextEditingController passwordController =
      TextEditingController();
  bool _loading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(labelText: 'First Name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: mobileNumberController,
                  decoration:
                      const InputDecoration(labelText: 'Mobile Number'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _loading
                      ? null
                      : () async {
                          try {
                            // Check if all fields are filled
                            if (firstNameController.text.isEmpty ||
                                lastNameController.text.isEmpty ||
                                mobileNumberController.text.isEmpty ||
                                emailController.text.trim().isEmpty ||
                                passwordController.text.isEmpty) {
                              throw 'All fields are required';
                            }
                            // Validate mobile number format
                            if (!_validateMobile(
                                mobileNumberController.text)) {
                              throw 'Invalid mobile number';
                            }
                            // Set loading state
                            setState(() {
                              _loading = true;
                            });
                            // Call signup method
                            final result = await authService.signUp(
                              emailController.text.trim(),
                              passwordController.text.trim(),
                              firstNameController.text.trim(),
                              lastNameController.text.trim(),
                              mobileNumberController.text.trim(),
                            );
                            if (result == "LOGIN") {
                              // Sign up successful, navigate to Home page
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const HomePage(),
                                ),
                              );
                            } else {
                              // Sign up failed, display error message
                              setState(() {
                                _errorMessage = result;
                                _loading = false; // Reset loading state
                              });
                            }
                          } catch (e) {
                            // Catch any exceptions during signup
                            setState(() {
                              _errorMessage = 'Error: $e';
                              _loading = false; // Reset loading state
                            });
                          }
                        },
                  child: const Text('Sign Up'),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _loading
                      ? null
                      : () async {
                          // Navigate to login page
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                  child: const Text(
                    'Already have an account? Login',
                    style: TextStyle(fontSize: 14, fontFamily: 'Roboto'),
                  ),
                ),
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
              ],
            ),
            if (_loading) // Show loader if loading state is true
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  bool _validateMobile(String value) {
    // Regular expression to match Indian mobile number format without country code
    RegExp mobileRegExp = RegExp(r"^(?:[6-9])\d{9}$");
    return mobileRegExp.hasMatch(value);
  }
}
