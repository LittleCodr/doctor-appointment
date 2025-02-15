import 'package:doctro_patient/api/retrofit_Api.dart';
import 'package:doctro_patient/api/network_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../api/base_model.dart';
import '../../api/server_error.dart';
import '../../const/Palette.dart';
import '../../const/app_string.dart';
import '../../localization/localization_constant.dart';
import '../../model/common_response.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  bool _isHidden = true;
  bool _isHidden1 = true;
  bool _isHidden2 = true;

  bool oldPassword = false;

  TextEditingController _oldPassword = TextEditingController();
  TextEditingController _newPassword = TextEditingController();
  TextEditingController _confirmPassword = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
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
          getTranslated(context, AppString.changePassword_title).toString(),
          style: TextStyle(fontSize: 18, color: Palette.dark_blue, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 10,
                  ),

                  /// Old Password ///
                  Text(
                    getTranslated(context, AppString.changePassword_oldPassword).toString(),
                    style: TextStyle(fontSize: 16, color: Palette.dark_blue),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Card(
                    color: Palette.dark_white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: TextFormField(
                        textAlignVertical: TextAlignVertical.center,
                        controller: _oldPassword,
                        keyboardType: TextInputType.text,
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9@#\$&._~]'))],
                        style: TextStyle(fontSize: 16, color: Palette.grey),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: getTranslated(context, AppString.changePassword_oldPassword_hint).toString(),
                          hintStyle: TextStyle(fontSize: 14, color: Palette.grey),
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
                            return getTranslated(context, AppString.changePassword_oldPassword_validator).toString();
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),

                  /// New Password ///
                  Text(
                    getTranslated(context, AppString.changePassword_newPassword).toString(),
                    style: TextStyle(fontSize: 16, color: Palette.dark_blue),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Card(
                    color: Palette.dark_white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: TextFormField(
                        controller: _newPassword,
                        keyboardType: TextInputType.text,
                        textAlignVertical: TextAlignVertical.center,
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9@#\$&._~]'))],
                        style: TextStyle(fontSize: 16, color: Palette.grey),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: getTranslated(context, AppString.changePassword_newPassword_hint).toString(),
                          hintStyle: TextStyle(fontSize: 14, color: Palette.grey),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isHidden1 ? Icons.visibility : Icons.visibility_off,
                              color: Palette.grey,
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
                            return getTranslated(context, AppString.changePassword_newPassword_validator1).toString();
                          } else if (value.length < 6) {
                            return getTranslated(context, AppString.changePassword_newPassword_validator2).toString();
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),

                  /// Confirm Password ///
                  Text(
                    getTranslated(context, AppString.changePassword_confirmPassword).toString(),
                    style: TextStyle(fontSize: 16, color: Palette.dark_blue),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Card(
                    color: Palette.dark_white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: TextFormField(
                        controller: _confirmPassword,
                        keyboardType: TextInputType.text,
                        textAlignVertical: TextAlignVertical.center,
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9@#\$&._~]'))],
                        style: TextStyle(fontSize: 16, color: Palette.grey),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: getTranslated(context, AppString.changePassword_confirmPassword_hint).toString(),
                          hintStyle: TextStyle(fontSize: 14, color: Palette.grey),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isHidden2 ? Icons.visibility : Icons.visibility_off,
                              color: Palette.grey,
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
                            return getTranslated(context, AppString.changePassword_confirmPassword_validator1).toString();
                          } else if (_newPassword.text != _confirmPassword.text) {
                            return getTranslated(context, AppString.changePassword_confirmPassword_validator1).toString();
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),

                  /// Button ///
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      width: width,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate() && oldPassword == false) {
                            changepassword();
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            getTranslated(context, AppString.changePassword_button).toString(),
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<BaseModel<CommonResponse>> changepassword() async {
    CommonResponse response;
    Map<String, dynamic> body = {
      "old_password": _oldPassword.text.toString(),
      "password": _newPassword.text.toString(),
      "password_confirmation": _confirmPassword.text.toString(),
    };
    try {
      response = await RestClient(RetroApi().dioData()).changePasswordRequest(body);
      if (response.success == true) {
        setState(
          () {
            _oldPassword.clear();
            _newPassword.clear();
            _confirmPassword.clear();
            Fluttertoast.showToast(
              msg: 'Change Password Successfully...',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Palette.blue,
              textColor: Palette.white,
            );
          },
        );
      } else {}
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
