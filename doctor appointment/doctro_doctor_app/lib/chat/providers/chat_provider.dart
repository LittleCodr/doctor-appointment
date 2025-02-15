import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctro/chat/constants/firestore_constants.dart';
import 'package:doctro/chat/models/message_chat.dart';
import 'package:doctro/constant/prefConstatnt.dart';
import 'package:doctro/constant/preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ChatProvider {
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;

  ChatProvider({required this.firebaseFirestore, required this.prefs, required this.firebaseStorage});

  String? getPref(String key) {
    return prefs.getString(key);
  }

  UploadTask uploadFile(File image, String fileName) {
    Reference reference = firebaseStorage.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(image);
    return uploadTask;
  }

  Future<void> updateDataFirestore(String collectionPath, String docPath, Map<String, dynamic> dataNeedUpdate) {
    return firebaseFirestore.collection(collectionPath).doc(docPath).update(dataNeedUpdate);
  }

  Stream<QuerySnapshot> getChatStream(String groupChatId, int limit) {
    return firebaseFirestore.collection(FirestoreConstants.pathMessageCollection).doc(groupChatId).collection(groupChatId).orderBy(FirestoreConstants.timestamp, descending: true).limit(limit).snapshots();
  }

  void sendMessage(String content, int type, String groupChatId, String currentUserId, String peerId) {
    DocumentReference documentReference = firebaseFirestore.collection(FirestoreConstants.pathMessageCollection).doc(groupChatId).collection(groupChatId).doc(DateTime.now().millisecondsSinceEpoch.toString());

    MessageChat messageChat = MessageChat(
      idFrom: currentUserId,
      idTo: peerId,
      timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: type,
    );

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(
        documentReference,
        messageChat.toJson(),
      );
    });
  }

  void sendNotification(String content, String token, String userId, int type, String userImage, String userName) async {
    try {
      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': "key=enter_your_firebase_server_key",
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': type == 1 ? "Image" : content,
              'title': SharedPreferenceHelper.getString(Preferences.name),
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'screen': 'screen',
              'doctorId': userId,
              'doctorImage': SharedPreferenceHelper.getString(Preferences.image),
              'doctorName': SharedPreferenceHelper.getString(Preferences.name),
              'doctorToken': SharedPreferenceHelper.getString(Preferences.messageToken)
            },
            "to": token,
          },
        ),
      );
      if (response.statusCode == 200) {
        print("sucess");
      } else {
        print("not send");
      }
    } catch (e) {
      print("error push notification");
    }
  }
}

class TypeMessage {
  static const text = 0;
  static const image = 1;
  static const sticker = 2;
}
