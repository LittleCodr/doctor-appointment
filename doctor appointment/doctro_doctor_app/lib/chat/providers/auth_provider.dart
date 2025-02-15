import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctro/chat/constants/firestore_constants.dart';
import 'package:doctro/chat/models/user_chat.dart';
import 'package:doctro/constant/prefConstatnt.dart';
import 'package:doctro/constant/preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Status { uninitialized, authenticated, authenticating, authenticateError, authenticateCanceled }

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;
  final SharedPreferences prefs;

  Status _status = Status.uninitialized;

  Status get status => _status;

  AuthProvider({
    required this.firebaseAuth,
    required this.prefs,
    required this.firebaseFirestore,
  });

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  String? getUserFirebaseId() {
    return prefs.getString(FirestoreConstants.id);
  }
  bool check = false;
  Future<bool> handleSignIn() async {

    _status = Status.authenticating;

    notifyListeners();

    try {
      User? user = (await _auth.createUserWithEmailAndPassword(
        email: SharedPreferenceHelper.getString(Preferences.user_email),
        password: SharedPreferenceHelper.getString(Preferences.password),
      ))
          .user;
      if (user != null) {
        final QuerySnapshot result = await firebaseFirestore.collection(FirestoreConstants.pathUserCollection).where(FirestoreConstants.id, isEqualTo: user.uid).get();
        final List<DocumentSnapshot> documents = result.docs;
        if (documents.length == 0) {
          firebaseFirestore.collection(FirestoreConstants.pathUserCollection).doc(user.uid).set({
            FirestoreConstants.nickname: SharedPreferenceHelper.getString(Preferences.user_name),
            FirestoreConstants.photoUrl: SharedPreferenceHelper.getString(Preferences.chat_profile),
            FirestoreConstants.userType: "doctor",
            FirestoreConstants.doctorId: SharedPreferenceHelper.getString(Preferences.doctorId),
            FirestoreConstants.id: user.uid,
            'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
            FirestoreConstants.chattingWith: null
          });

          User? currentUser = user;
          await prefs.setString(FirestoreConstants.id, currentUser.uid);
          await prefs.setString(FirestoreConstants.nickname, currentUser.displayName ?? "");
          await prefs.setString(FirestoreConstants.photoUrl, currentUser.photoURL ?? "");
        } else {
          DocumentSnapshot documentSnapshot = documents[0];
          UserChat userChat = UserChat.fromDocument(documentSnapshot);
          await prefs.setString(FirestoreConstants.id, userChat.id);
          await prefs.setString(FirestoreConstants.nickname, userChat.nickname);
          await prefs.setString(FirestoreConstants.photoUrl, userChat.photoUrl);
          await prefs.setString(FirestoreConstants.shopId, userChat.shopId);
          await prefs.setString(FirestoreConstants.userType, userChat.userType);
          await prefs.setString(Preferences.doctorId, userChat.doctorId);
        }
        _status = Status.authenticated;
        notifyListeners();
        return check = true;
      } else {
        _status = Status.authenticateError;
        notifyListeners();
        return check = false;
      }
    } on FirebaseAuthException catch (signUpError) {
      if (signUpError.code == 'ERROR_EMAIL_ALREADY_IN_USE' || signUpError.code == "email-already-in-use") {
        User? user = (await _auth.signInWithEmailAndPassword(
          email: SharedPreferenceHelper.getString(Preferences.user_email),
          password: SharedPreferenceHelper.getString(Preferences.password),
        ))
            .user;
        if (user != null) {
          final QuerySnapshot result = await firebaseFirestore.collection(FirestoreConstants.pathUserCollection).where(FirestoreConstants.id, isEqualTo: user.uid).get();
          final List<DocumentSnapshot> documents = result.docs;
          if (documents.length == 0) {
            firebaseFirestore.collection(FirestoreConstants.pathUserCollection).doc(user.uid).set({
              FirestoreConstants.nickname: SharedPreferenceHelper.getString(Preferences.user_name),
              FirestoreConstants.photoUrl: SharedPreferenceHelper.getString(Preferences.chat_profile),
              FirestoreConstants.userType: "doctor",
              FirestoreConstants.doctorId: SharedPreferenceHelper.getString(Preferences.doctorId),
              FirestoreConstants.id: user.uid,
              'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
              FirestoreConstants.chattingWith: null
            });

            User? currentUser = user;
            await prefs.setString(FirestoreConstants.id, currentUser.uid);
            await prefs.setString(FirestoreConstants.nickname, currentUser.displayName ?? "");
            await prefs.setString(FirestoreConstants.photoUrl, currentUser.photoURL ?? "");
          } else {
            DocumentSnapshot documentSnapshot = documents[0];
            UserChat userChat = UserChat.fromDocument(documentSnapshot);

            await prefs.setString(FirestoreConstants.id, userChat.id);
            await prefs.setString(FirestoreConstants.nickname, userChat.nickname);
            await prefs.setString(FirestoreConstants.photoUrl, userChat.photoUrl);
            await prefs.setString(FirestoreConstants.shopId, userChat.shopId);
            await prefs.setString(FirestoreConstants.userType, userChat.userType);
            await prefs.setString(FirestoreConstants.doctorId, userChat.doctorId);
          }

          _status = Status.authenticated;
          notifyListeners();

          return check = true;
        } else {
          _status = Status.authenticateError;
          notifyListeners();
          return check = false;
        }
      } else {
        return check = false;
      }
    }
  }

  Future<void> handleSignOut() async {
    _status = Status.uninitialized;
    await firebaseAuth.signOut();
  }
}
