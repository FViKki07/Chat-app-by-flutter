
import 'package:chatapp/api/apis.dart';
import 'package:flutter/material.dart';

import '../Models/chatuser.dart';
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
          backgroundColor: Colors.blueAccent,
          title: Text("Пользователи рядом"),
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

                  var _list_users = data
                      ?.map((e){
                        if (e.data() != null) {
                          print(e.data());
                          return ChatUser.fromJson(e.data() as Map<String,dynamic>);
                        }
                        else return null;
                      })
                      .toList() ??
                      [];

                  List<ChatUser> users = _list_users.where((element) => element != null && element.id != APIs.meInfo.id).map((e) => e!).toList();
                  if (users.isNotEmpty) {
                      return ListView.builder(
                        itemCount: users.length,
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Text("В ${APIs.getDistance(users[index].location)} метрах от вас"),
                              ChatUserCard(
                                user: users[index]),
                              Divider()
                            ],
                          );
                        });
                      } else {
                        return const Center(
                             child: Text('Никого нет поблизости',
                                style: TextStyle(fontSize: 20)));
                        }
                  }

              }

            )
    );
  }

}
