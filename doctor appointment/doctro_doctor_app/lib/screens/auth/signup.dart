import 'dart:core';
import 'package:country_picker/country_picker.dart';
import 'package:doctro/model/otp_verify.dart';
import 'package:doctro/retrofit/api_header.dart';
import 'package:doctro/retrofit/base_model.dart';
import 'package:doctro/retrofit/network_api.dart';
import 'package:doctro/constant/app_string.dart';
import 'package:doctro/constant/color_constant.dart';
import 'package:doctro/constant/common_function.dart';
import 'package:doctro/localization/localization_constant.dart';
import 'package:doctro/model/register.dart';
import 'package:doctro/retrofit/server_error.dart';
import 'package:doctro/screens/auth/phoneverification.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  //Set Height/Width Using MediaQuery
  late double width;
  late double height;

  //Set Password Visibility
  bool _isHidden = true;

//Set DropDown For Male/Female
  List<String> gender = [];
  String? _genderSelect;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      gender = [
        getTranslated(context, AppString.gender_male).toString(),
        getTranslated(context, AppString.gender_female).toString(),
      ];
    });
  }

  //Select Dob
  DateTime? _selectedDate;
  String newDateApiPass = "";

  //Set Empty Data Validation
  final _formkey = GlobalKey<FormState>();

  //Set TextInput Controller
  TextEditingController _name = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _dob = TextEditingController();
  TextEditingController _phone = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _phoneCode = TextEditingController(text: "+91");

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(width, height * 0.08),
        child: SafeArea(
          child: Container(
            margin: EdgeInsets.only(left: width * 0.05, right: width * 0.05, top: height * 0.02),
            alignment: AlignmentDirectional.topStart,
            child: InkWell(
              child: Padding(
                padding: EdgeInsets.zero,
                child: Icon(Icons.arrow_back_ios),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: SingleChildScrollView(
          child: Center(
            child: Form(
              key: _formkey,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: height * 0.04, left: width * 0.073, right: width * 0.073),
                    child: Text(
                      getTranslated(context, AppString.register_heading).toString(),
                      style: TextStyle(fontSize: width * 0.07, fontWeight: FontWeight.bold, color: hintColor),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: width * 0.020, right: width * 0.020, top: height * 0.027),
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: height * 0.01, left: width * 0.05, right: width * 0.05),
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(10)),
                          child: TextFormField(
                            controller: _name,
                            keyboardType: TextInputType.name,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]")),
                            ],
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: getTranslated(context, AppString.register_full_name).toString(),
                              hintStyle: TextStyle(
                                fontSize: width * 0.04,
                                color: hintColor,
                              ),
                            ),
                            validator: (String? value) {
                              if (value!.isEmpty) {
                                return getTranslated(context, AppString.please_enter_full_name).toString();
                              } else if (value.trim().length < 1) {
                                return getTranslated(context, AppString.please_enter_valid_name).toString();
                              }
                              return null;
                            },
                            onSaved: (String? name) {},
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: height * 0.01, left: width * 0.05, right: width * 0.05),
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(10)),
                          child: TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: getTranslated(context, AppString.register_email_hint).toString(),
                              hintStyle: TextStyle(
                                fontSize: width * 0.04,
                                color: hintColor,
                              ),
                            ),
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
                            onSaved: (String? name) {},
                          ),
                        ),
                        Container(
                          child: Row(
                            children: [
                              Container(
                                width: width * 0.21,
                                height: height * 0.06,
                                margin: EdgeInsets.only(
                                  top: height * 0.01,
                                  left: width * 0.05,
                                  right: width * 0.05,
                                ),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: width * 0.20,
                                      height: height * 0.06,
                                      decoration: BoxDecoration(
                                        color: cardColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: TextFormField(
                                        keyboardType: TextInputType.phone,
                                        textAlign: TextAlign.center,
                                        readOnly: true,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: hintColor,
                                        ),
                                        controller: _phoneCode,
                                        decoration: InputDecoration(
                                          hintText: '+91',
                                          border: InputBorder.none,
                                          hintStyle: TextStyle(
                                            fontSize: width * 0.04,
                                            color: hintColor,
                                          ),
                                        ),
                                        onTap: () {
                                          showCountryPicker(
                                            context: context,
                                            exclude: <String>['KN', 'MF'],
                                            showPhoneCode: true,
                                            onSelect: (Country country) {
                                              _phoneCode.text = "+" + country.phoneCode;
                                            },
                                            countryListTheme: CountryListThemeData(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(40.0),
                                                topRight: Radius.circular(40.0),
                                              ),
                                              inputDecoration: InputDecoration(
                                                labelText: getTranslated(context, AppString.register_phone_code_search).toString(),
                                                hintText: getTranslated(context, AppString.register_typing_search).toString(),
                                                prefixIcon: const Icon(Icons.search),
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: hintColor.withOpacity(0.2),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: width * 0.60,
                                height: height * 0.06,
                                margin: EdgeInsets.only(
                                  top: height * 0.01,
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 1),
                                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(10)),
                                child: TextFormField(
                                  controller: _phone,
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: [new FilteringTextInputFormatter.allow(RegExp("[0-9]")), LengthLimitingTextInputFormatter(10)],
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: getTranslated(context, AppString.register_phone_no).toString(),
                                    hintStyle: TextStyle(
                                      fontSize: width * 0.04,
                                      color: hintColor,
                                    ),
                                  ),
                                  validator: (String? value) {
                                    print(' ${value!.length}');
                                    if (value.isEmpty) {
                                      return getTranslated(context, AppString.please_enter_phone_no).toString();
                                    }
                                    if (value.length != 10) {
                                      return getTranslated(context, AppString.please_enter_valid_number).toString();
                                    }
                                    return null;
                                  },
                                  onSaved: (String? name) {},
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: height * 0.01, left: width * 0.05, right: width * 0.05),
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(10)),
                          child: TextFormField(
                            textCapitalization: TextCapitalization.words,
                            style: TextStyle(
                              fontSize: 16,
                              color: hintColor,
                            ),
                            controller: _dob,
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: getTranslated(context, AppString.register_birth_date_hint).toString(),
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                fontSize: width * 0.04,
                                color: hintColor,
                              ),
                            ),
                            validator: (String? value) {
                              if (value!.isEmpty) {
                                return getTranslated(context, AppString.please_select_birth_date).toString();
                              }
                              return null;
                            },
                            onTap: () {
                              _selectDate(context);
                            },
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: height * 0.01, left: width * 0.05, right: width * 0.05),
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(10)),
                          child: DropdownButtonFormField(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: getTranslated(context, AppString.register_select_gender_hint).toString(),
                              hintStyle: TextStyle(
                                fontSize: width * 0.04,
                                color: hintColor,
                              ),
                            ),
                            value: _genderSelect,
                            isExpanded: true,
                            iconSize: 25,
                            onSaved: (dynamic value) {
                              setState(
                                () {
                                  _genderSelect = value;
                                },
                              );
                            },
                            onChanged: (dynamic newValue) {
                              setState(
                                () {
                                  _genderSelect = newValue;
                                },
                              );
                            },
                            validator: (dynamic value) => value == null ? getTranslated(context, AppString.please_select_gender).toString() : null,
                            items: gender.map(
                              (location) {
                                return DropdownMenuItem<String>(
                                  child: new Text(
                                    location,
                                    style: TextStyle(
                                      fontSize: width * 0.04,
                                      color: hintColor,
                                    ),
                                  ),
                                  value: location,
                                );
                              },
                            ).toList(),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: height * 0.01, left: width * 0.05, right: width * 0.05),
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(10)),
                          child: TextFormField(
                            controller: _password,
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: getTranslated(context, AppString.register_password_hint).toString(),
                              hintStyle: TextStyle(
                                fontSize: width * 0.04,
                                color: hintColor,
                              ),
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
                                return getTranslated(context, AppString.please_enter_password).toString();
                              }
                              return null;
                            },
                            onSaved: (String? name) {},
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: height * 0.05, left: width * 0.05, right: width * 0.05, bottom: width * 0.05),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      width: width * 1.0,
                      height: height * 0.06,
                      child: ElevatedButton(
                        child: Text(
                          getTranslated(context, AppString.register_button).toString(),
                          style: TextStyle(fontSize: width * 0.045),
                          textAlign: TextAlign.center,
                        ),
                        onPressed: () {
                          if (_formkey.currentState!.validate()) {
                            callApiForRegister();
                          }
                        },
                      ),
                    ),
                  ),
                  Container(
                    child: Text(
                      getTranslated(context, AppString.register_description).toString(),
                      style: TextStyle(fontSize: width * 0.03, color: hintColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10, bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              getTranslated(context, AppString.register_all_ready_account).toString(),
                              style: TextStyle(fontSize: width * 0.035, color: hintColor),
                            ),
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(left: width * 0.009),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, 'SignIn');
                                },
                                child: Text(getTranslated(context, AppString.register_sign_in).toString(), style: TextStyle(color: loginButton, fontWeight: FontWeight.bold, fontSize: width * 0.035)),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Future<BaseModel<Register>> callApiForRegister() async {
    newDateApiPass = DateUtilForPass().formattedDate(DateTime.parse('$_selectedDate'));

    Map<String, dynamic> body = {
      "name": _name.text,
      "email": _email.text,
      "dob": newDateApiPass,
      "gender": _genderSelect,
      "phone": _phone.text,
      "password": _password.text,
      "phone_code": _phoneCode.text,
    };

    Register response;
    try {
      CommonFunction.onLoading(context);
      response = await RestClient(RetroApi().dioData()).registerRequest(body);
      CommonFunction.hideDialog(context);
      final data = OtpData(otp: response.data!.otp, id: response.data!.id);
      response.data!.verify != 1
          ? Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PhoneVerificationScreen(data: data)),
            )
          : Navigator.pushNamed(context, 'SignIn');
      Fluttertoast.showToast(
        msg: response.msg!,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (error, stacktrace) {
      CommonFunction.hideDialog(context);
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  _selectDate(BuildContext context) async {
    DateTime? newSelectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate != null ? _selectedDate! : DateTime.now(),
      firstDate: DateTime(1950, 1),
      lastDate: DateTime.now(),
    );
    if (newSelectedDate != null) {
      _selectedDate = newSelectedDate;
      _dob
        ..text = DateFormat('dd-MM-yyyy').format(_selectedDate!)
        ..selection = TextSelection.fromPosition(
          TextPosition(offset: _dob.text.length, affinity: TextAffinity.upstream),
        );
    }
  }
}

class DateUtilForPass {
  static const DATE_FORMAT = 'yyyy-MM-dd';

  String formattedDate(DateTime dateTime) {
    return DateFormat(DATE_FORMAT).format(dateTime);
  }
}
