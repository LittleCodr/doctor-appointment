import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../api/retrofit_Api.dart';
import '../../../api/network_api.dart';
import '../../api/base_model.dart';
import '../../api/server_error.dart';
import '../../const/Palette.dart';
import '../../const/app_string.dart';
import '../../localization/localization_constant.dart';
import '../../model/forgot_password_model.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController email = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    double width;
    double height;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(50, 40),
          child: SafeArea(
            child: Container(
                alignment: AlignmentDirectional.topStart,
                margin: EdgeInsets.only(top: height * 0.01, left: width * 0.05, right: width * 0.05),
                child: GestureDetector(
                  child: Icon(Icons.arrow_back_ios),
                  onTap: () {
                    Navigator.pop(context);
                  },
                )),
          ),
        ),
        body: Form(
          key: _formKey,
          child: Center(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: height * 0.1, left: width * 0.073, right: width * 0.073),
                  child: Text(
                    getTranslated(context, AppString.forgotPassword_title).toString(),
                    style: TextStyle(fontSize: width * 0.09, fontWeight: FontWeight.bold, color: Palette.dark_blue),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: height * 0.040, left: height * 0.040, right: height * 0.040),
                  child: Text(
                    getTranslated(context, AppString.forgotPassword_text).toString(),
                    style: TextStyle(fontSize: width * 0.040, color: Palette.dark_blue),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: width * 0.1, left: width * 0.07, right: width * 0.07),
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                  decoration: BoxDecoration(
                    color: Palette.dark_white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: email,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: getTranslated(context, AppString.forgotPassword_email_hint).toString(),
                      hintStyle: TextStyle(fontSize: width * 0.038, color: Palette.dark_blue),
                    ),
                    validator: (String? value) {
                      if (value!.isEmpty) {
                        return getTranslated(context, AppString.forgotPassword_email_validator1).toString();
                      }
                      if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                        return getTranslated(context, AppString.forgotPassword_email_validator2).toString();
                      }
                      return null;
                    },
                    onSaved: (String? name) {},
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: height * 0.05, left: width * 0.05, right: width * 0.05),
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        child: Text(
                          getTranslated(context, AppString.forgotPassword_resetPassword_button).toString(),
                          style: TextStyle(fontSize: width * 0.04),
                          textAlign: TextAlign.center,
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            callForForgotPassword();
                          }
                        },
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

  Future<BaseModel<ForgotPassword>> callForForgotPassword() async {
    ForgotPassword response;
    Map<String, dynamic> body = {
      "email": email.text,
    };
    try {
      response = await RestClient(RetroApi2().dioData2()).forgotPasswordRequest(body);
      setState(() {
        Fluttertoast.showToast(
          msg: '${response.msg}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Palette.blue,
          textColor: Palette.white,
        );
        email.clear();
      });
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
