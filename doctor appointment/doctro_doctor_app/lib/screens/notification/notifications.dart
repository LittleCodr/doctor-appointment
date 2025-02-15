import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctro/constant/app_string.dart';
import 'package:doctro/constant/color_constant.dart';
import 'package:doctro/constant/common_function.dart';
import 'package:doctro/localization/localization_constant.dart';
import 'package:doctro/model/Notification.dart';
import 'package:doctro/retrofit/api_header.dart';
import 'package:doctro/retrofit/base_model.dart';
import 'package:doctro/retrofit/server_error.dart';
import 'package:doctro/retrofit/network_api.dart';
import 'package:doctro/constant/prefConstatnt.dart';
import 'package:doctro/constant/preferences.dart';
import 'package:doctro/screens/auth/SignIn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {

  //Set Drawer Open
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  //Set Height/Width Using MediaQuery
  late double width;
  late double height;

  //Loader Data
  Future? loadData;

  //get preferences
  String? dName;
  String? dFullImage;
  String? phone;
  int? subscription;

  List<String> _drawer = [];
  List<String> _drawerMenu = [];

  //Notification List
  List<NotificationData> patientNotification = [];

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
    Future.delayed(Duration.zero, () {
      loadData = bookNotifications();
      dName = SharedPreferenceHelper.getString(Preferences.name);
      dFullImage = SharedPreferenceHelper.getString(Preferences.image);
      phone = SharedPreferenceHelper.getString(Preferences.phone_no);
      subscription = SharedPreferenceHelper.getInt(Preferences.subscription_status);
    });
  }

  @override
  Widget build(BuildContext context) {

    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Scaffold(
        key: _scaffoldKey,
        drawer:  Drawer(
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
                          }else if (_drawerMenu[index] == getTranslated(context, AppString.drawer_setting).toString()) {
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
                          }else if (_drawer[index] == getTranslated(context, AppString.drawer_setting).toString()) {
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
            preferredSize: Size(20, 60),
            child: SafeArea(
                top: true,
                child: Column(children: [
                  Container(
                    margin: EdgeInsets.only(left: width * 0.04, right: width * 0.04, top: height * 0.01),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.arrow_back_ios),
                          ),
                        ),
                        Container(
                            child: Text(
                          getTranslated(context, AppString.notification_heading).toString(),
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        )),
                        Container(
                          margin: EdgeInsets.only(),
                          child: IconButton(
                            onPressed: () {
                              _scaffoldKey.currentState!.openDrawer();
                            },
                            icon: SvgPicture.asset(
                              "assets/icons/dMenuBar.svg",
                              height: 16.0,
                              // width: 15.0,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]))),
        body: WillPopScope(
          onWillPop: () {
            Navigator.pushNamedAndRemoveUntil(context, 'loginHome', (route) => false);
            return Future<bool>.value(false);
          },
          child: RefreshIndicator(
            onRefresh: bookNotifications,
            child: FutureBuilder(
              future: loadData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    child: Center(
                      child: patientNotification.length == 0
                          ? Center(
                              child: Container(
                                margin: EdgeInsets.only(top: height * 0.3),
                                child: Container(
                                  child: Image.asset("assets/images/no-data.png"),
                                ),
                              ),
                            )
                          : Column(
                              children: [
                                ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    reverse: true,
                                    itemCount: 6 < patientNotification.length ? 6 : patientNotification.length,
                                    itemBuilder: (context, index) {
                                      String date = DateUtil().formattedDate(DateTime.parse(patientNotification[index].createdAt!));
                                      return InkWell(
                                        onTap: (){
                                          showDialog(
                                            context: context,
                                            builder: (context) => new AlertDialog(
                                              content: Text(patientNotification[index].message!),
                                              actions: [
                                                ElevatedButton(onPressed: (){
                                                  Navigator.pop(context);
                                                }, child: Text(getTranslated(context, AppString.schedule_ok_button).toString()))
                                              ],
                                            ),
                                          );
                                        },
                                        child: Column(
                                          children: [
                                            Container(
                                                margin: EdgeInsets.only(left: width * 0.02, right: width * 0.02),
                                                child: Column(children: <Widget>[
                                                  Container(
                                                    child: ListTile(
                                                      isThreeLine: true,
                                                      leading: SizedBox(
                                                        height: 70,
                                                        width: 60,
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(10),
                                                          child: Container(
                                                              decoration: new BoxDecoration(
                                                                  image: new DecorationImage(
                                                                      fit: BoxFit.fitHeight,
                                                                      image: NetworkImage(patientNotification[index].user!.fullImage!)))),
                                                        ),
                                                      ),
                                                      title: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Container(
                                                            child:
                                                                Text(patientNotification[index].user!.name!, style: TextStyle(fontSize: 16.0)),
                                                          ),
                                                          Container(
                                                              child: Text(
                                                            '$date',
                                                            style: TextStyle(fontSize: 14, color: passwordVisibility),
                                                          )),
                                                        ],
                                                      ),
                                                      subtitle: Container(
                                                        child: Text(
                                                          patientNotification[index].message!,
                                                          style: TextStyle(fontSize: 13, color: passwordVisibility),maxLines: 2,overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Divider(
                                                    thickness: 2,
                                                    color: divider,
                                                  ),
                                                ])),
                                          ],
                                        ),
                                      );
                                    }),
                                patientNotification.length < 6
                                    ? Container()
                                    : GestureDetector(
                                        onTap: () => Navigator.pushNamed(context, "ViewAllNotification"),
                                        child: Container(
                                          margin: EdgeInsets.only(top: height * 0.02),
                                          alignment: AlignmentDirectional.centerStart,
                                          height: height * 0.07,
                                          width: width * 0.88,
                                          color: divider,
                                          child: Container(
                                            margin: EdgeInsets.only(left: width * 0.02, right: width * 0.02),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  getTranslated(context, AppString.notification_view_all).toString(),
                                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: hintColor),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.only(right: width * 0.4),
                                                  child: SvgPicture.asset(
                                                    'assets/icons/longArrow.svg',
                                                    height: height * 0.012,
                                                  ),
                                                ),
                                                Text(
                                                  "${patientNotification.length}",
                                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: hintColor),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
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
              },
            ),
          ),
        ));
  }

  Future<BaseModel<Notifications>> bookNotifications() async {

    Notifications response;

    try {
      patientNotification.clear();
      response = await RestClient(RetroApi().dioData()).notifications();
      setState(() {
        patientNotification.addAll(response.data!);
      });
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  showAlertDialog(BuildContext context) {
    // set up the button
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

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      content: Text(getTranslated(context, AppString.are_you_sure_logout).toString()),
      actions: [cancel, okButton],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> logoutUser() async {
    SharedPreferenceHelper.clearPref();
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) => SignIn()), ModalRoute.withName('SignIn'));
  }

}

class DateUtil {
  static const DATE_FORMAT = 'dd-MM-yyyy';

  String formattedDate(DateTime dateTime) {
    return DateFormat(DATE_FORMAT).format(dateTime);
  }
}