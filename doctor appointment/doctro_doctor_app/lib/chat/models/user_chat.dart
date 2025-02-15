import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctro/chat/constants/firestore_constants.dart';

class UserChat {
  String id;
  String photoUrl;
  String nickname;
  String content;
  String shopId;
  String userType;
  String doctorId;
  String token;
  String userId;

  UserChat({required this.id, required this.photoUrl, required this.nickname, required this.content, required this.shopId, required this.userType, required this.doctorId, required this.token, required this.userId});

  Map<String, String> toJson() {
    return {
      FirestoreConstants.nickname: nickname,
      FirestoreConstants.photoUrl: photoUrl,
      FirestoreConstants.content: content,
      FirestoreConstants.shopId: shopId,
      FirestoreConstants.userType: userType,
      FirestoreConstants.doctorId: doctorId,
      FirestoreConstants.token: token,
      FirestoreConstants.userId: userId
    };
  }

  factory UserChat.fromDocument(DocumentSnapshot doc) {
    String photoUrl = "";
    String nickname = "";
    String content = "";
    String shopId = "";
    String userType = "";
    String doctorId = "";
    String token = "";
    String userId = "";

    try {
      photoUrl = doc.get(FirestoreConstants.photoUrl);
    } catch (e) {}
    try {
      nickname = doc.get(FirestoreConstants.nickname);
    } catch (e) {}
    try {
      content = doc.get(FirestoreConstants.content);
    } catch (e) {}
    try {
      shopId = doc.get(FirestoreConstants.shopId);
    } catch (e) {}
    try {
      userType = doc.get(FirestoreConstants.userType);
    } catch (e) {}
    try {
      doctorId = doc.get(FirestoreConstants.doctorId);
    } catch (e) {}
    try {
      token = doc.get(FirestoreConstants.token);
    } catch (e) {}
    try {
      userId = doc.get(FirestoreConstants.userId);
    } catch (e) {}
    return UserChat(userId: userId, id: doc.id, photoUrl: photoUrl, nickname: nickname, content: content, shopId: shopId, userType: userType, doctorId: doctorId, token: token);
  }
}
