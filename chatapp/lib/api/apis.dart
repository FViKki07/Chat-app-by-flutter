import 'dart:io';

import 'package:chatapp/Models/chatuser.dart';
import 'package:chatapp/Models/message.dart';
import 'package:chatapp/Widgets/chat_user_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;

  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static FirebaseStorage storage = FirebaseStorage.instance;

  static User get user => auth.currentUser!;

  static User? getAuthUser() {
    return auth.currentUser;
  }

  //static late ChatUser me;

  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  /*static ChatUser me = ChatUser(
      id: user.uid,
      name: user.displayName.toString(),
      email: user.email.toString(),
      about: "Hey, I'm using We Chat!",
      image: user.photoURL.toString(),
      createdAt: '',
      isOnline: false,
      lastActive: '',
      pushToken: '');*/

  /* static Future<ChatUser>? getSelf() async{
    var snapshot = await  firestore.collection('users').doc(user.uid).get().then((user) async{
      me = ChatUser.fromJson(user.data()!);
    });
    return me;
  }*/

  static Future<ChatUser?> getMe() async {
    var snapshot = await firestore.collection('users').doc(user.uid).get();
    ChatUser? me;
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      me ??= ChatUser.fromJson(data);
    }
    print("MEEE ${user.email}");
    return me;
  }

  static Future<void> createUser(String name_from_field) async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();

    final chatUser = ChatUser(
        image: '',
        name: name_from_field,
        about: 'about',
        createdAt: time,
        lastActive: time,
        isOnline: false,
        id: user.uid,
        pushToken: '',
        email: user.email.toString());
    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUser() {
    return firestore
        .collection('users')
        .where("id", isNotEqualTo: user.uid)
        .snapshots();
  }

  static Future<void> updateUserInfo(ChatUser me) async {
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'name': me.name, 'about': me.about});
  }

  static Future<bool> userWithNameExists(String name) async {
    var userId = await APIs.firestore
        .collection('users')
        .where("id", isNotEqualTo: user.uid)
        .get();

    var userName = await APIs.firestore
        .collection('users')
        .where("name", isEqualTo: name)
        .get();

    var userExists = userId.docs
        .where((doc1) => userName.docs.any((doc2) => doc1["id"] == doc2["id"]));

    return userExists.isNotEmpty;
  }

  static Future<void> updateProfilePicture(ChatUser me, File file) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext'));
    me.image = await ref.getDownloadURL();
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'image': me.image});
  }

  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages')
        .orderBy('time')
        .snapshots();
  }

  static Future<void> sendMessage(ChatUser chatUser, String msg) async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();

    final Message message = Message(
        toId: chatUser.id,
        read: '',
        type: Type.text,
        message: msg,
        fromId: user.uid,
        time: time);
    final ref = firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson());
  }

  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.time)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser chatUser) {
    return firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages/')
        .orderBy('time', descending: true)
        .limit(1)
        .snapshots();
  }
}
