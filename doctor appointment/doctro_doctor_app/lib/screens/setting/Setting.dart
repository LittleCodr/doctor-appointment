import 'package:doctro/constant/app_string.dart';
import 'package:doctro/constant/color_constant.dart';
import 'package:doctro/constant/prefConstatnt.dart';
import 'package:doctro/constant/preferences.dart';
import 'package:doctro/localization/localization_constant.dart';
import 'package:doctro/screens/setting/changeLanguage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../model/UpdateProfile.dart';
import '../../model/doctor_profile.dart';
import '../../retrofit/api_header.dart';
import '../../retrofit/base_model.dart';
import '../../retrofit/network_api.dart';
import '../../retrofit/server_error.dart';
import 'ChangePassword.dart';
import '../subscription/SubscriptionHistory.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool isCallEnable = false;

  @override
  void initState() {
    super.initState();
    doctorProfile();
  }

  @override
  Widget build(BuildContext context) {
    double width;
    double height;

    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size(20, 65),
          child: SafeArea(
              top: true,
              child: Column(children: [
                Container(
                  margin: EdgeInsets.only(left: width * 0.06, right: width * 0.06, top: height * 0.02),
                  child: Row(
                    children: [
                      Container(
                          child: GestureDetector(
                        child: Icon(Icons.arrow_back_ios),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      )),
                      Container(
                          margin: EdgeInsets.only(left: width / 3.5),
                          child: Text(
                            getTranslated(context, AppString.drawer_setting).toString(),
                            style: TextStyle(fontSize: 20, color: hintColor),
                            textAlign: TextAlign.center,
                          )),
                    ],
                  ),
                ),
              ]))),
      body: Container(
        height: height,
        width: width,
        color: back,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: height * 0.03,
                  ),
                  SwitchListTile(
                    value: isCallEnable,
                    onChanged: (value) {
                      print(value);
                      setState(() {
                        isCallEnable = value;
                        updateVCall(value == true ? 1 : 0);
                      });
                    },
                    title: Text(getTranslated(context, AppString.allowPatientsToVideoCallDirectly).toString()),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChangeLanguage()),
                      );
                    },
                    minLeadingWidth: 20,
                    title: Text(
                      getTranslated(context, AppString.drawer_change_language).toString(),
                      style: TextStyle(
                        color: colorButton,
                        fontSize: 16,
                      ),
                    ),
                    trailing: Icon(
                      Icons.keyboard_arrow_right_sharp,
                      color: colorButton,
                      size: 30,
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChangePassword()),
                      );
                    },
                    minLeadingWidth: 20,
                    title: Text(
                      getTranslated(context, AppString.drawer_change_password).toString(),
                      style: TextStyle(
                        color: colorButton,
                        fontSize: 16,
                      ),
                    ),
                    trailing: Icon(
                      Icons.keyboard_arrow_right_sharp,
                      color: colorButton,
                      size: 30,
                    ),
                  ),
                  SharedPreferenceHelper.getInt(Preferences.subscription_status) == 1
                      ? ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SubscriptionHistory()),
                            );
                          },
                          minLeadingWidth: 20,
                          title: Text(
                            getTranslated(context, AppString.drawer_subscription_history).toString(),
                            style: TextStyle(
                              color: colorButton,
                              fontSize: 16,
                            ),
                          ),
                          trailing: Icon(
                            Icons.keyboard_arrow_right_sharp,
                            color: colorButton,
                            size: 30,
                          ),
                        )
                      : Container()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<BaseModel<DoctorProfile>> doctorProfile() async {
    DoctorProfile response;

    try {
      response = await RestClient(RetroApi().dioData()).doctorProfile();

      if (response.data?.patientVCall != null) {
        isCallEnable = response.data?.patientVCall == 0 ? false : true;
      } else {
        isCallEnable = false;
      }

      setState(() {});
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  /// update vCall permission
  Future<BaseModel<UpdateProfile>> updateVCall(vCallData) async {
    UpdateProfile response;

    Map<String, dynamic> body = {"patient_vcall": vCallData};
    try {
      response = await RestClient(RetroApi().dioData()).updatePatientVcallRequest(body);

      if (response.success == true) {
        Fluttertoast.showToast(msg: response.msg!);
      }

      setState(() {});
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
