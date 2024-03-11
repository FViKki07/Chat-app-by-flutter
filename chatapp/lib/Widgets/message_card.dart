import 'package:chatapp/Models/message.dart';
import 'package:chatapp/api/apis.dart';
import 'package:chatapp/helper/conver_date.dart';
import 'package:flutter/material.dart';

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
    return APIs.user.uid == widget.message.fromId ? _selfMessage() : _opponMessage();
  }

  Widget _opponMessage(){
    if(widget.message.read.isEmpty){
      APIs.updateMessageReadStatus(widget.message);
      print('read update');
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.height * .02),
            margin: EdgeInsets.symmetric(horizontal: mq.width*.04,
            vertical: mq.height * .01),
            decoration: BoxDecoration(color: Colors.blue.shade200,
                //border: Border.all(color: Colors.lightBlue),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),)),
            child: Text(widget.message.message, style: TextStyle(fontSize: 15, color: Colors.black,),),
          ),
        ),

        Padding(
            padding: EdgeInsets.only(right: mq.width * .04),
            child:  Text( ConvertDate.getConvertedTime(context: context, time: widget.message.time), style: const TextStyle(fontSize: 13, color: Colors.black54))),

      ],
    );
  }

  Widget _selfMessage(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(width: mq.width *.04,),

            //if(widget.message.read.isNotEmpty)
             // const Icon(Icons.done_all_rounded, color: Colors.blue, size: 20),

            const SizedBox(width: 2,),
            Text( ConvertDate.getConvertedTime(context: context, time: widget.message.time), style: const TextStyle(fontSize: 13, color: Colors.black54)),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.height * .02),
            margin: EdgeInsets.symmetric(horizontal: mq.width*.04,
                vertical: mq.height * .01),
            decoration: BoxDecoration(color: Colors.white,
                border: Border.all(color: Colors.blueAccent),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30),)),
            child: Row(
              mainAxisAlignment:MainAxisAlignment.spaceBetween ,
              mainAxisSize: MainAxisSize.min,
               crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text( widget.message.message, style: TextStyle(fontSize: 15, color: Colors.black,),),
                SizedBox(width: mq.width * .02),
                if(widget.message.read.isNotEmpty)
                  const Icon(Icons.done_all_rounded, color: Colors.blue, size: 20)
                else
                  const Icon(Icons.check,  color: Colors.blue, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

}
