import 'package:doctro_patient/FirebaseProviders/auth_provider.dart';
import 'package:doctro_patient/Screen/Screens/Home.dart';
import 'package:doctro_patient/api/retrofit_Api.dart';
import 'package:doctro_patient/api/base_model.dart';
import 'package:doctro_patient/api/network_api.dart';
import 'package:doctro_patient/api/server_error.dart';
import 'package:doctro_patient/model/account_delete_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import '../../../const/prefConstatnt.dart';
import '../../../const/preference.dart';
import '../../const/Palette.dart';
import '../../const/app_string.dart';
import '../../localization/localization_constant.dart';

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    double width;
    double height;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
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
        title: Text(
          getTranslated(context, AppString.setting_title).toString(),
          style: TextStyle(fontSize: 18, color: Palette.dark_blue, fontWeight: FontWeight.bold),
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: loading,
        opacity: 0.5,
        progressIndicator: SpinKitFadingCircle(
          color: Palette.blue,
          size: 50.0,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                  ? Column(
                      children: [
                        Container(
                          height: height * 0.05,
                          width: width * 1,
                          color: Palette.light_blue,
                          child: Container(
                            alignment: Alignment.topLeft,
                            margin: EdgeInsets.only(left: width * 0.05, right: width * 0.05),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  getTranslated(context, AppString.setting_title).toString(),
                                  style: TextStyle(
                                    fontSize: width * 0.038,
                                    color: Color(0xFF003165),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, 'ChangeLanguage');
                          },
                          child: Container(
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.symmetric(vertical: height * 0.02, horizontal: width * 0.05),
                            child: Text(
                              getTranslated(context, AppString.setting_changeLanguage).toString(),
                              style: TextStyle(fontSize: width * 0.038, color: Palette.dark_blue),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, 'ChangePassword');
                          },
                          child: Container(
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.symmetric(vertical: height * 0.02, horizontal: width * 0.05),
                            child: Text(
                              getTranslated(context, AppString.setting_changePassword).toString(),
                              style: TextStyle(fontSize: width * 0.038, color: Palette.dark_blue),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            showDeleteAccountDialog(context);
                          },
                          child: Container(
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.symmetric(vertical: height * 0.02, horizontal: width * 0.05),
                            child: Text(
                              getTranslated(context, AppString.deleteAccount).toString(),
                              style: TextStyle(fontSize: width * 0.038, color: Palette.dark_blue),
                            ),
                          ),
                        ),
                        // : SizedBox()
                      ],
                    )
                  : SizedBox(),
              Container(
                height: height * 0.05,
                width: width * 1,
                color: Palette.light_blue,
                margin: EdgeInsets.only(top: height * 0.02),
                child: Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.symmetric(horizontal: width * 0.05),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        getTranslated(context, AppString.setting_general).toString(),
                        style: TextStyle(
                          fontSize: width * 0.038,
                          color: Palette.dark_blue,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: width * 0.05),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, 'AboutUs');
                      },
                      child: Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(top: height * 0.025),
                        child: Text(
                          getTranslated(context, AppString.setting_about).toString(),
                          style: TextStyle(fontSize: width * 0.038, color: Palette.dark_blue),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, 'PrivacyPolicy');
                      },
                      child: Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(top: height * 0.025),
                        child: Text(
                          getTranslated(context, AppString.setting_privacyPolicy).toString(),
                          style: TextStyle(fontSize: width * 0.038, color: Palette.dark_blue),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  showDeleteAccountDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(getTranslated(context, AppString.deleteAccountQuestion).toString()),
            content: Text(getTranslated(context, AppString.youWillLoseAllTheDataAndWonBeAbleToLogBackIn).toString()),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  getTranslated(context, AppString.cancel).toString(),
                  style: TextStyle(color: Palette.dark_grey),
                ),
                style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: Palette.white, side: BorderSide(color: Palette.dark_grey)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  callDeleteAccount();
                },
                child: Text(
                  getTranslated(context, AppString.delete).toString(),
                  style: TextStyle(color: Palette.white),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Palette.red.withAlpha(150),
                ),
              ),
            ],
          );
        });
  }

  Future logoutUser() async {
    setState(() {
      SharedPreferenceHelper.clearPref();
      Provider.of<AuthProvider>(context, listen: false).handleSignOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => Home()),
        ModalRoute.withName('SplashScreen'),
      );
    });
  }

  Future<BaseModel<AccountDeleteModel>> callDeleteAccount() async {
    AccountDeleteModel response;
    try {
      setState(() {
        loading = true;
      });
      response = await RestClient(RetroApi().dioData()).deleteAccount();
      if (response.success == true) {
        setState(() {
          if (response.message != null) {
            Fluttertoast.showToast(
              msg: '${response.message}',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Palette.blue,
              textColor: Palette.white,
            );
          }
          logoutUser();
        });
      } else {
        if (response.message != null) {
          Fluttertoast.showToast(
            msg: '${response.message}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Palette.blue,
            textColor: Palette.white,
          );
        }
      }
      setState(() {
        loading = false;
      });
    } catch (error) {
      setState(() {
        loading = false;
      });
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data;
  }
}

class SwitchScreen extends StatefulWidget {
  @override
  SwitchClass createState() => new SwitchClass();
}

class SwitchClass extends State {
  bool isSwitched = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: <Widget>[
        Column(
          children: [
            Column(
              children: [
                Column(
                  children: [
                    Container(
                      height: size.width * 0.038,
                      margin: EdgeInsets.only(),
                      child: Switch(
                        value: isSwitched,
                        onChanged: (value) {
                          setState(
                            () {
                              isSwitched = value;
                            },
                          );
                        },
                        activeColor: Palette.white,
                        activeTrackColor: Palette.dark_blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
