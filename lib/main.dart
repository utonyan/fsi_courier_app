import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fsi_courier_app/view/Dashboard/dashboard_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'view/home/components/body.dart'; // import your login page
import 'splash_screen.dart'; // Import the splash screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force opaque white status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark,
          ),
        ),
      ),
      home: const SplashScreenPage(),
    );
  }
}

// Splash screen with login check
class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");
    final expiryString = prefs.getString("auth_token_expiry");

    bool valid = false;
    if (token != null && expiryString != null) {
      final expiry = DateTime.parse(expiryString);
      valid = DateTime.now().isBefore(expiry);
    }

    // Navigate after splash delay
    Future.delayed(const Duration(seconds: 3), () {
      if (valid) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      } else {
        // Remove expired token
        prefs.remove("auth_token");
        prefs.remove("auth_token_expiry");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen(
      imagePath: 'assets/logo.png',
      text: 'Courier App',
      backgroundColor: Colors.white,
    );
  }
}

// Home Page
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: const Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(children: [Expanded(child: Body())]),
        ),
      ),
    );
  }
}
