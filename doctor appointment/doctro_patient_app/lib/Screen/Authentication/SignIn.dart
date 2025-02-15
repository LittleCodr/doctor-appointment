import 'dart:io';
import 'package:doctro_patient/FirebaseProviders/auth_provider.dart';
import 'package:doctro_patient/api/retrofit_Api.dart';
import 'package:doctro_patient/api/network_api.dart';
import 'package:doctro_patient/model/login_model.dart';
import 'package:doctro_patient/Screen/Authentication/phoneVerification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:doctro_patient/const/prefConstatnt.dart';
import 'package:doctro_patient/const/preference.dart';
import 'package:location/location.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doctro_patient/api/base_model.dart';
import 'package:doctro_patient/api/server_error.dart';
import 'package:doctro_patient/const/Palette.dart';
import 'package:doctro_patient/const/app_string.dart';
import 'package:doctro_patient/localization/localization_constant.dart';
import 'package:doctro_patient/model/detail_setting_model.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool _isHidden = true;

  String? msg = "";
  String? deviceToken = "";

  int? verify = 0;
  int? id = 0;
  List<String> gender = [];

  @override
  void initState() {
    super.initState();

    /// TODO Setup: Uncomment the following lines to automatically fill the email and password fields for testing, so you don't have to type them every time
    // emailController.text = "example@example.com";
    // passwordController.text = "12345678";
    
    getLocation();
    callApiSetting();
  }

  AuthProvider? authProvider;

  late LocationData _locationData;
  Location location = new Location();

  Future<void> getLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _locationData = await location.getLocation();

    prefs.setString('lat', _locationData.latitude.toString());
    prefs.setString('lang', _locationData.longitude.toString());
  }

  @override
  Widget build(BuildContext context) {
    authProvider = Provider.of<AuthProvider>(context);
    double width;
    width = MediaQuery.of(context).size.width;
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Container(
                  height: size.height * 1,
                  width: width * 1,
                  child: Stack(
                    children: [
                      Image.asset(
                        "assets/images/confident-doctor-half.png",
                        height: size.height * 0.5,
                        width: width * 1,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: size.height * 0.35,
                        child: Container(
                          width: width * 1,
                          height: size.height * 1,
                          decoration: BoxDecoration(
                            color: Palette.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(width * 0.1),
                              topRight: Radius.circular(width * 0.1),
                            ),
                          ),
                          child: ListView(
                            physics: NeverScrollableScrollPhysics(),
                            children: [
                              Column(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(top: width * 0.08),
                                    child: Column(
                                      children: [
                                        Text(
                                          getTranslated(context, AppString.signIn_welcome).toString(),
                                          style: TextStyle(fontSize: width * 0.1, fontWeight: FontWeight.bold, color: Palette.light_black),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Column(
                                      children: [
                                        Text(
                                          getTranslated(context, AppString.signIn_title).toString(),
                                          style: TextStyle(fontSize: width * 0.04, color: Palette.dark_grey1),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 15,
                                      ),
                                      decoration: BoxDecoration(color: Palette.dark_white, borderRadius: BorderRadius.circular(10)),
                                      child: TextFormField(
                                        controller: emailController,
                                        keyboardType: TextInputType.text,
                                        textAlignVertical: TextAlignVertical.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Palette.dark_blue,
                                        ),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: getTranslated(context, AppString.signIn_email_hint).toString(),
                                          hintStyle: TextStyle(
                                            fontSize: 16,
                                            color: Palette.dark_grey,
                                          ),
                                        ),
                                        validator: (String? value) {
                                          if (value!.isEmpty) {
                                            return getTranslated(context, AppString.signIn_email_validator1).toString();
                                          }
                                          if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                                            return getTranslated(context, AppString.signIn_email_validator2).toString();
                                          }
                                          return null;
                                        },
                                        onSaved: (String? name) {},
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 15,
                                      ),
                                      decoration: BoxDecoration(color: Palette.dark_white, borderRadius: BorderRadius.circular(10)),
                                      child: TextFormField(
                                        controller: passwordController,
                                        keyboardType: TextInputType.text,
                                        textAlignVertical: TextAlignVertical.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Palette.dark_blue,
                                        ),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: getTranslated(context, AppString.signIn_password_hint).toString(),
                                          hintStyle: TextStyle(
                                            fontSize: 16,
                                            color: Palette.dark_grey,
                                          ),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _isHidden ? Icons.visibility : Icons.visibility_off,
                                              color: Palette.grey,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _isHidden = !_isHidden;
                                              });
                                            },
                                          ),
                                        ),
                                        obscureText: _isHidden,
                                        validator: (String? value) {
                                          if (value!.isEmpty) {
                                            return getTranslated(context, AppString.signIn_password_validator).toString();
                                          }
                                          return null;
                                        },
                                        onSaved: (String? name) {},
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                                    child: Container(
                                      width: width * 1,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ElevatedButton(
                                        child: Text(
                                          getTranslated(context, AppString.signIn_signIn_button).toString(),
                                          style: TextStyle(fontSize: 18),
                                          textAlign: TextAlign.center,
                                        ),
                                        onPressed: () {
                                          if (formKey.currentState!.validate()) {
                                            callForLogin();
                                          } else {
                                            print('Not Login');
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    child: Text(
                                      getTranslated(context, AppString.signIn_forgotPassword_button).toString(),
                                      style: TextStyle(fontSize: 16, color: Palette.dark_grey),
                                      textAlign: TextAlign.center,
                                    ),
                                    onPressed: () {
                                      Navigator.pushNamed(context, 'ForgotPasswordScreen');
                                    },
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        getTranslated(context, AppString.signIn_notAccount).toString(),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Palette.dark_grey,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(context, 'SignUp');
                                        },
                                        child: Text(
                                          getTranslated(context, AppString.signIn_signUp_button).toString(),
                                          style: TextStyle(fontSize: 16, color: Palette.blue, fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ],
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
      ),
    );
  }

  Future<BaseModel<Login>> callForLogin() async {
    Login response;
    Map<String, dynamic> body = {
      "email": emailController.text.toString(),
      "password": passwordController.text.toString(),
      "device_token": SharedPreferenceHelper.getString(Preferences.device_token),
    };

    setState(() {
      Preferences.onLoading(context);
    });
    try {
      response = await RestClient(RetroApi2().dioData2()).loginRequest(body);
      if (response.success == true) {
        setState(() {
          Preferences.hideDialog(context);
          SharedPreferenceHelper.setString(FirestoreConstants.email, response.data!.email!);
          SharedPreferenceHelper.setString(
            FirestoreConstants.password,
            passwordController.text.toString(),
          );
          SharedPreferenceHelper.setString(FirestoreConstants.nickname, response.data!.name!);
          SharedPreferenceHelper.setString(FirestoreConstants.photoUrl, response.data!.fullImage!);
          SharedPreferenceHelper.setString(Preferences.image, response.data!.fullImage!);
          SharedPreferenceHelper.setString(Preferences.image, response.data!.fullImage!);
          SharedPreferenceHelper.setString(Preferences.userId, response.data!.id.toString());
          SharedPreferenceHelper.setString(Preferences.phone, response.data!.phone.toString());

          authProvider!.handleSignIn();

          verify = response.data!.verify;
          id = response.data!.id;

          verify != 0
              ? Navigator.pushReplacementNamed(context, "Home")
              : Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PhoneVerification(id: id),
                  ),
                );
          msg = response.msg;
          emailController.clear();
          passwordController.clear();
          SharedPreferenceHelper.setBoolean(Preferences.is_logged_in, true);
          if (response.data!.token != null) {
            SharedPreferenceHelper.setString(Preferences.auth_token, response.data!.token!);
          }

          Fluttertoast.showToast(
            msg: '${response.msg}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Palette.blue,
            textColor: Palette.white,
          );
        });
      } else {
        setState(() {
          Preferences.hideDialog(context);
          Fluttertoast.showToast(
            msg: '${response.msg}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Palette.blue,
            textColor: Palette.white,
          );
        });
      }
    } catch (error, stacktrace) {
      Preferences.hideDialog(context);
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<DetailSetting>> callApiSetting() async {
    DetailSetting response;

    try {
      response = await RestClient(RetroApi2().dioData2()).settingRequest();
      setState(() {
        if (response.success == true) {
          SharedPreferenceHelper.setString(Preferences.patientAppId, response.data!.patientAppId!);

          if (response.data!.patientAppId != null) {
            getOneSignalToken(SharedPreferenceHelper.getString(Preferences.patientAppId));
          }
        }
      });
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  getOneSignalToken(appId) async {
    OneSignal.Debug.setLogLevel(OSLogLevel.info);

    OneSignal.initialize(appId);
    if (kDebugMode) {
      print("OneSignal App ID: " + appId);
    }
    OneSignal.Notifications.addPermissionObserver((state) {
      print("Has permission " + state.toString());
    });
    print("Permission ${OneSignal.Notifications.permission}");
    Platform.isIOS
        ? OneSignal.Notifications.permission == false &&
                SharedPreferenceHelper.getBoolean(Preferences.notificationPermissionDialog) == false
            ? OneSignal.Notifications.requestPermission(true)
            : null
        : null;
    Platform.isAndroid ? OneSignal.Notifications.requestPermission(true) : null;
    if (kDebugMode) {
      print("OneSignal ID : ${OneSignal.User.pushSubscription.id}");
      print("OneSignal Token : ${OneSignal.User.pushSubscription.token}");
    }
    OneSignal.Debug.setAlertLevel(OSLogLevel.none);

    if (SharedPreferenceHelper.getString(Preferences.device_token) == "" ||
        SharedPreferenceHelper.getString(Preferences.device_token) == "N_A") {
      if (OneSignal.User.pushSubscription.id != null) {
        SharedPreferenceHelper.setString(Preferences.device_token, OneSignal.User.pushSubscription.id.toString());
      } else {
        // getOneSingleToken(appId);
        SharedPreferenceHelper.setString(Preferences.device_token, '');
      }
    }
  }
}
