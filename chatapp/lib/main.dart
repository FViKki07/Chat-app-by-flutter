import 'package:chatapp/presentation/home/home_screen.dart';
import 'package:chatapp/presentation/authentication/login_screen.dart';
import 'package:chatapp/presentation/near_users/near_user.dart';
import 'package:chatapp/presentation/profile/profile_screen.dart';
import 'package:chatapp/presentation/authentication/sign_upScreen.dart';
import 'package:chatapp/presentation/Screen/splash_screen.dart';
import 'package:chatapp/data/repositories/apis.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'firebase_options.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

//global object for accessing device screen size
late Size mq;
var flag = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initFirebase();

  _init_backgroud_location();

  runApp(const MyApp());
}

Future<bool> checkLocationPermission() async {
  PermissionStatus status = await Permission.location.request();

  if (status.isDenied) return false;
  _init_backgroud_location();
  return true;
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
      }, /*
      home: SplashScreen(
        child: LoginScreen(),
      ),*/
    );
  }

  Widget returnHome() {
    if (APIs.auth.currentUser != null) {
      return const HomeScreen();
    }
    return const LoginScreen();
  }
}

_initFirebase() async {
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

_init_backgroud_location() {
  bg.BackgroundGeolocation.onLocation((bg.Location location) {
    GeoFirePoint currLocation =
        GeoFirePoint(location.coords.latitude, location.coords.longitude);
    APIs.updateLocation(currLocation);
  });

  bg.BackgroundGeolocation.ready(bg.Config(
          desiredAccuracy: bg.Config.DESIRED_ACCURACY_MEDIUM,
          distanceFilter: 20.0,
          stopOnTerminate: false,
          startOnBoot: true,
          debug: true))
      .then((bg.State state) {
    if (!state.enabled) {
      bg.BackgroundGeolocation.start();
    }
  });
}
