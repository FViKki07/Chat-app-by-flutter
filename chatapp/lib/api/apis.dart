import 'package:chatapp/Models/chatuser.dart';
import 'package:chatapp/Widgets/chat_user_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class APIs {

  static FirebaseAuth auth = FirebaseAuth.instance;

  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static User get user => auth.currentUser!;

  static User? getAuthUser(){
    return auth.currentUser;
  }
  
  static late ChatUser me;
  
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get())
        .exists;
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

  static Future<void> getSelf() async{
    var snapshot = await  firestore.collection('users').doc(user.uid).get().then((user) async{
      me = ChatUser.fromJson(user.data()!);
    });
  }
  
  static Future<ChatUser?> getMe() async{
    var snapshot = await  firestore.collection('users').doc(user.uid).get();
    ChatUser? me;
    if(snapshot.exists){
      Map<String,dynamic> data = snapshot.data() as Map< String,dynamic>;
      me ??=ChatUser.fromJson(data);
    }
    print("MEEE ${user.email}");
    return me;
  }

  static Future<void> createUser(String name_from_field) async{
    final time = DateTime.now().microsecondsSinceEpoch.toString();

    final chatUser = ChatUser(image: '',
        name: name_from_field,
        about: 'about',
        createdAt: time,
        lastActive: time,
        isOnline: false,
        id: user.uid,
        pushToken: '',
        email: user.email.toString());
    return await firestore.collection('users').doc(user.uid).set(chatUser.toJson());
  }
  
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUser(){
    return firestore.collection('users').where("id",isNotEqualTo: user.uid).snapshots();
  }

  static Future<void> updateUserInfo() async {
    await firestore.collection('users').doc(user.uid).update({'name' : me.name, 'about' : me.about});
  }

  static Future<bool> userWithNameExists(String name) async{
    var userId = await APIs.firestore
        .collection('users')
        .where("id", isNotEqualTo: user.uid)
        .get();

    var userName = await APIs.firestore
        .collection('users')
        .where("name", isEqualTo: name)
        .get();

    var userExists = userId.docs.where((doc1) =>
        userName.docs.any((doc2) => doc1["id"] == doc2["id"]));

    return userExists.isNotEmpty;
  }
}