class ChatUser {
  ChatUser(
      {required this.roomId,
      required this.image,
      required this.name,
      required this.about,
      required this.createdAt,
      required this.lastActive,
      required this.isOnline,
      required this.id,
      required this.pushToken,
      required this.email});

  late List<String> roomId;
  late String image;
  late String name;
  late String about;
  late String createdAt;
  late String lastActive;
  late bool isOnline;
  late String id;
  late String pushToken;
  late String email;

  ChatUser.fromJson(Map<String, dynamic> json) {
    roomId = List.castFrom<dynamic, String>(json['roomId']);
    image = json['image'] ?? '';
    name = json['name'] ?? '';
    about = json['about'] ?? '';
    createdAt = json['created_at'] ?? '';
    lastActive = json['last_active'] ?? '';
    isOnline = json['is_online'] ?? '';
    id = json['id'] ?? '';
    pushToken = json['push_token'] ?? '';
    email = json['email'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['roomId'] = roomId;
    data['image'] = image;
    data['name'] = name;
    data['about'] = about;
    data['created_at'] = createdAt;
    data['last_active'] = lastActive;
    data['is_online'] = isOnline;
    data['id'] = id;
    data['push_token'] = pushToken;
    data['email'] = email;
    return data;
  }
}
