import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/Models/message.dart';
import 'package:chatapp/api/apis.dart';
import 'package:chatapp/helper/conver_date.dart';
import 'package:chatapp/helper/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});

  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId ? true : false;

    return InkWell(
        onLongPress: () {
          _showBottom(APIs.user.uid == widget.message.fromId);
        },
        child: isMe ? _selfMessage() : _opponMessage());
  }

  Widget _opponMessage() {
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * .03
                : mq.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
                color: Colors.blue.shade200,
                //border: Border.all(color: Colors.lightBlue),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                )),
            child: widget.message.type == Type.text
                ?
                //show text
                Text(
                    widget.message.message,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  )
                :
                //show image
                ClipRRect(
                    child: CachedNetworkImage(
                      imageUrl: widget.message.message,
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.image, size: 70),
                    ),
                  ),
          ),
        ),
        Padding(
            padding: EdgeInsets.only(right: mq.width * .04),
            child: Text(
                ConvertDate.getConvertedTime(
                    context: context, time: widget.message.time),
                style: const TextStyle(fontSize: 13, color: Colors.black54))),
      ],
    );
  }

  Widget _selfMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: mq.width * .04,
            ),

            //if(widget.message.read.isNotEmpty)
            // const Icon(Icons.done_all_rounded, color: Colors.blue, size: 20),

            const SizedBox(
              width: 2,
            ),
            Text(
                ConvertDate.getConvertedTime(
                    context: context, time: widget.message.time),
                style: const TextStyle(fontSize: 13, color: Colors.black54)),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.height * .02),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.blueAccent),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                )),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: widget.message.type == Type.text
                      ? Text(
                          widget.message.message,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        )
                      : ClipRRect(
                          child: CachedNetworkImage(
                            imageUrl: widget.message.message,
                            placeholder: (context, url) => const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.image, size: 70),
                          ),
                        ),
                ),
                SizedBox(width: mq.width * .02),
                if (widget.message.read.isNotEmpty)
                  const Icon(Icons.done_all_rounded,
                      color: Colors.blue, size: 20)
                else
                  const Icon(Icons.check, color: Colors.blue, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showBottom(bool isMe) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: mq.height * .015, horizontal: mq.width * .4),
                decoration: BoxDecoration(color: Colors.grey),
              ),
              widget.message.type == Type.text
                  ? _OptionItem(
                      icon: const Icon(Icons.copy_all_rounded,
                          color: Colors.blue, size: 26),
                      name: "Скопировать",
                      onTap: () async {
                        await Clipboard.setData(
                                ClipboardData(text: widget.message.message))
                            .then((value) {
                          Navigator.pop(context);

                          showToast(message: 'Текст скопирован!');
                        });
                      })
                  : _OptionItem(
                      icon:
                          const Icon(Icons.image, color: Colors.blue, size: 26),
                      name: "Сохранить изображение",
                      onTap: () {}),
              if (widget.message.type == Type.text && isMe)
                _OptionItem(
                    icon: const Icon(Icons.edit, color: Colors.blue, size: 26),
                    name: "Редактировать",
                    onTap: () {}),
              if (isMe)
                _OptionItem(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 26),
                    name: "Удалить",
                    onTap: () async {
                      await APIs.deleteMessage(widget.message).then((value) {
                        Navigator.pop(context);
                        showToast(message: "Сообщение удалено");
                      });
                    }),
              Divider(
                endIndent: mq.width * .04,
                indent: mq.width * .04,
              ),
              _OptionItem(
                  icon: const Icon(Icons.remove_red_eye,
                      color: Colors.blue, size: 26),
                  name: widget.message.read == ""
                      ? "Не прочтено"
                      : "Прочтено в: ${ConvertDate.getDateOfLastMsg(context: context, time: widget.message.read)}",
                  onTap: () {}),
            ],
          );
        });
  }
}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => onTap(),
        child: Padding(
          padding: EdgeInsets.only(
              left: mq.width * .05,
              top: mq.height * .015,
              bottom: mq.height * .025),
          child: Row(
            children: [
              icon,
              Flexible(
                  child: Text('     $name',
                      style: const TextStyle(fontSize: 15, letterSpacing: 0.5)))
            ],
          ),
        ));
  }
}
