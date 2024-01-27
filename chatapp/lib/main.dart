import 'package:chatapp/Screen/login_screen.dart';
import 'package:chatapp/Screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/Services/authentication.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Друг рядом',

      home: SplashScreen(
        child: LoginScreen(),
      ),
    );
  }
}

