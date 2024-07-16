import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dailygrocery/screens/login_page.dart';
import 'package:dailygrocery/screens/home_page.dart';
import 'package:dailygrocery/service/auth_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final storage = const FlutterSecureStorage();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Grocery',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CheckLoggedIn(),
    );
  }
}

class CheckLoggedIn extends StatefulWidget {
  const CheckLoggedIn({super.key});

  @override
  _CheckLoggedInState createState() => _CheckLoggedInState();
}

class _CheckLoggedInState extends State<CheckLoggedIn> {
  final storage = const FlutterSecureStorage();
  final AuthService authService = AuthService();
  @override
  void initState() {
    super.initState();
    _checkLoggedIn();
  }

  Future<void> _checkLoggedIn() async {
    final bool isVerified = await authService.verifyUserLoggedIn();
    if (isVerified) {
      // If tokens exist, navigate to Home page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
