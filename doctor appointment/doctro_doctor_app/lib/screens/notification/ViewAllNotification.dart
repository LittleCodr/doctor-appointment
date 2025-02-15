import 'dart:async';
import 'package:doctro/retrofit/api_header.dart';
import 'package:doctro/retrofit/base_model.dart';
import 'package:doctro/retrofit/network_api.dart';
import 'package:doctro/constant/app_string.dart';
import 'package:doctro/constant/color_constant.dart';
import 'package:doctro/localization/localization_constant.dart';
import 'package:doctro/model/Notification.dart';
import 'package:doctro/retrofit/server_error.dart';
import 'package:doctro/screens/home%20page/patient_information.dart';
import 'package:flutter/material.dart';

class ViewAllNotification extends StatefulWidget {
  @override
  _ViewAllAppointmentState createState() => _ViewAllAppointmentState();
}

class _ViewAllAppointmentState extends State<ViewAllNotification> {
  //Set Height/Width Using MediaQuery
  late double width;
  late double height;

  //Set Loader
  Future? loadData;

  //Notification List
  List<NotificationData> patientNotification = [];

  @override
  void initState() {
    super.initState();
    loadData = bookNotifications();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: PreferredSize(
            preferredSize: Size(20, 58),
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
                            Text(
                              getTranslated(context, AppString.notification_heading).toString(),
                              style: TextStyle(fontSize: width * 0.05, color: hintColor),
                            ),
                            Container(
                              margin: EdgeInsets.only(),
                              child: IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(Icons.arrow_back_ios),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ]))),
        body: FutureBuilder(
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
                                itemCount: patientNotification.length,
                                itemBuilder: (context, index) {
                                  String date = DateUtil().formattedDate(DateTime.parse(patientNotification[index].createdAt!));
                                  return InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => new AlertDialog(
                                          content: Text(patientNotification[index].message!),
                                          actions: [
                                            ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text(getTranslated(context, AppString.schedule_ok_button).toString()))
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
                                                      child: Container(decoration: new BoxDecoration(image: new DecorationImage(fit: BoxFit.fitHeight, image: NetworkImage(patientNotification[index].user!.fullImage!)))),
                                                    ),
                                                  ),
                                                  title: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Container(
                                                        child: Text(patientNotification[index].user!.name!, style: TextStyle(fontSize: 16.0)),
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
                                                      style: TextStyle(fontSize: 13, color: passwordVisibility),
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
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
}
