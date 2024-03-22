import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/Models/chatuser.dart';
import 'package:chatapp/api/apis.dart';
import 'package:chatapp/helper/conver_date.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Models/message.dart';
import '../Screen/chat_screen.dart';
import '../main.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  final String roomId = null;

  const ChatUserCard({super.key, required this.user, required roomId});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _message;
  late String roomId;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      //color: Colors.blue.shade100,
      child: InkWell(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => ChatScreen(user: widget.user)));
        },
        child: StreamBuilder(
          stream: APIs.getLastMessage(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final _list =
                data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
            if (_list.isNotEmpty) {
              _message = _list.first;
            }


            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .03),
                child: CachedNetworkImage(
                    width: mq.height * .055,
                    height: mq.height * .055,
                    imageUrl: widget.user.image,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                        const CircleAvatar(child: Icon(CupertinoIcons.person))),
              ),
              //const CircleAvatar(child: Icon(CupertinoIcons.person),),
              title: Text(widget.user.name),

              subtitle: Text(
                _message == null ? widget.user.about :
                _message!.type == Type.text ? _message!.message : 'Фотография',
                maxLines: 1,
              ),

              trailing: _message == null
                  ? null
                  : ((_message!.read.isEmpty &&
                          APIs.user.uid != _message!.fromId)
                      ? Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                              color: Colors.greenAccent.shade200,
                              borderRadius: BorderRadius.circular(10)),
                        )
                      : Text(
                          ConvertDate.getDateOfLastMsg(
                              context: context, time: _message!.time),
                          style: TextStyle(color: Colors.black54))),
              //trailing: Text('12:00', style : TextStyle(color:Colors.black54)),
            );
          },
        ),
      ),
    );
  }

  Future<bool> _findRoom(ChatUser chatUser) async{
    var idRooms = chatUser.roomId.where((id) => APIs.meInfo.roomId.contains(id));
    var rooms = await APIs.firestore.collection('rooms').where('id', isEqualTo: idRooms).where('authorizedUsers', ).get();
    if(rooms.docs.isNotEmpty){
      rooms.docs.where((element) => element.get(''))
    }
    APIs.meInfo.roomId
  }

}
