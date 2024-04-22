import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/api/apis.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../Models/chatuser.dart';
import '../Widgets/navigation.dart';
import '../helper/conver_date.dart';
import '../main.dart';
import '../helper/message.dart';

class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  // String? _image = widget.user.image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(widget.user.name),
      ),
      endDrawer: const NavigationDrawerWidget(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
        child: Column(
          children: [
            SizedBox(width: mq.width, height: mq.height * .03),
            widget.user.image.isEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .1),
                    child: CircleAvatar(
                        radius: mq.height * .1,
                        child: const Icon(
                          CupertinoIcons.person,
                          size: 50,
                        )))
                : ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .1),
                    child: CachedNetworkImage(
                      width: mq.height * .2,
                      height: mq.height * .2,
                      fit: BoxFit.cover,
                      imageUrl: widget.user.image,
                      errorWidget: (context, url, error) => const CircleAvatar(
                          child: Icon(CupertinoIcons.person)),
                    ),
                  ),
            widget.user.isOnline
                ? const Text('Онлайн',
                    style: TextStyle(color: Colors.green, fontSize: 16))
                : Text(
                    '${ConvertDate.getLastActiveTime(context: context, lastActive: widget.user.lastActive)}',
                    style: const TextStyle(color: Colors.red, fontSize: 16)),
            SizedBox(height: mq.height * .03),
            Text(widget.user.email,
                style: TextStyle(color: Colors.black54, fontSize: 20)),
            SizedBox(height: mq.height * .01),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'О себе: ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                Text(
                  '${widget.user.about}',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
