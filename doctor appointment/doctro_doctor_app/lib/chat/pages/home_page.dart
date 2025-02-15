import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctro/chat/constants/colors.dart';
import 'package:doctro/chat/constants/firestore_constants.dart';
import 'package:doctro/chat/providers/auth_provider.dart';
import 'package:doctro/chat/providers/home_provider.dart';
import 'package:doctro/chat/utils/debouncer.dart';
import 'package:doctro/chat/utils/utilities.dart';
import 'package:doctro/constant/app_string.dart';
import 'package:doctro/constant/color_constant.dart';
import 'package:doctro/localization/localization_constant.dart';
import 'package:doctro/screens/home%20page/login_home.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';
import 'pages.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  HomePageState({Key? key});

  final GoogleSignIn googleSignIn = GoogleSignIn();
  final ScrollController listScrollController = ScrollController();

  late Future<SharedPreferences> prefs = SharedPreferences.getInstance();

  var lastMessage;

  int _limit = 20;
  int _limitIncrement = 20;

  bool isLoading = false;

  late AuthProvider authProvider;
  late String currentUserId;
  late HomeProvider homeProvider;
  Debouncer searchDebouncer = Debouncer(milliseconds: 300);
  StreamController<bool> btnClearController = StreamController<bool>();

  String data = '';

  @override
  void initState() {
    super.initState();

    authProvider = context.read<AuthProvider>();
    homeProvider = context.read<HomeProvider>();

    if (authProvider.getUserFirebaseId()?.isNotEmpty == true) {
      currentUserId = authProvider.getUserFirebaseId()!;
    }
  }

  @override
  void dispose() {
    super.dispose();
    btnClearController.close();
  }

  void scrollListener() {
    if (listScrollController.offset >= listScrollController.position.maxScrollExtent && !listScrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  Future<bool> onBackPress() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginHomeScreen(chat: "")));
    return Future.value(false);
  }

  Future<void> handleSignOut() async {
    authProvider.handleSignOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 40,
        elevation: 1,
        leading: InkWell(
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginHomeScreen(chat: "")));
            },
            child: Icon(Icons.arrow_back)),
        backgroundColor: colorWhite,
        title: Text(
          getTranslated(context, AppString.chats).toString(),
          style: TextStyle(color: ColorConstants.primaryColor),
        ),
        centerTitle: true,
        foregroundColor: colorBlack,
      ),
      body: Container(
        color: back,
        child: WillPopScope(
          onWillPop: onBackPress,
          child: Stack(
            children: <Widget>[
              Column(
                children: [
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: homeProvider.getStreamFireStore(FirestoreConstants.pathUserCollection, _limit),
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasData) {
                          if ((snapshot.data?.docs.length ?? 0) > 0) {
                            return ListView.builder(
                              padding: const EdgeInsets.all(10),
                              itemBuilder: (context, index) => buildItem(context, snapshot.data?.docs[index]),
                              itemCount: snapshot.data?.docs.length,
                              controller: listScrollController,
                            );
                          } else {
                            return Center(
                              child: Text(getTranslated(context, AppString.no_user).toString()),
                            );
                          }
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: ColorConstants.themeColor,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
              Positioned(
                child: isLoading ? LoadingView() : const SizedBox.shrink(),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildItem(BuildContext context, DocumentSnapshot? document) {
    if (document != null) {
      UserChat userChat = UserChat.fromDocument(document);
      if (userChat.id == currentUserId) {
        return const SizedBox.shrink();
      } else {
        return Container(
          child: TextButton(
            child: Row(
              children: <Widget>[
                Material(
                  child: userChat.photoUrl.isNotEmpty
                      ? Image.network(
                          userChat.photoUrl,
                          fit: BoxFit.cover,
                          width: 50,
                          height: 50,
                          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return SizedBox(
                              width: 50,
                              height: 50,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: ColorConstants.themeColor,
                                  value: loadingProgress.expectedTotalBytes != null && loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, object, stackTrace) {
                            return const Icon(
                              Icons.account_circle,
                              size: 50,
                              color: ColorConstants.greyColor,
                            );
                          },
                        )
                      : const Icon(
                          Icons.account_circle,
                          size: 50,
                          color: ColorConstants.greyColor,
                        ),
                  borderRadius: const BorderRadius.all(Radius.circular(25)),
                  clipBehavior: Clip.hardEdge,
                ),
                Flexible(
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Text(
                            userChat.nickname,
                            maxLines: 1,
                            style: const TextStyle(color: ColorConstants.primaryColor),
                          ),
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.fromLTRB(10, 0, 0, 5),
                        ),
                        Container(
                          child: Text(
                            userChat.content,
                            maxLines: 1,
                            style: const TextStyle(color: ColorConstants.primaryColor),
                          ),
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                        )
                      ],
                    ),
                    margin: const EdgeInsets.only(left: 20),
                  ),
                ),
              ],
            ),
            onPressed: () {
              if (Utilities.isKeyboardShowing()) {
                Utilities.closeKeyboard(context);
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    peerId: userChat.id,
                    peerAvatar: userChat.photoUrl,
                    peerNickname: userChat.nickname,
                    token: userChat.token,
                    isNavigate: 'chatHome',
                  ),
                ),
              );
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(ColorConstants.greyColor2),
              shape: MaterialStateProperty.all<OutlinedBorder>(
                const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
          ),
          margin: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }
}
