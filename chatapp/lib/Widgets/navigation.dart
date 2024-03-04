import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../message.dart';
class NavigationDrawerWidget extends StatelessWidget {
  const NavigationDrawerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Drawer(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              buildHeader(context),
              buildMenuItems(context),
            ],
          ),
        ),
      );
}

Widget buildHeader(BuildContext context) => Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
      ),
    );

Widget buildMenuItems(BuildContext context) => Column(
      children: [
        ListTile(
          leading: const Icon(Icons.chat),
          title: const Text('Чаты'),
          onTap: () {
            Navigator.pushNamedAndRemoveUntil(context, "/home",(route) => false);
          },
        ),
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Профиль'),
          onTap: () {
            Navigator.pushNamedAndRemoveUntil(context, "/user",(route) => false);
          },
        ),
        const Divider(
          color: Colors.black,
        ),
        ListTile(
          leading: const Icon(Icons.output),
          title: const Text('Выйти'),
            onTap: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(context, "/login",(route) => false);
              showToast(message: "Вы успешно вышли из аккаунта");
            },
        )
      ],
    );
