class Room {
  Room({
    required final String title;
    required this.timeCreate,
    required this.authorizedUsers,
    required this.type,
    required this.roomId,
    required this.moderators,
  });
  late final String title;
  late final String timeCreate;
  late final List<String> authorizedUsers;
  late final TypeRoom type;
  late final String roomId;
  late final List<String> moderators;

  Room.fromJson(Map<String, dynamic> json){
    title = json['title'] ?? '';
    timeCreate = json['timeCreate'] ?? '';
    authorizedUsers = List.castFrom<dynamic, String>(json['authorizedUsers']) ?? [];
    type = json['type'] == TypeRoom.personal.name ? TypeRoom.personal: TypeRoom.group;
    roomId = json['roomId'] ?? '';
    moderators = List.castFrom<dynamic, String>(json['moderators'])?? [];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['title'] = title;
    data['timeCreate'] = timeCreate;
    data['authorizedUsers'] = authorizedUsers;
    data['type'] = type.name;
    data['roomId'] = roomId;
    data['moderators'] = moderators;
    return data;
  }
}

enum TypeRoom{personal, group}