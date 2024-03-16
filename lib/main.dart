import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:privtatize_ai/src/screens/register_password_view.dart';
import 'package:privtatize_ai/src/screens/validate_password_view.dart';

Future<bool> isFirstLaunch() async {
  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
  return isFirstLaunch;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool firstLaunch = await isFirstLaunch();
  runApp(MyApp(firstLaunch: firstLaunch));
} 

class MyApp extends StatelessWidget {
  final bool firstLaunch;
  const MyApp({super.key, required this.firstLaunch});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    await Future.delayed(const Duration(seconds: 3)); 
    
    if (isFirstLaunch) {
      await prefs.setBool('isFirstLaunch', false);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RegisterPasswordScreen()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ValidatePasswordScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFFc8ccc4), // ここに画像に合わせた背景色を設定
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Image.asset('assets/img/splash.png', // 画像のパスを指定
              width: 328, // 画像のサイズを指定
              height: 220),
        ),
      ),
    );
  }
}


