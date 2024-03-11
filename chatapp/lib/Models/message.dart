class Message {
  Message({
    required this.toId,
    required this.read,
    required this.type,
    required this.message,
    required this.fromId,
    required this.time,
  });
  late final String toId;
  late final String read;
  late final Type type;
  late final String message;
  late final String fromId;
  late final String time;

  Message.fromJson(Map<String, dynamic> json){
    toId = json['toId'].toString();
    read = json['read'].toString();
    type = json['type'].toString() == Type.image.name ? Type.image: Type.text;
    message = json['message'].toString();
    fromId = json['fromId'].toString();
    time = json['time'].toString();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['toId'] = toId;
    _data['read'] = read;
    _data['type'] = type.name;
    _data['message'] = message;
    _data['fromId'] = fromId;
    _data['time'] = time;
    return _data;
  }
}

enum Type{ text, image}