import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'view/home/components/body.dart';
import 'splash_screen.dart'; // 👈 Import the splash screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Force opaque white status bar (not transparent)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white, // solid white bar
      statusBarIconBrightness: Brightness.dark, // dark icons
      systemNavigationBarColor: Colors.white, // match navigation bar
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
        scaffoldBackgroundColor: Colors.white, // ✅ ensure consistent background
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white, // ✅ non-transparent
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.white, // white status bar
            statusBarIconBrightness: Brightness.dark, // dark icons
          ),
        ),
      ),
      home: const SplashScreenPage(),
    );
  }
}

// 🟦 Splash logic wrapper
class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  @override
  void initState() {
    super.initState();

    // Simulate loading for 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
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

// 🏠 Home Page
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // dismiss keyboard
      child: const Scaffold(
        backgroundColor: Colors.white, // ✅ match the system bar color
        body: SafeArea(
          child: Column(children: [Expanded(child: Body())]),
        ),
      ),
    );
  }
}
