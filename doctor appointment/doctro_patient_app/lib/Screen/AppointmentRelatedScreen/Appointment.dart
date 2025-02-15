import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctro_patient/Screen/MedicineAndPharmacy/MyPrescription.dart';
import 'package:doctro_patient/api/retrofit_Api.dart';
import 'package:doctro_patient/api/network_api.dart';
import 'package:doctro_patient/model/appointments_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../../api/base_model.dart';
import '../../api/server_error.dart';
import '../../const/Palette.dart';
import '../../const/app_string.dart';
import '../../localization/localization_constant.dart';
import '../../model/common_response.dart';
import '../../model/detail_setting_model.dart';

class Appointment extends StatefulWidget {
  @override
  _AppointmentState createState() => _AppointmentState();
}

class _AppointmentState extends State<Appointment> with SingleTickerProviderStateMixin {
  bool loading = false;

  List<UpcomingAppointment> upcomingAppointment = [];
  List<PastAppointment> pastAppointment = [];
  List<PendingAppointment> pendingAppointment = [];

  List<String> cancelReason = [];
  String reason = "";

  int? id = 0;
  int value = 0;

  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    callApiAppointment();
    callApiSetting();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    double width;
    double height;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return ModalProgressHUD(
      inAsyncCall: loading,
      opacity: 0.5,
      progressIndicator: SpinKitFadingCircle(
        color: Palette.blue,
        size: 50.0,
      ),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          body: SafeArea(
            child: NestedScrollView(
              floatHeaderSlivers: true,
              physics: NeverScrollableScrollPhysics(),
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        size: 20,
                        color: Palette.dark_blue,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    centerTitle: true,
                    backgroundColor: Palette.white,
                    foregroundColor: Palette.blue,
                    title: Text(
                      getTranslated(context, AppString.appointment_title).toString(),
                      style: TextStyle(fontSize: 18, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                    ),
                    pinned: true,
                    floating: true,
                    snap: true,
                    shadowColor: Palette.blue,
                    bottom: TabBar(
                      tabs: <Tab>[
                        Tab(
                          child: Text(
                            getTranslated(context, AppString.appointment_title_tab1).toString(),
                            style: TextStyle(
                              fontSize: 15,
                              color: Palette.blue,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Tab(
                          child: Text(
                            getTranslated(context, AppString.appointment_title_tab2).toString(),
                            style: TextStyle(
                              fontSize: 15,
                              color: Palette.blue,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Tab(
                          child: Text(
                            getTranslated(context, AppString.appointment_title_tab3).toString(),
                            style: TextStyle(
                              fontSize: 15,
                              color: Palette.blue,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                      controller: _tabController,
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  /// Tab 1 //
                  pendingAppointment.length != 0
                      ? RefreshIndicator(
                          onRefresh: callApiAppointment,
                          child: Container(
                            child: ListView.builder(
                              physics: AlwaysScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: pendingAppointment.length,
                              itemBuilder: (context, index) {
                                var statusColor = Palette.green;
                                if (pendingAppointment[index].appointmentStatus!.toUpperCase() == getTranslated(context, AppString.appointment_pending).toString()) {
                                  statusColor = Palette.dark_blue.withOpacity(0.6);
                                } else if (pendingAppointment[index].appointmentStatus!.toUpperCase() == getTranslated(context, AppString.appointment_cancel).toString()) {
                                  statusColor = Palette.red;
                                } else if (pendingAppointment[index].appointmentStatus!.toUpperCase() == getTranslated(context, AppString.appointment_approve).toString()) {
                                  statusColor = Palette.green;
                                }
                                return pendingAppointment.length != 0
                                    ? Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                            child: Container(
                                              width: width * 1,
                                              child: Card(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                ),
                                                elevation: 2,
                                                color: Palette.white,
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      margin: EdgeInsets.only(top: width * 0.02, left: width * 0.03, right: width * 0.03),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              Container(
                                                                child: Text(
                                                                  getTranslated(context, AppString.appointment_bookingID).toString(),
                                                                  style: TextStyle(fontSize: width * 0.035, color: Palette.blue, fontWeight: FontWeight.bold),
                                                                ),
                                                              ),
                                                              Text(
                                                                pendingAppointment[index].appointmentId!,
                                                                style: TextStyle(fontSize: width * 0.035, color: Palette.black, fontWeight: FontWeight.bold),
                                                              ),
                                                            ],
                                                          ),
                                                          Container(
                                                            child: Text(
                                                              pendingAppointment[index].appointmentStatus!.toUpperCase(),
                                                              style: TextStyle(fontSize: width * 0.035, color: statusColor, fontWeight: FontWeight.bold),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                        top: width * 0.02,
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Container(
                                                            width: width * 0.15,
                                                            margin: EdgeInsets.only(left: width * 0.028),
                                                            child: Column(
                                                              children: [
                                                                Container(
                                                                  width: width * 0.15,
                                                                  height: height * 0.07,
                                                                  decoration: new BoxDecoration(
                                                                    shape: BoxShape.circle,
                                                                    boxShadow: [
                                                                      new BoxShadow(
                                                                        color: Palette.blue,
                                                                        blurRadius: 1.0,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  child: CachedNetworkImage(
                                                                    alignment: Alignment.center,
                                                                    imageUrl: pendingAppointment[index].doctor!.fullImage!,
                                                                    imageBuilder: (context, imageProvider) => CircleAvatar(
                                                                      radius: 50,
                                                                      backgroundColor: Palette.white,
                                                                      child: CircleAvatar(
                                                                        radius: 25,
                                                                        backgroundImage: imageProvider,
                                                                      ),
                                                                    ),
                                                                    placeholder: (context, url) => SpinKitFadingCircle(color: Palette.blue),
                                                                    errorWidget: (context, url, error) => ClipRRect(
                                                                      borderRadius: BorderRadius.circular(30),
                                                                      child: Image.asset("assets/images/no_image.jpg"),
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            width: width * 0.6,
                                                            child: Column(
                                                              children: [
                                                                Container(
                                                                  alignment: AlignmentDirectional.topStart,
                                                                  margin: EdgeInsets.only(
                                                                    left: width * 0.02,
                                                                  ),
                                                                  child: Column(
                                                                    children: [
                                                                      Text(
                                                                        pendingAppointment[index].doctor!.name!,
                                                                        style: TextStyle(
                                                                          fontSize: width * 0.04,
                                                                          color: Palette.dark_blue,
                                                                        ),
                                                                        overflow: TextOverflow.ellipsis,
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                                pendingAppointment[index].hospital != null
                                                                    ? Column(
                                                                        children: [
                                                                          Container(
                                                                            alignment: AlignmentDirectional.topStart,
                                                                            margin: EdgeInsets.only(left: width * 0.02, right: width * 0.02, top: width * 0.005),
                                                                            child: Column(
                                                                              children: [
                                                                                Text(
                                                                                  pendingAppointment[index].hospital!.name!,
                                                                                  style: TextStyle(fontSize: width * 0.03, color: Palette.grey),
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                )
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Container(
                                                                            alignment: AlignmentDirectional.topStart,
                                                                            margin: EdgeInsets.only(left: width * 0.02, right: width * 0.02, top: width * 0.005),
                                                                            child: Column(
                                                                              children: [
                                                                                Text(
                                                                                  pendingAppointment[index].hospital!.address!,
                                                                                  style: TextStyle(fontSize: width * 0.03, color: Palette.grey),
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                )
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      )
                                                                    : SizedBox(),
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            child: Column(
                                                              children: [
                                                                PopupMenuButton(
                                                                  itemBuilder: (context) => [
                                                                    PopupMenuItem(
                                                                      child: Text(
                                                                        getTranslated(context, AppString.appointment_cancelAppointment).toString(),
                                                                        style: TextStyle(
                                                                          fontSize: width * 0.04,
                                                                          color: Palette.blue,
                                                                        ),
                                                                      ),
                                                                      value: 1,
                                                                    )
                                                                  ],
                                                                  onSelected: (dynamic values) {
                                                                    if (values == 1) {
                                                                      showDialog(
                                                                        context: context,
                                                                        builder: (context) {
                                                                          return StatefulBuilder(
                                                                            builder: (context, setState) {
                                                                              return AlertDialog(
                                                                                insetPadding: EdgeInsets.all(20),
                                                                                title: Text(
                                                                                  getTranslated(context, AppString.appointment_whyCancelAppointment).toString(),
                                                                                ),
                                                                                content: Container(
                                                                                  height: 250,
                                                                                  width: 280,
                                                                                  child: ListView.builder(
                                                                                    itemCount: cancelReason.length,
                                                                                    itemBuilder: (context, index) {
                                                                                      return RadioListTile(
                                                                                        value: index,
                                                                                        groupValue: value,
                                                                                        onChanged: (int? reason) {
                                                                                          setState(() {
                                                                                            value = reason!.toInt();
                                                                                          });
                                                                                        },
                                                                                        title: Text(cancelReason[index]),
                                                                                      );
                                                                                    },
                                                                                  ),
                                                                                ),
                                                                                actions: <Widget>[
                                                                                  OutlinedButton(
                                                                                    child: Text(
                                                                                      getTranslated(context, AppString.bookAppointment_no).toString(),
                                                                                    ),
                                                                                    onPressed: () {
                                                                                      setState(
                                                                                        () {
                                                                                          Navigator.of(context).pop();
                                                                                        },
                                                                                      );
                                                                                    },
                                                                                  ),
                                                                                  OutlinedButton(
                                                                                    child: Text(
                                                                                      getTranslated(context, AppString.bookAppointment_yes).toString(),
                                                                                    ),
                                                                                    onPressed: () {
                                                                                      setState(
                                                                                        () {
                                                                                          id = pendingAppointment[index].id;
                                                                                          reason = cancelReason[value];
                                                                                          Navigator.of(context).pop();
                                                                                          callApiCancelAppointment();
                                                                                        },
                                                                                      );
                                                                                    },
                                                                                  ),
                                                                                ],
                                                                              );
                                                                            },
                                                                          );
                                                                        },
                                                                      );
                                                                    }
                                                                  },
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(top: width * 0.03),
                                                      child: Column(
                                                        children: [
                                                          Divider(
                                                            height: width * 0.004,
                                                            color: Palette.dark_grey,
                                                            thickness: width * 0.001,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Container(
                                                                child: Text(
                                                                  getTranslated(context, AppString.appointment_dateTime).toString(),
                                                                  style: TextStyle(
                                                                    fontSize: width * 0.03,
                                                                    color: Palette.grey,
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                child: Text(
                                                                  getTranslated(context, AppString.appointment_patientName).toString(),
                                                                  style: TextStyle(
                                                                    fontSize: width * 0.03,
                                                                    color: Palette.grey,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Container(
                                                                child: Text(
                                                                  pendingAppointment[index].date! + '  ' + pendingAppointment[index].time!,
                                                                  style: TextStyle(fontSize: width * 0.03, color: Palette.dark_blue),
                                                                ),
                                                              ),
                                                              Container(
                                                                child: Text(
                                                                  pendingAppointment[index].patientName!,
                                                                  style: TextStyle(fontSize: width * 0.03, color: Palette.dark_blue),
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Center(
                                        child: Text(
                                          getTranslated(context, AppString.appointment_appointmentNotAvailable).toString(),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Palette.grey,
                                          ),
                                        ),
                                      );
                              },
                            ),
                          ),
                        )
                      : Container(
                          height: height * 0.9,
                          child: Center(
                            child: Text(
                              getTranslated(context, AppString.appointment_appointmentNotAvailable).toString(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Palette.grey,
                              ),
                            ),
                          ),
                        ),

                  /// Tab 2 //
                  upcomingAppointment.length != 0
                      ? RefreshIndicator(
                          onRefresh: callApiAppointment,
                          child: Container(
                            child: ListView.builder(
                              physics: AlwaysScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: upcomingAppointment.length,
                              itemBuilder: (context, index) {
                                var statusColor = Palette.green;
                                if (upcomingAppointment[index].appointmentStatus!.toUpperCase() == getTranslated(context, AppString.appointment_pending).toString()) {
                                  statusColor = Palette.dark_blue.withOpacity(0.6);
                                } else if (upcomingAppointment[index].appointmentStatus!.toUpperCase() == getTranslated(context, AppString.appointment_cancel).toString()) {
                                  statusColor = Palette.red;
                                } else if (upcomingAppointment[index].appointmentStatus!.toUpperCase() == getTranslated(context, AppString.appointment_approve).toString()) {
                                  statusColor = Palette.green;
                                }
                                String upcomingStatus = "";
                                if (upcomingAppointment[index].appointmentStatus!.toUpperCase() == "APPROVE") {
                                  upcomingStatus = "APPROVED";
                                }
                                return upcomingAppointment.length != 0
                                    ? Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                            child: Container(
                                              width: width * 1,
                                              child: Card(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                ),
                                                elevation: 2,
                                                color: Palette.white,
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      margin: EdgeInsets.only(top: 10, left: width * 0.03, right: width * 0.03),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              Container(
                                                                child: Text(
                                                                  getTranslated(context, AppString.appointment_bookingID).toString(),
                                                                  style: TextStyle(fontSize: width * 0.035, color: Palette.blue, fontWeight: FontWeight.bold),
                                                                ),
                                                              ),
                                                              Text(
                                                                upcomingAppointment[index].appointmentId!,
                                                                style: TextStyle(fontSize: width * 0.035, color: Palette.black, fontWeight: FontWeight.bold),
                                                              ),
                                                            ],
                                                          ),
                                                          Container(
                                                            child: Text(
                                                              upcomingStatus,
                                                              style: TextStyle(fontSize: width * 0.035, color: statusColor, fontWeight: FontWeight.bold),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                        top: width * 0.02,
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Container(
                                                            width: width * 0.15,
                                                            margin: EdgeInsets.only(left: width * 0.028, right: width * 0.028),
                                                            child: Column(
                                                              children: [
                                                                Container(
                                                                  width: width * 0.15,
                                                                  height: height * 0.07,
                                                                  decoration: new BoxDecoration(
                                                                    shape: BoxShape.circle,
                                                                    boxShadow: [
                                                                      new BoxShadow(
                                                                        color: Palette.blue,
                                                                        blurRadius: 1.0,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  child: CachedNetworkImage(
                                                                    alignment: Alignment.center,
                                                                    imageUrl: upcomingAppointment[index].doctor!.fullImage!,
                                                                    imageBuilder: (context, imageProvider) => CircleAvatar(
                                                                      radius: 50,
                                                                      backgroundColor: Palette.white,
                                                                      child: CircleAvatar(
                                                                        radius: 25,
                                                                        backgroundImage: imageProvider,
                                                                      ),
                                                                    ),
                                                                    placeholder: (context, url) => SpinKitFadingCircle(color: Palette.blue),
                                                                    errorWidget: (context, url, error) => ClipRRect(
                                                                      borderRadius: BorderRadius.circular(30),
                                                                      child: Image.asset("assets/images/no_image.jpg"),
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            width: width * 0.6,
                                                            child: Column(
                                                              children: [
                                                                Container(
                                                                  alignment: AlignmentDirectional.topStart,
                                                                  margin: EdgeInsets.only(left: width * 0.02, right: width * 0.02),
                                                                  child: Column(
                                                                    children: [
                                                                      Text(
                                                                        upcomingAppointment[index].doctor!.name!,
                                                                        style: TextStyle(
                                                                          fontSize: width * 0.04,
                                                                          color: Palette.dark_blue,
                                                                        ),
                                                                        overflow: TextOverflow.ellipsis,
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                                upcomingAppointment[index].hospital != null
                                                                    ? Column(
                                                                        children: [
                                                                          Container(
                                                                            alignment: AlignmentDirectional.topStart,
                                                                            margin: EdgeInsets.only(left: width * 0.02, right: width * 0.02, top: width * 0.005),
                                                                            child: Column(
                                                                              children: [
                                                                                Text(
                                                                                  upcomingAppointment[index].hospital!.name!,
                                                                                  style: TextStyle(fontSize: width * 0.03, color: Palette.grey),
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                )
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Container(
                                                                            alignment: AlignmentDirectional.topStart,
                                                                            margin: EdgeInsets.only(left: width * 0.02, right: width * 0.02, top: width * 0.005),
                                                                            child: Column(
                                                                              children: [
                                                                                Text(
                                                                                  upcomingAppointment[index].hospital!.address!,
                                                                                  style: TextStyle(fontSize: width * 0.03, color: Palette.grey),
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                )
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      )
                                                                    : SizedBox(),
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            child: Column(
                                                              children: [
                                                                PopupMenuButton(
                                                                  itemBuilder: (context) => [
                                                                    PopupMenuItem(
                                                                      child: Text(
                                                                        getTranslated(context, AppString.appointment_cancelAppointment).toString(),
                                                                        style: TextStyle(
                                                                          fontSize: width * 0.04,
                                                                          color: Palette.blue,
                                                                        ),
                                                                      ),
                                                                      value: 1,
                                                                    )
                                                                  ],
                                                                  onSelected: (dynamic values) {
                                                                    if (values == 1) {
                                                                      showDialog(
                                                                        context: context,
                                                                        builder: (context) {
                                                                          return StatefulBuilder(
                                                                            builder: (context, setState) {
                                                                              return AlertDialog(
                                                                                insetPadding: EdgeInsets.all(20),
                                                                                title: Text(
                                                                                  getTranslated(context, AppString.appointment_whyCancelAppointment).toString(),
                                                                                ),
                                                                                content: Container(
                                                                                  height: 250,
                                                                                  width: 280,
                                                                                  child: ListView.builder(
                                                                                    itemCount: cancelReason.length,
                                                                                    itemBuilder: (context, index) {
                                                                                      return RadioListTile(
                                                                                        value: index,
                                                                                        groupValue: value,
                                                                                        onChanged: (int? reason) {
                                                                                          setState(() {
                                                                                            value = reason!.toInt();
                                                                                          });
                                                                                        },
                                                                                        title: Text(cancelReason[index]),
                                                                                      );
                                                                                    },
                                                                                  ),
                                                                                ),
                                                                                actions: <Widget>[
                                                                                  OutlinedButton(
                                                                                    child: Text(
                                                                                      getTranslated(context, AppString.bookAppointment_no).toString(),
                                                                                    ),
                                                                                    onPressed: () {
                                                                                      setState(
                                                                                        () {
                                                                                          Navigator.of(context).pop();
                                                                                        },
                                                                                      );
                                                                                    },
                                                                                  ),
                                                                                  OutlinedButton(
                                                                                    child: Text(
                                                                                      getTranslated(context, AppString.bookAppointment_yes).toString(),
                                                                                    ),
                                                                                    onPressed: () {
                                                                                      setState(
                                                                                        () {
                                                                                          id = upcomingAppointment[index].id;
                                                                                          reason = cancelReason[value];
                                                                                          Navigator.of(context).pop();
                                                                                          callApiCancelAppointment();
                                                                                        },
                                                                                      );
                                                                                    },
                                                                                  ),
                                                                                ],
                                                                              );
                                                                            },
                                                                          );
                                                                        },
                                                                      );
                                                                    }
                                                                  },
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(top: width * 0.03),
                                                      child: Column(
                                                        children: [
                                                          Divider(
                                                            height: width * 0.004,
                                                            color: Palette.dark_grey,
                                                            thickness: width * 0.001,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Container(
                                                                child: Text(
                                                                  getTranslated(context, AppString.appointment_dateTime).toString(),
                                                                  style: TextStyle(
                                                                    fontSize: width * 0.03,
                                                                    color: Palette.grey,
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                child: Text(
                                                                  getTranslated(context, AppString.appointment_patientName).toString(),
                                                                  style: TextStyle(
                                                                    fontSize: width * 0.03,
                                                                    color: Palette.grey,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Container(
                                                                child: Text(
                                                                  upcomingAppointment[index].date! + '  ' + upcomingAppointment[index].time!,
                                                                  style: TextStyle(fontSize: width * 0.03, color: Palette.dark_blue),
                                                                ),
                                                              ),
                                                              Container(
                                                                child: Text(
                                                                  upcomingAppointment[index].patientName!,
                                                                  style: TextStyle(fontSize: width * 0.03, color: Palette.dark_blue),
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Center(
                                        child: Text(
                                          getTranslated(context, AppString.appointment_appointmentNotAvailable).toString(),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Palette.dark_blue,
                                          ),
                                        ),
                                      );
                              },
                            ),
                          ),
                        )
                      : Container(
                          height: height * 0.9,
                          child: Center(
                            child: Text(
                              getTranslated(context, AppString.appointment_appointmentNotAvailable).toString(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Palette.grey,
                              ),
                            ),
                          ),
                        ),

                  /// Tab 3 //
                  pastAppointment.length != 0
                      ? RefreshIndicator(
                          onRefresh: callApiAppointment,
                          child: Container(
                            child: ListView.builder(
                              physics: AlwaysScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: pastAppointment.length,
                              itemBuilder: (context, index) {
                                var statusColor = Palette.green;
                                if (pastAppointment[index].appointmentStatus!.toUpperCase() == getTranslated(context, AppString.appointment_pending).toString()) {
                                  statusColor = Palette.dark_blue.withOpacity(0.6);
                                } else if (pastAppointment[index].appointmentStatus!.toUpperCase() == getTranslated(context, AppString.appointment_cancel).toString()) {
                                  statusColor = Palette.red;
                                } else if (pastAppointment[index].appointmentStatus!.toUpperCase() == getTranslated(context, AppString.appointment_approve).toString()) {
                                  statusColor = Palette.green;
                                }
                                String pastStatus = "";
                                if (pastAppointment[index].appointmentStatus!.toUpperCase() == "CANCEL") {
                                  pastStatus = "CANCELED";
                                } else if (pastAppointment[index].appointmentStatus!.toUpperCase() == "COMPLETE") {
                                  pastStatus = "COMPLETED";
                                } else if (pastAppointment[index].appointmentStatus!.toUpperCase() == "APPROVE") {
                                  pastStatus = "APPROVED";
                                } else if (pastAppointment[index].appointmentStatus!.toUpperCase() == "PENDING") {
                                  pastStatus = "PENDING";
                                }
                                return Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        if (pastAppointment[index].appointmentStatus!.toUpperCase() == "COMPLETE") {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => MyPrescription(
                                                doctorImage: pastAppointment[index].doctor!.fullImage,
                                                doctorName: pastAppointment[index].doctor!.name,
                                                doctorTreatmentName: pastAppointment[index].doctor!.treatment!.name,
                                                doctorAddress: pastAppointment[index].hospital!.address ?? "",
                                                appointmentDate: pastAppointment[index].date,
                                                appointmentTime: pastAppointment[index].time,
                                                patientName: pastAppointment[index].patientName,
                                                appointmentIdPrescription: pastAppointment[index].prescription == true ? pastAppointment[index].id : 0,
                                                appointmentId: pastAppointment[index].id,
                                                userRating: pastAppointment[index].rate,
                                              ),
                                            ),
                                          );
                                        } else {
                                          Fluttertoast.showToast(msg: getTranslated(context, AppString.noDetailAvailable).toString());
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                        child: Container(
                                          width: width * 1,
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                10.0,
                                              ),
                                            ),
                                            elevation: 2,
                                            color: Palette.white,
                                            child: Column(
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.only(top: width * 0.02, left: width * 0.04, right: width * 0.04),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          Container(
                                                            child: Text(
                                                              getTranslated(context, AppString.appointment_bookingID).toString(),
                                                              style: TextStyle(fontSize: width * 0.035, color: Palette.blue, fontWeight: FontWeight.bold),
                                                            ),
                                                          ),
                                                          Text(
                                                            pastAppointment[index].appointmentId!,
                                                            style: TextStyle(fontSize: width * 0.035, color: Palette.black, fontWeight: FontWeight.bold),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          Container(
                                                            child: Text(
                                                              pastStatus,
                                                              style: TextStyle(fontSize: width * 0.035, color: statusColor, fontWeight: FontWeight.bold),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.only(
                                                    top: width * 0.02,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Container(
                                                        width: width * 0.15,
                                                        margin: EdgeInsets.only(left: width * 0.028, right: width * 0.028),
                                                        child: Column(
                                                          children: [
                                                            Container(
                                                              width: width * 0.15,
                                                              height: height * 0.07,
                                                              decoration: new BoxDecoration(
                                                                shape: BoxShape.circle,
                                                                boxShadow: [
                                                                  new BoxShadow(
                                                                    color: Palette.blue,
                                                                    blurRadius: 1.0,
                                                                  ),
                                                                ],
                                                              ),
                                                              child: CachedNetworkImage(
                                                                alignment: Alignment.center,
                                                                imageUrl: pastAppointment[index].doctor!.fullImage!,
                                                                imageBuilder: (context, imageProvider) => CircleAvatar(
                                                                  radius: 50,
                                                                  backgroundColor: Palette.white,
                                                                  child: CircleAvatar(
                                                                    radius: 25,
                                                                    backgroundImage: imageProvider,
                                                                  ),
                                                                ),
                                                                placeholder: (context, url) => SpinKitFadingCircle(color: Palette.white),
                                                                errorWidget: (context, url, error) => ClipRRect(
                                                                  borderRadius: BorderRadius.circular(30),
                                                                  child: Image.asset("assets/images/no_image.jpg", fit: BoxFit.fitHeight),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Expanded(child: Container(
                                                        width: width * 0.72,
                                                        child: Column(
                                                          children: [
                                                            Container(
                                                              alignment: AlignmentDirectional.topStart,
                                                              margin: EdgeInsets.only(left: width * 0.02, right: width * 0.02),
                                                              child: Column(
                                                                children: [
                                                                  Text(
                                                                    pastAppointment[index].doctor!.name!,
                                                                    style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                                                                    overflow: TextOverflow.ellipsis,
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            pastAppointment[index].hospital!.address != null
                                                                ? Column(
                                                              children: [
                                                                Container(
                                                                  alignment: AlignmentDirectional.topStart,
                                                                  margin: EdgeInsets.only(left: width * 0.02, right: width * 0.02, top: width * 0.005),
                                                                  child: Column(
                                                                    children: [
                                                                      Text(
                                                                        pastAppointment[index].hospital!.name!,
                                                                        style: TextStyle(fontSize: width * 0.03, color: Palette.grey),
                                                                        overflow: TextOverflow.ellipsis,
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                                Container(
                                                                  alignment: AlignmentDirectional.topStart,
                                                                  margin: EdgeInsets.only(left: width * 0.02, right: width * 0.02, top: width * 0.005),
                                                                  child: Column(
                                                                    children: [
                                                                      Text(
                                                                        pastAppointment[index].hospital!.address!,
                                                                        style: TextStyle(fontSize: width * 0.03, color: Palette.grey),
                                                                        overflow: TextOverflow.ellipsis,
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                                : SizedBox(),
                                                          ],
                                                        ),
                                                      )),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.only(top: width * 0.03),
                                                  child: Column(
                                                    children: [
                                                      Divider(
                                                        height: width * 0.004,
                                                        color: Palette.dark_grey,
                                                        thickness: width * 0.001,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Container(
                                                            child: Text(
                                                              getTranslated(context, AppString.appointment_dateTime).toString(),
                                                              style: TextStyle(fontSize: width * 0.03, color: Palette.grey),
                                                            ),
                                                          ),
                                                          Container(
                                                            child: Text(
                                                              getTranslated(context, AppString.appointment_patientName).toString(),
                                                              // 'Patient Name',
                                                              style: TextStyle(fontSize: width * 0.03, color: Palette.grey),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Container(
                                                            child: Text(
                                                              pastAppointment[index].date! + '  ' + pastAppointment[index].time!,
                                                              style: TextStyle(fontSize: width * 0.03, color: Palette.dark_blue),
                                                            ),
                                                          ),
                                                          Container(
                                                            child: Text(
                                                              pastAppointment[index].patientName!,
                                                              style: TextStyle(fontSize: width * 0.03, color: Palette.dark_blue),
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        )
                      : Container(
                          height: height * 0.9,
                          child: Center(
                            child: Text(
                              getTranslated(context, AppString.appointment_appointmentNotAvailable).toString(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Palette.grey,
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

  Future<BaseModel<Appointments>> callApiAppointment() async {
    Appointments response;
    setState(
      () {
        loading = true;
      },
    );
    try {
      response = await RestClient(RetroApi().dioData()).appointmentsRequest();
      if (response.success == true) {
        setState(
          () {
            pendingAppointment.clear();
            upcomingAppointment.clear();
            pastAppointment.clear();
            loading = false;
            upcomingAppointment.addAll(response.data!.upcomingAppointment!);
            pastAppointment.addAll(response.data!.pastAppointment!);
            pendingAppointment.addAll(response.data!.pendingAppointment!);
          },
        );
      } else {
        loading = false;
      }
    } catch (error, stacktrace) {
      setState(() {
        loading = false;
      });
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<CommonResponse>> callApiCancelAppointment() async {
    CommonResponse response;
    Map<String, dynamic> body = {
      "appointment_id": id,
      "cancel_reason": reason,
    };
    try {
      response = await RestClient(RetroApi().dioData()).cancelAppointmentRequest(body);
      if (response.success == true) {
        setState(() {
          Fluttertoast.showToast(
            msg: '${response.msg}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );

          pendingAppointment.clear();
          upcomingAppointment.clear();
          pastAppointment.clear();
          callApiAppointment();
        });
      } else {
        Fluttertoast.showToast(
          msg: '${response.msg}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<DetailSetting>> callApiSetting() async {
    DetailSetting response;
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi().dioData()).settingRequest();
      loading = false;
      if (response.success == true) {
        var convertCancelReason = json.decode(response.data!.cancelReason!);
        cancelReason.clear();
        for (int i = 0; i < convertCancelReason.length; i++) {
          cancelReason.add(convertCancelReason[i]);
        }
      }
    } catch (error, stacktrace) {
      setState(() {
        loading = false;
      });
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
