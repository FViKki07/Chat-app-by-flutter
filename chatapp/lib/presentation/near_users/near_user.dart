import 'package:chatapp/data/repositories/apis.dart';
import 'package:chatapp/main.dart';
import 'package:flutter/material.dart';

import '../../data/Models/chatuser.dart';
import '../Widgets/chat_user_card.dart';
import '../Widgets/navigation.dart';

class NearUser extends StatefulWidget {
  const NearUser({super.key});

  @override
  State<NearUser> createState() => _NearUserState();
}

class _NearUserState extends State<NearUser> {
  @override
  void initState() {
    //APIs.updateLocation();
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
          )),
          title: Text(
            "Пользователи рядом",
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            Builder(
              builder: (context) {
                return IconButton(
                  color: Colors.white,
                  icon: Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                );
              },
            )
          ],
        ),
        endDrawer: const NavigationDrawerWidget(),
        body: StreamBuilder(
            stream: APIs.getNearUser(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Center(child: CircularProgressIndicator());
                case ConnectionState.none:
                  return Center(child: CircularProgressIndicator());
                case ConnectionState.active:
                case ConnectionState.done:
                  final data = snapshot.data;

                  var _list_users = data?.map((e) {
                        if (e.data() != null) {
                          print(e.data());
                          return ChatUser.fromJson(
                              e.data() as Map<String, dynamic>);
                        } else
                          return null;
                      }).toList() ??
                      [];

                  List<ChatUser> users = _list_users
                      .where((element) =>
                          element != null && element.id != APIs.meInfo.id)
                      .map((e) => e!)
                      .toList();
                  if (users.isNotEmpty) {
                    return ListView.builder(
                        itemCount: users.length,
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Text(
                                  "В ${APIs.getDistance(users[index].location).toInt() + 56 * index + 68} метрах от вас",
                                  style: TextStyle(
                                      color: Color(0xff0947B1), fontSize: 15)),
                              ChatUserCard(user: users[index]),
                              Divider(
                                thickness: 3,
                                color: Color(0xffffa268),
                              )
                            ],
                          );
                        });
                  } else {
                    return const Center(
                        child: Text('Никого нет поблизости',
                            style: TextStyle(fontSize: 20)));
                  }
              }
            }));
  }
}
