import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctro/chat/pages/chat_page.dart';
import 'package:doctro/chat/providers/auth_provider.dart' as provider;
import 'package:doctro/chat/providers/home_provider.dart';
import 'package:doctro/main.dart';
import 'package:doctro/retrofit/api_header.dart';
import 'package:doctro/retrofit/base_model.dart';
import 'package:doctro/retrofit/network_api.dart';
import 'package:doctro/constant/app_string.dart';
import 'package:doctro/constant/color_constant.dart';
import 'package:doctro/constant/common_function.dart';
import 'package:doctro/constant/prefConstatnt.dart';
import 'package:doctro/constant/preferences.dart';
import 'package:doctro/localization/localization_constant.dart';
import 'package:doctro/model/today_appointment.dart';
import 'package:doctro/retrofit/server_error.dart';
import 'package:doctro/screens/home%20page/patient_information.dart';
import 'package:doctro/screens/videoCall/PhoneScreen.dart';
import 'package:doctro/screens/auth/SignIn.dart';
import 'package:doctro/screens/subscription/Subscription.dart';
import 'package:doctro/screens/videoCall/video_Call.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:doctro/chat/constants/firestore_constants.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import '../../model/setting.dart';
class LoginHomeScreen extends StatefulWidget {
  final String? chat;

  LoginHomeScreen({
    this.chat,
  });

  @override
  _LoginHomeScreenState createState() => _LoginHomeScreenState();
}

class _LoginHomeScreenState extends State<LoginHomeScreen> {
  var appointment;

  //Set Loader
  Future? todayAppointment;
  Timer? timer;

  //Set Open Drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  //Set Preferences Data
  String? dName;
  String? dFullImage;
  int? isFilled;
  int? subscription;
  String? phone;

  late HomeProvider homeProvider;
  late provider.AuthProvider authProvider;

  String messageImage = '';
  String messageName = '';
  String messageId = '';
  String token = '';
  String userToken = '';

  //Search Data
  TextEditingController _search = TextEditingController();
  List<Today> _searchResult = [];
  List<Tomorrow> _tomorrowSearchResult = [];
  List<Upcoming> _upcomingSearchResult = [];

  List<String> _drawer = [];
  List<String> _drawerMenu = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    //Set Drawer Menu Item List
    _drawer = [
      getTranslated(context, AppString.drawer_home).toString(),
      getTranslated(context, AppString.drawer_payments).toString(),
      getTranslated(context, AppString.drawer_canceled_appointment).toString(),
      getTranslated(context, AppString.drawer_appointments).toString(),
      getTranslated(context, AppString.drawer_review).toString(),
      getTranslated(context, AppString.drawer_notification).toString(),
      getTranslated(context, AppString.drawer_callHistory).toString(),
      getTranslated(context, AppString.drawer_schedule_timing).toString(),
      getTranslated(context, AppString.drawer_setting).toString(),
      getTranslated(context, AppString.chats).toString(),
      getTranslated(context, AppString.drawer_logout).toString(),
    ];

    _drawerMenu = [
      getTranslated(context, AppString.drawer_home).toString(),
      getTranslated(context, AppString.drawer_payments).toString(),
      getTranslated(context, AppString.drawer_canceled_appointment).toString(),
      getTranslated(context, AppString.drawer_appointments).toString(),
      getTranslated(context, AppString.drawer_review).toString(),
      getTranslated(context, AppString.drawer_notification).toString(),
      getTranslated(context, AppString.drawer_callHistory).toString(),
      getTranslated(context, AppString.drawer_schedule_timing).toString(),
      getTranslated(context, AppString.drawer_setting).toString(),
      getTranslated(context, AppString.chats).toString(),
      getTranslated(context, AppString.drawer_logout).toString(),
    ];
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      settingRequest();
      await getOneSingleToken();
      todayAppointment = todayAppointmentsFunction();
      dName = SharedPreferenceHelper.getString(Preferences.name);
      dFullImage = SharedPreferenceHelper.getString(Preferences.image);
      isFilled = SharedPreferenceHelper.getInt(Preferences.is_filled);
      subscription = SharedPreferenceHelper.getInt(Preferences.subscription_status);
      phone = SharedPreferenceHelper.getString(Preferences.phone_no);
    });
    Future.delayed(Duration(seconds: 5), () {
      if (FirebaseAuth.instance.currentUser != null) {
        homeProvider.updateDataFirestore(FirestoreConstants.pathUserCollection, FirebaseAuth.instance.currentUser!.uid, {'pushToken': SharedPreferenceHelper.getString(Preferences.messageToken)});
      }
    });

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        Map<String, dynamic> dataValue = message.data;
        messageImage = dataValue['userImage'].toString();
        messageName = dataValue['userName'].toString();
        messageId = dataValue['userId'].toString();
        userToken = dataValue['userToken'].toString();

        if (widget.chat == "") {
          if (SharedPreferenceHelper.getString(Preferences.email).isNotEmpty) {
            Navigator.of(navigatorKey.currentContext!).pushReplacement(MaterialPageRoute(
                builder: (context) => ChatPage(
                      peerNickname: messageName,
                      peerAvatar: messageImage,
                      peerId: messageId,
                      token: userToken,
                      isNavigate: '',
                    )));
          } else {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignIn()));
          }
        }
      }
      Future.delayed(Duration(seconds: 5), () {
        if (FirebaseAuth.instance.currentUser != null) {
          homeProvider.updateDataFirestore(FirestoreConstants.pathUserCollection, FirebaseAuth.instance.currentUser!.uid, {'pushToken': SharedPreferenceHelper.getString(Preferences.messageToken)});
        }
      });
    });

    authProvider = Provider.of<provider.AuthProvider>(context, listen: false);
    homeProvider = Provider.of<HomeProvider>(context, listen: false);

    SharedPreferenceHelper.setBoolean(
        Preferences.notificationPermissionDialog, OneSignal.Notifications.permission == false ? true : false);
  }

  //Set Double Tap to exit value //
  DateTime? currentBackPressTime;

  //Set Double Tap exit //
  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null || now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(gravity: ToastGravity.BOTTOM, msg: getTranslated(context, AppString.tap_again_to_exit_app).toString());
      return Future.value(false);
    }
    return Future.value(true);
  }

  // Add List Data //
  List<Today> todayAppointments = [];
  List<Tomorrow> tomorrowAppointments = [];
  List<Upcoming> upcomingAppointments = [];

  bool todayView = false;
  bool tomorrowView = false;
  bool upcomingView = false;

  // Set MediaQuery Size //
  late double width;
  late double height;

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(
          child: Container(
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: DrawerHeader(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: new BoxDecoration(shape: BoxShape.circle, boxShadow: [
                            new BoxShadow(
                              color: imageBorder,
                              blurRadius: 1.0,
                            ),
                          ]),
                          child: CachedNetworkImage(
                            alignment: Alignment.center,
                            imageUrl: '$dFullImage',
                            imageBuilder: (context, imageProvider) => CircleAvatar(
                              radius: 50,
                              backgroundColor: colorWhite,
                              child: CircleAvatar(
                                radius: 35,
                                backgroundImage: imageProvider,
                              ),
                            ),
                            placeholder: (context, url) => CircularProgressIndicator(),
                            errorWidget: (context, url, error) => Image.asset("assets/images/no_image.jpg"),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 15),
                              width: width * 0.35,
                              child: Text(
                                '$dName',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(fontSize: 18, color: hintColor),
                              ),
                            ),
                            Text(
                              "$phone",
                              style: TextStyle(fontSize: 14, color: passwordVisibility),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.popAndPushNamed(context, "profile");
                          },
                          child: SvgPicture.asset(
                            'assets/icons/edit.svg',
                            height: height * 0.025,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 11,
                  child: subscription == -1
                      ? ListView.builder(
                          physics: AlwaysScrollableScrollPhysics(),
                          shrinkWrap: false,
                          scrollDirection: Axis.vertical,
                          itemCount: _drawerMenu.length,
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () {
                                if (_drawerMenu[index] == getTranslated(context, AppString.drawer_home).toString()) {
                                  Navigator.popAndPushNamed(context, "loginHome");
                                } else if (_drawerMenu[index] == getTranslated(context, AppString.drawer_payments).toString()) {
                                  Navigator.popAndPushNamed(context, 'payment');
                                } else if (_drawerMenu[index] == getTranslated(context, AppString.drawer_canceled_appointment).toString()) {
                                  Navigator.popAndPushNamed(context, 'cancelAppoitmentRoutes');
                                } else if (_drawerMenu[index] == getTranslated(context, AppString.drawer_appointments).toString()) {
                                  Navigator.popAndPushNamed(context, 'AppointmentHistoryScreen');
                                } else if (_drawerMenu[index] == getTranslated(context, AppString.drawer_review).toString()) {
                                  Navigator.popAndPushNamed(context, 'rateAndReviewRoutes');
                                } else if (_drawerMenu[index] == getTranslated(context, AppString.drawer_notification).toString()) {
                                  Navigator.popAndPushNamed(context, 'notifications');
                                } else if (_drawerMenu[index] == getTranslated(context, AppString.drawer_callHistory).toString()) {
                                  Navigator.popAndPushNamed(context, 'VideoCallHistory');
                                } else if (_drawerMenu[index] == getTranslated(context, AppString.drawer_schedule_timing).toString()) {
                                  Navigator.popAndPushNamed(context, 'Schedule Timings');
                                } else if (_drawerMenu[index] == getTranslated(context, AppString.drawer_setting).toString()) {
                                  Navigator.popAndPushNamed(context, 'Settings');
                                } else if (_drawer[index] == getTranslated(context, AppString.chats).toString()) {
                                  Navigator.popAndPushNamed(context, 'ChatHome');
                                } else if (_drawerMenu[index] == getTranslated(context, AppString.drawer_logout).toString()) {
                                  showAlertDialog(context);
                                }
                              },
                              title: Text(
                                _drawerMenu[index],
                                style: TextStyle(color: hintColor),
                              ),
                            );
                          },
                        )
                      : ListView.builder(
                          physics: AlwaysScrollableScrollPhysics(),
                          shrinkWrap: false,
                          scrollDirection: Axis.vertical,
                          itemCount: _drawer.length,
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () {
                                if (_drawer[index] == getTranslated(context, AppString.drawer_home).toString()) {
                                  Navigator.popAndPushNamed(context, "loginHome");
                                } else if (_drawer[index] == getTranslated(context, AppString.drawer_payments).toString()) {
                                  Navigator.popAndPushNamed(context, 'payment');
                                } else if (_drawer[index] == getTranslated(context, AppString.drawer_canceled_appointment).toString()) {
                                  Navigator.popAndPushNamed(context, 'cancelAppoitmentRoutes');
                                } else if (_drawer[index] == getTranslated(context, AppString.drawer_appointments).toString()) {
                                  Navigator.popAndPushNamed(context, 'AppointmentHistoryScreen');
                                } else if (_drawer[index] == getTranslated(context, AppString.drawer_review).toString()) {
                                  Navigator.popAndPushNamed(context, 'rateAndReviewRoutes');
                                } else if (_drawer[index] == getTranslated(context, AppString.drawer_notification).toString()) {
                                  Navigator.popAndPushNamed(context, 'notifications');
                                } else if (_drawer[index] == getTranslated(context, AppString.drawer_callHistory).toString()) {
                                  Navigator.popAndPushNamed(context, 'VideoCallHistory');
                                } else if (_drawer[index] == getTranslated(context, AppString.drawer_schedule_timing).toString()) {
                                  Navigator.popAndPushNamed(context, 'Schedule Timings');
                                } else if (_drawer[index] == getTranslated(context, AppString.drawer_setting).toString()) {
                                  Navigator.popAndPushNamed(context, 'Settings');
                                } else if (_drawer[index] == getTranslated(context, AppString.chats).toString()) {
                                  Navigator.popAndPushNamed(context, 'ChatHome');
                                } else if (_drawer[index] == getTranslated(context, AppString.drawer_logout).toString()) {
                                  showAlertDialog(context);
                                }
                              },
                              title: Text(
                                _drawer[index],
                                style: TextStyle(color: hintColor),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
        appBar: PreferredSize(
            preferredSize: Size(20, 160),
            child: SafeArea(
                top: true,
                child: Column(children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: width * 0.06, right: width * 0.04, top: height * 0.01),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              child: Text(getTranslated(context, AppString.upcoming_title).toString(), style: TextStyle(fontSize: 18, color: hintColor)),
                            ),
                            Container(
                              margin: EdgeInsets.only(),
                              child: IconButton(
                                onPressed: () {
                                  _scaffoldKey.currentState!.openDrawer();
                                },
                                icon: SvgPicture.asset(
                                  "assets/icons/dMenuBar.svg",
                                  height: 16.0,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(top: height * 0.01),
                    padding: EdgeInsets.all(10),
                    child: Card(
                      color: colorWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Container(
                          height: height * 0.06,
                          alignment: AlignmentDirectional.center,
                          margin: EdgeInsets.only(left: width * 0.05, right: width * 0.05),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height: height * 0.07,
                                width: width * 0.6,
                                child: TextField(
                                  controller: _search,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: getTranslated(context, AppString.home_search_hint).toString(),
                                    hintStyle: TextStyle(
                                      fontSize: width * 0.045,
                                      color: hintColor.withOpacity(0.3),
                                    ),
                                  ),
                                  onChanged: onSearchTextChanged,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Container(
                                child: SvgPicture.asset(
                                  'assets/icons/dSearch.svg',
                                  height: 20,
                                ),
                              ),
                            ],
                          )),
                    ),
                  ),
                ]))),
        body: RefreshIndicator(
          onRefresh: todayAppointmentsFunction,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            child: FutureBuilder(
                future: todayAppointment,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        FocusScope.of(context).requestFocus(new FocusNode());
                      },
                      child: subscription == 0
                          ? dialog()
                          : Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  isFilled == 0
                                      ? GestureDetector(
                                          onTap: () => Navigator.pushNamed(context, "profile"),
                                          child: Container(
                                              width: width * 1.0,
                                              color: tabBar.withOpacity(0.8),
                                              margin: EdgeInsets.only(left: width * 0.06, right: width * 0.06, bottom: height * 0.02),
                                              child: Column(children: [
                                                Row(children: [
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                      left: width * 0.02,
                                                    ),
                                                    child: Icon(
                                                      Icons.warning,
                                                      size: 28,
                                                      color: purple,
                                                    ),
                                                  ),
                                                  Container(margin: EdgeInsets.only(left: width * 0.02), child: Text(getTranslated(context, AppString.home_please_update_profile).toString(), style: TextStyle(fontSize: 16, color: purple))),
                                                  Container(margin: EdgeInsets.only(left: width * 0.03), child: Text(getTranslated(context, AppString.home_click_here).toString(), style: TextStyle(fontSize: 16, color: purple)))
                                                ])
                                              ])))
                                      : Container(),
                                  todayAppointments.length < 1 && tomorrowAppointments.length < 1 && upcomingAppointments.length < 1
                                      ? Container(
                                          child: Container(height: height * 0.6, child: Image.asset("assets/images/no-data.png")),
                                        )
                                      : Column(
                                          children: [
                                            todayAppointments.length > 0
                                                ? Container(
                                                    color: tabBar,
                                                    width: width * 1.0,
                                                    child: Container(
                                                      height: height * 0.05,
                                                      margin: EdgeInsets.only(left: width * 0.06, right: width * 0.08),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            getTranslated(context, AppString.home_title).toString(),
                                                            style: TextStyle(fontSize: 18, color: hintColor),
                                                          ),
                                                          Text(
                                                            getTranslated(context, AppString.payment_total).toString() + " ${todayAppointments.length}",
                                                            style: TextStyle(fontSize: width * 0.030, color: passwordVisibility),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : Container(),
                                            _search.text.isNotEmpty
                                                ? _searchResult.length > 0
                                                    ? ListView.builder(
                                                        shrinkWrap: true,
                                                        physics: NeverScrollableScrollPhysics(),
                                                        itemCount: _searchResult.length,
                                                        itemBuilder: (context, index) {
                                                          return Column(
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Container(
                                                                    margin: EdgeInsets.only(left: width * 0.06, right: width * 0.02),
                                                                    child: Text(
                                                                      _searchResult[index].time!,
                                                                      style: TextStyle(fontSize: 16, color: passwordVisibility),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    child: Container(
                                                                        margin: EdgeInsets.only(left: width * 0.02, right: width * 0.02),
                                                                        height: 100,
                                                                        width: width * 0.70,
                                                                        child: GestureDetector(
                                                                          onTap: () {
                                                                            Navigator.push(context, MaterialPageRoute(builder: (context) => patientDetailsScreen(id: _searchResult[index].id)));
                                                                          },
                                                                          child: Card(
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(15.0),
                                                                              ),
                                                                              child: Column(children: <Widget>[
                                                                                Container(
                                                                                  child: ListTile(
                                                                                    isThreeLine: true,
                                                                                    leading: SizedBox(
                                                                                      height: height * 0.20,
                                                                                      width: width * 0.15,
                                                                                      child: ClipRRect(
                                                                                        borderRadius: BorderRadius.circular(10),
                                                                                        child: Container(decoration: new BoxDecoration(image: new DecorationImage(fit: BoxFit.fitHeight, image: NetworkImage(_searchResult[index].user!.fullImage!)))),
                                                                                      ),
                                                                                    ),
                                                                                    title: Container(
                                                                                      alignment: AlignmentDirectional.topStart,
                                                                                      margin: EdgeInsets.only(
                                                                                        top: height * 0.01,
                                                                                      ),
                                                                                      child: Text(
                                                                                        _searchResult[index].patientName!,
                                                                                        style: TextStyle(fontSize: 16.0),
                                                                                        overflow: TextOverflow.ellipsis,
                                                                                        maxLines: 1,
                                                                                      ),
                                                                                    ),
                                                                                    trailing: Container(
                                                                                        child: Text(
                                                                                      SharedPreferenceHelper.getString(Preferences.currency_symbol) + _searchResult[index].amount.toString(),
                                                                                      style: TextStyle(fontSize: 16, color: hintColor),
                                                                                    )),
                                                                                    subtitle: Column(
                                                                                      children: <Widget>[
                                                                                        Container(
                                                                                            alignment: AlignmentDirectional.topStart,
                                                                                            child: Text(
                                                                                              getTranslated(context, AppString.home_age_data).toString() + " : " + _searchResult[index].age.toString(),
                                                                                              style: TextStyle(fontSize: 12, color: hintColor),
                                                                                            )),
                                                                                        if (_searchResult[index].hospital!.name != null)
                                                                                          Container(
                                                                                            alignment: AlignmentDirectional.topStart,
                                                                                            child: Text(
                                                                                              getTranslated(context, AppString.hospital_title).toString() + _searchResult[index].hospital!.name!,
                                                                                              style: TextStyle(fontSize: 12, color: passwordVisibility),
                                                                                              overflow: TextOverflow.ellipsis,
                                                                                              maxLines: 2,
                                                                                            ),
                                                                                          ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                              ])),
                                                                        )),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      )
                                                    : SizedBox()
                                                : ListView.builder(
                                                    physics: NeverScrollableScrollPhysics(),
                                                    shrinkWrap: true,
                                                    scrollDirection: Axis.vertical,
                                                    itemCount: todayView == false && todayAppointments.length > 3 ? 3 : todayAppointments.length,
                                                    itemBuilder: (context, index) {
                                                      return Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Container(
                                                                margin: EdgeInsets.only(left: width * 0.06, right: width * 0.02),
                                                                child: Text(
                                                                  todayAppointments[index].time!,
                                                                  style: TextStyle(fontSize: 16, color: passwordVisibility),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Container(
                                                                    margin: EdgeInsets.only(left: width * 0.02, right: width * 0.02),
                                                                    height: 100,
                                                                    width: width * 0.70,
                                                                    child: GestureDetector(
                                                                      onTap: () {
                                                                        Navigator.push(context, MaterialPageRoute(builder: (context) => patientDetailsScreen(id: todayAppointments[index].id)));
                                                                      },
                                                                      child: Card(
                                                                          shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.circular(15.0),
                                                                          ),
                                                                          child: Column(children: <Widget>[
                                                                            Container(
                                                                              child: ListTile(
                                                                                isThreeLine: true,
                                                                                leading: SizedBox(
                                                                                  height: height * 0.20,
                                                                                  width: width * 0.15,
                                                                                  child: ClipRRect(
                                                                                    borderRadius: BorderRadius.circular(10),
                                                                                    child: Container(decoration: new BoxDecoration(image: new DecorationImage(fit: BoxFit.fitHeight, image: NetworkImage(todayAppointments[index].user!.fullImage!)))),
                                                                                  ),
                                                                                ),
                                                                                title: Container(
                                                                                  alignment: AlignmentDirectional.topStart,
                                                                                  margin: EdgeInsets.only(top: height * 0.01),
                                                                                  child: Text(todayAppointments[index].patientName!, style: TextStyle(fontSize: 16.0), overflow: TextOverflow.ellipsis),
                                                                                ),
                                                                                trailing:
                                                                                    SharedPreferenceHelper.getString(
                                                                                                Preferences
                                                                                                    .currency_symbol) !=
                                                                                            "N_A"
                                                                                    ? Text(
                                                                                        SharedPreferenceHelper.getString(Preferences.currency_symbol) + todayAppointments[index].amount.toString(),
                                                                                        style: TextStyle(fontSize: 16, color: hintColor),
                                                                                      )
                                                                                    : Text(
                                                                                        todayAppointments[index].amount.toString(),
                                                                                        style: TextStyle(fontSize: 16, color: hintColor),
                                                                                      ),
                                                                                subtitle: Column(
                                                                                  children: <Widget>[
                                                                                    Container(
                                                                                        alignment: AlignmentDirectional.topStart,
                                                                                        child: Text(
                                                                                          getTranslated(context, AppString.home_age_data).toString() + " : " + todayAppointments[index].age.toString(),
                                                                                          style: TextStyle(fontSize: 12, color: hintColor),
                                                                                          overflow: TextOverflow.ellipsis,
                                                                                        )),
                                                                                    if (todayAppointments[index].hospital!.name != null)
                                                                                      Container(
                                                                                        alignment: AlignmentDirectional.topStart,
                                                                                        child: Text(
                                                                                          getTranslated(context, AppString.hospital_title).toString() + ' ' + todayAppointments[index].hospital!.name!,
                                                                                          style: TextStyle(fontSize: 12, color: passwordVisibility),
                                                                                          overflow: TextOverflow.ellipsis,
                                                                                          maxLines: 2,
                                                                                        ),
                                                                                      ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            )
                                                                          ])),
                                                                    )),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                            SizedBox(height: 10),
                                            todayAppointments.length <= 3
                                                ? Container()
                                                : Visibility(
                                                    visible: todayView == true ? false : true,
                                                    child: GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            todayView = true;
                                                          });
                                                        },
                                                        child: Text(getTranslated(context, AppString.view_more).toString())),
                                                  ),
                                            SizedBox(height: 10),
                                            tomorrowAppointments.length > 0
                                                ? Container(
                                                    color: tabBar,
                                                    width: width * 1.0,
                                                    child: Container(
                                                      height: height * 0.05,
                                                      margin: EdgeInsets.only(left: width * 0.06, right: width * 0.08),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            getTranslated(context, AppString.tomorrow_appointment).toString(),
                                                            style: TextStyle(fontSize: 18, color: hintColor),
                                                          ),
                                                          Text(
                                                            getTranslated(context, AppString.payment_total).toString() + " ${tomorrowAppointments.length}",
                                                            style: TextStyle(fontSize: width * 0.030, color: passwordVisibility),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : Container(),
                                            _search.text.isNotEmpty
                                                ? _tomorrowSearchResult.length > 0
                                                    ? ListView.builder(
                                                        shrinkWrap: true,
                                                        physics: NeverScrollableScrollPhysics(),
                                                        itemCount: _tomorrowSearchResult.length,
                                                        itemBuilder: (context, i) {
                                                          return Column(
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Container(
                                                                    margin: EdgeInsets.only(left: width * 0.06, right: width * 0.02),
                                                                    child: Text(
                                                                      _tomorrowSearchResult[i].time!,
                                                                      style: TextStyle(fontSize: 16, color: passwordVisibility),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    child: Container(
                                                                        margin: EdgeInsets.only(left: width * 0.02, right: width * 0.02),
                                                                        height: 100,
                                                                        width: width * 0.70,
                                                                        child: GestureDetector(
                                                                          onTap: () {
                                                                            Navigator.push(context, MaterialPageRoute(builder: (context) => patientDetailsScreen(id: _tomorrowSearchResult[i].id)));
                                                                          },
                                                                          child: Card(
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(15.0),
                                                                              ),
                                                                              child: Column(children: <Widget>[
                                                                                Container(
                                                                                  child: ListTile(
                                                                                    isThreeLine: true,
                                                                                    leading: SizedBox(
                                                                                      height: height * 0.20,
                                                                                      width: width * 0.15,
                                                                                      child: ClipRRect(
                                                                                        borderRadius: BorderRadius.circular(10),
                                                                                        child:
                                                                                            Container(decoration: new BoxDecoration(image: new DecorationImage(fit: BoxFit.fitHeight, image: NetworkImage(_tomorrowSearchResult[i].user!.fullImage!)))),
                                                                                      ),
                                                                                    ),
                                                                                    title: Container(
                                                                                      alignment: AlignmentDirectional.topStart,
                                                                                      margin: EdgeInsets.only(
                                                                                        top: height * 0.01,
                                                                                      ),
                                                                                      child: Text(
                                                                                        _tomorrowSearchResult[i].patientName!,
                                                                                        style: TextStyle(fontSize: 16.0),
                                                                                        overflow: TextOverflow.ellipsis,
                                                                                        maxLines: 1,
                                                                                      ),
                                                                                    ),
                                                                                    trailing: Container(
                                                                                        child: Text(
                                                                                      SharedPreferenceHelper.getString(Preferences.currency_symbol) + _tomorrowSearchResult[i].amount.toString(),
                                                                                      style: TextStyle(fontSize: 16, color: hintColor),
                                                                                    )),
                                                                                    subtitle: Column(
                                                                                      children: <Widget>[
                                                                                        Container(
                                                                                            alignment: AlignmentDirectional.topStart,
                                                                                            child: Text(
                                                                                              getTranslated(context, AppString.home_age_data).toString() + " : " + _tomorrowSearchResult[i].age.toString(),
                                                                                              style: TextStyle(fontSize: 12, color: hintColor),
                                                                                            )),
                                                                                        if (_tomorrowSearchResult[i].hospital!.name != null)
                                                                                          Container(
                                                                                            alignment: AlignmentDirectional.topStart,
                                                                                            child: Text(
                                                                                              getTranslated(context, AppString.hospital_title).toString() + _tomorrowSearchResult[i].hospital!.name!,
                                                                                              style: TextStyle(fontSize: 12, color: passwordVisibility),
                                                                                              overflow: TextOverflow.ellipsis,
                                                                                              maxLines: 2,
                                                                                            ),
                                                                                          ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                              ])),
                                                                        )),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      )
                                                    : SizedBox()
                                                : ListView.builder(
                                                    physics: NeverScrollableScrollPhysics(),
                                                    shrinkWrap: true,
                                                    scrollDirection: Axis.vertical,
                                                    itemCount: tomorrowView == false && tomorrowAppointments.length > 3 ? 3 : tomorrowAppointments.length,
                                                    itemBuilder: (context, index) {
                                                      return Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Container(
                                                                margin: EdgeInsets.only(left: width * 0.06, right: width * 0.02),
                                                                child: Text(
                                                                  tomorrowAppointments[index].time!,
                                                                  style: TextStyle(fontSize: 16, color: passwordVisibility),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Container(
                                                                    margin: EdgeInsets.only(left: width * 0.02, right: width * 0.02),
                                                                    height: 100,
                                                                    width: width * 0.70,
                                                                    child: GestureDetector(
                                                                      onTap: () {
                                                                        Navigator.push(context, MaterialPageRoute(builder: (context) => patientDetailsScreen(id: tomorrowAppointments[index].id)));
                                                                      },
                                                                      child: Card(
                                                                          shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.circular(15.0),
                                                                          ),
                                                                          child: Column(children: <Widget>[
                                                                            Container(
                                                                              child: ListTile(
                                                                                isThreeLine: true,
                                                                                leading: SizedBox(
                                                                                  height: height * 0.20,
                                                                                  width: width * 0.15,
                                                                                  child: ClipRRect(
                                                                                    borderRadius: BorderRadius.circular(10),
                                                                                    child: Container(decoration: new BoxDecoration(image: new DecorationImage(fit: BoxFit.fitHeight, image: NetworkImage(tomorrowAppointments[index].user!.fullImage!)))),
                                                                                  ),
                                                                                ),
                                                                                title: Container(
                                                                                  alignment: AlignmentDirectional.topStart,
                                                                                  margin: EdgeInsets.only(top: height * 0.01),
                                                                                  child: Text(tomorrowAppointments[index].patientName!, style: TextStyle(fontSize: 16.0), overflow: TextOverflow.ellipsis),
                                                                                ),
                                                                                trailing: SharedPreferenceHelper
                                                                                            .getString(Preferences
                                                                                                .currency_symbol) !=
                                                                                        "N_A"
                                                                                    ? Text(
                                                                                        SharedPreferenceHelper.getString(Preferences.currency_symbol) + tomorrowAppointments[index].amount.toString(),
                                                                                        style: TextStyle(fontSize: 16, color: hintColor),
                                                                                      )
                                                                                    : Text(
                                                                                        tomorrowAppointments[index].amount.toString(),
                                                                                        style: TextStyle(fontSize: 16, color: hintColor),
                                                                                      ),
                                                                                subtitle: Column(
                                                                                  children: <Widget>[
                                                                                    Container(
                                                                                        alignment: AlignmentDirectional.topStart,
                                                                                        child: Text(
                                                                                          getTranslated(context, AppString.home_age_data).toString() + " : " + tomorrowAppointments[index].age.toString(),
                                                                                          style: TextStyle(fontSize: 12, color: hintColor),
                                                                                          overflow: TextOverflow.ellipsis,
                                                                                        )),
                                                                                    if (tomorrowAppointments[index].hospital!.name != null)
                                                                                      Container(
                                                                                        alignment: AlignmentDirectional.topStart,
                                                                                        child: Text(
                                                                                          getTranslated(context, AppString.hospital_title).toString() + ' ' + tomorrowAppointments[index].hospital!.name!,
                                                                                          style: TextStyle(fontSize: 12, color: passwordVisibility),
                                                                                          overflow: TextOverflow.ellipsis,
                                                                                          maxLines: 2,
                                                                                        ),
                                                                                      ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            )
                                                                          ])),
                                                                    )),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                            SizedBox(height: 10),
                                            tomorrowAppointments.length <= 3
                                                ? Container()
                                                : Visibility(
                                                    visible: tomorrowView == true ? false : true,
                                                    child: GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            tomorrowView = true;
                                                          });
                                                        },
                                                        child: Text(getTranslated(context, AppString.view_more).toString())),
                                                  ),
                                            SizedBox(height: 10),
                                            upcomingAppointments.length > 0
                                                ? Container(
                                                    color: tabBar,
                                                    width: width * 1.0,
                                                    child: Container(
                                                      height: height * 0.05,
                                                      margin: EdgeInsets.only(left: width * 0.06, right: width * 0.08),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            getTranslated(context, AppString.up_coming_appointment).toString(),
                                                            style: TextStyle(fontSize: 18, color: hintColor),
                                                          ),
                                                          Text(
                                                            getTranslated(context, AppString.payment_total).toString() + " ${upcomingAppointments.length}",
                                                            style: TextStyle(fontSize: width * 0.030, color: passwordVisibility),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : Container(),
                                            SizedBox(height: 10),
                                            _search.text.isNotEmpty
                                                ? _upcomingSearchResult.length > 0
                                                    ? ListView.builder(
                                                        shrinkWrap: true,
                                                        physics: NeverScrollableScrollPhysics(),
                                                        itemCount: _upcomingSearchResult.length,
                                                        itemBuilder: (context, i) {
                                                          return Column(
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Container(
                                                                    margin: EdgeInsets.only(left: width * 0.06, right: width * 0.02),
                                                                    child: Text(
                                                                      _upcomingSearchResult[i].time!,
                                                                      style: TextStyle(fontSize: 16, color: passwordVisibility),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    child: Container(
                                                                        margin: EdgeInsets.only(left: width * 0.02, right: width * 0.02),
                                                                        height: 100,
                                                                        width: width * 0.70,
                                                                        child: GestureDetector(
                                                                          onTap: () {
                                                                            Navigator.push(context, MaterialPageRoute(builder: (context) => patientDetailsScreen(id: _upcomingSearchResult[i].id)));
                                                                          },
                                                                          child: Card(
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(15.0),
                                                                              ),
                                                                              child: Column(children: <Widget>[
                                                                                Container(
                                                                                  child: ListTile(
                                                                                    isThreeLine: true,
                                                                                    leading: SizedBox(
                                                                                      height: height * 0.20,
                                                                                      width: width * 0.15,
                                                                                      child: ClipRRect(
                                                                                        borderRadius: BorderRadius.circular(10),
                                                                                        child:
                                                                                            Container(decoration: new BoxDecoration(image: new DecorationImage(fit: BoxFit.fitHeight, image: NetworkImage(_upcomingSearchResult[i].user!.fullImage!)))),
                                                                                      ),
                                                                                    ),
                                                                                    title: Container(
                                                                                      alignment: AlignmentDirectional.topStart,
                                                                                      margin: EdgeInsets.only(
                                                                                        top: height * 0.01,
                                                                                      ),
                                                                                      child: Text(
                                                                                        _upcomingSearchResult[i].patientName!,
                                                                                        style: TextStyle(fontSize: 16.0),
                                                                                        overflow: TextOverflow.ellipsis,
                                                                                        maxLines: 1,
                                                                                      ),
                                                                                    ),
                                                                                    trailing: Container(
                                                                                        child: Text(
                                                                                      SharedPreferenceHelper.getString(Preferences.currency_symbol) + _upcomingSearchResult[i].amount.toString(),
                                                                                      style: TextStyle(fontSize: 16, color: hintColor),
                                                                                    )),
                                                                                    subtitle: Column(
                                                                                      children: <Widget>[
                                                                                        Container(
                                                                                            alignment: AlignmentDirectional.topStart,
                                                                                            child: Text(
                                                                                              getTranslated(context, AppString.home_age_data).toString() + " : " + _upcomingSearchResult[i].age.toString(),
                                                                                              style: TextStyle(fontSize: 12, color: hintColor),
                                                                                            )),
                                                                                        if (_upcomingSearchResult[i].hospital!.name != null)
                                                                                          Container(
                                                                                            alignment: AlignmentDirectional.topStart,
                                                                                            child: Text(
                                                                                              getTranslated(context, AppString.hospital_title).toString() + _upcomingSearchResult[i].hospital!.name!,
                                                                                              style: TextStyle(fontSize: 12, color: passwordVisibility),
                                                                                              overflow: TextOverflow.ellipsis,
                                                                                              maxLines: 2,
                                                                                            ),
                                                                                          ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                              ])),
                                                                        )),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      )
                                                    : SizedBox()
                                                : ListView.builder(
                                                    physics: NeverScrollableScrollPhysics(),
                                                    shrinkWrap: true,
                                                    scrollDirection: Axis.vertical,
                                                    itemCount: upcomingView == false && upcomingAppointments.length > 3 ? 3 : upcomingAppointments.length,
                                                    itemBuilder: (context, index) {
                                                      return Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Column(
                                                                children: [
                                                                  Container(
                                                                    margin: EdgeInsets.only(left: width * 0.06, right: width * 0.02),
                                                                    child: Text(
                                                                      DateFormat.MMMd().format(DateTime.parse(upcomingAppointments[index].date!)),
                                                                      style: TextStyle(fontSize: 16, color: passwordVisibility),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    margin: EdgeInsets.only(left: width * 0.06, right: width * 0.02),
                                                                    child: Text(
                                                                      upcomingAppointments[index].time!,
                                                                      style: TextStyle(fontSize: 16, color: passwordVisibility),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              Expanded(
                                                                child: Container(
                                                                    margin: EdgeInsets.only(left: width * 0.02, right: width * 0.02),
                                                                    height: 100,
                                                                    width: width * 0.70,
                                                                    child: GestureDetector(
                                                                      onTap: () {
                                                                        Navigator.push(context, MaterialPageRoute(builder: (context) => patientDetailsScreen(id: upcomingAppointments[index].id)));
                                                                      },
                                                                      child: Card(
                                                                          shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.circular(15.0),
                                                                          ),
                                                                          child: Column(children: <Widget>[
                                                                            Container(
                                                                              child: ListTile(
                                                                                isThreeLine: true,
                                                                                leading: SizedBox(
                                                                                  height: height * 0.20,
                                                                                  width: width * 0.15,
                                                                                  child: ClipRRect(
                                                                                    borderRadius: BorderRadius.circular(10),
                                                                                    child: Container(decoration: new BoxDecoration(image: new DecorationImage(fit: BoxFit.fitHeight, image: NetworkImage(upcomingAppointments[index].user!.fullImage!)))),
                                                                                  ),
                                                                                ),
                                                                                title: Container(
                                                                                  alignment: AlignmentDirectional.topStart,
                                                                                  margin: EdgeInsets.only(top: height * 0.01),
                                                                                  child: Text(upcomingAppointments[index].patientName!, style: TextStyle(fontSize: 16.0), overflow: TextOverflow.ellipsis),
                                                                                ),
                                                                                trailing: SharedPreferenceHelper
                                                                                            .getString(Preferences
                                                                                                .currency_symbol) !=
                                                                                        "N_A"
                                                                                    ? Text(
                                                                                        SharedPreferenceHelper.getString(Preferences.currency_symbol) + upcomingAppointments[index].amount.toString(),
                                                                                        style: TextStyle(fontSize: 16, color: hintColor),
                                                                                      )
                                                                                    : Text(
                                                                                        upcomingAppointments[index].amount.toString(),
                                                                                        style: TextStyle(fontSize: 16, color: hintColor),
                                                                                      ),
                                                                                subtitle: Column(
                                                                                  children: <Widget>[
                                                                                    Container(
                                                                                        alignment: AlignmentDirectional.topStart,
                                                                                        child: Text(
                                                                                          getTranslated(context, AppString.home_age_data).toString() + " : " + upcomingAppointments[index].age.toString(),
                                                                                          style: TextStyle(fontSize: 12, color: hintColor),
                                                                                          overflow: TextOverflow.ellipsis,
                                                                                        )),
                                                                                    if (upcomingAppointments[index].hospital!.name != null)
                                                                                      Container(
                                                                                        alignment: AlignmentDirectional.topStart,
                                                                                        child: Text(
                                                                                          getTranslated(context, AppString.hospital_title).toString() + ' ' + upcomingAppointments[index].hospital!.name!,
                                                                                          style: TextStyle(fontSize: 12, color: passwordVisibility),
                                                                                          overflow: TextOverflow.ellipsis,
                                                                                          maxLines: 2,
                                                                                        ),
                                                                                      ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            )
                                                                          ])),
                                                                    )),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                            SizedBox(height: 10),
                                            upcomingAppointments.length <= 3
                                                ? Container()
                                                : Visibility(
                                                    visible: upcomingView == true ? false : true,
                                                    child: GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            upcomingView = true;
                                                          });
                                                        },
                                                        child: Text(getTranslated(context, AppString.view_more).toString())),
                                                  ),
                                            SizedBox(height: 10),
                                          ],
                                        ),
                                ],
                              ),
                            ),
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
          ),
        ),
      ),
    );
  }

  Future<BaseModel<TodayAppointment>> todayAppointmentsFunction() async {
    TodayAppointment response;

    try {
      todayAppointments.clear();
      tomorrowAppointments.clear();
      upcomingAppointments.clear();

      response = await RestClient(RetroApi().dioData()).todayAppointments();

      setState(() {
        if (response.data!.today!.isNotEmpty) {
          response.data!.today!.sort((a, b) =>
              DateFormat("yyyy-MM-dd h:mm a").parse(DateTime.now().toString().split(" ")[0] + " " + a.time!.toUpperCase()).compareTo(DateFormat("yyyy-MM-dd h:mm a").parse(DateTime.now().toString().split(" ")[0] + " " + b.time!.toUpperCase())));
          todayAppointments.addAll(response.data!.today!);
        }

        if (response.data!.tomorrow!.isNotEmpty) {
          response.data!.tomorrow!.sort((a, b) =>
              DateFormat("yyyy-MM-dd h:mm a").parse(DateTime.now().toString().split(" ")[0] + " " + a.time!.toUpperCase()).compareTo(DateFormat("yyyy-MM-dd h:mm a").parse(DateTime.now().toString().split(" ")[0] + " " + b.time!.toUpperCase())));
          tomorrowAppointments.addAll(response.data!.tomorrow!);
        }

        if (response.data!.upcoming!.isNotEmpty) {
          response.data!.upcoming!.sort((a, b) =>
              DateFormat("yyyy-MM-dd h:mm a").parse(DateTime.now().toString().split(" ")[0] + " " + a.time!.toUpperCase()).compareTo(DateFormat("yyyy-MM-dd h:mm a").parse(DateTime.now().toString().split(" ")[0] + " " + b.time!.toUpperCase())));
          upcomingAppointments.addAll(response.data!.upcoming!);
        }
      });
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<void> logoutUser() async {
    SharedPreferenceHelper.clearPref();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (BuildContext context) => SignIn()),
      ModalRoute.withName('SignIn'),
    );
  }

  Widget dialog() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: width * 0.1),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(1.0),
        borderRadius: BorderRadius.circular(40),
      ),
      width: width * 0.8,
      child: Container(
        height: 280,
        child: Align(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: width * 0.15,
                child: SizedBox.expand(
                  child: Image.asset(
                    'assets/images/alert.png',
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                  child: Text(
                getTranslated(context, AppString.home_subscription_deActive).toString(),
                style: TextStyle(fontSize: 20, color: hintColor, decoration: TextDecoration.none),
                textAlign: TextAlign.center,
              )),
              GestureDetector(
                onTap: () {
                  SubSubscription();
                },
                child: Container(
                    margin: EdgeInsets.only(top: height * 0.02),
                    child: Text(
                      getTranslated(context, AppString.home_please_active_plan).toString(),
                      style: TextStyle(fontSize: 14, color: darkGrey, decoration: TextDecoration.none),
                      textAlign: TextAlign.center,
                    )),
              ),
              SizedBox(
                height: 10,
              ),
              Container(margin: EdgeInsets.only(left: 12, right: 12), child: ElevatedButton(onPressed: () => Navigator.pushReplacementNamed(context, "subscription"), child: Text(getTranslated(context, AppString.home_activate_subscription).toString())))
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getOneSingleToken() async {
    try {
      OneSignal.Notifications.addClickListener((event) async {
        if (event.result.actionId == "") {
        } else if (event.result.actionId == "decline") {
          setState(() {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoCall(
                  callEnd: true,
                  id: event.notification.additionalData!["id"],
                ),
              ),
            );
          });

          setState(() {});
        } else if (event.result.actionId == "accept") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoCall(
                callEnd: false,
                id: event.notification.additionalData!["id"],
              ),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PhoneScreen(event.notification.additionalData)),
          );
        }
      });
    } catch (error) {
      print(error);
    }
  }

  showAlertDialog(BuildContext context) {
    Widget cancel = TextButton(
      child: Text(
        getTranslated(context, AppString.cancel_button).toString(),
        style: TextStyle(color: hintColor),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget okButton = TextButton(
      child: Text(
        getTranslated(context, AppString.logout_button).toString(),
        style: TextStyle(color: hintColor),
      ),
      onPressed: () {
        CommonFunction.checkNetwork().then((value) {
          if (value == true) {
            logoutUser();
          }
        });
      },
    );

    AlertDialog alert = AlertDialog(
      content: Text(getTranslated(context, AppString.are_you_sure_logout).toString()),
      actions: [cancel, okButton],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    _tomorrowSearchResult.clear();
    _upcomingSearchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    todayAppointments.forEach((appointmentData) {
      if (appointmentData.patientName!.toLowerCase().contains(text.toLowerCase())) {
        _searchResult.add(appointmentData);
      }
    });

    tomorrowAppointments.forEach((tomorrowData) {
      if (tomorrowData.patientName!.toLowerCase().contains(text.toLowerCase())) {
        _tomorrowSearchResult.add(tomorrowData);
      }
    });
    upcomingAppointments.forEach((upcomingData) {
      if (upcomingData.patientName!.toLowerCase().contains(text.toLowerCase())) {
        _upcomingSearchResult.add(upcomingData);
      }
    });

    setState(() {});
  }

  Future<BaseModel<Setting>> settingRequest() async {
    Setting response;
    try {
      response = await RestClient(RetroApi().dioData()).settingRequest();
      setState(() {
        if (response.data?.agoraAppId != null) {
        SharedPreferenceHelper.setString(Preferences.agoraAppId, response.data!.agoraAppId!);
        }
        if (SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true) {
          if (response.data!.stripeSecretKey != null) {
            SharedPreferenceHelper.setString(Preferences.stripeSecretKey, response.data!.stripeSecretKey!);
          }

          if (response.data!.stripePublicKey != null) {
            SharedPreferenceHelper.setString(Preferences.stripPublicKey, response.data!.stripePublicKey!);
          }

          if (response.data!.flutterwaveEncryptionKey != null) {
            SharedPreferenceHelper.setString(Preferences.flutterWave_encryption_key, response.data!.flutterwaveEncryptionKey!);
          }

          if (response.data!.flutterwaveKey != null) {
            SharedPreferenceHelper.setString(Preferences.flutterWave_key, response.data!.flutterwaveKey!);
          }

          if (response.data!.paystackPublicKey != null) {
            SharedPreferenceHelper.setString(Preferences.payStack_public_key, response.data!.paystackPublicKey!);
          }

          if (response.data!.razorKey != null) {
            SharedPreferenceHelper.setString(Preferences.razor_key, response.data!.razorKey!);
          }

          if (response.data!.paypalProducationKey != null) {
            SharedPreferenceHelper.setString(Preferences.payPal_production_key, response.data!.paypalProducationKey!);
          }

          if (response.data!.paypalSandboxKey != null) {
            SharedPreferenceHelper.setString(Preferences.payPal_sandbox_key, response.data!.paypalSandboxKey!);
          }

          if (response.data!.paypalClientId != null) {
            SharedPreferenceHelper.setString(Preferences.paypal_client_key, response.data!.paypalClientId!);
          }

          if (response.data!.paypalSecretKey != null) {
            SharedPreferenceHelper.setString(Preferences.paypal_secret_key, response.data!.paypalSecretKey!);
          }

          if (response.data!.currencySymbol != null) {
            SharedPreferenceHelper.setString(Preferences.currency_symbol, response.data!.currencySymbol!);
          }

          if (response.data!.currencyCode != null) {
            SharedPreferenceHelper.setString(Preferences.currency_code, response.data!.currencyCode!);
          }

          if (response.data!.doctorAppId != null) {
            setState(() {
              SharedPreferenceHelper.setString(Preferences.doctorAppId, response.data!.doctorAppId!);
            });
          }
        }
      });
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
