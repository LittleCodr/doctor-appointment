import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctro_patient/const/Palette.dart';
import 'package:doctro_patient/const/app_string.dart';
import 'package:doctro_patient/localization/localization_constant.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:doctro_patient/const/preference.dart';
import '../Screen/Screens/Home.dart';
import 'full_photo_page.dart';
import 'loading_view.dart';
import 'package:doctro_patient/FirebaseProviders/auth_provider.dart';
import 'package:doctro_patient/FirebaseProviders/chat_provider.dart';
import 'package:doctro_patient/FirebaseProviders/setting_provider.dart';
import 'package:doctro_patient/FirebaseModels/message_chat.dart';
import 'package:doctro_patient/const/prefConstatnt.dart';

class ChatPage extends StatefulWidget {
  final String peerId;
  final String peerAvatar;
  final String peerNickname;
  final String doctorToken;
  final String where;

  ChatPage({Key? key, required this.peerId, required this.peerAvatar, required this.peerNickname, required this.doctorToken, required this.where}) : super(key: key);

  @override
  State createState() => ChatPageState(
        peerId: peerId,
        peerAvatar: peerAvatar,
        peerNickname: peerNickname,
      );
}

class ChatPageState extends State<ChatPage> {
  ChatPageState({Key? key, required this.peerId, required this.peerAvatar, required this.peerNickname});

  String peerId;
  String peerAvatar;
  String peerNickname;
  late String currentUserId;
  late SettingProvider settingProvider;

  List<QueryDocumentSnapshot> listMessage = [];
  int _limit = 20;
  int _limitIncrement = 20;
  String groupChatId = "";

  File? imageFileCamera;
  File? imageFileGallery;
  bool isLoading = false;
  bool isShowSticker = false;
  String imageUrlCamera = "";
  String imageUrlGallery = "";

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  late ChatProvider chatProvider;
  late AuthProvider authProvider;

  @override
  void initState() {
    super.initState();
    chatProvider = context.read<ChatProvider>();
    authProvider = context.read<AuthProvider>();

    focusNode.addListener(onFocusChange);
    listScrollController.addListener(_scrollListener);
    readLocal();
  }

  _scrollListener() {
    if (listScrollController.offset >= listScrollController.position.maxScrollExtent && !listScrollController.position.outOfRange && _limit <= listMessage.length) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      setState(() {
        isShowSticker = false;
      });
    }
  }

  void readLocal() {
    if (authProvider.getUserFirebaseId()?.isNotEmpty == true) {
      currentUserId = authProvider.getUserFirebaseId()!;
    } else {}
    if (currentUserId.compareTo(peerId) > 0) {
      groupChatId = '$currentUserId-$peerId';
    } else {
      groupChatId = '$peerId-$currentUserId';
    }

    chatProvider.updateDataFirestore(
      FirestoreConstants.pathUserCollection,
      currentUserId,
      {FirestoreConstants.chattingWith: peerId},
    );
  }

  Future getImageFromGallery() async {
    ImagePicker imagePicker = ImagePicker();
    final pickedFile;

    pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageFileGallery = File(pickedFile.path);
      if (imageFileGallery != null) {
        setState(() {
          isLoading = true;
          uploadFileGallery();
        });
      }
    }
  }

  Future getImageFromCamera() async {
    ImagePicker imagePicker = ImagePicker();
    final pickedFile;

    pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      imageFileCamera = File(pickedFile.path);
      if (imageFileCamera != null) {
        setState(() {
          isLoading = true;
          uploadFileCamera();
        });
      }
    }
  }

  void getSticker() {
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
  }

  Future uploadFileCamera() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    UploadTask uploadTask = chatProvider.uploadFile(imageFileCamera!, fileName);
    try {
      TaskSnapshot snapshot = await uploadTask;
      imageUrlCamera = await snapshot.ref.getDownloadURL();
      setState(() {
        isLoading = false;
        onSendMessage(imageUrlCamera, TypeMessage.image);
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }

  Future uploadFileGallery() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    UploadTask uploadTask = chatProvider.uploadFile(imageFileGallery!, fileName);
    try {
      TaskSnapshot snapshot = await uploadTask;
      imageUrlGallery = await snapshot.ref.getDownloadURL();
      setState(() {
        isLoading = false;
        onSendMessage(imageUrlGallery, TypeMessage.image);
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }

  void onSendMessage(String content, int type) {
    if (content.trim().isNotEmpty) {
      textEditingController.clear();
      chatProvider.sendMessage(content, type, groupChatId, currentUserId, peerId);
      chatProvider.sendNotification(content, widget.doctorToken, SharedPreferenceHelper.getString(Preferences.name)!, currentUserId, type, peerNickname, peerAvatar);
      listScrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: getTranslated(context, AppString.nothing_to_send_toast).toString(), backgroundColor: Palette.dark_grey);
    }
  }

  Widget buildItem(int index, DocumentSnapshot? document) {
    if (document != null) {
      MessageChat messageChat = MessageChat.fromDocument(document);
      if (messageChat.idFrom == currentUserId) {
        return Row(
          children: <Widget>[
            messageChat.type == TypeMessage.text
                // Text
                ? Container(
                    child: Text(
                      messageChat.content,
                      style: const TextStyle(color: Palette.dark_blue),
                    ),
                    padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                    width: 200,
                    decoration: BoxDecoration(color: Palette.white, borderRadius: BorderRadius.circular(8)),
                    margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20 : 10, right: 10),
                  )
                : messageChat.type == TypeMessage.image

                    /// Image
                    ? Container(
                        child: OutlinedButton(
                          child: Material(
                            child: Image.network(
                              messageChat.content,
                              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  decoration: const BoxDecoration(
                                    color: Palette.white,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                  ),
                                  width: 200,
                                  height: 200,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Palette.blue,
                                      value: loadingProgress.expectedTotalBytes != null && loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, object, stackTrace) {
                                return Material(
                                  child: Image.asset(
                                    'images/img_not_available.jpeg',
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                );
                              },
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                            borderRadius: const BorderRadius.all(Radius.circular(8)),
                            clipBehavior: Clip.hardEdge,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullPhotoPage(
                                  url: messageChat.content,
                                ),
                              ),
                            );
                          },
                          style: ButtonStyle(padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(0))),
                        ),
                        margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20 : 10, right: 10),
                      )
                    : Container(
                        child: Image.asset(
                          'images/${messageChat.content}.gif',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20 : 10, right: 10),
                      ),
          ],
          mainAxisAlignment: MainAxisAlignment.end,
        );
      } else {
        /// Left (peer message)
        return Container(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  isLastMessageLeft(index)
                      ? Material(
                          child: Image.network(
                            peerAvatar,
                            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  color: Palette.blue,
                                  value: loadingProgress.expectedTotalBytes != null && loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                                ),
                              );
                            },
                            errorBuilder: (context, object, stackTrace) {
                              return const Icon(
                                Icons.account_circle,
                                size: 35,
                                color: Palette.dark_grey,
                              );
                            },
                            width: 35,
                            height: 35,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(18),
                          ),
                          clipBehavior: Clip.hardEdge,
                        )
                      : Container(width: 35),
                  messageChat.type == TypeMessage.text
                      ? Container(
                          child: Text(
                            messageChat.content,
                            style: const TextStyle(color: Palette.white),
                          ),
                          padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                          width: 200,
                          decoration: BoxDecoration(color: Palette.blue, borderRadius: BorderRadius.circular(8)),
                          margin: const EdgeInsets.only(left: 10),
                        )
                      : messageChat.type == TypeMessage.image
                          ? Container(
                              child: TextButton(
                                child: Material(
                                  child: Image.network(
                                    messageChat.content,
                                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        decoration: const BoxDecoration(
                                          color: Palette.dark_white,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8),
                                          ),
                                        ),
                                        width: 200,
                                        height: 200,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: Palette.blue,
                                            value: loadingProgress.expectedTotalBytes != null && loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, object, stackTrace) => Material(
                                      child: Image.asset(
                                        'images/img_not_available.jpeg',
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(8),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                    ),
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FullPhotoPage(url: messageChat.content),
                                    ),
                                  );
                                },
                                style: ButtonStyle(padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(0))),
                              ),
                              margin: const EdgeInsets.only(left: 10),
                            )
                          : Container(
                              child: Image.asset(
                                'images/${messageChat.content}.gif',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                              margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20 : 10, right: 10),
                            ),
                ],
              ),
              isLastMessageLeft(index)
                  ? Container(
                      child: Text(
                        DateFormat('dd MMM kk:mm').format(DateTime.fromMillisecondsSinceEpoch(int.parse(messageChat.timestamp))),
                        style: const TextStyle(color: Palette.dark_grey, fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                      margin: const EdgeInsets.only(left: 50, top: 5, bottom: 5),
                    )
                  : const SizedBox.shrink()
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
          margin: const EdgeInsets.only(bottom: 10),
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 && listMessage[index - 1].get(FirestoreConstants.idFrom) == currentUserId) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 && listMessage[index - 1].get(FirestoreConstants.idFrom) != currentUserId) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      chatProvider.updateDataFirestore(
        FirestoreConstants.pathUserCollection,
        currentUserId,
        {FirestoreConstants.chattingWith: null},
      );
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  Future<bool> onWillPop() {
    if (widget.where == "DoctorDetail") {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Home(),
        ),
      );
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              size: 20,
              color: Palette.dark_blue,
            ),
            onPressed: () {
              if (widget.where == "DoctorDetail") {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Home(),
                  ),
                );
              }
            },
          ),
          title: Text(
            peerNickname,
            style: const TextStyle(color: Palette.dark_blue),
          ),
          centerTitle: true,
          backgroundColor: Palette.white,
        ),
        body: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                /// List of messages
                buildListMessage(),

                /// Input content
                buildInput(),
              ],
            ),

            // Loading
            buildLoading()
          ],
        ),
      ),
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading ? LoadingView() : const SizedBox.shrink(),
    );
  }

  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          Material(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              child: IconButton(
                icon: const Icon(Icons.image),
                onPressed: () {
                  _modalBottomSheetMenu();
                },
                color: Palette.dark_blue,
              ),
            ),
            color: Palette.white,
          ),

          // Edit text
          Flexible(
            child: TextField(
              onSubmitted: (value) {
                onSendMessage(textEditingController.text, TypeMessage.text);
              },
              style: const TextStyle(color: Palette.dark_blue, fontSize: 15),
              controller: textEditingController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration.collapsed(
                hintText: getTranslated(context, AppString.type_yourMessage_hint).toString(),
                hintStyle: TextStyle(color: Palette.dark_grey),
              ),
              focusNode: focusNode,
            ),
          ),

          /// Button send message
          Material(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => onSendMessage(
                  textEditingController.text,
                  TypeMessage.text,
                ),
                color: Palette.dark_blue,
              ),
            ),
            color: Palette.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Palette.dark_white, width: 0.5),
          ),
          color: Palette.white),
    );
  }

  void _modalBottomSheetMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Palette.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            height: 150,
            width: 200,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Palette.white),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 5, 0, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      getImageFromCamera();
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.06,
                      color: Palette.white,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            getTranslated(context, AppString.fromCamera).toString(),
                            style: TextStyle(color: Palette.black, fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      getImageFromGallery();
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.06,
                      color: Palette.white,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            getTranslated(context, AppString.fromGallery).toString(),
                            style: TextStyle(color: Palette.black, fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: groupChatId.isNotEmpty
          ? StreamBuilder<QuerySnapshot>(
              stream: chatProvider.getChatStream(groupChatId, _limit),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  listMessage = snapshot.data!.docs;
                  if (listMessage.isNotEmpty) {
                    return ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemBuilder: (context, index) => buildItem(index, snapshot.data?.docs[index]),
                      itemCount: snapshot.data?.docs.length,
                      reverse: true,
                      controller: listScrollController,
                    );
                  } else {
                    return Center(
                      child: Text(
                        getTranslated(context, AppString.no_message_hereYet).toString(),
                      ),
                    );
                  }
                } else {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Palette.blue,
                    ),
                  );
                }
              },
            )
          : const Center(
              child: CircularProgressIndicator(
                color: Palette.blue,
              ),
            ),
    );
  }
}
