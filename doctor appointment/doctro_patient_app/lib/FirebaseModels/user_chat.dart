import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctro_patient/const/prefConstatnt.dart';

class UserChat {
  String id;
  String photoUrl;
  String nickname;
  String aboutMe;
  String userType;
  String token;

  UserChat({required this.id, required this.photoUrl, required this.nickname, required this.aboutMe, required this.userType, required this.token});

  Map<String, String> toJson() {
    return {
      FirestoreConstants.nickname: nickname,
      FirestoreConstants.aboutMe: aboutMe,
      FirestoreConstants.photoUrl: photoUrl,
      FirestoreConstants.userType: userType,
      FirestoreConstants.token: token,
    };
  }

  factory UserChat.fromDocument(DocumentSnapshot? doc) {
    String aboutMe = "";
    String photoUrl = "";
    String nickname = "";
    String userType = "";
    String token = "";
    try {
      aboutMe = doc!.get(FirestoreConstants.aboutMe);
    } catch (e) {}
    try {
      photoUrl = doc!.get(FirestoreConstants.photoUrl);
    } catch (e) {}
    try {
      nickname = doc!.get(FirestoreConstants.nickname);
    } catch (e) {}
    try {
      userType = doc!.get(FirestoreConstants.userType);
    } catch (e) {}
    try {
      token = doc!.get(FirestoreConstants.token);
    } catch (e) {}
    return UserChat(
      id: doc!.id,
      photoUrl: photoUrl,
      nickname: nickname,
      aboutMe: aboutMe,
      userType: userType,
      token: token,
    );
  }
}
