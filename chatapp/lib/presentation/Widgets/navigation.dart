import 'package:chatapp/data/repositories/apis.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import '../../helper/message.dart';

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
          leading: const Icon(Icons.chat, color: Color(0xffffa268)),
          title: const Text('Чаты'),
          onTap: () {
            Navigator.pushNamedAndRemoveUntil(
                context, "/home", (route) => false);
          },
        ),
        ListTile(
          leading: const Icon(Icons.person, color: Color(0xffffa268)),
          title: const Text('Профиль'),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, "/user");
          },
        ),
        /*ListTile(
          leading: const Icon(Icons.location_searching),
          title: const Text('Найти местоположение'),
          onTap: () async {
            GeoFirePoint myPosition = await APIs.determinePosition();
            print('My position: ${myPosition.data}');
          },
        ),*/
        ListTile(
          leading:
              const Icon(Icons.location_searching, color: Color(0xffffa268)),
          title: const Text('Найти людей рядом'),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, "/nearUser");
          },
        ),
        const Divider(
          color: Colors.black,
        ),
        ListTile(
          leading: const Icon(Icons.output, color: Color(0xffffa268)),
          title: const Text('Выйти'),
          onTap: () async {
            Navigator.pushNamedAndRemoveUntil(
                    context, "/login", (route) => false)
                .then((_) => {APIs.updateActiveStatus(false)})
                .then((_) => FirebaseAuth.instance.signOut());

            //APIs.auth = FirebaseAuth.instance;
            //FirebaseAuth.instance.signOut();

            showToast(message: "Вы успешно вышли из аккаунта");
          },
        ),
      ],
    );
