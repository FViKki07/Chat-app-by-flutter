import 'package:chatapp/Screen/login_screen.dart';
import 'package:chatapp/Screen/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/Services/authentication.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();//?
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Друг рядом',

      home: SplashScreen(
        child: LoginScreen(),
      ),
    );
  }
}

