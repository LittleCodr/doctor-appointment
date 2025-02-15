import 'package:doctro/model/ForgotPassword.dart';
import 'package:doctro/retrofit/api_header.dart';
import 'package:doctro/retrofit/base_model.dart';
import 'package:doctro/retrofit/network_api.dart';
import 'package:doctro/constant/app_string.dart';
import 'package:doctro/constant/color_constant.dart';
import 'package:doctro/localization/localization_constant.dart';
import 'package:doctro/retrofit/server_error.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late double width;
  late double height;

  String msg = "";

  //validation form
  var _formKey = GlobalKey<FormState>();

  TextEditingController _email = TextEditingController();

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(width * 0.05, height * 0.05),
        child: SafeArea(
          child: Container(
              alignment: AlignmentDirectional.topStart,
              margin: EdgeInsets.only(top: height * 0.025, left: width * 0.05, right: width * 0.05),
              child: GestureDetector(
                child: Icon(Icons.arrow_back_ios),
                onTap: () {
                  Navigator.pop(context);
                },
              )),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Center(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: height * 0.1, left: width * 0.073, right: width * 0.073),
                    child: Text(
                      getTranslated(context, AppString.forgot_password_title).toString(),
                      style: TextStyle(fontSize: width * 0.09, fontWeight: FontWeight.bold, color: hintColor),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: height * 0.040),
                    child: Text(
                      getTranslated(context, AppString.forgot_password_description).toString(),
                      style: TextStyle(fontSize: width * 0.040, color: hintColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: width * 0.020, right: width * 0.020, top: height * 0.052),
                    child: Card(
                      color: cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        height: height * 0.07,
                        width: width * 0.85,
                        child: TextFormField(
                          controller: _email,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              alignLabelWithHint: true,
                              contentPadding: EdgeInsets.only(
                                left: 10,
                                right: 10,
                              ),
                              hintText: getTranslated(context, AppString.forgot_email_hint).toString(),
                              hintStyle: TextStyle(
                                fontSize: width * 0.034,
                                color: hintColor,
                              )),
                          validator: (String? value) {
                            Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                            RegExp regex = new RegExp(pattern as String);

                            if (value!.length == 0) {
                              return getTranslated(context, AppString.please_enter_email).toString();
                            }
                            if (!regex.hasMatch(value)) {
                              return getTranslated(context, AppString.please_enter_valid_email).toString();
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      height: height * 0.06,
                      width: width * 0.83,
                      margin: EdgeInsets.only(left: width * 0.018, right: width * 0.018),
                      child: ElevatedButton(
                        child: Text(
                          getTranslated(context, AppString.forgot_reset_button).toString(),
                          style: TextStyle(fontSize: width * 0.04),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            forgotPasswordScreenRequest();
                          }
                        },
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

  Future<BaseModel<ForgotPassword>> forgotPasswordScreenRequest() async {
    ForgotPassword response;
    try {
      Map<String, dynamic> body = {"email": _email.text};
      response = (await RestClient(RetroApi().dioData()).forgotPasswordScreen(body));
      setState(() {
        if (response.success == true) {
          Navigator.pushReplacementNamed(context, "SignIn");
          Fluttertoast.showToast(
            msg: response.msg!,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        } else {
          Fluttertoast.showToast(
            msg: response.msg!,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        }
      });
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
