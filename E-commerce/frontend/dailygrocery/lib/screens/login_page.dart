import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dailygrocery/service/auth_service.dart';
import 'package:dailygrocery/screens/home_page.dart';
import 'package:dailygrocery/screens/signup_page.dart';
import 'package:dailygrocery/screens/loader.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService authService = AuthService();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? _responseMessage;
  bool _isLoading = false;
  final storage = const FlutterSecureStorage();
  final String _usernameKey = 'loginEmail';
  final String _passwordKey = 'loginPassword';
  @override
  void initState() {
    super.initState();
    _loadDataFromStorage();
  }

  Future<void> _loadDataFromStorage() async {
    final isLoginEmail = await storage.containsKey(key: _usernameKey);
    final isPassword = await storage.containsKey(key: _passwordKey);
    if (isPassword && isLoginEmail) {
      // Retrieve username and password from secure storage
      String? username = await storage.read(key: _usernameKey);
      String? password = await storage.read(key: _passwordKey);

      // Set initial values for input fields
      setState(() {
        emailController.text = username ?? '';
        passwordController.text = password ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child:Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                  onPressed: _isLoading
                      ? null
                      : () async {
                          setState(() {
                            _isLoading = true;
                          });
                          try {
                            final message = await authService.login(
                              emailController.text.trim(),
                              passwordController.text.trim(),
                            );
                            if (message == "LOGIN") {
                              // Login successful, navigate to Home page
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => HomePage()),
                              );
                            } else {
                              // Login failed, display error message
                              setState(() {
                                _responseMessage = message;
                                _isLoading = false;
                              });
                            }
                          } catch (e) {
                            setState(() {
                              _responseMessage = '$e';
                              _isLoading = false;
                            });
                          }
                        },
                  child: const Text('Login'),
                ),
                const SizedBox(height: 10),
                if (_responseMessage != null)
                  Text(
                    _responseMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                // SizedBox(height: 10),
                // Signup link
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => SignUpPage()));
                  },
                  child: Text('Sign Up'),
                ),
              ],
            ),
            if (_isLoading) Loader(), // Display loader if isLoading is true
          ],
        ),
      ),
      ),
  
  );}
}
