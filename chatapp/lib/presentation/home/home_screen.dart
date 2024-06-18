import 'dart:convert';
import 'dart:developer';

import 'package:chatapp/presentation/Widgets/chat_user_card.dart';
import 'package:chatapp/data/repositories/apis.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/presentation/Widgets/navigation.dart';
import 'package:flutter/services.dart';
import '../../data/Models/chatuser.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  //List<Room> _list_rooms = [];
  List<ChatUser> _list_users = [];
  List<ChatUser> _list_search = [];
  bool _isSearching = false;

  //List<ChatUser> nearlyUser = APIs.getNearUser();
  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
    //APIs.updateLocation();

    SystemChannels.lifecycle.setMessageHandler((message) {
      print('Message ${message}');

      // if (APIs.getAuthUser() != null) {
      if (message.toString().contains('resume')) APIs.updateActiveStatus(true);
      if (message.toString().contains('paused')) APIs.updateActiveStatus(false);
      //}

      if (message.toString().contains('detached'))
        APIs.updateActiveStatus(false); //не работает полный выход из системы
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      }, //выяснить про открытие клавиатуры и enddraweer
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) {
            return;
          }
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
          } else {
            SystemNavigator.pop();
          }
        },
        child: Scaffold(
            key: _scaffoldKey,
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
              title: _isSearching
                  ? TextField(
                      decoration: const InputDecoration(
                          border: InputBorder.none, hintText: 'Имя или почта'),
                      autofocus: true,
                      style: TextStyle(fontSize: 17, letterSpacing: 0.5),
                      onChanged: (val) {
                        _list_search.clear();

                        for (var user in _list_users) {
                          if (user.name
                                  .toLowerCase()
                                  .contains(val.toLowerCase()) ||
                              user.email
                                  .toLowerCase()
                                  .contains(val.toLowerCase())) {
                            _list_search.add(user);
                          }
                          setState(() {
                            _list_search;
                          });
                        }
                      },
                    )
                  : Text(
                      "Чаты",
                      style: TextStyle(color: Colors.white),
                    ),
              actions: [
                IconButton(
                  color: Colors.white,
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                    });
                  },
                  icon: Icon(_isSearching
                      ? CupertinoIcons.clear_circled_solid
                      : Icons.search),
                ),
                IconButton(
                  color: Colors.white,
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                    });
                    FocusScope.of(context).unfocus();
                    _scaffoldKey.currentState!.openEndDrawer();
                  },
                  icon: Icon(Icons.menu),
                ),
              ],
            ),
            endDrawer: const NavigationDrawerWidget(),

            //floatingActionButton: Padding(),
            body: StreamBuilder(
                stream: APIs.getMyUsersId(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return const Center(child: CircularProgressIndicator());
                    case ConnectionState.active:
                    case ConnectionState.done:
                      return StreamBuilder(
                          stream: APIs.getAllUsers(
                              snapshot.data?.docs.map((e) => e.id).toList() ??
                                  []),
                          builder: (context, snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.waiting:
                              case ConnectionState.none:
                              case ConnectionState.active:
                              case ConnectionState.done:
                                final data = snapshot.data?.docs;
                                _list_users = data
                                        ?.map(
                                            (e) => ChatUser.fromJson(e.data()))
                                        .toList() ??
                                    [];

                                //_list_users = snapshot.data ?? [];
                                if (_list_users.isNotEmpty) {
                                  return Container(
                                      decoration: const BoxDecoration(
                                        image: DecorationImage(
                                            image:
                                                AssetImage('images/back.jpg'),
                                            fit: BoxFit.cover),
                                      ),
                                      child: ListView.builder(
                                          itemCount: _isSearching
                                              ? _list_search.length
                                              : _list_users.length,
                                          physics: BouncingScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            return ChatUserCard(
                                                user: _isSearching
                                                    ? _list_search[index]
                                                    : _list_users[index]);
                                          }));
                                } else {
                                  return Container(
                                      decoration: const BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage('images/back.jpg'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      child: const Center(
                                          child: Text('Чатов нет',
                                              style: TextStyle(fontSize: 20))));
                                }
                            }
                          });
                  }
                })),
      ),
    );
  }
}

showAlertDialog(BuildContext context) {
  // set up the button
  Widget okButton = TextButton(
    child: Text("OK"),
    onPressed: () {},
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Упс"),
    content: Text(
        "Чтобы пользоваться приложением, необходимо установить разрешение в настройках телефона."),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
