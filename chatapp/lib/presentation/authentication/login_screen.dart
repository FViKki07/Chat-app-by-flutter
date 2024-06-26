import 'package:chatapp/presentation/authentication/sign_upScreen.dart';
import 'package:chatapp/presentation/Widgets/form_container.dart';
import 'package:chatapp/data/repositories/apis.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../helper/message.dart';
import '../../domain/auth/firebase_auth.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isSigning = false;
  final FirebaseAuthService _auth = FirebaseAuthService();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
            decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.topRight,
              colors: [
                Color(0xffffa268),
                Color(0xff0947B1),
              ]),
        )), //shadowColor: Colors.blueAccent,
        title: Text(
          "Вход",
          style: TextStyle(
              fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('images/back.jpg'), fit: BoxFit.cover),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Вход",
                    style:
                        TextStyle(fontSize: 27, fontWeight: FontWeight.bold)),
                const SizedBox(
                  height: 30,
                ),
                FormContainer(
                  controller: _emailController,
                  hintText: "Почта",
                  isPasswordField: false,
                ),
                const SizedBox(
                  height: 10,
                ),
                FormContainer(
                  controller: _passwordController,
                  hintText: "Пароль",
                  isPasswordField: true,
                ),
                SizedBox(
                  height: 30,
                ),
                GestureDetector(
                  onTap:
                      _signIn /*() {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                        (route) => false);
                  }*/
                  ,
                  child: Container(
                    width: 180,
                    height: 45,
                    decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                        child: _isSigning
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text("Вход",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold))),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Еще нет аккаунта?"),
                    SizedBox(
                      width: 5,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpScreen()),
                            (route) => false);
                      },
                      child: Text("Зарегистрироваться",
                          style: TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _signIn() async {
    setState(() {
      _isSigning = true;
    });

    String email = _emailController.text;
    String password = _passwordController.text;

    User? user = await _auth.signInWithEmailAndPassword(email, password);

    setState(() {
      _isSigning = false;
    });

    if (user != null) {
      print("User is successfully signedIn");
      showToast(message: "Вы вошли в аккаунт");
      Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
      //APIs.getMe();
    } else {
      showToast(message: "Ошибка");
      print("Some error happend");
    }
  }
}
