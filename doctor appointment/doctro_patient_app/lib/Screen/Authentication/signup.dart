import 'package:country_picker/country_picker.dart';
import 'package:doctro_patient/api/retrofit_Api.dart';
import 'package:doctro_patient/api/network_api.dart';
import 'package:doctro_patient/Screen/Authentication/phoneVerification.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../AppointmentRelatedScreen/BookAppointment.dart';
import '../../api/base_model.dart';
import '../../api/server_error.dart';
import '../../const/Palette.dart';
import '../../const/app_string.dart';
import '../../const/prefConstatnt.dart';
import '../../localization/localization_constant.dart';
import '../../model/register_model.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController _name = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _phone = TextEditingController();
  TextEditingController _phoneCode = TextEditingController();
  TextEditingController _dob = TextEditingController();
  TextEditingController _password = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _isHidden = true;

  DateTime? _selectedDate;
  List<String> gender = [];
  String? _selectGender;
  int? id;
  int? verify;

  String newDateApiPass = "";
  var temp;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      gender = [getTranslated(context, AppString.signUp_male).toString(), getTranslated(context, AppString.signUp_female).toString()];
    });
  }

  @override
  Widget build(BuildContext context) {
    double width;
    double height;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(width, height * 0.05),
        child: SafeArea(
          child: Container(
            alignment: AlignmentDirectional.topStart,
            child: GestureDetector(
              child: Padding(
                padding: const EdgeInsets.all(15),
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
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      getTranslated(context, AppString.signUp_title).toString(),
                      style: TextStyle(
                        fontSize: width * 0.07,
                        fontWeight: FontWeight.bold,
                        color: Palette.dark_blue,
                      ),
                    ),
                    Column(
                      children: [
                        SizedBox(
                          height: 30,
                        ),

                        /// Name ///
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Palette.dark_white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextFormField(
                            controller: _name,
                            keyboardType: TextInputType.text,
                            textAlignVertical: TextAlignVertical.center,
                            textCapitalization: TextCapitalization.words,
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z ]'))],
                            style: TextStyle(
                              fontSize: 16,
                              color: Palette.dark_blue,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: getTranslated(context, AppString.signUp_userName_hint).toString(),
                              hintStyle: TextStyle(
                                fontSize: 16,
                                color: Palette.dark_grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            validator: (String? value) {
                              value!.trim();
                              if (value.isEmpty) {
                                return getTranslated(context, AppString.signUp_userName_validator1).toString();
                              } else if (value.trim().length < 1) {
                                return getTranslated(context, AppString.signUp_userName_validator2).toString();
                              }
                              return null;
                            },
                            onSaved: (String? name) {},
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),

                        /// Email ///
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                          decoration: BoxDecoration(color: Palette.dark_white, borderRadius: BorderRadius.circular(10)),
                          child: TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.text,
                            textAlignVertical: TextAlignVertical.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Palette.dark_blue,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: getTranslated(context, AppString.signUp_email_hint).toString(),
                              hintStyle: TextStyle(fontSize: 16, color: Palette.dark_grey, fontWeight: FontWeight.bold),
                            ),
                            validator: (String? value) {
                              if (value!.isEmpty) {
                                return getTranslated(context, AppString.signUp_email_validator1).toString();
                              }
                              if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                                return getTranslated(context, AppString.signUp_email_validator1).toString();
                              }
                              return null;
                            },
                            onSaved: (String? name) {},
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),

                        /// Phone No. ///
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: width * 0.2,
                              padding: EdgeInsets.symmetric(horizontal: 9, vertical: 2),
                              decoration: BoxDecoration(
                                color: Palette.dark_white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: TextFormField(
                                keyboardType: TextInputType.phone,
                                textAlign: TextAlign.center,
                                readOnly: true,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Palette.dark_blue,
                                ),
                                controller: _phoneCode,
                                decoration: InputDecoration(
                                  hintText: '+91',
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(fontSize: width * 0.04, color: Palette.dark_grey, fontWeight: FontWeight.bold),
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
                                        labelText: getTranslated(context, AppString.signUp_phoneCode_label).toString(),
                                        hintText: getTranslated(context, AppString.signUp_phoneCode_hint).toString(),
                                        prefixIcon: const Icon(Icons.search),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Palette.grey.withOpacity(0.2),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Container(
                              width: width * 0.65,
                              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                              decoration: BoxDecoration(color: Palette.dark_white, borderRadius: BorderRadius.circular(10)),
                              child: TextFormField(
                                controller: _phone,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp('[0-9]'),
                                  ),
                                  LengthLimitingTextInputFormatter(10)
                                ],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Palette.dark_blue,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: getTranslated(context, AppString.signUp_phoneNo_hint).toString(),
                                  hintStyle: TextStyle(
                                    fontSize: width * 0.04,
                                    color: Palette.dark_grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                validator: (String? value) {
                                  if (value!.isEmpty) {
                                    return getTranslated(context, AppString.signUp_phoneNo_validator1).toString();
                                  }
                                  return null;
                                },
                                onSaved: (String? name) {},
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),

                        /// Birth Date ///
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                          decoration: BoxDecoration(color: Palette.dark_white, borderRadius: BorderRadius.circular(10)),
                          child: TextFormField(
                            textCapitalization: TextCapitalization.words,
                            textAlignVertical: TextAlignVertical.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Palette.dark_blue,
                            ),
                            controller: _dob,
                            decoration: InputDecoration(
                              hintText: getTranslated(context, AppString.signUp_birthDate_hint).toString(),
                              border: InputBorder.none,
                              hintStyle: TextStyle(fontSize: width * 0.04, color: Palette.dark_grey, fontWeight: FontWeight.bold),
                            ),
                            validator: (String? value) {
                              if (value!.isEmpty) {
                                return getTranslated(context, AppString.signUp_birthDate_validator1).toString();
                              }
                              return null;
                            },
                            onTap: () {
                              _selectDate(context);
                            },
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),

                        /// Gender ///
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                          decoration: BoxDecoration(
                            color: Palette.dark_white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonFormField(
                            hint: Text(
                              getTranslated(context, AppString.signUp_selectGender_hint).toString(),
                              style: TextStyle(fontSize: 16, color: Palette.dark_grey, fontWeight: FontWeight.bold),
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                            ),
                            style: TextStyle(
                              fontSize: 16,
                              color: Palette.dark_blue,
                            ),
                            alignment: Alignment.centerLeft,
                            isExpanded: true,
                            iconSize: 25,
                            onChanged: (dynamic newValue) {
                              setState(
                                () {
                                  _selectGender = newValue;
                                },
                              );
                            },
                            validator: (dynamic value) => value == null ? getTranslated(context, AppString.signUp_selectGender_validator).toString() : null,
                            items: gender.map(
                              (location) {
                                return DropdownMenuItem<String>(
                                  child: new Text(
                                    location,
                                    style: TextStyle(
                                      fontSize: width * 0.04,
                                      color: Palette.dark_blue,
                                    ),
                                  ),
                                  value: location,
                                );
                              },
                            ).toList(),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),

                        /// Password ///
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                          decoration: BoxDecoration(color: Palette.dark_white, borderRadius: BorderRadius.circular(10)),
                          child: TextFormField(
                            controller: _password,
                            keyboardType: TextInputType.text,
                            textAlignVertical: TextAlignVertical.center,
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9@#\$&._~]'))],
                            style: TextStyle(
                              fontSize: 16,
                              color: Palette.dark_blue,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: getTranslated(context, AppString.signUp_password_hint).toString(),
                              hintStyle: TextStyle(
                                fontSize: 16,
                                color: Palette.dark_grey,
                                fontWeight: FontWeight.bold,
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
                                return getTranslated(context, AppString.signUp_password_validator1).toString();
                              }
                              if (value.length < 6) {
                                return getTranslated(context, AppString.signUp_password_validator2).toString();
                              }
                              return null;
                            },
                            onSaved: (String? name) {},
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                    Container(
                      width: width,
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ElevatedButton(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            getTranslated(context, AppString.signUp_signUp_button).toString(),
                            style: TextStyle(fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            callApiRegister();
                          } else {
                            print("Unsuccessful");
                          }
                        },
                      ),
                    ),
                    Container(
                      child: Text(
                        getTranslated(context, AppString.signUp_text).toString(),
                        style: TextStyle(fontSize: 12, color: Palette.dark_blue),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          getTranslated(context, AppString.signUp_alreadyAccount).toString(),
                          style: TextStyle(fontSize: 16, color: Palette.dark_blue),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, 'SignIn');
                          },
                          child: Text(
                            getTranslated(context, AppString.signUp_signIn_button).toString(),
                            style: TextStyle(color: Palette.blue, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<BaseModel<Register>> callApiRegister() async {
    Register response;
    newDateApiPass = DateUtilForPass().formattedDate(DateTime.parse('$_selectedDate'));
    Map<String, dynamic> body = {
      "name": _name.text,
      "email": _email.text,
      "phone": _phone.text,
      "dob": newDateApiPass,
      "gender": _selectGender,
      "password": _password.text,
      "phone_code": _phoneCode.text,
    };
    setState(() {
      Preferences.onLoading(context);
    });
    try {
      response = await RestClient(RetroApi2().dioData2()).registerRequest(body);
      if (response.success == true) {
        setState(() {
          Preferences.hideDialog(context);
          id = response.data!.id;
          response.data!.verify != 1
              ? Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PhoneVerification(id: id),
                  ),
                )
              : Navigator.pushReplacementNamed(context, "SignIn");
          Fluttertoast.showToast(
            msg: getTranslated(context, AppString.signUp_successFully_toast).toString() + " " + '${response.data!.name}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Palette.blue,
            textColor: Palette.white,
          );
        });
      }
      setState(() {
        Preferences.hideDialog(context);
      });
    } catch (error, stacktrace) {
      setState(() {
        Preferences.hideDialog(context);
      });
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
