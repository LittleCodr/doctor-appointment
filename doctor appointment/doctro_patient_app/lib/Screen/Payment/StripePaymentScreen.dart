import 'package:doctro_patient/const/preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/retrofit_Api.dart';
import '../../api/base_model.dart';
import '../../api/network_api.dart';
import '../../api/server_error.dart';
import '../../const/app_string.dart';
import '../../const/prefConstatnt.dart';
import '../../localization/localization_constant.dart';
import '../../model/book_appointments_model.dart';

class StripePaymentScreen extends StatefulWidget {
  final String? selectAppointmentFor;
  final int? hospitalId;
  final String? patientName;
  final String? illnessInformation;
  final String? age;
  final String? patientAddress;
  final String? phoneNo;
  final String? selectDrugEffects;
  final String? note;
  final String? newDate; // pass Api
  final String? selectTime;
  final String? appointmentFees;
  final int? doctorId;
  final String? newDateUser; // show user
  final List<String>? reportImages;

  StripePaymentScreen({
    this.selectAppointmentFor,
    this.hospitalId,
    this.patientName,
    this.illnessInformation,
    this.age,
    this.patientAddress,
    this.phoneNo,
    this.selectDrugEffects,
    this.note,
    this.newDate,
    this.selectTime,
    this.appointmentFees,
    this.doctorId,
    this.newDateUser,
    this.reportImages,
  });

  @override
  _StripePaymentScreenState createState() => _StripePaymentScreenState();
}

class _StripePaymentScreenState extends State<StripePaymentScreen> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  late var str;
  var parts;
  var year;
  var date;

  var error;
  var paymentToken;

  String? passBookDate = "";
  String? passBookTime = "";
  String passBookID = "";

  String? bookingId = "";

  CardFieldInputDetails? _card;
  TokenData? tokenData;

  @override
  void initState() {
    super.initState();
    setKey();
  }

  Future setKey() async {
    Stripe.publishableKey = SharedPreferenceHelper.getString(Preferences.stripe_public_key)!;
    Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
    Stripe.urlScheme = 'flutter stripe';
    await Stripe.instance.applySettings();
    print("Success");
  }

  _passDateTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(
      () {
        passBookDate = widget.newDateUser;
        passBookTime = widget.selectTime;
        passBookID = '$bookingId';
        prefs.setString('BookDate', passBookDate!);
        prefs.setString('BookTime', passBookTime!);
        prefs.setString('BookID', passBookID);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      body: ListView(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: CardField(
                  autofocus: true,
                  onCardChanged: (card) {
                    setState(() {
                      _card = card;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(15),
                child: ElevatedButton(
                  onPressed: _card?.complete == true ? _handleCreateTokenPress : null,
                  child: Text(getTranslated(context, AppString.stripePaymentBookAppointment_pay).toString()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleCreateTokenPress() async {
    if (_card == null) {
      return;
    }

    try {
      final tokenData = await Stripe.instance.createToken(CreateTokenParams.card(params: CardTokenParams(type: TokenType.Card)));
      setState(() {
        this.tokenData = tokenData;
        callApiBook();
      });
      return;
    } catch (e) {
      rethrow;
    }
  }

  Future<BaseModel<BookAppointments>> callApiBook() async {
    BookAppointments response;
    Map<String, dynamic> body = {
      "hospital_id": widget.hospitalId,
      "appointment_for": widget.selectAppointmentFor,
      "patient_name": widget.patientName,
      "illness_information": widget.illnessInformation,
      "age": widget.age,
      "patient_address": widget.patientAddress,
      "phone_no": widget.phoneNo,
      "drug_effect": widget.selectDrugEffects,
      "note": widget.note != "" ? widget.note : "No note",
      "date": widget.newDate,
      "time": widget.selectTime,
      "payment_type": "Stripe",
      "payment_status": 1,
      "payment_token": tokenData!.id,
      "amount": widget.appointmentFees,
      "doctor_id": widget.doctorId,
      "report_image": widget.reportImages!.length != 0 ? widget.reportImages : "",
    };
    setState(() {
      Preferences.onLoading(context);
    });
    try {
      response = await RestClient(RetroApi().dioData()).bookAppointment(body);
      if (response.success == true) {
        setState(
          () {
            Preferences.hideDialog(context);
            bookingId = response.data;
            _passDateTime();
            Navigator.pushReplacementNamed(context, 'BookSuccess');
            Fluttertoast.showToast(
              msg: '${response.msg}',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
            );
          },
        );
      } else {
        Preferences.hideDialog(context);
      }
    } catch (error, stacktrace) {
      setState(() {
        Preferences.hideDialog(context);
      });
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
