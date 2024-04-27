import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/Screen/view_profile_screen.dart';
import 'package:chatapp/helper/conver_date.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../Models/chatuser.dart';
import '../Models/message.dart';
import '../Widgets/message_card.dart';
import '../api/apis.dart';
import '../main.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;

  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _list = [];

  final _textContoller = TextEditingController();

  // final ScrollController _scrollController = ScrollController();

  bool _showEmoji = false, _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        if (_showEmoji) {
          setState(() {
            _showEmoji = !_showEmoji;
          });
        }
      },
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) {
            return;
          }
          if (_showEmoji) {
            setState(() {
              _showEmoji = !_showEmoji;
            });
          } else {
            Navigator.pop(context);
          }
        },
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.blueAccent,
              //elevation: 2,
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),
            backgroundColor: const Color.fromARGB(255, 234, 248, 255),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                      stream: APIs.getAllMessages(widget.user),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return Center(child: CircularProgressIndicator());
                          case ConnectionState.active:
                          case ConnectionState.done:
                            final data = snapshot.data?.docs;
                            _list = data
                                    ?.map((e) => Message.fromJson(e.data()))
                                    .toList() ??
                                [];

                            if (_list.isNotEmpty) {
                              /*WidgetsBinding.instance!.addPostFrameCallback((_) {
                                _scrollController.animateTo(
                                  _scrollController.position.maxScrollExtent,
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              });*/
                              return ListView.builder(
                                  reverse: true,
                                  itemCount: _list.length,
                                  //controller: _scrollController,
                                  physics: BouncingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return MessageCard(
                                      message: _list[index],
                                    );
                                  });
                            } else {
                              return const Center(
                                  child: Text('Начните чат 👋',
                                      style: TextStyle(fontSize: 20)));
                            }
                        }
                      }),
                ),
                if (_isLoading)
                  const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                          child: CircularProgressIndicator(strokeWidth: 2))),
                _chatInput(),
                if (_showEmoji)
                  SizedBox(
                    height: mq.height * .35,
                    child: EmojiPicker(
                      textEditingController: _textContoller,
                      config: Config(
                        bgColor: const Color.fromARGB(255, 234, 248, 255),
                        columns: 8,
                        emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                      ),
                    ),
                  )
              ],
            )),
      ),
    );
  }

  Widget _appBar() {
    return SafeArea(
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ViewProfileScreen(user: widget.user)));
        },
        child: StreamBuilder(
            stream: APIs.getUserInfo(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

              return Row(
                children: [
                  SizedBox(
                    height: mq.height * .2,
                  ),
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back, color: Colors.black54)),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .03),
                    child: widget.user.image.isEmpty
                        ? const CircleAvatar(child: Icon(CupertinoIcons.person))
                        : CachedNetworkImage(
                            width: mq.height * .05,
                            height: mq.height * .05,
                            imageUrl: widget.user.image,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) =>
                                const CircleAvatar(
                                    child: Icon(CupertinoIcons.person))),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.user.name,
                          style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w500)),
                      Text(
                          list.isNotEmpty
                              ? list[0].isOnline
                                  ? 'Онлайн'
                                  : ConvertDate.getLastActiveTime(
                                      context: context,
                                      lastActive: list[0].lastActive)
                              : ConvertDate.getLastActiveTime(
                                  context: context,
                                  lastActive: widget.user.lastActive),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ))
                    ],
                  )
                ],
              );
            }),
      ),
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * .01, horizontal: mq.width * .025),
      child: Row(
        children: [
          Expanded(
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        setState(() => _showEmoji = !_showEmoji);
                      },
                      icon: Icon(Icons.emoji_emotions,
                          color: Colors.blueAccent, size: 25)),
                  Expanded(
                    child: TextField(
                      controller: _textContoller,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      onTap: () {
                        if (_showEmoji)
                          setState(() => _showEmoji = !_showEmoji);
                      },
                      decoration: const InputDecoration(
                        hintMaxLines: null,
                        hintText: "Сообщение",
                        hintStyle: TextStyle(color: Colors.blueAccent),
                        border: InputBorder.none,
                        //isDense: true,
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        // Picking multiple images
                        final List<XFile> images =
                            await picker.pickMultiImage(imageQuality: 70);

                        // uploading & sending image one by one
                        for (var i in images) {
                          setState(() => _isLoading = true);
                          await APIs.sendImage(widget.user, File(i.path));
                          setState(() => _isLoading = false);
                        }
                      },
                      icon: Icon(Icons.image, color: Colors.blueAccent)),
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 70);
                        if (image != null) {
                          setState(() => _isLoading = true);
                          await APIs.sendImage(widget.user, File(image.path));
                          setState(() => _isLoading = false);
                        }
                      },
                      icon: Icon(Icons.camera, color: Colors.blueAccent)),
                  SizedBox(
                    width: mq.width * .02,
                  )
                ],
              ),
            ),
          ),
          MaterialButton(
            onPressed: () {
              if (_textContoller.text.isNotEmpty) {
                if(_list.isEmpty) {
                  APIs.sendFirstMessage(widget.user, _textContoller.text, Type.text);

                } else {
                  APIs.sendMessage(widget.user, _textContoller.text, Type.text);
                }
                _textContoller.text = '';
              }
            },
            shape: CircleBorder(),
            minWidth: 0,
            color: Colors.blueAccent,
            padding: EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            child: Icon(Icons.send, color: Colors.white, size: 28),
          )
        ],
      ),
    );
  }
}
