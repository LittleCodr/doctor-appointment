import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctro_patient/Chat/utilities.dart';
import 'package:doctro_patient/FirebaseProviders/auth_provider.dart';
import 'package:doctro_patient/FirebaseProviders/chat_provider.dart';
import 'package:doctro_patient/FirebaseProviders/home_provider.dart';
import 'package:doctro_patient/FirebaseProviders/setting_provider.dart';
import 'package:doctro_patient/FirebaseModels/user_chat.dart';
import 'package:doctro_patient/Chat/chatPage.dart';
import 'package:doctro_patient/const/Palette.dart';
import 'package:doctro_patient/const/app_string.dart';
import 'package:doctro_patient/const/prefConstatnt.dart';
import 'package:doctro_patient/localization/localization_constant.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'loading_view.dart';

class Chat extends StatefulWidget {
  final int doctorId;
  final String where;

  Chat({
    required this.doctorId,
    required this.where,
  });

  @override
  State createState() => ChatState();
}

class ChatState extends State<Chat> {
  ChatState({Key? key});

  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final ScrollController listScrollController = ScrollController();

  int _limit = 20;
  final int _limitIncrement = 20;
  bool isLoading = false;

  late AuthProvider authProvider;
  late String currentUserId;
  late HomeProvider homeProvider;
  StreamController<bool> btnClearController = StreamController<bool>();
  TextEditingController searchBarTec = TextEditingController();

  late SettingProvider settingProvider;

  late ChatProvider chatProvider;
  String groupChatId = "";
  List<QueryDocumentSnapshot> listMessage = [];

  @override
  void initState() {
    super.initState();
    print("doctor id: " + widget.doctorId.toString());
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    chatProvider = context.read<ChatProvider>();

    if (authProvider.getUserFirebaseId()?.isNotEmpty == true) {
      currentUserId = authProvider.getUserFirebaseId()!;
      setState(() {});
    }
    registerNotification();
    listScrollController.addListener(scrollListener);
  }

  @override
  void dispose() {
    super.dispose();
    btnClearController.close();
  }

  void registerNotification() {
    firebaseMessaging.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('onMessage: $message');
      if (message.notification != null) {
        showNotification(message.notification!);
      }
      return;
    });

    firebaseMessaging.getToken().then((token) {
      print('push token: $token');
      if (token != null) {
        homeProvider.updateDataFirestore(FirestoreConstants.pathUserCollection, currentUserId, {'pushToken': token});
      }
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.message.toString());
    });
  }

  void scrollListener() {
    if (listScrollController.offset >= listScrollController.position.maxScrollExtent && !listScrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  void showNotification(RemoteNotification remoteNotification) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      Platform.isAndroid ? 'com.dfa.flutterchatdemo' : 'com.duytq.flutterchatdemo',
      'Flutter chat demo',
      playSound: true,
      enableVibration: true,
      importance: Importance.max,
      priority: Priority.high,
    );
    DarwinNotificationDetails iOSPlatformChannelSpecifics = const DarwinNotificationDetails();
    NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

    print(remoteNotification);

    await flutterLocalNotificationsPlugin.show(
      0,
      remoteNotification.title,
      remoteNotification.body,
      platformChannelSpecifics,
      payload: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // List
          Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: homeProvider.getStreamFireStore(FirestoreConstants.pathUserCollection, _limit, widget.doctorId.toString()),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData) {
                      if ((snapshot.data?.docs.length ?? 0) > 0) {
                        UserChat userChat = UserChat.fromDocument(snapshot.data?.docs[0]);
                        if (Utilities.isKeyboardShowing()) {
                          Utilities.closeKeyboard(context);
                        }
                        return ChatPage(
                          peerId: userChat.id,
                          peerAvatar: userChat.photoUrl,
                          peerNickname: userChat.nickname,
                          doctorToken: userChat.token,
                          where: widget.where,
                        );
                      } else {
                        return Stack(
                          children: [
                            Center(
                              child: Text(
                                getTranslated(context, AppString.something_went_wrong_toast).toString(),
                                style: TextStyle(fontSize: 16, color: Palette.dark_blue),
                              ),
                            ),
                            Positioned(
                              top: 40,
                              left: 5,
                              child: IconButton(
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  size: 20,
                                  color: Palette.dark_blue,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ],
                        );
                      }
                    } else {
                      return const Center(
                        child: SpinKitFadingCircle(
                          color: Palette.blue,
                          size: 50.0,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),

          // Loading
          Positioned(
            child: isLoading ? LoadingView() : const SizedBox.shrink(),
          )
        ],
      ),
    );
  }
}
