import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  final Widget? child;
  const SplashScreen({
    super.key,
    this.child,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(Duration(seconds: 3), () {
      //SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          // systemNavigationBarColor: Colors.blueAccent,
          statusBarColor: Colors.blueAccent));

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => widget.child!),
          (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/friends.jpg'),
                fit: BoxFit.cover, // Adjust the fit as needed
              ),
            ),
          ),
          const Center(
            child: FractionallySizedBox(
              widthFactor: 1.0,
              heightFactor: 0.6, // Reduce the height for placing above
              child: Align(
                alignment: Alignment.topCenter,
                child: Text(
                  "Добро пожаловать в Друг Рядом",
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
