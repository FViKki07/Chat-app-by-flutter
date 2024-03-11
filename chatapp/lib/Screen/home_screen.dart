import 'dart:convert';
import 'dart:developer';

import 'package:chatapp/Widgets/chat_user_card.dart';
import 'package:chatapp/api/apis.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/Widgets/navigation.dart';
import 'package:flutter/services.dart';

import '../Models/chatuser.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<ChatUser> _list_users = [];

  List<ChatUser> _list_search = [];
  bool _isSearching = false;

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
              stream: APIs.getAllUser(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Center(child: CircularProgressIndicator());
                  case ConnectionState.active:
                  case ConnectionState.done:
                    final data = snapshot.data?.docs;
                    _list_users =
                        data?.map((e) => ChatUser.fromJson(e.data()))
                            .toList() ??
                            [];
                    if (_list_users.isNotEmpty) {
                      return ListView.builder(
                          itemCount: _isSearching
                              ? _list_search.length
                              : _list_users.length,
                          physics: BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return ChatUserCard(user:
                            _isSearching ? _list_search[index] :
                            _list_users[index]);
                          });
                    } else {
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
