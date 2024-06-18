import 'package:chatapp/data/Models/chatuser.dart';
import 'package:chatapp/helper/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthenticationRepository {
  User? getCurrentUser();

  Future<User?> signUpWithEmailAndPassword(
      String email, String password, String name);
}

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  static FirebaseAuth _auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<User?> signUpWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      var userExists = await firestore
          .collection('users')
          .where("name", isEqualTo: name)
          .get();
      if (userExists.docs.isNotEmpty) {
        throw Exception("Пользователь с таким именем уже есть");
      }
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        showToast(message: 'The email address is already in use');
        print('Данный адрес эл. почты уже используется');
      } else if (e.code == 'invalid-email') {
        showToast(message: 'Некорректная почта\nПример: example@gmail.com');
      } else if (e.code == 'weak-password') {
        showToast(message: 'Слабый пароль');
      } else {
        print("=====" + e.code);
        showToast(message: "Ошибка: ${e.code}");
        print("Ошибка");
      }
    } on Exception catch (e) {
      showToast(
          message: "Ошибка: ${e.toString().replaceAll("Exception: ", "")}");
      print("$e");
    }
    return null;
  }

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        showToast(message: 'Неправильный логин или пароль');
      } else {
        showToast(message: 'Ошибка');
        print("Some error occured");
      }
    }
    return null;
  }
}
