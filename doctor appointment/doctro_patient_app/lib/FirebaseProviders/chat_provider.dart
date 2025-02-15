import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctro_patient/FirebaseModels/message_chat.dart';
import 'package:doctro_patient/const/prefConstatnt.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../const/preference.dart';

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

  void sendNotification(String content, String token, String userName, String userId, int type, String doctorName, String doctorImage) async {
    try {
      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': "key=AAAA_WaO0s4:APA91bFT2izwlImaTCqkyT05BwDiAyNlx-zRBSWvFsn5PSvaH0szBzgW7JV69HQF3oWbcGPPr4SKoh_kn81ioGpLQQN569CcdokKVgPDGS4c5NJQNByX1gG6Vub23hVFNEtM5FrmonPA", //Enter_Your_Server_Key
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{'body': type == 1 ? "Image" : content, 'title': userName, 'click_action': 'FLUTTER_NOTIFICATION_CLICK', 'sound': 'default'},
            'priority': 'high',
            'data': <String, dynamic>{
              'screen': 'screen',
              'userId': userId,
              'userToken': SharedPreferenceHelper.getString(Preferences.notificationRegisterKey),
              'userImage': SharedPreferenceHelper.getString(Preferences.image),
              'userName': userName,
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

  Future<Stream<QuerySnapshot>> getChatRooms() async {
    String? myUsername = prefs.getString(FirestoreConstants.nickname);
    return FirebaseFirestore.instance.collection(FirestoreConstants.pathMessageCollection).orderBy("content", descending: true).where(FirestoreConstants.pathMessageCollection, arrayContains: myUsername).snapshots();
  }
}

class TypeMessage {
  static const text = 0;
  static const image = 1;
  static const sticker = 2;
}
