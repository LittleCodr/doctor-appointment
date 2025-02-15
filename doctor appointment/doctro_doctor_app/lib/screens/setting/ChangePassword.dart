import 'package:doctro/retrofit/api_header.dart';
import 'package:doctro/retrofit/base_model.dart';
import 'package:doctro/retrofit/network_api.dart';
import 'package:doctro/constant/app_string.dart';
import 'package:doctro/constant/color_constant.dart';
import 'package:doctro/localization/localization_constant.dart';
import 'package:doctro/retrofit/server_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:doctro/model/ChangePassword.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  //Set MediaQuery Height / Width
  late double height;
  late double width;

  //Change Password Controller
  TextEditingController _oldPassword = TextEditingController();
  TextEditingController _newPassword = TextEditingController();
  TextEditingController _confirmPassword = TextEditingController();

  //validation
  var _formKey = GlobalKey<FormState>();

  //Check Old Password
  bool oldPassword = false;

  //Set Visibility True/False
  bool _isHidden = true;
  bool _isHidden1 = true;
  bool _isHidden2 = true;

  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size(20, 65),
          child: SafeArea(
              top: true,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  margin: EdgeInsets.only(left: width * 0.06, right: width * 0.06, top: height * 0.02),
                  child: Row(
                    children: [
                      GestureDetector(
                        child: Icon(Icons.arrow_back_ios),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      Container(
                        margin: EdgeInsets.only(left: width * 0.2),
                        child: Text(
                          getTranslated(context, AppString.change_password_heading).toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ]))),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: AlwaysScrollableScrollPhysics(),
          child: Center(
            child: Form(
              key: _formKey,
              child: Container(
                margin: EdgeInsets.only(top: height * 0.02),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: width * 0.1, top: height * 0.03, right: width * 0.1),
                      alignment: AlignmentDirectional.bottomStart,
                      child: Text(
                        getTranslated(context, AppString.change_old_password).toString(),
                        style: TextStyle(fontSize: 16, color: hintColor),
                      ),
                    ),
                    Card(
                      color: cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        height: height * 0.07,
                        width: width * 0.85,
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          child: TextFormField(
                            controller: _oldPassword,
                            keyboardType: TextInputType.name,
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9!@#\$.*&~_]'))],
                            style: TextStyle(fontSize: 16, color: passwordVisibility),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: getTranslated(context, AppString.change_old_password_hint).toString(),
                              hintStyle: TextStyle(fontSize: width * 0.035, color: passwordVisibility),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isHidden ? Icons.visibility : Icons.visibility_off,
                                  color: passwordVisibility,
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
                                return getTranslated(context, AppString.please_enter_old_password).toString();
                              } else if (value.length < 6) {
                                return getTranslated(context, AppString.please_enter_valid_password).toString();
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: width * 0.1, top: height * 0.03, right: width * 0.1),
                      alignment: AlignmentDirectional.bottomStart,
                      child: Text(
                        getTranslated(context, AppString.change_enter_new_password).toString(),
                        style: TextStyle(fontSize: 16, color: hintColor),
                      ),
                    ),
                    Card(
                      color: cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        height: height * 0.07,
                        width: width * 0.85,
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          child: TextFormField(
                            controller: _newPassword,
                            keyboardType: TextInputType.name,
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9!@#\$.*&~_]'))],
                            style: TextStyle(fontSize: 16, color: passwordVisibility),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: getTranslated(context, AppString.change_enter_new_password_hint).toString(),
                              hintStyle: TextStyle(fontSize: width * 0.035, color: passwordVisibility),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isHidden1 ? Icons.visibility : Icons.visibility_off,
                                  color: passwordVisibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isHidden1 = !_isHidden1;
                                  });
                                },
                              ),
                            ),
                            obscureText: _isHidden1,
                            validator: (String? value) {
                              if (value!.isEmpty) {
                                return getTranslated(context, AppString.please_enter_new_password).toString();
                              } else if (value.length < 6) {
                                return getTranslated(context, AppString.please_enter_valid_password).toString();
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: width * 0.1, top: height * 0.03, right: width * 0.1),
                      alignment: AlignmentDirectional.bottomStart,
                      child: Text(
                        getTranslated(context, AppString.change_enter_confirm_password).toString(),
                        style: TextStyle(fontSize: 16, color: hintColor),
                      ),
                    ),
                    Card(
                      color: cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        height: height * 0.07,
                        width: width * 0.85,
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          child: TextFormField(
                              controller: _confirmPassword,
                              keyboardType: TextInputType.name,
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9!@#\$.*&~_]'))],
                              style: TextStyle(fontSize: 16, color: passwordVisibility),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: getTranslated(context, AppString.change_enter_confirm_password_hint).toString(),
                                hintStyle: TextStyle(fontSize: width * 0.035, color: passwordVisibility),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isHidden2 ? Icons.visibility : Icons.visibility_off,
                                    color: passwordVisibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isHidden2 = !_isHidden2;
                                    });
                                  },
                                ),
                              ),
                              obscureText: _isHidden2,
                              validator: (String? value) {
                                if (value!.isEmpty) {
                                  return getTranslated(context, AppString.please_enter_confirm_password).toString();
                                } else if (_newPassword.text != _confirmPassword.text) {
                                  return getTranslated(context, AppString.confirm_not_match).toString();
                                }
                                return null;
                              }),
                        ),
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.only(left: width * 0.08, right: width * 0.08, top: height * 0.06),
                        width: width * 1.0,
                        height: height * 0.06,
                        child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate() && oldPassword == false) {
                                changePassword();
                              }
                            },
                            child: Text(
                              getTranslated(context, AppString.change_password_button).toString(),
                              style: TextStyle(fontSize: 18),
                            )))
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<BaseModel<ChangePasswordModel>> changePassword() async {
    ChangePasswordModel response;
    try {
      Map<String, dynamic> body = {"old_password": _oldPassword.text, "password": _newPassword.text, "password_confirmation": _confirmPassword.text};
      response = (await RestClient(RetroApi().dioData()).changePasswordRequest(body));
      setState(() {
        if (response.success == true) {
          oldPassword = true;
          Fluttertoast.showToast(
            msg: response.data!,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
          Navigator.pushReplacementNamed(context, 'loginHome');
        } else {
          oldPassword = false;
          Fluttertoast.showToast(
            msg: response.data!,
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
