import 'package:doctro_patient/api/retrofit_Api.dart';
import 'package:doctro_patient/api/network_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../../api/base_model.dart';
import '../../api/server_error.dart';
import '../../const/Palette.dart';
import '../../const/app_string.dart';
import '../../localization/localization_constant.dart';
import '../../model/check_otp_model.dart';
import '../../model/resend_otp_model.dart';
import 'package:pinput/pinput.dart';

class PhoneVerification extends StatefulWidget {
  final int? id;

  PhoneVerification({this.id});

  @override
  _PhoneVerificationState createState() => _PhoneVerificationState();
}

class _PhoneVerificationState extends State<PhoneVerification> {
  int? id = 0;
  bool loader = false;

  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    id = widget.id;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width;
    double height;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(width * 0.125, width * 0.12),
        child: SafeArea(
          child: Container(
            alignment: AlignmentDirectional.topStart,
            margin: EdgeInsets.only(top: height * 0.015, left: width * 0.05, right: width * 0.05),
            child: GestureDetector(
              child: Icon(Icons.arrow_back_ios),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: loader,
        opacity: 0.5,
        progressIndicator: SpinKitFadingCircle(
          color: Palette.blue,
          size: 50.0,
        ),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: SingleChildScrollView(
            child: Center(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: height * 0.1, left: width * 0.073, right: width * 0.073),
                      child: Text(
                        getTranslated(context, AppString.phoneVerification_title).toString(),
                        style: TextStyle(fontSize: width * 0.08, fontWeight: FontWeight.bold, color: Palette.dark_blue),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: height * 0.06),
                      child: Text(
                        getTranslated(context, AppString.phoneVerification_enterOtp_hint).toString(),
                        style: TextStyle(fontSize: width * 0.038, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: width * 0.06),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.all(20.0),
                            padding: const EdgeInsets.all(20.0),
                            child: Pinput(
                              length: 4,
                              autofocus: true,
                              keyboardType: TextInputType.number,
                              focusNode: _pinPutFocusNode,
                              controller: _pinPutController,
                              submittedPinTheme: PinTheme().copyWith(
                                  decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: Palette.blue,
                                border: Border.all(
                                  color: Palette.tealAccent.withOpacity(.2),
                                ),
                              )),
                              focusedPinTheme: PinTheme().copyWith(
                                  decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: Palette.white,
                                border: Border.all(
                                  color: Palette.tealAccent.withOpacity(.2),
                                ),
                              )),
                              followingPinTheme: PinTheme().copyWith(
                                  decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: Palette.blue,
                                border: Border.all(
                                  color: Palette.tealAccent.withOpacity(.2),
                                ),
                              )),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: TweenAnimationBuilder(
                        tween: Tween(begin: 30.0, end: 0.0),
                        duration: Duration(seconds: 30),
                        builder: (_, dynamic value, child) => Text(
                          "00:${value.toInt()}",
                          style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(width * 0.1),
                      child: Column(
                        children: [
                          Text(
                            getTranslated(context, AppString.phoneVerification_notReceivedCode).toString(),
                            style: TextStyle(fontSize: width * 0.035, color: Palette.dark_blue),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: width * 0.0, vertical: width * 0.02),
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    callApiResendOtp();
                                  },
                                  child: Text(
                                    getTranslated(context, AppString.phoneVerification_resendCode).toString(),
                                    style: TextStyle(color: Palette.blue, fontWeight: FontWeight.bold, fontSize: width * 0.04),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: width,
                      margin: EdgeInsets.all(20),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: 5),
                        child: ElevatedButton(
                          child: Text(
                            getTranslated(context, AppString.phoneVerification_verifyOtp_button).toString(),
                            style: TextStyle(fontSize: width * 0.04),
                            textAlign: TextAlign.center,
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              callApiOTP();
                            } else {}
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
      ),
    );
  }

  Future<BaseModel<CheckOtpModel>> callApiOTP() async {
    CheckOtpModel response;
    Map<String, dynamic> body = {
      "user_id": id,
      "otp": _pinPutController.text,
    };
    setState(() {
      loader = true;
    });
    try {
      response = await RestClient(RetroApi2().dioData2()).checkOtp(body);
      setState(() {
        loader = false;
        if (response.success == true) {
          Navigator.pushReplacementNamed(context, "SignIn");
          Fluttertoast.showToast(
            msg: '${response.msg}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        } else {
          Fluttertoast.showToast(
            msg: '${response.msg}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        }
      });
    } catch (error, stacktrace) {
      setState(() {
        loader = false;
      });
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<ResendOtp>> callApiResendOtp() async {
    ResendOtp response;
    setState(() {
      loader = true;
    });
    try {
      response = await RestClient(RetroApi2().dioData2()).resendOtpRequest(id);
      setState(() {
        loader = false;
        if (response.success == true) {
          setState(() {
            Fluttertoast.showToast(
              msg: '${response.msg}',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
            );
          });
        } else {
          setState(() {
            Fluttertoast.showToast(
              msg: '${response.msg}',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
            );
          });
        }
      });
    } catch (error, stacktrace) {
      setState(() {
        loader = false;
      });
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
