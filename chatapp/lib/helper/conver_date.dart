import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ConvertDate {
  static String getConvertedTime(
      {required BuildContext context, required String time}) {
    final date = DateTime.fromMicrosecondsSinceEpoch(int.parse(time));
    return TimeOfDay.fromDateTime(date).format(context);
  }

  /*static String getMessageTime(
      {required BuildContext context, required String time}) {
      
    return "";
  }*/

  static String getDateOfLastMsg(
      {required BuildContext context, required String time}) {
    final DateTime sent = DateTime.fromMicrosecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();

    if (now.year == sent.year) {
      if (now.month == sent.month) {
        if (now.day == sent.day) {
          return TimeOfDay.fromDateTime(sent).format(context);
        } else if (sent.isBefore(DateTime(now.year, now.month, now.day + 7)) &&
            sent.isAfter(DateTime(now.year, now.month, now.day - 7)))
          return getWeekDay(sent.weekday);
        else {
          return addZero(sent, false);
        }
      } else {
        return addZero(sent, false);
      }
    }

    return addZero(sent, true);
  }

  static String getWeekDay(int week) {
    switch (week) {
      case (1):
        return 'Пн';
      case (2):
        return 'Вт';
      case (3):
        return 'Ср';
      case (4):
        return 'Чт';
      case (5):
        return 'Пт';
      case (6):
        return 'Сб';
      case (7):
        return 'Вс';
    }
    return 'none';
  }

  static String addZero(DateTime time, bool year) {
    String date =
        '${time.day < 10 ? '0${time.day}' : time.day.toString()}.${time.month < 10 ? '0${time.month}' : time.month.toString()}';
    if (year) {
      return '$date.${time.year}';
    }
    return date;
  }

  static String getLastActiveTime(
      {required BuildContext context, required String lastActive}) {
    final int i = int.tryParse(lastActive) ?? -1;

    if (i == -1) return 'был(а) давно';

    DateTime time = DateTime.fromMicrosecondsSinceEpoch(i);
    print(
        'DateTime: ${time.day}.${time.month}.${time.year} ${time.hour}:${time.minute}:${time.second}.${time.millisecond}');
    DateTime now = DateTime.now();

    print('Time $time');
    String formattedTime = TimeOfDay.fromDateTime(time).format(context);
    if (time.day == now.day &&
        time.month == now.month &&
        time.year == time.year) {
      return 'была(а) сегодня в $formattedTime';
    }

    if ((now.difference(time).inHours / 24).round() == 1) {
      return 'был(а) вчера в $formattedTime';
    }

    return 'был(а) ${addZero(time, false)}';
  }
}
