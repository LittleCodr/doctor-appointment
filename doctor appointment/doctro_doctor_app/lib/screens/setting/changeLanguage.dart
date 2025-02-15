import 'dart:convert';
import 'package:doctro/constant/app_string.dart';
import 'package:doctro/constant/color_constant.dart';
import 'package:doctro/constant/prefConstatnt.dart';
import 'package:doctro/constant/preferences.dart';
import 'package:doctro/localization/language_model.dart';
import 'package:doctro/localization/localization_constant.dart';
import 'package:doctro/main.dart';
import 'package:doctro/model/UpdateProfile.dart';
import 'package:doctro/model/doctor_profile.dart';
import 'package:doctro/retrofit/api_header.dart';
import 'package:doctro/retrofit/base_model.dart';
import 'package:doctro/retrofit/network_api.dart';
import 'package:doctro/retrofit/server_error.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ChangeLanguage extends StatefulWidget {
  const ChangeLanguage({Key? key}) : super(key: key);

  @override
  _ChangeLanguageState createState() => _ChangeLanguageState();
}

class _ChangeLanguageState extends State<ChangeLanguage> {
  Future? languageLoader;

  //profile image
  String? name;

  var convertDegree;
  var eduCertificate;

  String callDegree = '';
  String callCollege = '';
  String callYear = '';
  String callCertificate = '';
  String callCertificateYear = '';
  String valueDegree = '';
  String valueCollege = '';
  String valueYear = '';
  String certificate = '';
  String certificateYear = '';

  //Select Dob
  DateTime? _selectedDate;
  String newDateApiPass = "";
  String? showFormat = '';
  var temp;

  //Doctor Profile Controller
  TextEditingController _pDegree = TextEditingController();
  TextEditingController _pExperience = TextEditingController();
  TextEditingController _pStartTime = TextEditingController();
  TextEditingController _pEndTime = TextEditingController();
  TextEditingController _pTimeSlot = TextEditingController();
  TextEditingController _pAppointmentFees = TextEditingController();
  TextEditingController _pName = TextEditingController();
  TextEditingController _pDob = TextEditingController();
  TextEditingController _pDesc = TextEditingController();
  TextEditingController _pCollege = TextEditingController();
  TextEditingController _pCollegeYear = TextEditingController();
  TextEditingController _pCertificate = TextEditingController();
  TextEditingController _pCertificateYear = TextEditingController();
  TextEditingController _pBasedOn = TextEditingController();

  final picker = ImagePicker();

  //Set DropDown Popular Field
  List<String> popular = [];
  String? _selectedPopular;

  //Set DropDown For Male/Female
  List<String> gender = [];
  String? _genderSelect;

  int? isFilled;

  int? treatmentId;

  int? categoryId;
  int? expertiseId;
  String? hospitalId;

  //Choose Images
  String? image;

  //Set MediaQuery Height / Width
  double? width;
  double? height;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    gender = [
      getTranslated(context, AppString.gender_male).toString(),
      getTranslated(context, AppString.gender_female).toString(),
    ];

    popular = [
      getTranslated(context, AppString.popular_yes).toString(),
      getTranslated(context,AppString.popular_no).toString(),
    ];
  }

  @override
  void initState() {
    super.initState();
    languageLoader = doctorProfile();
    name = SharedPreferenceHelper.getString(Preferences.name);
    isFilled = SharedPreferenceHelper.getInt(Preferences.is_filled);
    image = SharedPreferenceHelper.getString(Preferences.image);
  }

  int? value;

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: colorWhite,
          leadingWidth: 40,
          leading: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: colorBlack,
                size: 30,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          title: Text(
            getTranslated(context, AppString.chang_language).toString(),
            style: TextStyle(color: hintColor, fontSize: 18),
          ),
        ),
        body: FutureBuilder(
            future: languageLoader,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return GestureDetector(
                  onTap: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                        itemCount: Language.languageList().length,
                        itemBuilder: (context, index) {
                          this.value = 0;
                          this.value = Language.languageList()[index].languageCode == SharedPreferenceHelper.getString(Preferences.current_language_code) ? index : null;
                          if (SharedPreferenceHelper.getString(Preferences.current_language_code) == 'N_A') {
                            this.value = 0;
                          }

                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(boxShadow: [
                                BoxShadow(
                                  color: grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 7,
                                  offset: Offset(0, 3), // changes position of shadow
                                ),
                              ], color: colorWhite, borderRadius: BorderRadius.circular(20)),
                              height: height * 0.1,
                              width: width,
                              child: Center(
                                  child: RadioListTile(
                                value: index,
                                controlAffinity: ListTileControlAffinity.trailing,
                                groupValue: this.value,
                                activeColor: colorBlack,
                                onChanged: (dynamic value) async {
                                  Future.delayed(Duration(seconds: 1), () async {
                                    this.value = value;
                                    Locale local = await setLocale(Language.languageList()[index].languageCode);
                                    setState(() {
                                      MyApp.setLocale(context, local);
                                      SharedPreferenceHelper.setString(Preferences.current_language_code, Language.languageList()[index].languageCode);
                                      SharedPreferenceHelper.setString(Preferences.language_name, Language.languageList()[index].name);
                                      updateProfile();
                                      Navigator.popAndPushNamed(context, "loginHome");
                                    });
                                  });
                                },
                                title: Text(Language.languageList()[index].name),
                              )),
                            ),
                          );
                        }),
                  ),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }));
  }

  Future<BaseModel<DoctorProfile>> doctorProfile() async {
    DoctorProfile response;

    try {
      response = await RestClient(RetroApi().dioData()).doctorProfile();
      setState(() {
        if (response.data!.education != null) {
          convertDegree = json.decode(response.data!.education!);
        }

        if (response.data!.certificate != null) {
          eduCertificate = json.decode(response.data!.certificate!);
        }

        _pName.text = response.data!.name!;
        showFormat = response.data!.dob;
        newDateApiPass = DateUtil().formattedDate(DateTime.parse('$showFormat'));
        _pDob.text = newDateApiPass;

        _genderSelect = response.data!.gender!;

        if (convertDegree != null) {
          for (int i = 0; i < convertDegree.length; i++) {
            //Split Data Condition
            if (_pDegree.text.length == 0) {
              _pDegree.text = _pDegree.text + convertDegree[i]['degree'];
            } else {
              _pDegree.text = _pDegree.text + ',' + convertDegree[i]['degree'];
            }
            if (_pCollege.text.length == 0) {
              _pCollege.text = _pCollege.text + convertDegree[i]['college'];
            } else {
              _pCollege.text = _pCollege.text + ',' + convertDegree[i]['college'];
            }
            if (_pCollegeYear.text.length == 0) {
              _pCollegeYear.text = _pCollegeYear.text + convertDegree[i]['year'];
            } else {
              _pCollegeYear.text = _pCollegeYear.text + ',' + convertDegree[i]['year'];
            }
          }
        }

        if (eduCertificate != null) {
          for (int i = 0; i < eduCertificate.length; i++) {
            if (_pCertificate.text.length == 0) {
              _pCertificate.text = _pCertificate.text + eduCertificate[i]['certificate'];
            } else {
              _pCertificate.text = _pCertificate.text + ',' + eduCertificate[i]['certificate'];
            }

            if (_pCertificateYear.text.length == 0) {
              _pCertificateYear.text = _pCertificateYear.text + eduCertificate[i]['certificate_year'];
            } else {
              _pCertificateYear.text = _pCertificateYear.text + ',' + eduCertificate[i]['certificate_year'];
            }
          }
        }

        _pExperience.text = response.data!.experience!;
        _pAppointmentFees.text = response.data!.appointmentFees!;
        _pTimeSlot.text = response.data!.timeslot!;
        _pStartTime.text = response.data!.startTime!;
        _pEndTime.text = response.data!.endTime!;
        _pBasedOn.text = response.data!.basedOn!;
        _pDesc.text = response.data!.desc!;

        _selectedPopular = response.data!.isPopular.toString();

        treatmentId = response.data!.treatmentId!;
        categoryId = response.data!.categoryId;
        expertiseId = response.data!.expertiseId;
        hospitalId = response.data!.hospitalId;

        setState(() {});
      });
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<UpdateProfile>> updateProfile() async {
    var eEducationList = JsonEncoder().convert(convertDegree);
    var cCertificateList = JsonEncoder().convert(eduCertificate);

    //pass date formate
    if (_selectedDate != null) {
      temp = '$_selectedDate';
    } else {
      temp = '$showFormat';
    }

    newDateApiPass = DateUtilForPass().formattedDate(DateTime.parse('$temp'));
    Map<String, dynamic> body = {
      "name": _pName.text,
      "treatment_id": treatmentId,
      "category_id": categoryId,
      "expertise_id": expertiseId,
      "hospital_id": hospitalId,
      "dob": newDateApiPass,
      "gender": _genderSelect,
      "education": eEducationList,
      "certificate": cCertificateList,
      "experience": _pExperience.text,
      "appointment_fees": _pAppointmentFees.text,
      "start_time": _pStartTime.text.toLowerCase(),
      "end_time": _pEndTime.text.toLowerCase(),
      "timeslot": _pTimeSlot.text,
      "desc": _pDesc.text,
      "besdon": _pBasedOn.text,
      "is_popular": _selectedPopular == getTranslated(context, AppString.popular_yes).toString() ? 1 : 0,
      "language": SharedPreferenceHelper.getString(Preferences.language_name)
    };

    UpdateProfile response;

    try {
      response = await RestClient(RetroApi().dioData()).updateProfile(body);
      Navigator.pushNamed(context, "loginHome");
      SharedPreferenceHelper.setInt(Preferences.is_filled, 1);

      Fluttertoast.showToast(
        msg: response.msg!,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}

//Pass Date Like this format  in api
class DateUtilForPass {
  static const DATE_FORMAT = 'yyyy-MM-dd';

  String formattedDate(DateTime dateTime) {
    return DateFormat(DATE_FORMAT).format(dateTime);
  }
}

//Show Date like this format in User
class DateUtil {
  static const DATE_FORMAT = 'dd-MM-yyyy';

  String formattedDate(DateTime dateTime) {
    return DateFormat(DATE_FORMAT).format(dateTime);
  }
}
