import 'dart:io';

import 'package:chatapp/data/Models/chatuser.dart';
import 'package:chatapp/data/repositories/apis.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ChatUserRepository {
  static FirebaseFirestore firestore = APIs.firestore;
  static User get user => APIs.auth.currentUser!;

  static late ChatUser meInfo;

  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  static Future<void> createUser(String nameFromField) async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();

    final chatUser = ChatUser(
        image: '',
        name: nameFromField,
        about: 'about',
        createdAt: time,
        lastActive: time,
        isOnline: false,
        id: user.uid,
        pushToken: '',
        email: user.email.toString(),
        location: await APIs.determinePosition().then((value) => value.data));
    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

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

  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        meInfo = ChatUser.fromJson(user.data()!);
        await APIs.getMessagingToken();

        //for setting user status to active
        APIs.updateActiveStatus(true);
      } else {
        await createUser('NoName').then((value) => getSelfInfo());
      }
    });
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    return firestore
        .collection('users')
        .where('id', whereIn: userIds.isEmpty ? [''] : userIds)
        .snapshots();
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

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().microsecondsSinceEpoch.toString(),
      'push_token': meInfo.pushToken
    });
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
    final ref = APIs.storage.ref().child('profile_pictures/${user.uid}.$ext');
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext'));
    me.image = await ref.getDownloadURL();
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'image': me.image});
  }
}
