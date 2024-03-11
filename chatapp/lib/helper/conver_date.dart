import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ConvertDate{

  static String getConvertedTime({required BuildContext context,
  required String time}){
    final date = DateTime.fromMicrosecondsSinceEpoch(int.parse(time));
    print("Time: ${date}");
    return TimeOfDay.fromDateTime(date).format(context);
  }
}