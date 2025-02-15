import 'package:connectivity/connectivity.dart';
import 'package:doctro/constant/app_string.dart';
import 'package:doctro/localization/localization_constant.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:doctro/main.dart';
import 'color_constant.dart';

class CommonFunction {
  //Set Loader SignUp & Sign In
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
                new Text(getTranslated(context, AppString.please_wait).toString()),
              ],
            ),
          ),
        );
      },
    );
  }

  static toastMessage(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        //timeInSecForIosWeb: 1,
        backgroundColor: blackOpacity,
        textColor: colorWhite,
        fontSize: 16.0);
  }

  static hideDialog(BuildContext context) {
    Navigator.pop(context);
  }

  //Check Internet Connection Data
  static Future<bool> checkNetwork() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else {
      Fluttertoast.showToast(
        msg: getTranslated(navigatorKey.currentState!.context, AppString.noInternetConnection).toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return false;
    }
  }
}
