import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Preferences {
  Preferences._();

  /// TODO Setup: Enter Your google map key here
  static const String map_key = "Enter_Your_google_map_key";

  static const String is_logged_in = "isLoggedIn";
  static const String name = "name";
  static const String phone = "phone";
  static const String auth_token = "authToken";
  static const String is_dark_mode = "is_dark_mode";
  static const String current_language = "current_language";
  static const String current_language_code = "current_language_code";
  static const String image = "image";
  static const String userId = "loginId";
  static const String reportImage = "reportImage";
  static const String reportImage1 = "reportImage1";
  static const String reportImage2 = "reportImage2";
  static const String reportFile = "reportFile";
  static const String device_token = "device_token";
  static const String patientAppId = "patientAppId";
  static const String agoraAppId = "agoraAppId";
  static const String currency_code = "currency_code";
  static const String currency_symbol = "currency_symbol";
  static const String cod = "cod";
  static const String stripe = "stripe";
  static const String paypal = "paypal";
  static const String razor = "razor";
  static const String flutterWave = "flutterWave";
  static const String payStack = "payStack";
  static const String isLiveKey = "isLiveKey";
  static const String notificationRegisterKey = "notificationRegisterKey";

  static const String stripe_public_key = "stripe_public_key";
  static const String stripe_secret_key = "stripe_secret_key";
  static const String paypal_sandbox_key = "paypal_sandbox_key";
  static const String paypal_production_key = "paypal_production_key";
  static const String paypal_Client_Id = "paypal_Client_Id";
  static const String paypal_Secret_key = "paypal_Secret_key";
  static const String razor_key = "razor_key";
  static const String flutterWave_key = "flutterWave_key";
  static const String flutterWave_encryption_key = "flutterWave_encryption_key";
  static const String payStack_public_key = "payStack_public_key";
  static const String notificationPermissionDialog = "notificationPermissionDialog";

  static Future<bool> checkNetwork() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else {
      Fluttertoast.showToast(
        msg: "No Internet Connection",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return false;
    }
  }

  static onLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(20),
            child: new Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                new CircularProgressIndicator(),
                SizedBox(width: 20),
                new Text("PleaseWait"),
              ],
            ),
          ),
        );
      },
    );
  }

  static hideDialog(BuildContext context) {
    Navigator.pop(context);
  }
}

class FirestoreConstants {
  static const pathUserCollection = "users";
  static const pathMessageCollection = "messages";
  static const email = "email";
  static const password = "password";
  static const nickname = "nickname";
  static const aboutMe = "aboutMe";
  static const photoUrl = "photoUrl";
  static const id = "id";
  static const userId = "userId";
  static const chattingWith = "chattingWith";
  static const idFrom = "idFrom";
  static const idTo = "idTo";
  static const timestamp = "timestamp";
  static const content = "content";
  static const type = "type";
  static const userType = "userType";
  static const login = "login";
  static const doctorId = "doctorId";
  static const token = "pushToken";
}
