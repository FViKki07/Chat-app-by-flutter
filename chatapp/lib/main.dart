
import 'package:chatapp/Screen/home_screen.dart';
import 'package:chatapp/Screen/login_screen.dart';
import 'package:chatapp/Screen/profile_screen.dart';
import 'package:chatapp/Screen/sign_upScreen.dart';
import 'package:chatapp/Screen/splash_screen.dart';
import 'package:chatapp/api/apis.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/Services/authentication.dart';
import 'firebase_options.dart';

//global object for accessing device screen size
late Size mq;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();//?
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //await FirebaseAppCheck.instance.activate();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Друг рядом',
      routes: {
        '/': (context) => SplashScreen(
          // Here, you can decide whether to show the LoginPage or HomePage based on user authentication
          child: returnHome(),
        ),
        '/login': (context) => const LoginScreen(),
        '/signUp': (context) => SignUpScreen(),
        '/home': (context) => HomeScreen(),
        '/user': (context) => ProfileScreen(),
      },/*
      home: SplashScreen(
        child: LoginScreen(),
      ),*/
    );
  }
}

Widget returnHome(){
  if(APIs.getAuthUser() != null)
    return HomeScreen();
  return LoginScreen();
}

