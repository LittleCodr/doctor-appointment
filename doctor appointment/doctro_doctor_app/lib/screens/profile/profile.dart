import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctro/model/UpdateProfile.dart';
import 'package:doctro/model/doctor_profile.dart';
import 'package:doctro/model/update_profile_image.dart';
import 'package:doctro/retrofit/api_header.dart';
import 'package:doctro/retrofit/base_model.dart';
import 'package:doctro/retrofit/network_api.dart';
import 'package:doctro/constant/app_string.dart';
import 'package:doctro/constant/color_constant.dart';
import 'package:doctro/constant/prefConstatnt.dart';
import 'package:doctro/constant/preferences.dart';
import 'package:doctro/localization/localization_constant.dart';
import 'package:doctro/model/EducationCertificate.dart';
import 'package:doctro/model/EducationModel.dart';
import 'package:doctro/model/categories.dart';
import 'package:doctro/model/Treatment.dart';
import 'package:doctro/model/expertise.dart';
import 'package:doctro/model/hospital.dart';
import 'package:doctro/retrofit/server_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreen createState() => _ProfileScreen();
}

//profile image
String? name = "";
String? msg = "";

//Choose Images
String? image;

class _ProfileScreen extends State<ProfileScreen> {
  Future? doctorLoader;

  //Add List Data
  List<EducationModel> educationList = [];
  List<EducationCertificate> certificateList = [];

  bool oldPassword = false;

  //alertdialog
  TextEditingController _degree = TextEditingController();
  TextEditingController _college = TextEditingController();
  TextEditingController _completeYear = TextEditingController();
  TextEditingController _certificate = TextEditingController();
  TextEditingController _year = TextEditingController();

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
  List<String> selectedHospitals = [];

  //Set Stepper
  int _currentStep = 0;
  StepperType stepperType = StepperType.horizontal;

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

  //Set Open Drawer
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final GlobalKey<FormState> _step1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _step2 = GlobalKey<FormState>();

  //Set List Data Hospital
  List<HospitalName> hospitalReq = [];

  //Set List Data Treatment
  List<TreatmentData> treatmentReq = [];
  TreatmentData? _valueTreatment;

  //Set List Data Category
  List<CategoriesData> categoryReq = [];
  CategoriesData? _valueCategories;

  //Set List Data Expertise
  List<Expert> expertReq = [];
  Expert? _valueExpertise;

  //update user image
  File? proImage;
  final picker = ImagePicker();

  //Set DropDown Popular Field
  List<String> popular = [];
  String? _selectedPopular;

  //Set DropDown For Male/Female
  List<String> gender = [];
  String? _genderSelect;

  int? isFilled;

  //Set MediaQuery Height / Width
  double? width;
  late double height;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    gender = [
      "male",
      "female",
    ];

    popular = [
      getTranslated(context, AppString.popular_yes).toString(),
      getTranslated(context, AppString.popular_no).toString(),
    ];
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      doctorLoader = treatment();
      hospital();
      name = SharedPreferenceHelper.getString(Preferences.name);
      isFilled = SharedPreferenceHelper.getInt(Preferences.is_filled);
      image = SharedPreferenceHelper.getString(Preferences.image);
    });
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(width! * 0.3, 170),
        child: SafeArea(
          top: true,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: height * 0.02),
                color: Colors.transparent,
                child: Container(
                  margin: EdgeInsets.only(left: width! * 0.92),
                  child: GestureDetector(
                    child: Icon(
                      Icons.arrow_back_ios,
                      size: 28,
                    ),
                    onTap: () {
                      if (_currentStep == 0) Navigator.pop(context);
                      if (_currentStep == 1) cancel();
                      if (_currentStep == 2) cancel();
                    },
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: width! * 0.04, right: width! * 0.04),
                child: Row(
                  children: [
                    SizedBox(
                      height: 90,
                      width: 90,
                      child: Stack(
                        children: [
                          proImage != null
                              ? Container(
                                  width: 80,
                                  height: 80,
                                  decoration: new BoxDecoration(shape: BoxShape.circle, boxShadow: [
                                    new BoxShadow(
                                      color: imageBorder,
                                      blurRadius: 1.0,
                                    ),
                                  ]),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: Image.file(
                                      proImage!,
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                )
                              : Container(
                                  width: 82,
                                  height: 82,
                                  decoration: new BoxDecoration(shape: BoxShape.circle, boxShadow: [
                                    new BoxShadow(
                                      color: imageBorder,
                                      blurRadius: 1.5,
                                    ),
                                  ]),
                                  child: CachedNetworkImage(
                                    imageUrl: SharedPreferenceHelper.getString(Preferences.image),
                                    imageBuilder: (context, imageProvider) => CircleAvatar(
                                      backgroundColor: colorWhite,
                                      child: CircleAvatar(
                                        radius: 36,
                                        backgroundImage: imageProvider,
                                      ),
                                    ),
                                    placeholder: (context, url) => CircularProgressIndicator(color: loginButton),
                                    errorWidget: (context, url, error) => Image.asset("images/no_image.png"),
                                  ),
                                ),
                          Positioned(
                            top: 52,
                            left: 58,
                            child: GestureDetector(
                              onTap: () {
                                chooseProfileImage();
                              },
                              child: CircleAvatar(
                                  backgroundColor: colorWhite,
                                  radius: 13,
                                  child: Icon(
                                    Icons.add,
                                    color: loginButton,
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: width! * 0.05, right: width! * 0.05),
                      child: Text(
                        "$name",
                        style: TextStyle(fontSize: width! * 0.047, color: hintColor),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: FutureBuilder(
          future: doctorLoader,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Container(
                width: width,
                margin: EdgeInsets.symmetric(horizontal: 5),
                child: Column(
                  children: [
                    Expanded(
                      child: Stepper(
                        type: stepperType,
                        physics: ScrollPhysics(),
                        onStepCancel: null,
                        currentStep: _currentStep,
                        onStepTapped: (step) => tapped(step),
                        onStepContinue: continued,
                        steps: <Step>[
                          // Step 1 //
                          Step(
                            title: new Text(
                              getTranslated(context, AppString.profile_personal_information).toString(),
                              style: TextStyle(fontSize: 12),
                            ),
                            content: GestureDetector(
                              onTap: () {
                                FocusScope.of(context).requestFocus(new FocusNode());
                              },
                              child: Form(
                                key: _step1,
                                child: SingleChildScrollView(
                                  child: Container(
                                    child: Column(
                                      children: [
                                        Container(
                                          alignment: Alignment.topLeft,
                                          margin: EdgeInsets.only(top: width! * 0.01),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                getTranslated(context, AppString.profile_doctor_name).toString(),
                                                style: TextStyle(fontSize: width! * 0.04, color: hintColor),
                                              ),
                                              TextFormField(
                                                controller: _pName,
                                                enableInteractiveSelection: false,
                                                keyboardType: TextInputType.name,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]")),
                                                ],
                                                style: TextStyle(fontSize: 14, color: passwordVisibility),
                                                decoration: InputDecoration(
                                                  hintText: getTranslated(context, AppString.profile_enter_name_hint).toString(),
                                                  hintStyle: TextStyle(fontSize: width! * 0.035, color: passwordVisibility),
                                                ),
                                                validator: (String? value) {
                                                  if (value!.isEmpty) {
                                                    return getTranslated(context, AppString.please_enter_profile_valid_name).toString();
                                                  } else if (value.trim().length < 1) {
                                                    return getTranslated(context, AppString.please_enter_valid_name).toString();
                                                  }
                                                  return null;
                                                },
                                                onSaved: (String? name) {},
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          alignment: Alignment.topLeft,
                                          margin: EdgeInsets.only(top: width! * 0.01),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                getTranslated(context, AppString.profile_date_of_birth).toString(),
                                                style: TextStyle(fontSize: width! * 0.04, color: hintColor),
                                              ),
                                              TextFormField(
                                                textCapitalization: TextCapitalization.words,
                                                enableInteractiveSelection: false,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: hintColor,
                                                ),
                                                controller: _pDob,
                                                readOnly: true,
                                                decoration: InputDecoration(
                                                  hintText: getTranslated(context, AppString.profile_date_of_birth_hint).toString(),
                                                  hintStyle: TextStyle(
                                                    fontSize: width! * 0.04,
                                                    color: hintColor,
                                                  ),
                                                ),
                                                validator: (String? value) {
                                                  if (value!.isEmpty) {
                                                    return getTranslated(context, AppString.please_enter_birth_date).toString();
                                                  }
                                                  return null;
                                                },
                                                onTap: () {
                                                  _selectDate(context);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              getTranslated(context, AppString.select_hospital).toString(),
                                              style: TextStyle(fontSize: width! * 0.04, color: hintColor),
                                            ),
                                            ListView.builder(
                                              shrinkWrap: true,
                                              physics: NeverScrollableScrollPhysics(),
                                              itemCount: hospitalReq.length,
                                              itemBuilder: (context, index) {
                                                return CheckboxListTile(
                                                  value: hospitalReq[index].isSelected,
                                                  title: Text(hospitalReq[index].name!),
                                                  onChanged: (val) {
                                                    setState(
                                                      () {
                                                        hospitalReq[index].isSelected = val!;
                                                      },
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                        Divider(
                                          height: 4,
                                        ),
                                        Container(
                                          alignment: Alignment.topLeft,
                                          margin: EdgeInsets.only(top: width! * 0.02),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                getTranslated(context, AppString.profile_gender).toString(),
                                                style: TextStyle(fontSize: width! * 0.038, color: hintColor),
                                              ),
                                              StatefulBuilder(
                                                builder: (context, myState) {
                                                  return DropdownButtonFormField<String>(
                                                    hint: Text(getTranslated(context, AppString.profile_gender_hint).toString()),
                                                    value: _genderSelect,
                                                    isExpanded: true,
                                                    iconSize: 35,
                                                    items: gender.map((genders) {
                                                      return DropdownMenuItem<String>(
                                                        child: new Text(genders),
                                                        value: genders,
                                                      );
                                                    }).toList(),
                                                    onSaved: (value) {
                                                      myState(() {
                                                        _genderSelect = value;
                                                      });
                                                    },
                                                    onChanged: (newValue) {
                                                      myState(() {
                                                        _genderSelect = newValue;
                                                      });
                                                    },
                                                    validator: (value) {
                                                      if (_genderSelect == null) {
                                                        return getTranslated(context, AppString.please_enter_profile_valid_name).toString();
                                                      }
                                                      return null;
                                                    },
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          alignment: Alignment.topLeft,
                                          margin: EdgeInsets.only(top: width! * 0.02),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                getTranslated(context, AppString.profile_description).toString(),
                                                style: TextStyle(fontSize: width! * 0.04, color: hintColor),
                                              ),
                                              TextFormField(
                                                controller: _pDesc,
                                                enableInteractiveSelection: false,
                                                keyboardType: TextInputType.name,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter.allow(RegExp("[a-zA-Z &.,]")),
                                                ],
                                                style: TextStyle(fontSize: 14, color: passwordVisibility),
                                                decoration: InputDecoration(
                                                  hintText: getTranslated(context, AppString.profile_description_hint).toString(),
                                                  hintStyle: TextStyle(fontSize: width! * 0.035, color: passwordVisibility),
                                                ),
                                                validator: (String? value) {
                                                  if (value!.isEmpty) {
                                                    return getTranslated(context, AppString.please_enter_description).toString();
                                                  } else if (value.trim().length < 1) {
                                                    return getTranslated(context, AppString.please_enter_valid_description).toString();
                                                  }
                                                  return null;
                                                },
                                                onSaved: (String? name) {},
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            isActive: _currentStep >= 0,
                            state: _currentStep >= 0 ? StepState.complete : StepState.disabled,
                          ),
                          // Step 2 //
                          Step(
                            title: new Text(
                              getTranslated(context, AppString.profile_education_information).toString(),
                              style: TextStyle(fontSize: 12),
                              textAlign: TextAlign.start,
                            ),
                            content: Form(
                              key: _step2,
                              child: SingleChildScrollView(
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        alignment: Alignment.topLeft,
                                        margin: EdgeInsets.only(top: width! * 0.01),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              getTranslated(context, AppString.profile_degree).toString(),
                                              style: TextStyle(fontSize: width! * 0.038, color: hintColor),
                                            ),
                                            TextFormField(
                                              controller: _pDegree,
                                              keyboardType: TextInputType.text,
                                              style: TextStyle(fontSize: 14, color: passwordVisibility),
                                              decoration: InputDecoration(
                                                hintText: getTranslated(context, AppString.profile_degree_hint).toString(),
                                                hintStyle: TextStyle(fontSize: width! * 0.035, color: passwordVisibility),
                                              ),
                                              validator: (String? value) {
                                                if (value!.isEmpty) {
                                                  return getTranslated(context, AppString.please_enter_degree).toString();
                                                } else if (value.trim().length < 1) {
                                                  return getTranslated(context, AppString.please_enter_valid_degree).toString();
                                                }
                                                return null;
                                              },
                                              onSaved: (String? name) {},
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.topLeft,
                                        margin: EdgeInsets.only(top: width! * 0.01),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              getTranslated(context, AppString.profile_college).toString(),
                                              style: TextStyle(fontSize: width! * 0.038, color: hintColor),
                                            ),
                                            TextFormField(
                                              controller: _pCollege,
                                              keyboardType: TextInputType.text,
                                              style: TextStyle(fontSize: 14, color: passwordVisibility),
                                              decoration: InputDecoration(
                                                hintText: getTranslated(context, AppString.profile_college_hint).toString(),
                                                hintStyle: TextStyle(fontSize: width! * 0.035, color: passwordVisibility),
                                              ),
                                              validator: (String? value) {
                                                if (value!.isEmpty) {
                                                  return getTranslated(context, AppString.please_enter_college).toString();
                                                } else if (value.trim().length < 1) {
                                                  return getTranslated(context, AppString.please_enter_valid_college).toString();
                                                }
                                                return null;
                                              },
                                              onSaved: (String? name) {},
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.topLeft,
                                        margin: EdgeInsets.only(top: width! * 0.01),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              getTranslated(context, AppString.profile_year_of_completion).toString(),
                                              style: TextStyle(fontSize: width! * 0.038, color: hintColor),
                                            ),
                                            TextFormField(
                                              controller: _pCollegeYear,
                                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                                              inputFormatters: [new FilteringTextInputFormatter.allow(RegExp("[0-9]"))],
                                              style: TextStyle(fontSize: 14, color: passwordVisibility),
                                              decoration: InputDecoration(
                                                hintText: getTranslated(context, AppString.profile_year_hint).toString(),
                                                hintStyle: TextStyle(fontSize: width! * 0.035, color: passwordVisibility),
                                              ),
                                              validator: (String? value) {
                                                if (value!.isEmpty) {
                                                  return getTranslated(context, AppString.please_enter_year_of_completion).toString();
                                                }
                                                return null;
                                              },
                                              onSaved: (String? name) {},
                                            ),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  insetPadding: EdgeInsets.all(10),
                                                  title: Text(getTranslated(context, AppString.profile_education_certificate).toString()),
                                                  content: Container(
                                                    height: height * 0.3,
                                                    width: width! * 1.0,
                                                    child: Column(
                                                      children: [
                                                        TextField(
                                                          onChanged: (value) {
                                                            setState(() {
                                                              valueDegree = value;
                                                            });
                                                          },
                                                          controller: _degree,
                                                          decoration: InputDecoration(hintText: getTranslated(context, AppString.profile_dialog_degree_hint).toString()),
                                                        ),
                                                        TextField(
                                                          onChanged: (value) {
                                                            setState(() {
                                                              valueCollege = value;
                                                            });
                                                          },
                                                          controller: _college,
                                                          decoration: InputDecoration(hintText: getTranslated(context, AppString.profile_dialog_education).toString()),
                                                        ),
                                                        TextField(
                                                          onChanged: (value) {
                                                            setState(() {
                                                              valueYear = value;
                                                            });
                                                          },
                                                          controller: _completeYear,
                                                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                          inputFormatters: [new FilteringTextInputFormatter.allow(RegExp("[0-9]"))],
                                                          decoration: InputDecoration(hintText: getTranslated(context, AppString.profile_dialog_year_of_completion).toString()),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    OutlinedButton(
                                                      child: Text(getTranslated(context, AppString.profile_dialog_ok_button).toString()),
                                                      onPressed: () {
                                                        setState(() {
                                                          if (_degree.text.isNotEmpty && _college.text.isNotEmpty && _completeYear.text.isNotEmpty) {
                                                            String addDegree = "";
                                                            String addCollege = "";
                                                            String addYear = "";
                                                            callDegree = valueDegree;
                                                            callCollege = valueCollege;
                                                            callYear = valueYear;
                                                            addDegree = _pDegree.text + "," + _degree.text;
                                                            addCollege = _pCollege.text + "," + _college.text;
                                                            addYear = _pCollegeYear.text + "," + _completeYear.text;

                                                            _pDegree.text = addDegree;
                                                            _pCollege.text = addCollege;
                                                            _pCollegeYear.text = addYear;
                                                            _degree.clear();
                                                            _college.clear();
                                                            _completeYear.clear();
                                                            Navigator.pop(context);
                                                          } else {
                                                            Fluttertoast.showToast(
                                                              msg: getTranslated(context, AppString.please_fill_data).toString(),
                                                              toastLength: Toast.LENGTH_SHORT,
                                                              gravity: ToastGravity.BOTTOM,
                                                            );
                                                          }
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                );
                                              });
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(top: height * 0.01),
                                          height: width! * 0.10,
                                          width: width! * 0.35,
                                          child: Row(
                                            children: [
                                              Card(
                                                color: divider,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(45)),
                                                child: Icon(Icons.add, size: width! * 0.06, color: loginButton),
                                              ),
                                              Text(getTranslated(context, AppString.profile_add_more_button).toString())
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.topLeft,
                                        margin: EdgeInsets.only(top: width! * 0.03),
                                        child: Column(
                                          children: [
                                            Text(
                                              getTranslated(context, AppString.profile_dialog_certificate).toString(),
                                              style: TextStyle(fontSize: width! * 0.038, color: hintColor),
                                            )
                                          ],
                                        ),
                                      ),
                                      TextFormField(
                                        controller: _pCertificate,
                                        keyboardType: TextInputType.text,
                                        style: TextStyle(fontSize: 14, color: passwordVisibility),
                                        decoration: InputDecoration(
                                          hintText: getTranslated(context, AppString.profile_dialog_certificate_hint).toString(),
                                          hintStyle: TextStyle(fontSize: width! * 0.035, color: passwordVisibility),
                                        ),
                                        validator: (String? value) {
                                          if (value!.isEmpty) {
                                            return getTranslated(context, AppString.dialog_please_enter_certificate).toString();
                                          } else if (value.trim().length < 1) {
                                            return getTranslated(context, AppString.dialog_please_enter_valid_certificate).toString();
                                          }
                                          return null;
                                        },
                                        onSaved: (String? name) {},
                                      ),
                                      Container(
                                        alignment: Alignment.topLeft,
                                        margin: EdgeInsets.only(top: width! * 0.02),
                                        child: Column(
                                          children: [
                                            Text(
                                              getTranslated(context, AppString.profile_dialog_certificate_year).toString(),
                                              style: TextStyle(fontSize: width! * 0.038, color: hintColor),
                                            )
                                          ],
                                        ),
                                      ),
                                      TextFormField(
                                        controller: _pCertificateYear,
                                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                                        inputFormatters: [new FilteringTextInputFormatter.allow(RegExp("[0-9]"))],
                                        style: TextStyle(fontSize: 14, color: passwordVisibility),
                                        decoration: InputDecoration(
                                          hintText: getTranslated(context, AppString.profile_dialog_certificate_year_hint).toString(),
                                          hintStyle: TextStyle(fontSize: width! * 0.035, color: passwordVisibility),
                                        ),
                                        validator: (String? value) {
                                          if (value!.isEmpty) {
                                            return getTranslated(context, AppString.dialog_please_enter_certificate_year).toString();
                                          }
                                          return null;
                                        },
                                        onSaved: (String? name) {},
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: height * 0.02),
                                        height: width! * 0.10,
                                        width: width! * 0.35,
                                        child: GestureDetector(
                                          onTap: () {
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    insetPadding: EdgeInsets.all(10),
                                                    title: Text(getTranslated(context, AppString.profile_dialog_certificate).toString()),
                                                    content: Container(
                                                      height: height * 0.2,
                                                      width: width! * 1.0,
                                                      child: Column(
                                                        children: [
                                                          TextField(
                                                            onChanged: (value) {
                                                              setState(() {
                                                                certificate = value;
                                                              });
                                                            },
                                                            controller: _certificate,
                                                            decoration: InputDecoration(hintText: getTranslated(context, AppString.profile_dialog_certificate).toString()),
                                                          ),
                                                          TextField(
                                                            onChanged: (value) {
                                                              setState(() {
                                                                certificateYear = value;
                                                              });
                                                            },
                                                            controller: _year,
                                                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                            inputFormatters: [new FilteringTextInputFormatter.allow(RegExp("[0-9]"))],
                                                            decoration: InputDecoration(hintText: getTranslated(context, AppString.profile_dialog_year).toString()),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    actions: <Widget>[
                                                      OutlinedButton(
                                                        child: Text(getTranslated(context, AppString.profile_dialog_ok_button).toString()),
                                                        onPressed: () {
                                                          setState(() {
                                                            if (_certificate.text.isNotEmpty && _year.text.isNotEmpty) {
                                                              String addCertificate = "";
                                                              String addCertificateYear = "";
                                                              callCertificate = certificate;
                                                              callCertificateYear = certificateYear;

                                                              addCertificate = _pCertificate.text + "," + _certificate.text;
                                                              addCertificateYear = _pCertificateYear.text + "," + _year.text;
                                                              _pCertificate.text = addCertificate;
                                                              _pCertificateYear.text = addCertificateYear;

                                                              _certificate.clear();
                                                              _year.clear();
                                                              Navigator.pop(context);
                                                            } else {
                                                              Fluttertoast.showToast(
                                                                msg: getTranslated(context, AppString.please_fill_data).toString(),
                                                                toastLength: Toast.LENGTH_SHORT,
                                                                gravity: ToastGravity.BOTTOM,
                                                              );
                                                            }
                                                          });
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                });
                                          },
                                          child: Row(
                                            children: [
                                              Card(
                                                color: divider,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(45)),
                                                child: Icon(Icons.add, size: width! * 0.06, color: loginButton),
                                              ),
                                              Text(getTranslated(context, AppString.profile_add_more_button).toString())
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            isActive: _currentStep >= 0,
                            state: _currentStep >= 1 ? StepState.complete : StepState.disabled,
                          ),
                          // Step 3 //
                          Step(
                            title: new Text(
                              getTranslated(context, AppString.profile_other_information).toString(),
                              style: TextStyle(fontSize: 12),
                            ),
                            content: Form(
                              key: _formkey,
                              child: SingleChildScrollView(
                                child: Container(
                                  child: Column(
                                    children: [
                                      Container(
                                        alignment: Alignment.topLeft,
                                        margin: EdgeInsets.only(top: width! * 0.02),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              getTranslated(context, AppString.profile_experience).toString(),
                                              style: TextStyle(fontSize: width! * 0.038, color: hintColor),
                                            ),
                                            TextFormField(
                                              enableInteractiveSelection: false,
                                              controller: _pExperience,
                                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                                              inputFormatters: [
                                                new FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                                              ],
                                              style: TextStyle(fontSize: 14, color: passwordVisibility),
                                              decoration: InputDecoration(
                                                hintText: getTranslated(context, AppString.profile_experience_hint).toString(),
                                                hintStyle: TextStyle(fontSize: width! * 0.035, color: passwordVisibility),
                                              ),
                                              validator: (String? value) {
                                                if (value!.isEmpty) {
                                                  return getTranslated(context, AppString.please_enter_experience).toString();
                                                }
                                                return null;
                                              },
                                              onSaved: (String? name) {},
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.topLeft,
                                        margin: EdgeInsets.only(top: width! * 0.02),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              getTranslated(context, AppString.profile_appointment_fees).toString(),
                                              style: TextStyle(fontSize: width! * 0.038, color: hintColor),
                                            ),
                                            TextFormField(
                                              enableInteractiveSelection: false,
                                              controller: _pAppointmentFees,
                                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                                              inputFormatters: [
                                                new FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                                              ],
                                              style: TextStyle(fontSize: 14, color: passwordVisibility),
                                              decoration: InputDecoration(
                                                hintText: getTranslated(context, AppString.profile_appointment_fees_hint).toString(),
                                                hintStyle: TextStyle(fontSize: width! * 0.035, color: passwordVisibility),
                                              ),
                                              validator: (String? value) {
                                                if (value!.isEmpty) {
                                                  return getTranslated(context, AppString.please_enter_appointment_fees).toString();
                                                }
                                                return null;
                                              },
                                              onSaved: (String? name) {},
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.topLeft,
                                        margin: EdgeInsets.only(top: width! * 0.02),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              getTranslated(context, AppString.profile_treatment).toString(),
                                              style: TextStyle(fontSize: width! * 0.038, color: hintColor),
                                            ),
                                            DropdownButtonFormField<TreatmentData>(
                                              value: _valueTreatment,
                                              isExpanded: true,
                                              focusColor: red,
                                              iconSize: 35,
                                              items: treatmentReq.length > 1
                                                  ? treatmentReq.map((TreatmentData item) {
                                                      return DropdownMenuItem(
                                                        child: Text(item.name!, style: TextStyle(color: hintColor)),
                                                        value: item,
                                                      );
                                                    }).toList()
                                                  : treatmentReq.map((TreatmentData item) {
                                                      return DropdownMenuItem(
                                                        child: Text(item.name!, style: TextStyle(color: hintColor)),
                                                        value: item,
                                                      );
                                                    }).toList(),
                                              onChanged: (value) {
                                                _valueTreatment = value;
                                                categoryReq.clear();
                                                expertReq.clear();
                                                _valueCategories = null;
                                                _valueExpertise = null;
                                                setState(() {});
                                                FutureBuilder<BaseModel<Categories>>(
                                                  future: category(value!.id, 0, 0),
                                                  builder: (context, snapshot) {
                                                    if (snapshot.connectionState != ConnectionState.done) {
                                                      return Container(
                                                        child: CircularProgressIndicator(),
                                                      );
                                                    } else {
                                                      categoryReq.addAll(snapshot.data!.data!.categoriesData!);
                                                      var data = snapshot.data;

                                                      if (data != null) {
                                                        return Container();
                                                      } else {
                                                        return Container();
                                                      }
                                                    }
                                                  },
                                                );
                                              },
                                              hint: Text(getTranslated(context, AppString.profile_treatment_hint).toString()),
                                              validator: (value) {
                                                if (_valueTreatment == null) {
                                                  return getTranslated(context, AppString.please_select_treatment).toString();
                                                }
                                                return null;
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.topLeft,
                                        margin: EdgeInsets.only(top: width! * 0.02),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              getTranslated(context, AppString.profile_categories).toString(),
                                              style: TextStyle(fontSize: width! * 0.038, color: hintColor),
                                            ),
                                            DropdownButtonFormField<CategoriesData>(
                                              value: _valueCategories,
                                              isExpanded: true,
                                              focusColor: red,
                                              iconSize: 35,
                                              items: categoryReq.length > 1
                                                  ? categoryReq.map((CategoriesData item) {
                                                      return DropdownMenuItem<CategoriesData>(
                                                        child: Text(item.name!, style: TextStyle(color: hintColor)),
                                                        value: item,
                                                      );
                                                    }).toList()
                                                  : categoryReq.map((CategoriesData item) {
                                                      return DropdownMenuItem<CategoriesData>(
                                                        child: Text(item.name!, style: TextStyle(color: hintColor)),
                                                        value: item,
                                                      );
                                                    }).toList(),
                                              onChanged: (CategoriesData? value) {
                                                setState(() {
                                                  _valueCategories = value;
                                                  FutureBuilder<BaseModel<Expertise>>(
                                                    future: expertise(value!.id, 0),
                                                    builder: (context, snapshot) {
                                                      if (snapshot.connectionState != ConnectionState.done) {
                                                        return Center(
                                                          child: CircularProgressIndicator(),
                                                        );
                                                      } else {
                                                        categoryReq.clear();
                                                        expertReq.addAll(snapshot.data!.data!.expertiseData!);
                                                        var data = snapshot.data;
                                                        if (data != null) {
                                                          return Container();
                                                        } else {
                                                          return Container();
                                                        }
                                                      }
                                                    },
                                                  );
                                                });
                                              },
                                              hint: Text(getTranslated(context, AppString.profile_categories_hint).toString()),
                                              validator: (value) {
                                                if (_valueCategories == null) {
                                                  return getTranslated(context, AppString.please_select_categories).toString();
                                                }
                                                return null;
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.topLeft,
                                        margin: EdgeInsets.only(top: width! * 0.02),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              getTranslated(context, AppString.profile_expertise).toString(),
                                              style: TextStyle(fontSize: width! * 0.038, color: hintColor),
                                            ),
                                            DropdownButtonFormField<Expert>(
                                              value: _valueExpertise,
                                              isExpanded: true,
                                              focusColor: red,
                                              iconSize: 35,
                                              items: expertReq.length > 1
                                                  ? expertReq.map((Expert item) {
                                                      return DropdownMenuItem<Expert>(
                                                        child: Text(item.name!, style: TextStyle(color: hintColor)),
                                                        value: item,
                                                      );
                                                    }).toList()
                                                  : expertReq.map((Expert item) {
                                                      return DropdownMenuItem<Expert>(
                                                        child: Text(
                                                          item.name!,
                                                          style: TextStyle(color: hintColor),
                                                        ),
                                                        value: item,
                                                      );
                                                    }).toList(),
                                              onChanged: (Expert? value) {
                                                setState(() {
                                                  _valueExpertise = value;
                                                  FutureBuilder<BaseModel<Expertise>>(
                                                    future: expertise(value!.id, 0),
                                                    builder: (context, snapshot) {
                                                      if (snapshot.connectionState != ConnectionState.done) {
                                                        return Container();
                                                      } else {
                                                        expertReq.clear();
                                                        expertReq.addAll(snapshot.data!.data!.expertiseData!);
                                                        var data = snapshot.data;
                                                        if (data != null) {
                                                          return Container();
                                                        } else {
                                                          return Container();
                                                        }
                                                      }
                                                    },
                                                  );
                                                });
                                              },
                                              hint: Text(getTranslated(context, AppString.profile_expertise_hint).toString()),
                                              validator: (value) {
                                                if (_valueExpertise == null) {
                                                  return getTranslated(context, AppString.please_select_expertise).toString();
                                                }
                                                return null;
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.topLeft,
                                        margin: EdgeInsets.only(top: width! * 0.02),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              getTranslated(context, AppString.profile_time_slot).toString(),
                                              style: TextStyle(fontSize: width! * 0.038, color: hintColor),
                                            ),
                                            TextFormField(
                                              enableInteractiveSelection: false,
                                              controller: _pTimeSlot,
                                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                                              inputFormatters: [
                                                new FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                                              ],
                                              style: TextStyle(fontSize: 14, color: passwordVisibility),
                                              decoration: InputDecoration(
                                                hintText: getTranslated(context, AppString.profile_time_slot_hint).toString(),
                                                hintStyle: TextStyle(fontSize: width! * 0.035, color: passwordVisibility),
                                              ),
                                              validator: (String? value) {
                                                if (value!.isEmpty) {
                                                  return getTranslated(context, AppString.please_enter_time_slot).toString();
                                                }
                                                return null;
                                              },
                                              onSaved: (String? name) {},
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.topLeft,
                                        margin: EdgeInsets.only(top: width! * 0.02),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              getTranslated(context, AppString.revenue_model).toString(),
                                              style: TextStyle(fontSize: width! * 0.038, color: hintColor),
                                            ),
                                            TextFormField(
                                              enableInteractiveSelection: false,
                                              controller: _pBasedOn,
                                              readOnly: true,
                                              style: TextStyle(fontSize: 14, color: passwordVisibility),
                                              decoration: InputDecoration(
                                                hintText:
                                                    getTranslated(context, AppString.revenue_model_hint).toString() +
                                                        " " +
                                                        ("${getTranslated(context, AppString.read_only).toString()}"),
                                                hintStyle: TextStyle(fontSize: width! * 0.035, color: passwordVisibility),
                                              ),
                                              validator: (String? value) {
                                                if (value!.isEmpty) {
                                                  return getTranslated(context, AppString.please_enter_based_on).toString();
                                                }
                                                return null;
                                              },
                                              onSaved: (String? name) {},
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.topLeft,
                                        margin: EdgeInsets.only(top: width! * 0.02),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              getTranslated(context, AppString.profile_start_time).toString(),
                                              style: TextStyle(fontSize: width! * 0.038, color: hintColor),
                                            ),
                                            TextFormField(
                                              enableInteractiveSelection: false,
                                              controller: _pStartTime,
                                              readOnly: true,
                                              style: TextStyle(fontSize: 14, color: passwordVisibility),
                                              decoration: InputDecoration(
                                                hintText: getTranslated(context, AppString.profile_start_time_hint).toString(),
                                                hintStyle: TextStyle(fontSize: width! * 0.035, color: passwordVisibility),
                                              ),
                                              onTap: () async {
                                                final TimeOfDay? result = await showTimePicker(
                                                    context: context,
                                                    initialTime: TimeOfDay.now(),
                                                    builder: (context, child) {
                                                      return MediaQuery(
                                                          data: MediaQuery.of(context).copyWith(
                                                            // Using 12-Hour format
                                                            alwaysUse24HourFormat: false,
                                                          ),
                                                          // If you want 24-Hour format, just change alwaysUse24HourFormat to true
                                                          child: child!);
                                                    });
                                                if (result != null) {
                                                  setState(() {
                                                    String data = result.format(context).toLowerCase();
                                                    String str;
                                                    var parts;
                                                    String? startPart;

                                                    int checkData;
                                                    str = data;
                                                    parts = str.split(":");
                                                    startPart = parts[0].trim();
                                                    checkData = int.parse(startPart!);
                                                    if (checkData > 9) {
                                                      _pStartTime.text = result.format(context).toLowerCase();
                                                    } else {
                                                      _pStartTime.text = "0" + result.format(context).toLowerCase();
                                                    }
                                                  });
                                                }
                                              },
                                              validator: (String? value) {
                                                if (value!.isEmpty) {
                                                  return getTranslated(context, AppString.please_enter_start_time).toString();
                                                }
                                                return null;
                                              },
                                              onSaved: (String? name) {},
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.topLeft,
                                        margin: EdgeInsets.only(top: width! * 0.02),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              getTranslated(context, AppString.profile_end_time).toString(),
                                              style: TextStyle(fontSize: width! * 0.038, color: hintColor),
                                            ),
                                            TextFormField(
                                              enableInteractiveSelection: false,
                                              controller: _pEndTime,
                                              readOnly: true,
                                              style: TextStyle(fontSize: 14, color: passwordVisibility),
                                              decoration: InputDecoration(
                                                hintText: getTranslated(context, AppString.profile_end_time_hint).toString(),
                                                hintStyle: TextStyle(fontSize: width! * 0.035, color: passwordVisibility),
                                              ),
                                              onTap: () async {
                                                final TimeOfDay? result = await showTimePicker(
                                                    context: context,
                                                    initialTime: TimeOfDay.now(),
                                                    builder: (context, child) {
                                                      return MediaQuery(
                                                          data: MediaQuery.of(context).copyWith(
                                                              // Using 12-Hour format
                                                              alwaysUse24HourFormat: false),
                                                          // If you want 24-Hour format, just change alwaysUse24HourFormat to true
                                                          child: child!);
                                                    });
                                                if (result != null) {
                                                  setState(() {
                                                    String data = result.format(context).toLowerCase();
                                                    String str;
                                                    var parts;
                                                    String? startPart;

                                                    int checkData;
                                                    str = data;
                                                    parts = str.split(":");
                                                    startPart = parts[0].trim();
                                                    checkData = int.parse(startPart!);
                                                    if (checkData > 9) {
                                                      _pEndTime.text = result.format(context).toLowerCase();
                                                    } else {
                                                      _pEndTime.text = "0" + result.format(context).toLowerCase();
                                                    }
                                                  });
                                                }
                                              },
                                              validator: (String? value) {
                                                if (value!.isEmpty) {
                                                  return getTranslated(context, AppString.please_enter_end_time).toString();
                                                }
                                                return null;
                                              },
                                              onSaved: (String? name) {},
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.topLeft,
                                        margin: EdgeInsets.only(top: width! * 0.02),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              getTranslated(context, AppString.profile_popular).toString(),
                                              style: TextStyle(fontSize: width! * 0.038, color: hintColor),
                                            ),
                                            DropdownButton(
                                              hint: Text(getTranslated(context, AppString.profile_popular).toString()),
                                              value: _selectedPopular == '0' ? getTranslated(context, AppString.popular_no).toString() : getTranslated(context, AppString.popular_yes).toString(),
                                              isExpanded: true,
                                              iconSize: 35,
                                              onChanged: (dynamic newValue) {
                                                setState(() {
                                                  _selectedPopular = newValue;
                                                });
                                              },
                                              items: popular.map((popular) {
                                                return DropdownMenuItem(
                                                  child: new Text(popular),
                                                  value: popular,
                                                );
                                              }).toList(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            isActive: _currentStep >= 0,
                            state: _currentStep >= 2 ? StepState.complete : StepState.disabled,
                          ),
                        ],
                        controlsBuilder: (BuildContext context, ControlsDetails controls) {
                          return Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              SizedBox(),
                              SizedBox(),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
      bottomNavigationBar: Container(
        height: width! * 0.12,
        child: ElevatedButton(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_currentStep == 0)
                Text(
                  getTranslated(context, AppString.profile_continue_button).toString(),
                  style: TextStyle(fontSize: width! * 0.04, color: colorWhite),
                ),
              if (_currentStep == 1)
                Text(
                  getTranslated(context, AppString.profile_continue_button).toString(),
                  style: TextStyle(fontSize: width! * 0.04, color: colorWhite),
                ),
              if (_currentStep == 2)
                Text(
                  getTranslated(context, AppString.profile_submit_button).toString(),
                  style: TextStyle(fontSize: width! * 0.04, color: colorWhite),
                ),
            ],
          ),
          onPressed: () {
            if (_currentStep == 0 && _step1.currentState!.validate()) {
              for (int i = 0; i < hospitalReq.length; i++) {
                if (hospitalReq[i].isSelected == true) {
                  selectedHospitals.add(hospitalReq[i].id.toString());
                }
              }

              if (selectedHospitals.isNotEmpty) {
                continued();
              } else {
                Fluttertoast.showToast(msg: getTranslated(context, AppString.please_select_hospital).toString());
              }
            } else if (_currentStep == 1 && _step2.currentState!.validate()) {
              List<String> degree = [];
              List<String> college = [];
              List<String> year = [];
              List<String> certificate = [];
              List<String> certificateYear = [];

              degree = _pDegree.text.toString().split(",");
              college = _pCollege.text.toString().split(',');
              year = _pCollegeYear.text.toString().split(',');

              certificate = _pCertificate.text.toString().split(',');
              certificateYear = _pCertificateYear.text.toString().split(',');

              educationList.clear();
              certificateList.clear();

              for (int i = 0; i < degree.length; i++) {
                EducationModel education = new EducationModel();
                education.degree = degree[i];
                education.college = college[i];
                education.year = year[i];
                educationList.add(education);
              }

              for (int i = 0; i < certificate.length; i++) {
                EducationCertificate certificateData = new EducationCertificate();
                certificateData.certificate = certificate[i];
                certificateData.certificateYear = certificateYear[i];
                certificateList.add(certificateData);
              }

              continued();
            } else {
              if (_currentStep == 2 && _formkey.currentState!.validate()) {
                updateProfile();
              }
            }
          },
        ),
      ),
    );
  }

  Future<BaseModel<UpdateProfile>> updateProfile() async {
    var eEducationList = JsonEncoder().convert(educationList);
    var cCertificateList = JsonEncoder().convert(certificateList);

    //pass date formate
    if (_selectedDate != null) {
      temp = '$_selectedDate';
    } else {
      temp = '$showFormat';
    }

    String hospitalIds = '';
    List<String> data = [];
    for (int i = 0; i < hospitalReq.length; i++) {
      if (hospitalReq[i].isSelected == true) {
        data.add(hospitalReq[i].id.toString());
      }
    }

    for (int j = 0; j < data.length; j++) {
      if (data.length <= 1) {
        hospitalIds = data[j];
      } else {
        hospitalIds += data[j] + ',';
      }
    }

    if (data.length > 1) {
      String result = hospitalIds.substring(0, hospitalIds.length - 1);
      hospitalIds = result + " ";
    }

    newDateApiPass = DateUtilForPass().formattedDate(DateTime.parse('$temp'));
    Map<String, dynamic> body = {
      "name": _pName.text,
      "treatment_id": _valueTreatment!.id,
      "category_id": _valueCategories!.id,
      "expertise_id": _valueExpertise!.id,
      "hospital_id": hospitalIds,
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
      "based_on": _pBasedOn.text,
      "is_popular": _selectedPopular == getTranslated(context, AppString.popular_yes).toString() ? 1 : 0
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

  Future<BaseModel<DoctorProfile>> doctorProfile() async {
    DoctorProfile response;

    try {
      response = await RestClient(RetroApi().dioData()).doctorProfile();

      var convertDegree;
      var eduCertificate;
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

      if (response.data!.experience != null) {
        _pExperience.text = response.data!.experience!;
      }

      if (response.data!.appointmentFees != null) {
        _pAppointmentFees.text = response.data!.appointmentFees!;
      }

      if (response.data!.desc != null) {
        _pDesc.text = response.data!.desc!;
      }

      _pTimeSlot.text = response.data!.timeslot!;
      _pStartTime.text = response.data!.startTime!;
      _pEndTime.text = response.data!.endTime!;
      _pBasedOn.text = response.data!.basedOn!;

      _selectedPopular = response.data!.isPopular.toString();

      if (response.data!.hospitalId != null) {
        List<String> list = response.data!.hospitalId!.split(",");
        for (int i = 0; i < hospitalReq.length; i++) {
          for (int j = 0; j < list.length; j++) {
            if (int.parse(list[j]) == hospitalReq[i].id) {
              setState(() {
                hospitalReq[i].isSelected = true;
              });
            }
          }
        }
      }

      for (int i = 0; i < treatmentReq.length; i++) {
        if (response.data!.treatmentId == treatmentReq[i].id) {
          _valueTreatment = treatmentReq[i];
          category(_valueTreatment!.id, response.data!.categoryId, response.data!.expertiseId);
          setState(() {});
        }
      }

      setState(() {});
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<Hospitals>> hospital() async {
    Hospitals response;
    try {
      hospitalReq.clear();
      response = await RestClient(RetroApi().dioData()).hospitalRequest();
      setState(() {
        for (int i = 0; i < response.data!.length; i++) {
          hospitalReq.add(response.data![i]);
        }
        doctorProfile();
      });
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<ImageUpload>> uploadImage() async {
    Map<String, dynamic> body = {
      "image": image,
    };
    ImageUpload response;
    try {
      response = await RestClient(RetroApi().dioData()).uploadImage(body);
      setState(() {
        msg = response.data;
        SharedPreferenceHelper.setString(Preferences.image, response.data!);
      });
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  void proImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        SharedPreferenceHelper.setString(Preferences.image, pickedFile.path);
        proImage = File(SharedPreferenceHelper.getString(Preferences.image));
        List<int> imageBytes = proImage!.readAsBytesSync();
        image = base64Encode(imageBytes);
        uploadImage();
      } else {
        print('No image selected.');
      }
    });
  }

  void proImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        SharedPreferenceHelper.setString(Preferences.image, pickedFile.path);
        proImage = File(SharedPreferenceHelper.getString(Preferences.image));
        List<int> imageBytes = proImage!.readAsBytesSync();
        image = base64Encode(imageBytes);
        uploadImage();
      } else {
        print('No image selected.');
      }
    });
  }

  void chooseProfileImage() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.photo_library),
                    title: new Text(
                      getTranslated(context, AppString.choose_image_gallery).toString(),
                    ),
                    onTap: () {
                      proImageFromGallery();
                      Navigator.of(context).pop();
                    }),
                new ListTile(
                  leading: new Icon(Icons.photo_camera),
                  title: new Text(
                    getTranslated(context, AppString.choose_image_camera).toString(),
                  ),
                  onTap: () {
                    proImageFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<BaseModel> treatment() async {
    Treatment response;
    try {
      response = await RestClient(RetroApi().dioData()).treatmentRequest();
      setState(() {
        for (int i = 0; i < response.data!.length; i++) {
          treatmentReq.add(response.data![i]);
        }
      });
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<Categories>> category(id, categoryId, int? expertiseId) async {
    Categories response;
    try {
      response = await RestClient(RetroApi().dioData()).categoryRequest(id);
      setState(() {
        for (int i = 0; i < response.categoriesData!.length; i++) {
          categoryReq.add(response.categoriesData![i]);
        }

        if (categoryReq.length != 0) {
          for (int i = 0; i < categoryReq.length; i++) {
            if (categoryId == categoryReq[i].id) {
              _valueCategories = categoryReq[i];
              expertise(_valueCategories!.id, expertiseId);
            }
          }
        }
      });
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<Expertise>> expertise(id, expertiseId) async {
    Expertise response;
    try {
      response = await RestClient(RetroApi().dioData()).expertiseRequest(id);
      setState(() {
        for (int i = 0; i < response.expertiseData!.length; i++) {
          expertReq.add(response.expertiseData![i]);
        }
        if (expertReq.length != 0) {
          for (int i = 0; i < expertReq.length; i++) {
            if (expertiseId == expertReq[i].id) {
              _valueExpertise = expertReq[i];
            }
          }
        }
      });
    } catch (error, stacktrace) {
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
      _pDob
        ..text = DateFormat('dd-MM-yyyy').format(_selectedDate!)
        ..selection = TextSelection.fromPosition(
          TextPosition(offset: _pDob.text.length, affinity: TextAffinity.upstream),
        );
    }
  }

  tapped(int step) {
    setState(() => _currentStep = step);
  }

  continued() {
    if (_currentStep < 2) {
      setState(() => _currentStep += 1);
    }
  }

  cancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
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
