import 'dart:convert';
import 'dart:developer';

import 'package:chatapp/Widgets/chat_user_card.dart';
import 'package:chatapp/api/apis.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/Widgets/navigation.dart';
import 'package:flutter/services.dart';

import '../Models/chatuser.dart';
import '../Models/room.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Room> _list_rooms = [];
  List<ChatUser> _list_users = [];
  List<ChatUser> _list_search = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
    
    getUsers().then((List<ChatUser> fetchedUsers) {
      setState(() {
        _list_users = fetchedUsers;
      });
      for(var i in fetchedUsers)
        print(i.name);
    });

      SystemChannels.lifecycle.setMessageHandler((message) {
        print('Message ${message}');

        if(APIs.getAuthUser() != null){
          if(message.toString().contains('resume')) APIs.updateActiveStatus(true);
          if(message.toString().contains('paused')) APIs.updateActiveStatus(false);
        }

        if(message.toString().contains('detached')) APIs.updateActiveStatus(false);//не работает полный выход из системы
        return Future.value(message);
      });
  }

  static Future<List<ChatUser>> getUsers() async {
    QuerySnapshot<Map<String, dynamic>> usersSnapshot = await APIs.allUsers();
    List<ChatUser> users = usersSnapshot.docs.map((doc) {
      return ChatUser.fromJson(doc.data());
    }).toList();
    return users;
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
            backgroundColor: Colors.blueAccent,
            title: _isSearching
                ? TextField(
              decoration: const InputDecoration(
                  border: InputBorder.none, hintText: 'Имя или почта'),
              autofocus: true,
              style: TextStyle(fontSize: 17, letterSpacing: 0.5),
              onChanged: (val) {
                _list_search.clear();

                for (var user in _list_users) {
                  if (user.name.toLowerCase().contains(val.toLowerCase()) ||
                      user.email.toLowerCase().contains(val.toLowerCase())) {
                    _list_search.add(user);
                  }
                  setState(() {
                    _list_search;
                  });
                }
              },
            )
                : Text("Чаты"),
            actions: [
              IconButton(
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
              stream: APIs.getAllRooms(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Center(child: CircularProgressIndicator());
                  case ConnectionState.active:
                  case ConnectionState.done:
                    final data = snapshot.data?.docs;
                    _list_rooms =
                        data?.map((e) => Room.fromJson(e.data()))
                            .toList() ??
                            [];
                    if (!_isSearching && _list_rooms.isNotEmpty) {
                      return ListView.builder(
                          itemCount: _list_rooms.length,
                          physics: BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Center();
                            /*return ChatUserCard(user:
                            _isSearching ? _list_search[index] :
                            _list_users[index]);*/
                          });
                    }
                    else if(_isSearching){
                      return ListView.builder(
                          itemCount: _list_search.length,
                          physics: BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return ChatUserCard(user:
                            _list_search[index], roomId: null,);
                          });
                    }
                    else {
                      return const Center(
                          child:
                          Text('Чатов нет', style: TextStyle(fontSize: 20)));
                    }
                }
              })
      ),
    ),);
  }

}

