import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctro_patient/model/insurers_response.dart';
import 'package:list_tile_switch/list_tile_switch.dart';
import '../Payment/PaypalPaymentScreen.dart';
import '../../api/retrofit_Api.dart';
import '../../api/network_api.dart';
import '../../model/show_address_model.dart';
import '../../model/time_slot_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutterwave_standard/core/flutterwave.dart';
import 'package:flutterwave_standard/models/requests/customer.dart';
import 'package:flutterwave_standard/models/requests/customizations.dart';
import 'package:flutterwave_standard/models/responses/charge_response.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../const/prefConstatnt.dart';
import '../../../const/preference.dart';
import '../Location/ShowLocation.dart';
import '../../api/base_model.dart';
import '../../api/server_error.dart';
import '../../const/Palette.dart';
import '../../const/app_string.dart';
import '../../database/form_helper.dart';
import '../../localization/localization_constant.dart';
import '../../model/detail_setting_model.dart';
import '../../model/apply_offer_model.dart';
import '../../model/book_appointments_model.dart';
import '../../model/doctor_detail_model.dart';
import 'appointment_stripe_service.dart';

enum SingingCharacter { Paypal, Razorpay, Stripe, FlutterWave, PayStack, COD }

class BookAppointment extends StatefulWidget {
  final int? id;

  BookAppointment({this.id});

  @override
  _BookAppointmentState createState() => _BookAppointmentState();
}

class _BookAppointmentState extends State<BookAppointment> {
  bool loading = false;

  late PlatformFile file;

  bool isPaymentClicked = false;
  String? _paymentToken = "";

  List<String> reportImages = [];

  // RazorPay //
  late Razorpay _razorpay;

  // FlutterWave //
  final String txRef = "";
  final String amount = "";

  // Detail_Setting & Payment_Detail //
  String? businessName = "";
  String? logo = "";
  String? razorpayKey = "";
  int? cod = 0;
  int? stripe = 0;
  int? paypal = 0;
  int? razor = 0;
  int? flutterWave = 0;
  int? payStack = 0;
  int? isLiveKey = 0;

  String? userPhoneNo = "";
  String? userEmail = "";
  String? userName = "";

  // Payment count //
  SingingCharacter? _character;
  int? selectedRadio;
  late var str;
  var parts;
  var paymentType;
  var startPart;

  int _currentStep = 0;
  StepperType stepperType = StepperType.horizontal;

  String? selectTime = "";
  int? timeIndex;

  String? name = "";
  String? expertise = "";
  String? appointmentFees = "";
  dynamic newAppointmentFees = 0.0;
  String? experience = "";
  dynamic rate = 0;
  String? desc = "";
  String education = "";
  String certificate = "";
  String? fullImage = "";
  String? treatmentName = "";
  String? hospitalName = "";
  String? hospitalAddress = "";
  int? hospitalId = 0;

  List<HospitalId> hospital = [];
  List<HospitalGallery> hospitalGallery = [];
  HospitalId? hospitalDetailData;

  TextEditingController patientNameController = TextEditingController();
  TextEditingController illnessInformation = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController patientAddressController = TextEditingController();
  TextEditingController phoneNoController = TextEditingController();
  TextEditingController note = TextEditingController();
  TextEditingController date = TextEditingController();
  TextEditingController time = TextEditingController();
  TextEditingController policyNumberController = TextEditingController();

  TextEditingController _offerController = TextEditingController();

  String reportImage = "";
  String reportImage1 = "";
  String reportImage2 = "";
  File? _proImage;
  File? _proImage1;
  File? _proImage2;
  final picker = ImagePicker();

  List<DataSlots> timeList = [];

  DateTime? _selectedDate;
  late DateTime _firstTimeSelected;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _step1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _step2 = GlobalKey<FormState>();

  final GlobalKey<FormState> _offerFormKey = GlobalKey<FormState>();

  List<String> appointmentFor = [];
  String? selectAppointmentFor;

  List<String> drugEffects = [];
  String? selectDrugEffects;
  InsurersData? selectedInsures;
  String selectInsured = "";
  List<ShowAddressData> showAddress = [];
  int selectAddressId = 0;
  ShowAddressData? showAddressData;

  int? id = 0;
  String newDate = "";
  String newDateUser = "";

  String passBookDate = "";
  String passBookTime = "";
  String passBookID = "";

  String? bookingId = "";

  //Discount //
  String discountType = "";
  int? isFlat = 0;
  int? flatDiscount = 0;
  int? discount = 0;
  int? minDiscount = 0;
  DateTime? todayDate;
  double prAmount = 0;

  _getDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(
      () {
        userPhoneNo = prefs.getString('phone_no');
        userEmail = prefs.getString('email');
        userName = prefs.getString('name');
      },
    );
  }

  _passDateTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(
      () {
        passBookDate = '$newDateUser';
        passBookTime = '$selectTime';
        passBookID = '$bookingId';
        prefs.setString('BookDate', passBookDate);
        prefs.setString('BookTime', passBookTime);
        prefs.setString('BookID', passBookID);
      },
    );
  }

  var publicKey = SharedPreferenceHelper.getString(Preferences.payStack_public_key);
  final plugin = PaystackPlugin();
  String? paymentToken = "";

  String? _lat = "";
  String? _lang = "";

  @override
  void initState() {
    Stripe.publishableKey = SharedPreferenceHelper.getString(Preferences.stripe_public_key)!;
    super.initState();
    id = widget.id;
    // callApiDoctorDetail();
    _getDetail();
    callGetInsurers();
    callApiShowAddress();
    selectedRadio = 0;
    callApiSetting();
    _getAddress();

    Future.delayed(Duration.zero, () {
      appointmentFor = ["My Self", "Patient"];
      drugEffects = ["Yes", "No"];
    });

    // RazorPay //
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    // PayStack //
    plugin.initialize(publicKey: SharedPreferenceHelper.getString(Preferences.payStack_public_key)!);
    todayDate = DateTime.now();
    _firstTimeSelected = DateTime.now();
    date
      ..text = DateFormat('dd-MM-yyyy').format(_firstTimeSelected)
      ..selection = TextSelection.fromPosition(
        TextPosition(offset: date.text.length, affinity: TextAffinity.upstream),
      );
    var temp = '$_firstTimeSelected';
    // Date Format Display user
    newDateUser = DateUtil().formattedDate(DateTime.parse(temp));
    // // Date Format pass Api
    newDate = DateUtilForPass().formattedDate(DateTime.parse(temp));

    date.text = newDateUser;

    timeSlot();
  }

  _getAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(
      () {
        _lat = prefs.getString('lat');
        _lang = prefs.getString('lang');
        callApiDoctorDetail();
        setState(() {});
      },
    );
  }

  setSelectedRadio(int val) {
    setState(() {
      selectedRadio = val;
    });
  }

  // RazorPay Clear //
  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  bool isInsured = false;

  @override
  Widget build(BuildContext context) {
    double width;
    double height;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(width * 0.3, size.height * 0.23),
          child: SafeArea(
            top: true,
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: size.height * 0.01),
                  color: Palette.transparent,
                  child: Container(
                    alignment: Alignment.topRight,
                    margin: EdgeInsets.only(right: width * 0.02, left: width * 0.02),
                    child: GestureDetector(
                      child: Icon(Icons.arrow_back_ios),
                      onTap: () {
                        if (_currentStep == 0) Navigator.pop(context);
                        if (_currentStep == 1) cancel();
                        if (_currentStep == 2) cancel();
                      },
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: width * 0.04, right: width * 0.04),
                  child: Row(
                    children: [
                      Container(
                        child: Column(
                          children: [
                            Container(
                              width: width * 0.2,
                              height: width * 0.2,
                              child: CachedNetworkImage(
                                alignment: Alignment.center,
                                imageUrl: '$fullImage',
                                imageBuilder: (context, imageProvider) => CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Palette.image_circle,
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundImage: imageProvider,
                                  ),
                                ),
                                placeholder: (context, url) => SpinKitPulse(color: Palette.blue),
                                errorWidget: (context, url, error) => ClipRRect(
                                  borderRadius: BorderRadius.circular(60),
                                  child: Image.asset("assets/images/no_image.jpg", width: width * 0.2, height: width * 0.2, fit: BoxFit.fitHeight),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: width * 0.6,
                        margin: EdgeInsets.only(left: width * 0.04, right: width * 0.04),
                        child: Column(
                          children: [
                            Container(
                              alignment: AlignmentDirectional.topStart,
                              child: Column(
                                children: [
                                  Text(
                                    '$name',
                                    style: TextStyle(fontSize: width * 0.047, color: Palette.dark_blue),
                                    overflow: TextOverflow.ellipsis,
                                  )
                                ],
                              ),
                            ),
                            Container(
                              alignment: AlignmentDirectional.topStart,
                              margin: EdgeInsets.only(top: width * 0.01),
                              child: Column(
                                children: [
                                  Text(
                                    '$expertise',
                                    style: TextStyle(fontSize: width * 0.038, color: Palette.grey),
                                    overflow: TextOverflow.ellipsis,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: width * 0.03),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: Text(
                          getTranslated(context, AppString.bookAppointment_appointmentFees).toString(),
                          style: TextStyle(fontSize: width * 0.045, color: Palette.blue),
                        ),
                      ),
                      Container(
                        child: Text(
                          SharedPreferenceHelper.getString(Preferences.currency_symbol).toString() + '$appointmentFees',
                          style: TextStyle(fontSize: width * 0.04, color: Palette.black),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        body: ModalProgressHUD(
          child: Container(
            child: Form(
              key: _formKey,
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
                        /// Step 1 //
                        Step(
                          title: new Text(
                            getTranslated(context, AppString.bookAppointment_appointmentFor_hint).toString(),
                          ),
                          content: Form(
                            key: _step1,
                            child: SingleChildScrollView(
                              child: Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(top: width * 0.03),
                                      child: Column(
                                        children: [
                                          Text(
                                            getTranslated(context, AppString.bookAppointment_appointmentFor_title).toString(),
                                            style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      ),
                                    ),
                                    DropdownButtonFormField(
                                      hint: Text(
                                        getTranslated(context, AppString.bookAppointment_mySelf).toString() + ' / ' + getTranslated(context, AppString.bookAppointment_patient).toString(),
                                        style: TextStyle(
                                          fontSize: width * 0.035,
                                          color: Palette.grey,
                                        ),
                                      ),
                                      value: selectAppointmentFor,
                                      isExpanded: true,
                                      iconSize: 30,
                                      onSaved: (dynamic value) {
                                        setState(() {
                                          selectAppointmentFor = value;
                                        });
                                      },
                                      onChanged: (dynamic newValue) {
                                        setState(
                                          () {
                                            selectAppointmentFor = newValue;
                                          },
                                        );
                                      },
                                      validator: (dynamic value) => value == null ? getTranslated(context, AppString.bookAppointment_appointmentFor_validator).toString() : null,
                                      items: appointmentFor.map((location) {
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
                                      }).toList(),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: width * 0.05),
                                      child: Column(
                                        children: [
                                          Text(
                                            getTranslated(context, AppString.bookAppointment_hospital_title).toString(),
                                            style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      ),
                                    ),
                                    DropdownButtonFormField(
                                      hint: Text(
                                        getTranslated(context, AppString.bookAppointment_hospital_hint).toString(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: width * 0.035,
                                          color: Palette.grey,
                                        ),
                                      ),
                                      value: hospitalDetailData,
                                      isExpanded: true,
                                      iconSize: 30,
                                      onSaved: (dynamic value) {
                                        setState(() {
                                          hospitalDetailData = value;
                                          print("$hospitalDetailData");
                                        });
                                      },
                                      onChanged: (HospitalId? newValue) {
                                        setState(
                                          () {
                                            hospitalId = hospital[hospital.indexOf(newValue!)].hospitalDetails!.id;
                                            print("HospitalId $hospitalId");
                                          },
                                        );
                                      },
                                      validator: (dynamic value) => value == null ? getTranslated(context, AppString.bookAppointment_hospital_validator).toString() : null,
                                      items: hospital.map((location) {
                                        return DropdownMenuItem<HospitalId>(
                                          child: new Text(
                                            location.hospitalDetails!.name!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: width * 0.04,
                                              color: Palette.dark_blue,
                                            ),
                                          ),
                                          value: location,
                                        );
                                      }).toList(),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: width * 0.05),
                                      child: Column(
                                        children: [
                                          Text(
                                            getTranslated(context, AppString.bookAppointment_patient_title).toString(),
                                            style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      ),
                                    ),
                                    TextFormField(
                                      textCapitalization: TextCapitalization.words,
                                      controller: patientNameController,
                                      keyboardType: TextInputType.text,
                                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z ]'))],
                                      style: TextStyle(
                                        fontSize: width * 0.04,
                                        color: Palette.dark_blue,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: getTranslated(context, AppString.bookAppointment_patient_hint).toString(),
                                        hintStyle: TextStyle(
                                          fontSize: width * 0.04,
                                          color: Palette.grey,
                                        ),
                                      ),
                                      validator: (String? value) {
                                        value!.trim();
                                        if (value.isEmpty) {
                                          return getTranslated(context, AppString.bookAppointment_patient_validator1).toString();
                                        } else if (value.trim().length < 1) {
                                          return getTranslated(context, AppString.bookAppointment_patient_validator2).toString();
                                        }
                                        return null;
                                      },
                                      onChanged: (String name) {
                                        name.trim();
                                      },
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: width * 0.05),
                                      child: Column(
                                        children: [
                                          Text(
                                            getTranslated(context, AppString.bookAppointment_illness_title).toString(),
                                            style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      ),
                                    ),
                                    TextFormField(
                                      textCapitalization: TextCapitalization.words,
                                      controller: illnessInformation,
                                      keyboardType: TextInputType.text,
                                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9 ]'))],
                                      style: TextStyle(
                                        fontSize: width * 0.04,
                                        color: Palette.dark_blue,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: getTranslated(context, AppString.bookAppointment_illness_hint).toString(),
                                        // 'Enter patient illness',
                                        hintStyle: TextStyle(
                                          fontSize: width * 0.04,
                                          color: Palette.grey,
                                        ),
                                      ),
                                      validator: (String? value) {
                                        if (value!.isEmpty) {
                                          return getTranslated(context, AppString.bookAppointment_illness_validator1).toString();
                                        } else if (value.trim().length < 1) {
                                          return getTranslated(context, AppString.bookAppointment_illness_validator2).toString();
                                        }
                                        return null;
                                      },
                                      onSaved: (String? name) {},
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: width * 0.05),
                                      child: Column(
                                        children: [
                                          Text(
                                            getTranslated(context, AppString.bookAppointment_age_title).toString(),
                                            style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      ),
                                    ),
                                    TextFormField(
                                      controller: ageController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]'))],
                                      style: TextStyle(
                                        fontSize: width * 0.04,
                                        color: Palette.dark_blue,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: getTranslated(context, AppString.bookAppointment_age_hint).toString(),
                                        hintStyle: TextStyle(
                                          fontSize: width * 0.04,
                                          color: Palette.grey,
                                        ),
                                      ),
                                      validator: (String? value) {
                                        if (value!.isEmpty) {
                                          return getTranslated(context, AppString.bookAppointment_age_validator).toString();
                                        }
                                        return null;
                                      },
                                      onSaved: (String? name) {},
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: width * 0.05),
                                      child: Column(
                                        children: [
                                          Text(
                                            getTranslated(context, AppString.bookAppointment_patientAddress_title).toString(),
                                            style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        if (showAddress.length == 0) {
                                          FormHelper.showMessage(
                                            context,
                                            "No Address",
                                            "No any address, Please add address.",
                                            "No",
                                            () {
                                              Navigator.of(context).pop();
                                            },
                                            buttonText2: "Add",
                                            isConfirmationDialog: true,
                                            onPressed2: () {
                                              Navigator.of(context).pop();
                                              SharedPreferenceHelper.setString('isWhere', "BookAppointment");
                                              SharedPreferenceHelper.setString('doctorId', widget.id.toString());
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => ShowLocation(),
                                                ),
                                              );
                                            },
                                          );
                                        }
                                      },
                                      child: DropdownButtonFormField(
                                        hint: Text(
                                          getTranslated(context, AppString.bookAppointment_patientAddress_text).toString(),
                                          style: TextStyle(
                                            fontSize: width * 0.04,
                                            color: Palette.grey,
                                          ),
                                        ),
                                        value: showAddressData,
                                        isExpanded: true,
                                        iconSize: 30,
                                        onTap: () {
                                          if (showAddress.length == 0) {
                                            Fluttertoast.showToast(
                                              msg: "Please add Address.",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.CENTER,
                                            );
                                          }
                                        },
                                        onSaved: (dynamic value) {
                                          setState(() {
                                            showAddressData = value;
                                          });
                                        },
                                        onChanged: (ShowAddressData? newValue) {
                                          setState(
                                            () {
                                              selectAddressId = newValue!.id!;
                                            },
                                          );
                                        },
                                        validator: (dynamic value) => value == null ? getTranslated(context, AppString.bookAppointment_patientAddress_validator1).toString() : null,
                                        items: showAddress.map((location) {
                                          return DropdownMenuItem<ShowAddressData>(
                                            child: new Text(
                                              location.address!,
                                              style: TextStyle(
                                                fontSize: width * 0.04,
                                                color: Palette.dark_blue,
                                              ),
                                            ),
                                            value: location,
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: width * 0.05),
                                      child: Column(
                                        children: [
                                          Text(
                                            getTranslated(context,AppString.bookAppointment_phoneNo_title).toString(),
                                            style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      ),
                                    ),
                                    TextFormField(
                                      controller: phoneNoController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9]')), LengthLimitingTextInputFormatter(10)],
                                      style: TextStyle(
                                        fontSize: width * 0.035,
                                        color: Palette.dark_blue,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: getTranslated(context,AppString.bookAppointment_phoneNo_hint).toString(),
                                        hintStyle: TextStyle(
                                          fontSize: width * 0.04,
                                          color: Palette.grey,
                                        ),
                                      ),
                                      validator: (String? value) {
                                        if (value!.isEmpty) {
                                          return getTranslated(context, AppString.bookAppointment_phoneNo_Validator1).toString();
                                        }

                                        return null;
                                      },
                                      onSaved: (String? name) {},
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: width * 0.05),
                                      child: Column(
                                        children: [
                                          Text(
                                            getTranslated(context, AppString.bookAppointment_sideEffects_title).toString(),
                                            style: TextStyle(fontSize: width * 0.038, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      ),
                                    ),
                                    DropdownButtonFormField(
                                      hint: Text(
                                        getTranslated(context, AppString.bookAppointment_sideEffects_hint).toString(),
                                        style: TextStyle(
                                          fontSize: width * 0.04,
                                          color: Palette.grey,
                                        ),
                                      ),
                                      value: selectDrugEffects,
                                      isExpanded: true,
                                      iconSize: 30,
                                      onSaved: (dynamic value) {
                                        setState(() {
                                          selectDrugEffects = value;
                                        });
                                      },
                                      onChanged: (dynamic newValue) {
                                        setState(
                                          () {
                                            selectDrugEffects = newValue;
                                          },
                                        );
                                      },
                                      validator: (dynamic value) => value == null ? getTranslated(context, AppString.bookAppointment_sideEffects_validator).toString() : null,
                                      items: drugEffects.map((location) {
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
                                      }).toList(),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: width * 0.05),
                                      child: Column(
                                        children: [
                                          Text(
                                            getTranslated(context, AppString.bookAppointment_note_title).toString(),
                                            style: TextStyle(fontSize: width * 0.038, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      ),
                                    ),
                                    TextFormField(
                                      textCapitalization: TextCapitalization.sentences,
                                      controller: note,
                                      keyboardType: TextInputType.text,
                                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9,. ]'))],
                                      maxLength: 40,
                                      style: TextStyle(
                                        fontSize: width * 0.04,
                                        color: Palette.dark_blue,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: getTranslated(context, AppString.bookAppointment_note_hint).toString(),
                                        hintStyle: TextStyle(
                                          fontSize: width * 0.04,
                                          color: Palette.grey,
                                        ),
                                      ),
                                      onSaved: (String? name) {},
                                    ),
                                    ListTileSwitch(
                                      value: isInsured,
                                      onChanged: (value) {
                                        setState(() {
                                          isInsured = value;
                                        });
                                      },
                                      title: Text(
                                        getTranslated(context, AppString.patientInsured).toString(),
                                        style: TextStyle(fontSize: width * 0.038, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                                      ),
                                      dense: true,
                                      contentPadding: EdgeInsets.zero,
                                      switchActiveColor: Palette.purple,
                                      visualDensity: VisualDensity(vertical: -4, horizontal: -4),
                                      switchType: SwitchType.custom,
                                    ),
                                    Visibility(
                                      visible: isInsured,
                                      child: Column(
                                        children: [
                                          DropdownButtonFormField(
                                            hint: Text(
                                              getTranslated(context, AppString.choosePolicyProvider).toString(),
                                              style: TextStyle(
                                                fontSize: width * 0.04,
                                                color: Palette.grey,
                                              ),
                                            ),
                                            value: selectedInsures,
                                            isExpanded: true,
                                            iconSize: 30,
                                            onSaved: (dynamic value) {
                                              setState(() {
                                                selectedInsures = value;
                                              });
                                            },
                                            onChanged: (InsurersData? newValue) {
                                              setState(
                                                () {
                                                  selectInsured = newValue!.name ?? "";
                                                },
                                              );
                                            },
                                            validator: (dynamic value) => value == null ? getTranslated(context, AppString.choosePolicyProvider).toString() : null,
                                            items: allInsurers.map((location) {
                                              return DropdownMenuItem<InsurersData>(
                                                child: new Text(
                                                  location.name ?? "",
                                                  style: TextStyle(
                                                    fontSize: width * 0.04,
                                                    color: Palette.dark_blue,
                                                  ),
                                                ),
                                                value: location,
                                              );
                                            }).toList(),
                                          ),
                                          TextFormField(
                                            controller: policyNumberController,
                                            keyboardType: TextInputType.number,
                                            validator: (String? value) {
                                              if (value!.isEmpty) {
                                                return getTranslated(context,AppString.policyNumber).toString();
                                              }

                                              return null;
                                            },
                                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                            style: TextStyle(
                                              fontSize: width * 0.04,
                                              color: Palette.dark_blue,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: getTranslated(context, AppString.policyNumber).toString(),
                                              hintStyle: TextStyle(
                                                fontSize: width * 0.04,
                                                color: Palette.grey,
                                              ),
                                            ),
                                            onSaved: (String? name) {},
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: width * 0.05),
                                      child: Column(
                                        children: [
                                          Text(
                                            getTranslated(context, AppString.bookAppointment_reportImage_title).toString(),
                                            style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                                          )
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          child: Row(
                                            children: [
                                              Container(
                                                alignment: Alignment.topLeft,
                                                margin: EdgeInsets.only(top: width * 0.028, left: width * 0.02, right: width * 0.02),
                                                child: Container(
                                                  height: width * 0.24,
                                                  width: width * 0.24,
                                                  child: Card(
                                                    color: Palette.dash_line,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                                    child: _proImage != null
                                                        ? GestureDetector(
                                                            onTap: () {
                                                              _chooseProfileImage();
                                                            },
                                                            child: Image.file(
                                                              _proImage!,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          )
                                                        : Container(
                                                            height: width * 0.24,
                                                            width: width * 0.24,
                                                            child: CachedNetworkImage(
                                                              height: width * 0.24,
                                                              width: width * 0.24,
                                                              alignment: Alignment.center,
                                                              imageUrl: reportImage,
                                                              fit: BoxFit.fitHeight,
                                                              placeholder: (context, url) => SpinKitFadingCircle(color: Palette.blue),
                                                              errorWidget: (context, url, error) => IconButton(
                                                                icon: Icon(
                                                                  Icons.add_outlined,
                                                                  size: 50,
                                                                  color: Palette.blue,
                                                                ),
                                                                onPressed: () {
                                                                  _chooseProfileImage();
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          child: Row(
                                            children: [
                                              Container(
                                                margin: EdgeInsets.only(top: width * 0.028, left: width * 0.02, right: width * 0.02),
                                                child: Container(
                                                  height: width * 0.24,
                                                  width: width * 0.24,
                                                  child: Card(
                                                    color: Palette.dash_line,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                                    child: _proImage1 != null
                                                        ? GestureDetector(
                                                            onTap: () {
                                                              _chooseProfileImage1();
                                                            },
                                                            child: Image.file(
                                                              _proImage1!,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          )
                                                        : Container(
                                                            height: width * 0.24,
                                                            width: width * 0.24,
                                                            child: CachedNetworkImage(
                                                              height: width * 0.24,
                                                              width: width * 0.24,
                                                              alignment: Alignment.center,
                                                              imageUrl: reportImage1,
                                                              fit: BoxFit.fitHeight,
                                                              placeholder: (context, url) => SpinKitFadingCircle(color: Palette.blue),
                                                              errorWidget: (context, url, error) => IconButton(
                                                                icon: Icon(
                                                                  Icons.add_outlined,
                                                                  size: 50,
                                                                  color: Palette.blue,
                                                                ),
                                                                onPressed: () {
                                                                  _chooseProfileImage1();
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          child: Row(
                                            children: [
                                              Container(
                                                alignment: Alignment.topLeft,
                                                margin: EdgeInsets.only(top: width * 0.028, left: width * 0.02, right: width * 0.02),
                                                child: Container(
                                                  height: width * 0.24,
                                                  width: width * 0.24,
                                                  child: Card(
                                                    color: Palette.dash_line,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                                    child: _proImage2 != null
                                                        ? GestureDetector(
                                                            onTap: () {
                                                              _chooseProfileImage2();
                                                            },
                                                            child: Image.file(
                                                              _proImage2!,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          )
                                                        : Container(
                                                            height: width * 0.24,
                                                            width: width * 0.24,
                                                            child: CachedNetworkImage(
                                                              height: width * 0.24,
                                                              width: width * 0.24,
                                                              alignment: Alignment.center,
                                                              imageUrl: reportImage2,
                                                              fit: BoxFit.fitHeight,
                                                              placeholder: (context, url) => SpinKitFadingCircle(color: Palette.blue),
                                                              errorWidget: (context, url, error) => IconButton(
                                                                icon: Icon(
                                                                  Icons.add_outlined,
                                                                  size: 50,
                                                                  color: Palette.blue,
                                                                ),
                                                                onPressed: () {
                                                                  _chooseProfileImage2();
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          isActive: _currentStep >= 0,
                          state: _currentStep >= 0 ? StepState.complete : StepState.disabled,
                        ),

                        /// Step 2 //
                        Step(
                          title: new Text(
                            getTranslated(context, AppString.bookAppointment_dateTime).toString(),
                          ),
                          content: Form(
                            key: _step2,
                            child: Container(
                              child: Column(
                                children: [
                                  Container(
                                    alignment: AlignmentDirectional.center,
                                    margin: EdgeInsets.only(top: width * 0.01),
                                    child: Column(
                                      children: [
                                        Text(
                                          getTranslated(context, AppString.bookAppointment_appointmentDate_title).toString(),
                                          style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: width * 0.1,
                                    width: width * 1,
                                    margin: EdgeInsets.only(top: width * 0.02),
                                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                    decoration: BoxDecoration(color: Palette.dash_line, borderRadius: BorderRadius.circular(10)),
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: TextFormField(
                                        focusNode: AlwaysDisabledFocusNode(),
                                        controller: date,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: getTranslated(context, AppString.bookAppointment_appointmentDate_hint).toString(),
                                          hintStyle: TextStyle(fontSize: width * 0.038, color: Palette.dark_blue),
                                        ),
                                        onTap: () {
                                          _selectDate(context);
                                        },
                                        validator: (String? value) {
                                          if (value!.isEmpty) {
                                            return getTranslated(context, AppString.bookAppointment_appointmentDate_validator).toString();
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                  Container(
                                    child: 0 < timeList.length
                                        ? Column(
                                            children: [
                                              Container(
                                                alignment: AlignmentDirectional.center,
                                                margin: EdgeInsets.only(top: width * 0.05),
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      getTranslated(context, AppString.bookAppointment_appointmentTime_title).toString(),
                                                      style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(top: width * 0.04),
                                                child: GridView.builder(
                                                  itemCount: timeList.length,
                                                  shrinkWrap: true,
                                                  scrollDirection: Axis.vertical,
                                                  physics: NeverScrollableScrollPhysics(),
                                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisSpacing: 5,
                                                    mainAxisSpacing: 5,
                                                    crossAxisCount: 3,
                                                    childAspectRatio: 1.8,
                                                  ),
                                                  itemBuilder: (context, index) {
                                                    return Column(
                                                      children: [
                                                        InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              timeIndex = index;
                                                              selectTime = timeList[index].startTime;
                                                            });
                                                          },
                                                          child: Container(
                                                            height: 52,
                                                            width: width * 0.3,
                                                            child: Card(
                                                              color: index == timeIndex ? Palette.blue : Palette.dash_line,
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(10.0),
                                                              ),
                                                              child: Column(
                                                                children: [
                                                                  Container(
                                                                    padding: EdgeInsets.all(12),
                                                                    child: Text(
                                                                      timeList[index].startTime!,
                                                                      style: TextStyle(color: index == timeIndex ? Palette.white : Palette.blue),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          )
                                        : Container(
                                            height: height * 0.4,
                                            width: MediaQuery.of(context).size.width,
                                            child: Center(
                                              child: Text(
                                                getTranslated(context, AppString.bookAppointment_selectOtherDate).toString(),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(fontSize: width * 0.04, color: Palette.grey),
                                              ),
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          isActive: _currentStep >= 0,
                          state: _currentStep >= 1 ? StepState.complete : StepState.disabled,
                        ),

                        /// Step 3 //
                        Step(
                          title: new Text(
                            getTranslated(context, AppString.bookAppointment_payment_title).toString(),
                          ),
                          content: GestureDetector(
                            onTap: () {
                              FocusScope.of(context).requestFocus(new FocusNode());
                            },
                            child: Container(
                              height: height / 1.5,
                              width: MediaQuery.of(context).size.width,
                              child: ListView(
                                shrinkWrap: false,
                                scrollDirection: Axis.vertical,
                                physics: NeverScrollableScrollPhysics(),
                                children: [
                                  Form(
                                    key: _offerFormKey,
                                    child: Container(
                                      height: height * 0.1,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: TextFormField(
                                              controller: _offerController,
                                              keyboardType: TextInputType.text,
                                              textCapitalization: TextCapitalization.words,
                                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]'))],
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                filled: true,
                                                fillColor: Palette.dark_white,
                                                hintText: getTranslated(context, AppString.bookAppointment_offerCode_hint).toString(),
                                                hintStyle: TextStyle(
                                                  fontSize: width * 0.04,
                                                  color: Palette.dark_grey,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                disabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                  borderSide: BorderSide(
                                                    color: Colors.transparent,
                                                  ),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                  borderSide: BorderSide(
                                                    color: Colors.transparent,
                                                  ),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  borderSide: BorderSide(
                                                    color: Colors.transparent,
                                                  ),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  borderSide: BorderSide(
                                                    color: Colors.transparent,
                                                  ),
                                                ),
                                                focusedErrorBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  borderSide: BorderSide(
                                                    color: Colors.transparent,
                                                  ),
                                                )
                                              ),
                                              validator: (String? value) {
                                                if (value!.isEmpty) {
                                                  return getTranslated(context, AppString.bookAppointment_offerCode_validator).toString();
                                                }
                                                return null;
                                              },
                                              onSaved: (String? name) {},
                                            )),
                                         
                                          Expanded(
                                              flex:2,
                                              child: Container(
                                            height: height * 0.05,
                                            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                                            child: ElevatedButton(
                                              onPressed: () {
                                                if (_offerFormKey.currentState!.validate()) {
                                                  callApiApplyOffer();
                                                }
                                              },
                                              child: Text(
                                                getTranslated(context, AppString.bookAppointment_apply_button).toString(),
                                              ),
                                            ),
                                          )),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      paypal == 1
                                          ? Platform.isAndroid
                                              ? Container(
                                                  margin: EdgeInsets.all(5),
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(boxShadow: [
                                                    BoxShadow(
                                                      color: Palette.dark_grey.withOpacity(0.2),
                                                      spreadRadius: 2,
                                                      blurRadius: 7,
                                                      offset: Offset(0, 3), // changes position of shadow
                                                    ),
                                                  ], borderRadius: BorderRadius.circular(10), color: Palette.white),
                                                  height: MediaQuery.of(context).size.height * 0.08,
                                                  child: RadioListTile<SingingCharacter>(
                                                    controlAffinity: ListTileControlAffinity.trailing,
                                                    title: Container(
                                                      width: MediaQuery.of(context).size.width / 5,
                                                      child: Row(
                                                        children: [
                                                          Image.network(
                                                            "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b7/PayPal_Logo_Icon_2014.svg/1200px-PayPal_Logo_Icon_2014.svg.png",
                                                            height: 30,
                                                            width: 50,
                                                          ),
                                                          SizedBox(
                                                            width: MediaQuery.of(context).size.width * 0.01,
                                                          ),
                                                          Text(
                                                            getTranslated(context, AppString.payPal).toString(),
                                                            style: TextStyle(fontSize: 16, color: Palette.black),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    value: SingingCharacter.Paypal,
                                                    activeColor: Palette.black,
                                                    groupValue: _character,
                                                    onChanged: (SingingCharacter? value) {
                                                      setState(() {
                                                        _character = value;
                                                        isPaymentClicked = true;
                                                      });
                                                    },
                                                  ),
                                                )
                                              : Container()
                                          : Container(),
                                      razor == 1
                                          ? Container(
                                              alignment: Alignment.center,
                                              margin: EdgeInsets.all(5),
                                              decoration: BoxDecoration(boxShadow: [
                                                BoxShadow(
                                                  color: Palette.dark_grey.withOpacity(0.2),
                                                  spreadRadius: 2,
                                                  blurRadius: 7,
                                                  offset: Offset(0, 3), // changes position of shadow
                                                ),
                                              ], borderRadius: BorderRadius.circular(10), color: Palette.white),
                                              height: MediaQuery.of(context).size.height * 0.08,
                                              child: RadioListTile<SingingCharacter>(
                                                controlAffinity: ListTileControlAffinity.trailing,
                                                title: Container(
                                                  width: MediaQuery.of(context).size.width / 5,
                                                  child: Row(
                                                    children: [
                                                      Image.network(
                                                        "https://avatars.githubusercontent.com/u/7713209?s=280&v=4",
                                                        height: 30,
                                                        width: 50,
                                                      ),
                                                      SizedBox(
                                                        width: MediaQuery.of(context).size.width * 0.01,
                                                      ),
                                                      Text(getTranslated(context, AppString.razorPay).toString(), style: TextStyle(fontSize: 16, color: Palette.black)),
                                                    ],
                                                  ),
                                                ),
                                                value: SingingCharacter.Razorpay,
                                                activeColor: Palette.black,
                                                groupValue: _character,
                                                onChanged: (SingingCharacter? value) {
                                                  setState(
                                                    () {
                                                      _character = value;
                                                      isPaymentClicked = true;
                                                    },
                                                  );
                                                },
                                              ),
                                            )
                                          : Container(),
                                      stripe == 1
                                          ? Container(
                                              alignment: Alignment.center,
                                              margin: EdgeInsets.all(5),
                                              decoration: BoxDecoration(boxShadow: [
                                                BoxShadow(
                                                  color: Palette.grey.withOpacity(0.2),
                                                  spreadRadius: 2,
                                                  blurRadius: 7,
                                                  offset: Offset(0, 3), // changes position of shadow
                                                ),
                                              ], borderRadius: BorderRadius.circular(10), color: Palette.white),
                                              height: MediaQuery.of(context).size.height * 0.08,
                                              child: RadioListTile<SingingCharacter>(
                                                controlAffinity: ListTileControlAffinity.trailing,
                                                title: Container(
                                                  width: MediaQuery.of(context).size.width / 5,
                                                  child: Row(
                                                    children: [
                                                      Image.network(
                                                        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT3PGzfbaZZzR0j8rOWBjWJPGWnkPzkm12f5A&usqp=CAU",
                                                        height: 30,
                                                        width: 50,
                                                      ),
                                                      SizedBox(
                                                        width: MediaQuery.of(context).size.width * 0.01,
                                                      ),
                                                      Text(getTranslated(context, AppString.stripe_label).toString(), style: TextStyle(fontSize: 16, color: Palette.black)),
                                                    ],
                                                  ),
                                                ),
                                                value: SingingCharacter.Stripe,
                                                activeColor: Palette.black,
                                                groupValue: _character,
                                                onChanged: (SingingCharacter? value) {
                                                  setState(() {
                                                    _character = value;
                                                    isPaymentClicked = true;
                                                  });
                                                },
                                              ))
                                          : Container(),
                                      flutterWave == 1
                                          ? Container(
                                              alignment: Alignment.center,
                                              margin: EdgeInsets.all(5),
                                              decoration: BoxDecoration(boxShadow: [
                                                BoxShadow(
                                                  color: Palette.dark_grey.withOpacity(0.2),
                                                  spreadRadius: 2,
                                                  blurRadius: 7,
                                                  offset: Offset(0, 3), // changes position of shadow
                                                ),
                                              ], borderRadius: BorderRadius.circular(10), color: Palette.white),
                                              height: MediaQuery.of(context).size.height * 0.08,
                                              child: RadioListTile<SingingCharacter>(
                                                controlAffinity: ListTileControlAffinity.trailing,
                                                title: Container(
                                                  width: MediaQuery.of(context).size.width / 5,
                                                  // color: Colors.red,
                                                  child: Row(
                                                    children: [
                                                      Image.network(
                                                        "https://cdn.filestackcontent.com/OITnhSPCSzOuiVvwnH7r",
                                                        height: 30,
                                                        width: 50,
                                                      ),
                                                      SizedBox(
                                                        width: MediaQuery.of(context).size.width * 0.01,
                                                      ),
                                                      Flexible(
                                                        child: Text(getTranslated(context, AppString.flutterWave_label).toString(), overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(fontSize: 16, color: Palette.black)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                value: SingingCharacter.FlutterWave,
                                                activeColor: Palette.black,
                                                groupValue: _character,
                                                onChanged: (SingingCharacter? value) {
                                                  setState(() {
                                                    _character = value;
                                                    isPaymentClicked = true;
                                                  });
                                                },
                                              ))
                                          : Container(),
                                      payStack == 1
                                          ? Container(
                                              alignment: Alignment.center,
                                              margin: EdgeInsets.all(5),
                                              decoration: BoxDecoration(boxShadow: [
                                                BoxShadow(
                                                  color: Palette.dark_grey.withOpacity(0.2),
                                                  spreadRadius: 2,
                                                  blurRadius: 7,
                                                  offset: Offset(0, 3), // changes position of shadow
                                                ),
                                              ], borderRadius: BorderRadius.circular(10), color: Palette.white),
                                              height: MediaQuery.of(context).size.height * 0.08,
                                              child: RadioListTile<SingingCharacter>(
                                                controlAffinity: ListTileControlAffinity.trailing,
                                                title: Container(
                                                  width: MediaQuery.of(context).size.width / 5,
                                                  child: Row(
                                                    children: [
                                                      Image.network(
                                                        "https://website-v3-assets.s3.amazonaws.com/assets/img/hero/Paystack-mark-white-twitter.png",
                                                        height: 30,
                                                        width: 50,
                                                      ),
                                                      SizedBox(
                                                        width: MediaQuery.of(context).size.width * 0.01,
                                                      ),
                                                      Text(getTranslated(context, AppString.payStackLabel).toString(), style: TextStyle(fontSize: 16, color: Palette.black)),
                                                    ],
                                                  ),
                                                ),
                                                value: SingingCharacter.PayStack,
                                                activeColor: Palette.black,
                                                groupValue: _character,
                                                onChanged: (SingingCharacter? value) {
                                                  setState(() {
                                                    _character = value;
                                                    isPaymentClicked = true;
                                                  });
                                                },
                                              ),
                                            )
                                          : Container(),
                                      cod == 1
                                          ? Container(
                                              alignment: Alignment.center,
                                              margin: EdgeInsets.all(5),
                                              decoration: BoxDecoration(boxShadow: [
                                                BoxShadow(
                                                  color: Palette.dark_grey.withOpacity(0.2),
                                                  spreadRadius: 2,
                                                  blurRadius: 7,
                                                  offset: Offset(0, 3), // changes position of shadow
                                                ),
                                              ], borderRadius: BorderRadius.circular(10), color: Palette.white),
                                              height: MediaQuery.of(context).size.height * 0.08,
                                              child: RadioListTile<SingingCharacter>(
                                                controlAffinity: ListTileControlAffinity.trailing,
                                                title: Text(
                                                  getTranslated(context, AppString.codLabel).toString(),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: TextStyle(fontSize: 16, color: Palette.black),
                                                ),
                                                value: SingingCharacter.COD,
                                                activeColor: Palette.black,
                                                groupValue: _character,
                                                onChanged: (SingingCharacter? value) {
                                                  setState(() {
                                                    _character = value;
                                                    isPaymentClicked = true;
                                                  });
                                                },
                                              ),
                                            )
                                          : Container(),
                                    ],
                                  ),
                                ],
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
            ),
          ),
          inAsyncCall: loading,
          opacity: 0.5,
          progressIndicator: CircularProgressIndicator(),
        ),
        bottomNavigationBar: Container(
          height: 50,
          child: ElevatedButton(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_currentStep == 0)
                  Text(
                    getTranslated(context, AppString.bookAppointment_continue_button).toString(),
                    style: TextStyle(fontSize: width * 0.04, color: Palette.white),
                  ),
                if (_currentStep == 1)
                  Text(
                    getTranslated(context, AppString.bookAppointment_continue_button).toString(),
                    style: TextStyle(fontSize: width * 0.04, color: Palette.white),
                  ),
                if (_currentStep == 2)
                  '$newAppointmentFees' == "0.0"
                      ? Text(
                          getTranslated(context, AppString.bookAppointment_pay_button).toString() + SharedPreferenceHelper.getString(Preferences.currency_symbol).toString() + '$appointmentFees',
                          style: TextStyle(fontSize: width * 0.04, color: Palette.white),
                        )
                      : Text(
                          getTranslated(context,AppString.bookAppointment_pay_button).toString() + SharedPreferenceHelper.getString(Preferences.currency_symbol).toString() + '$newAppointmentFees',
                          style: TextStyle(fontSize: width * 0.04, color: Palette.white),
                        )
              ],
            ),
            onPressed: () {
              setState(
                () {
                  if (_currentStep == 0 && _step1.currentState!.validate()) {
                    continued();
                  } else if (_currentStep == 1) {
                    if (selectTime != null && selectTime != "" && selectTime != "null") {
                      continued();
                    } else {
                      Fluttertoast.showToast(
                        msg: getTranslated(context, "selectTime").toString(),
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                      );
                    }
                  } else if (_currentStep == 2) {
                    str = "$_character";
                    parts = str.split(".");
                    startPart = parts[0].trim();
                    paymentType = parts.sublist(1).join('.').trim();

                    if (_character!.index == 0) {
                      setState(() {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) => PaypalPayment(
                              total: "$newAppointmentFees" != "0.0" ? '$newAppointmentFees' : '$appointmentFees',
                              onFinish: (number) async {
                                if (number != null && number.toString() != '') {
                                  setState(() {
                                    _paymentToken = number;
                                    callApiBook();
                                  });
                                }
                              },
                            ),
                          ),
                        );
                      });
                    } else if (_character!.index == 1) {
                      openCheckoutRazorPay();
                    } else if (_character!.index == 2) {
                      Provider.of<StripePayment>(context, listen: false).makePayment(
                          context: context,
                          selectAppointmentFor: selectAppointmentFor!,
                          hospitalId: hospitalId,
                          patientName: patientNameController.text,
                          illnessInformation: illnessInformation.text,
                          age: ageController.text,
                          patientAddress: selectAddressId.toString(),
                          phoneNo: phoneNoController.text,
                          selectDrugEffects: selectDrugEffects,
                          note: note.text,
                          newDate: newDate,
                          selectTime: selectTime,
                          appointmentFees: "$newAppointmentFees" != "0.0" ? '$newAppointmentFees' : '$appointmentFees',
                          doctorId: id,
                          newDateUser: newDateUser,
                          reportImages: reportImages,
                          isInsured: isInsured,
                          insurerName: selectInsured,
                          policyNumber: policyNumberController.text);
                    } else if (_character!.index == 3) {
                      flutterWavePayment(context, appointmentFees);
                    } else if (_character!.index == 4) {
                      paystackFunction();
                    } else if (_character!.index == 5) {
                      setState(() {
                        callApiBook();
                      });
                    }
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  ///flutter wave
  final String currencyFlutterWave = "RWF";

  flutterWavePayment(context, payAmount) async {
    final flutterwave = Flutterwave(
        context: context,
        publicKey: SharedPreferenceHelper.getString(Preferences.flutterWave_key)!,
        currency: this.currencyFlutterWave,
        txRef: Uuid().v1(),
        amount: payAmount.toString(),
        customer: customer,
        paymentOptions: "card",
        customization: Customization(title: "Delicious"),
        redirectUrl: "https://www.google.com",
        isTestMode: true);
    final ChargeResponse response = await flutterwave.charge();
    if (response.transactionId!.isNotEmpty) {
      setState(() {
        _paymentToken = response.transactionId;
        callApiBook();
        ;
      });
    }
  }

  final Customer customer = Customer(name: SharedPreferenceHelper.getString(Preferences.name)!, phoneNumber: SharedPreferenceHelper.getString(Preferences.phone)!, email: SharedPreferenceHelper.getString(FirestoreConstants.email)!);

  Future<BaseModel<BookAppointments>> callApiBook() async {
    BookAppointments response;
    Map<String, dynamic> body = {
      "appointment_for": selectAppointmentFor,
      "hospital_id": hospitalId,
      "patient_name": patientNameController.text,
      "illness_information": illnessInformation.text,
      "age": ageController.text,
      "patient_address": selectAddressId,
      "phone_no": phoneNoController.text,
      "drug_effect": selectDrugEffects,
      "note": note.text != "" ? note.text : "No note",
      "date": newDate,
      "time": selectTime,
      "payment_type": paymentType,
      "payment_status": _character!.index == 5 ? 0 : 1,
      "_paymentToken": _character!.index == 5 ? "" : _paymentToken,
      "amount": newAppointmentFees != 0.0 ? newAppointmentFees.toString() : appointmentFees,
      "doctor_id": id,
      "report_image": reportImages.length != 0 ? reportImages : "",
    };
    if (isInsured == true) {
      body['is_insured'] = isInsured == true ? 1 : 0;
      body['policy_insurer_name'] = selectInsured;
      body['policy_number'] = policyNumberController.text;
    } else if (isInsured == false) {
      body['is_insured'] = isInsured == true ? 1 : 0;
    }
    print(body);
    setState(() {
      Preferences.onLoading(context);
    });
    try {
      response = await RestClient(RetroApi().dioData()).bookAppointment(body);
      if (response.success == true) {
        setState(() {
          Preferences.hideDialog(context);
          bookingId = response.data;
          _passDateTime();
          Fluttertoast.showToast(
            msg: '${response.msg}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
          );
          Navigator.pushReplacementNamed(context, 'BookSuccess');
        });
      } else {
        Preferences.hideDialog(context);
      }
    } catch (error, stacktrace) {
      Preferences.hideDialog(context);
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  // RazorPay Code //
  void openCheckoutRazorPay() async {
    var map = {
      'key': SharedPreferenceHelper.getString(Preferences.razor_key),
      'amount': "$newAppointmentFees" != "0.0" ? num.parse('$newAppointmentFees') * 100 : num.parse('$appointmentFees') * 100,
      'name': '$businessName',
      'currency': SharedPreferenceHelper.getString(Preferences.currency_code),
      'image': '$logo',
      'description': '',
      'send_sms_hash': 'true',
      'prefill': {'contact': '$userPhoneNo', 'email': '$userEmail'},
      'external': {
        'wallets': ['paytm']
      }
    };
    var options = map;
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: e');
    }
  }

  // RazorPay Success Method //
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _paymentToken = response.paymentId;
    _paymentToken != "" && _paymentToken!.isNotEmpty ? callApiBook() : Fluttertoast.showToast(msg: getTranslated(context, AppString.bookAppointment_paymentNotComplete_toast).toString(), toastLength: Toast.LENGTH_SHORT);
  }

  // RazorPay Error Method //
  void _handlePaymentError(PaymentFailureResponse response) {}

  // RazorPay Wallet Method //
  void _handleExternalWallet(ExternalWalletResponse response) {}

  paystackFunction() async {
    int convertAmount = newAppointmentFees != 0.0 ? int.parse(newAppointmentFees.toString().split(".")[0].toString()) * 100 : int.parse(appointmentFees.toString().split(".")[0].toString());
    int amountToPaystack = convertAmount * 100;
    Charge charge = Charge()
      ..amount = amountToPaystack
      ..reference = _getReference()
      ..currency = SharedPreferenceHelper.getString(Preferences.currency_code)
      ..email = userEmail;
    CheckoutResponse response = await plugin.checkout(
      context,
      method: CheckoutMethod.card,
      charge: charge,
    );
    if (response.status == true) {
      _paymentToken = response.reference;
      _paymentToken != "" && _paymentToken!.isNotEmpty ? callApiBook() : Fluttertoast.showToast(msg: getTranslated(context, AppString.bookAppointment_paymentNotComplete_toast).toString(), toastLength: Toast.LENGTH_SHORT);
      setState(() {
        paymentToken = response.reference;
      });
    } else {
      print('error : ' + response.message);
    }
  }

  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }
    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Call Doctor Time Api //

  Future<BaseModel<Timeslot>> timeSlot() async {
    Timeslot response;
    Map<String, dynamic> body = {
      "doctor_id": id,
      "date": newDate,
    };
    setState(() {
      loading = true;
    });
    try {
      setState(() {
        timeList.clear();
      });
      response = await RestClient(RetroApi().dioData()).timeslot(body);
      if (response.success == true) {
        setState(() {
          loading = false;
          timeList.addAll(response.data!);
        });
      }
    } catch (error, stacktrace) {
      setState(() {
        loading = false;
      });
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  // Call Doctor Detail Api //
  Future<BaseModel<DoctorDetailModel>> callApiDoctorDetail() async {
    DoctorDetailModel response;
    Map<String, dynamic> body = {
      "lat": _lat,
      "lang": _lang,
    };
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi2().dioData2()).doctorDetailRequest(id, body);
      if (response.success == true) {
        setState(() {
          loading = false;
          name = response.data!.name;
          rate = response.data!.rate;
          experience = response.data!.experience;
          appointmentFees = response.data!.appointmentFees;
          desc = response.data!.desc;
          expertise = response.data!.expertise!.name;
          fullImage = response.data!.fullImage;
          treatmentName = response.data!.treatment!.name;

          hospital.addAll(response.data!.hospitalId!);
          for (int i = 0; i < hospital.length; i++) {
            hospitalName = response.data!.hospitalId![i].hospitalDetails!.name!;
            hospitalAddress = response.data!.hospitalId![i].hospitalDetails!.address;
          }
          // hospitalGallery.addAll(response.data!.hospitalId![0].hospitalGallery!);
        });
      }
    } catch (error, stacktrace) {
      setState(() {
        loading = false;
      });
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  // ShowAddress //
  Future<BaseModel<ShowAddress>> callApiShowAddress() async {
    ShowAddress response;
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi().dioData()).showAddressRequest();
      showAddress.clear();
      setState(() {
        loading = false;
        if (response.success == true) {
          showAddress.addAll(response.data!);
        }
      });
    } catch (error, stacktrace) {
      setState(() {
        loading = false;
      });
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<DetailSetting>> callApiSetting() async {
    DetailSetting response;
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi().dioData()).settingRequest();
      loading = false;
      if (response.success == true) {
        razorpayKey = response.data!.razorKey;
        businessName = response.data!.businessName;
        logo = response.data!.logo;
        cod = response.data!.cod;
        stripe = response.data!.stripe;
        paypal = response.data!.paypal;
        flutterWave = response.data!.flutterwave;
        razor = response.data!.razor;
        payStack = response.data!.payStack;
        isLiveKey = response.data!.isLiveKey;
      }
    } catch (error, stacktrace) {
      setState(() {
        loading = false;
      });
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
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

  // Select Date Method //
  _selectDate(BuildContext context) async {
    DateTime? newSelectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate != null ? _selectedDate! : DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 366)),
    );
    if (newSelectedDate != null) {
      _selectedDate = newSelectedDate;
      date
        ..text = DateFormat('dd-MM-yyyy').format(_selectedDate!)
        ..selection = TextSelection.fromPosition(
          TextPosition(offset: date.text.length, affinity: TextAffinity.upstream),
        );
      var temp = '$_selectedDate';
      // Date Format  display user
      newDateUser = DateUtil().formattedDate(DateTime.parse(temp));
      // Date Format pass Api
      newDate = DateUtilForPass().formattedDate(DateTime.parse(temp));
    }
    timeSlot();
  }

  // Select Image //
  void _proImgFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(
      () {
        if (pickedFile != null) {
          SharedPreferenceHelper.setString(Preferences.reportImage, pickedFile.path);
          _proImage = File(SharedPreferenceHelper.getString(Preferences.reportImage)!);
          List<int> imageBytes = _proImage!.readAsBytesSync();
          reportImage = base64Encode(imageBytes);
          if (reportImage != "null") {
            reportImages.add(reportImage);
          }
        } else {
          print('No image selected.');
        }
      },
    );
  }

  void _proImgFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        SharedPreferenceHelper.setString(Preferences.reportImage, pickedFile.path);
        _proImage = File(SharedPreferenceHelper.getString(Preferences.reportImage)!);
        List<int> imageBytes = _proImage!.readAsBytesSync();
        reportImage = base64Encode(imageBytes);
        if (reportImage != "null") {
          reportImages.add(reportImage);
        }
      } else {
        print('No image selected.');
      }
    });
  }

  // Select Image1 //
  void _proImgFromGallery1() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(
      () {
        if (pickedFile != null) {
          SharedPreferenceHelper.setString(Preferences.reportImage1, pickedFile.path);
          _proImage1 = File(SharedPreferenceHelper.getString(Preferences.reportImage1)!);
          List<int> imageBytes = _proImage1!.readAsBytesSync();
          reportImage1 = base64Encode(imageBytes);
          if (reportImage1 != "null") {
            reportImages.add(reportImage1);
          }
        } else {
          print('No image selected.');
        }
      },
    );
  }

  void _proImgFromCamera1() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        SharedPreferenceHelper.setString(Preferences.reportImage1, pickedFile.path);
        _proImage1 = File(SharedPreferenceHelper.getString(Preferences.reportImage1)!);
        List<int> imageBytes = _proImage1!.readAsBytesSync();
        reportImage1 = base64Encode(imageBytes);
        if (reportImage1 != "null") {
          reportImages.add(reportImage1);
        }
      } else {
        print('No image selected.');
      }
    });
  }

  // Select Image2 //
  void _proImgFromGallery2() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(
      () {
        if (pickedFile != null) {
          SharedPreferenceHelper.setString(Preferences.reportImage2, pickedFile.path);
          _proImage2 = File(SharedPreferenceHelper.getString(Preferences.reportImage2)!);
          List<int> imageBytes = _proImage2!.readAsBytesSync();
          reportImage2 = base64Encode(imageBytes);
          if (reportImage2 != "null") {
            reportImages.add(reportImage2);
          }
        } else {
          print('No image selected.');
        }
      },
    );
  }

  void _proImgFromCamera2() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        SharedPreferenceHelper.setString(Preferences.reportImage2, pickedFile.path);
        _proImage2 = File(SharedPreferenceHelper.getString(Preferences.reportImage2)!);
        List<int> imageBytes = _proImage2!.readAsBytesSync();
        reportImage2 = base64Encode(imageBytes);
        if (reportImage2 != "null") {
          reportImages.add(reportImage2);
        }
      } else {
        print('No image selected.');
      }
    });
  }

  //  Offer //

  Future<BaseModel<ApplyOffer>> callApiApplyOffer() async {
    ApplyOffer response;
    var offerDateToday = "$todayDate";
    String offerDate = DateUtilForPass().formattedDate(DateTime.parse(offerDateToday));
    Map<String, dynamic> body = {
      "offer_code": _offerController.text,
      "date": offerDate,
      "doctor_id": id,
      "from": "appointment",
    };
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi().dioData()).applyOfferRequest(body);
      if (response.success == true) {
        setState(() {
          loading = false;
          discountType = response.data!.discountType!.toUpperCase();
          flatDiscount = response.data!.flatDiscount;
          isFlat = response.data!.isFlat;
          minDiscount = response.data!.minDiscount;
          discount = response.data!.discount;

          if (discountType == "AMOUNT" && isFlat == 1) {
            if (int.parse('$appointmentFees') > flatDiscount!) {
              if (flatDiscount! < minDiscount!) {
                newAppointmentFees = int.parse('$appointmentFees') - int.parse('$flatDiscount');
              } else {
                newAppointmentFees = int.parse('$appointmentFees') - int.parse('$minDiscount');
              }
              Fluttertoast.showToast(
                msg: getTranslated(context, AppString.bookAppointment_offerApply_toast).toString(),
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
              );
            } else {
              Fluttertoast.showToast(
                msg: getTranslated(context, AppString.bookAppointment_worthMore_toast).toString() + SharedPreferenceHelper.getString(Preferences.currency_symbol).toString() + '$flatDiscount.',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
              );
            }
          } else if (discountType == "AMOUNT" && isFlat == 0) {
            if (int.parse('$appointmentFees') > discount!) {
              if (discount! < minDiscount!) {
                newAppointmentFees = int.parse('$appointmentFees') - int.parse('$discount');
              } else {
                newAppointmentFees = int.parse('$appointmentFees') - int.parse('$minDiscount');
              }
              Fluttertoast.showToast(
                msg: getTranslated(context, AppString.bookAppointment_offerApply_toast).toString(),
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
              );
            } else {
              Fluttertoast.showToast(
                msg: getTranslated(context, AppString.bookAppointment_worthMore_toast).toString() + SharedPreferenceHelper.getString(Preferences.currency_symbol).toString() + '$discount.',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
              );
            }
          } else if (discountType == "PERCENTAGE") {
            setState(() {
              prAmount = (int.parse('$appointmentFees') * int.parse('$discount')) / 100;
              if (prAmount <= minDiscount!) {
                newAppointmentFees = double.parse('$appointmentFees') - double.parse('$prAmount');
              } else {
                newAppointmentFees = double.parse('$appointmentFees') - double.parse('$minDiscount');
              }
            });
            Fluttertoast.showToast(
              msg: int.parse('$appointmentFees') >= prAmount || int.parse('$appointmentFees') >= minDiscount!
                  ? getTranslated(context, AppString.bookAppointment_offerApply_toast).toString()
                  : getTranslated(context, AppString.bookAppointment_itemWorth_toast).toString() + '$prAmount' + getTranslated(context, AppString.bookAppointment_orMore_toast).toString(),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
            );
            newAppointmentFees = int.parse('$appointmentFees') >= prAmount || int.parse('$appointmentFees') >= minDiscount! ? newAppointmentFees : appointmentFees;
          }
        });
      } else {
        setState(() {
          loading = false;
          Fluttertoast.showToast(
            msg: '${response.msg}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
          );
        });
      }
    } catch (error, stacktrace) {
      setState(() {
        loading = false;
      });
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  // Image Function //
  void _chooseProfileImage() {
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
                      getTranslated(context, AppString.fromGallery).toString(),
                    ),
                    onTap: () {
                      _proImgFromGallery();
                      Navigator.of(context).pop();
                    }),
                new ListTile(
                  leading: new Icon(Icons.photo_camera),
                  title: new Text(
                    getTranslated(context, AppString.fromCamera).toString(),
                  ),
                  onTap: () {
                    _proImgFromCamera();
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

  void _chooseProfileImage1() {
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
                      getTranslated(context, AppString.fromGallery).toString(),
                    ),
                    onTap: () {
                      _proImgFromGallery1();
                      Navigator.of(context).pop();
                    }),
                new ListTile(
                  leading: new Icon(Icons.photo_camera),
                  title: new Text(
                    getTranslated(context, AppString.fromCamera).toString(),
                  ),
                  onTap: () {
                    _proImgFromCamera1();
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

  void _chooseProfileImage2() {
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
                      getTranslated(context, AppString.fromGallery).toString(),
                    ),
                    onTap: () {
                      _proImgFromGallery2();
                      Navigator.of(context).pop();
                    }),
                new ListTile(
                  leading: new Icon(Icons.photo_camera),
                  title: new Text(
                    getTranslated(context, AppString.fromCamera).toString(),
                  ),
                  onTap: () {
                    _proImgFromCamera2();
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

  List<InsurersData> allInsurers = [];

  Future<BaseModel<InsurersResponse>> callGetInsurers() async {
    InsurersResponse response;
    try {
      setState(() {
        allInsurers.clear();
      });
      response = await RestClient(RetroApi().dioData()).callInsurers();
      if (response.success == true) {
        setState(() {
          allInsurers.addAll(response.data!);
        });
      }
    } catch (error) {
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}

// Date Format  Display user
class DateUtil {
  static const DATE_FORMAT = 'dd-MM-yyyy';

  String formattedDate(DateTime dateTime) {
    return DateFormat(DATE_FORMAT).format(dateTime);
  }
}

// Date Format pass Api
class DateUtilForPass {
  static const DATE_FORMAT = 'yyyy-MM-dd';

  String formattedDate(DateTime dateTime) {
    return DateFormat(DATE_FORMAT).format(dateTime);
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
