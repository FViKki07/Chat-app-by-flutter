import 'package:chatapp/Screen/login_screen.dart';
import 'package:chatapp/Widgets/form_container.dart';
import 'package:chatapp/api/apis.dart';
import 'package:chatapp/auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../helper/message.dart';

import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  final FirebaseAuthService _auth = FirebaseAuthService();

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool _isSigningUp = false;

  @override
  void dispose(){
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        //shadowColor: Colors.blueAccent,
        title: Text(
          "Регистрация",
          style: TextStyle(
              fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Регистрация",
                  style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold)),
              SizedBox(
                height: 30,
              ),
              FormContainer(
                controller: _usernameController,
                hintText: "Имя пользователя",
                isPasswordField: false,
              ),
              SizedBox(
                height: 10,
              ),
              FormContainer(
                controller: _emailController,
                hintText: "Почта",
                isPasswordField: false,
              ),
              SizedBox(
                height: 10,
              ),
              FormContainer(
                controller: _passwordController,
                hintText: "Пароль (от 6 символов)",
                isPasswordField: true,
              ),
              SizedBox(
                height: 30,
              ),
              GestureDetector(
                onTap: _signUp,
                child: Container(
                  width: 250,
                  height: 45,
                  decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(10)),
                  child:  Center(
                      child: _isSigningUp ? CircularProgressIndicator(color: Colors.white) : Text("Зарегистрироваться",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold))),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text("Уже есть аккаунт?"),
                SizedBox(
                  width: 5,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LoginScreen()),(route) => false);
                  },
                  child: Text("Вход",
                      style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold)),
                )
              ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _signUp() async{

    setState(() {
      _isSigningUp = true;
    });

    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    User? user = await _auth.signUpWithEmailAndPassword(email, password, username);

    setState(() {
      _isSigningUp = false;
    });

    if(user != null){

      if(await APIs.userExists()){
        showToast(message: "Пользователь создан");
        print("User is successfullu created");
        Navigator.pushNamedAndRemoveUntil(context, "/home",(route) => false);
      }else{
        await APIs.createUser(_usernameController.text).then((value){
          showToast(message: "Пользователь создан");
          print("----------User is successfullu edited to users");
          Navigator.pushNamedAndRemoveUntil(context, "/home",(route) => false);
        });
      }
    }else{
      showToast(message: "Ошибка");
      print("Some error happend");
    }
  }

}
