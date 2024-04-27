
import 'package:chatapp/Screen/home_screen.dart';
import 'package:chatapp/Screen/login_screen.dart';
import 'package:chatapp/Screen/near_user.dart';
import 'package:chatapp/Screen/profile_screen.dart';
import 'package:chatapp/Screen/sign_upScreen.dart';
import 'package:chatapp/Screen/splash_screen.dart';
import 'package:chatapp/api/apis.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/Services/authentication.dart';
import 'firebase_options.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';


//global object for accessing device screen size
late Size mq;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();//?

  await _initFirebase();
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
          child: returnHome(),
        ),
        '/login': (context) => const LoginScreen(),
        '/signUp': (context) => SignUpScreen(),
        '/home': (context) => HomeScreen(),
        '/user': (context) => ProfileScreen(),
        '/nearUser': (context) => NearUser()
      },/*
      home: SplashScreen(
        child: LoginScreen(),
      ),*/
    );
  }
}

_initFirebase() async{

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  var result = await FlutterNotificationChannel.registerNotificationChannel(
    description: 'For showing message notification',
    id: 'chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Chats',
  );
  print('\nNotification channel result: $result');
}

Widget returnHome(){
  if(APIs.auth.currentUser != null)
    return HomeScreen();
  return LoginScreen();
}

