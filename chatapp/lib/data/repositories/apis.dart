import 'dart:convert';
import 'dart:io';

import 'package:chatapp/data/Models/chatuser.dart';
import 'package:chatapp/data/Models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:geoflutterfire2/geoflutterfire2.dart';

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;

  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static FirebaseStorage storage = FirebaseStorage.instance;

  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  static User get user => auth.currentUser!;

  static final geo = GeoFlutterFire();

  //static User? getAuthUser() {
  //return auth.currentUser;
  // }

  static late ChatUser meInfo;

  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  static Future<void> getMessagingToken() async {
    await messaging.requestPermission();

    await messaging.getToken().then((t) {
      if (t != null) {
        meInfo.pushToken = t;
        print('Push token : $t');
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }

  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": meInfo.name,
          "body": msg,
          "android_channel_id": "chats",
        },
        "data": {
          "some_data": "User ID: ${meInfo.id}",
        },
      };

      var response =
          await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: {
                HttpHeaders.contentTypeHeader: 'application/json',
                HttpHeaders.authorizationHeader:
                    'key=AAAA6_I92lE:APA91bEWxbaViJSJG4itO2PD2uTWm9VI5agoM5B4_Ie8cl2Hi31B9TCBoyjb1OOnOAd6LhJluxiE0NXVSZjR57R0Lwdx2rumFxNALAnBKlTbMr_FKOA6Ll1fDJqDgZm3_vJPWBEIIV7g'
              },
              body: jsonEncode(body));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    } catch (e) {
      print('\nsendPushError: $e');
    }
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
        await getMessagingToken();

        //for setting user status to active
        APIs.updateActiveStatus(true);
      } else {
        await createUser('NoName').then((value) => getSelfInfo());
      }
    });
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
        location: await determinePosition().then((value) => value.data));
    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
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
        .orderBy('time', descending: true)
        .snapshots();
  }

  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();

    final Message message = Message(
        toId: chatUser.id,
        read: '',
        type: type,
        message: msg,
        fromId: user.uid,
        time: time);
    final ref = firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson()).then((val) =>
        sendPushNotification(chatUser, type == Type.text ? msg : 'Фотография'));
  }

  static Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .doc(chatUser.id)
        .set({}).then((value) async {
      firestore
          .collection('users')
          .doc(chatUser.id)
          .collection('my_users')
          .doc(user.uid)
          .set({}).then((value) => sendMessage(chatUser, msg, type));
    });

    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({});
  }

  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.time)
        .update({'read': DateTime.now().microsecondsSinceEpoch.toString()});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser chatUser) {
    return firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages/')
        .orderBy('time', descending: true)
        .limit(1)
        .snapshots();
  }

  static Future<void> sendImage(ChatUser chatUser, File file) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.id)}/${DateTime.now().microsecondsSinceEpoch}.$ext');
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext'));
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  static Future<void> deleteMessage(Message message) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.time)
        .delete();

    if (message.type == Type.image) {
      await storage.refFromURL(message.message).delete();
    }
  }

  static Future<void> updateMessage(Message message, String updateMsg) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.time)
        .update({'message': updateMsg});
  }
//------------------------LOCATION--------------------------------

  static double getDistance(Map<String, dynamic> data) {
    var otherPoint = geopointFrom(data);
    var myGeoPoint = geopointFrom(meInfo.location);
    GeoFirePoint meLocation = geo.point(
        latitude: myGeoPoint.latitude, longitude: myGeoPoint.longitude);
    return meLocation.distance(
            lat: otherPoint.latitude, lng: otherPoint.longitude) *
        1000;
  }

  static Future<void> updateLocation(GeoFirePoint location) async {
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'location': location.data});
  }

  static (double?, double?) getLocation(String loc) {
    double? latitude, longitude;

    if (loc.isNotEmpty) {
      var listLocation = loc.split(" ");

      if (listLocation.length >= 3) {
        latitude = double.tryParse(listLocation[1].split(',').first);
        longitude = double.tryParse(listLocation[3]);
      }
    }

    return (latitude, longitude);
  }

  static GeoPoint geopointFrom(Map<String, dynamic> data) =>
      data['geopoint'] as GeoPoint;

  static Stream<List<DocumentSnapshot>> getNearUser() {
    var currLocation = geopointFrom(meInfo.location);

    GeoFirePoint center = geo.point(
        latitude: currLocation.latitude, longitude: currLocation.longitude);

    var collectionReference = firestore.collection('users');

    double radius = 1000;
    String field = 'location';

    return geo
        .collection(collectionRef: collectionReference)
        .within(center: center, radius: radius, field: field);
  }

  static Future<GeoFirePoint> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition().then((value) =>
        geo.point(latitude: value.latitude, longitude: value.longitude));
  }
}
