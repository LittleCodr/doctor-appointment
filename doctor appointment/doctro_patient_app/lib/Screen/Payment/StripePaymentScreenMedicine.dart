import 'dart:convert';
import 'package:doctro_patient/Screen/MedicineAndPharmacy/AllPharamacy.dart';
import 'package:doctro_patient/api/retrofit_Api.dart';
import 'package:doctro_patient/api/base_model.dart';
import 'package:doctro_patient/api/network_api.dart';
import 'package:doctro_patient/api/server_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../../const/prefConstatnt.dart';
import '../../../const/preference.dart';
import '../../../database/db_service.dart';
import '../../../models/data_model.dart';
import '../../const/Palette.dart';
import '../../const/app_string.dart';
import '../../localization/localization_constant.dart';
import '../../model/common_response.dart';

class StripePaymentScreenMedicine extends StatefulWidget {
  final int? pharamacyId;
  final String? amount;
  final String? deliveryType;
  final String? prescriptionFilePath;
  final String? strFinalDeliveryCharge;
  final List<Map>? listData;

  StripePaymentScreenMedicine({
    this.pharamacyId,
    this.amount,
    this.deliveryType,
    this.strFinalDeliveryCharge,
    this.listData,
    this.prescriptionFilePath,
  });

  @override
  _StripePaymentScreenMedicineState createState() => _StripePaymentScreenMedicineState();
}

class _StripePaymentScreenMedicineState extends State<StripePaymentScreenMedicine> {
  bool loading = false;

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

  ProductModel? model;
  late DBService dbService;

  CardFieldInputDetails? _card;

  TokenData? tokenData;

  @override
  void initState() {
    super.initState();
    dbService = new DBService();
    model = new ProductModel();
    _getAddress();
    setKey();
  }

  Future setKey() async {
    Stripe.publishableKey = SharedPreferenceHelper.getString(Preferences.stripe_public_key)!;
    await Stripe.instance.applySettings();
  }

  String? address = "";
  int addressId = 0;

  String isWhere = "";
  String? userLat = "";
  String? userLang = "";
  String? userPhoneNo = "";
  String? userEmail = "";

  _getAddress() async {
    setState(
      () {
        address = (SharedPreferenceHelper.getString('Address'));
        addressId = (SharedPreferenceHelper.getInt('addressId'));
        userLat = SharedPreferenceHelper.getString('lat');
        userLang = SharedPreferenceHelper.getString('lang');
        //user data
        userPhoneNo = SharedPreferenceHelper.getString('phone_no');
        userEmail = SharedPreferenceHelper.getString('email');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: loading,
      opacity: 1,
      progressIndicator: SpinKitFadingCircle(
        color: Palette.blue,
        size: 50.0,
      ),
      child: Scaffold(
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
                    child: Text(
                      getTranslated(context, AppString.stripePaymentBookAppointment_pay).toString(),
                    ),
                    // text: 'Create token',
                  ),
                ),
              ],
            ),
          ],
        ),
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
        callApiBookMedicine();
      });
      return;
    } catch (e) {
      rethrow;
    }
  }

  Future<BaseModel<CommonResponse>> callApiBookMedicine() async {
    String fileName = widget.prescriptionFilePath!.split('/').last;
    CommonResponse response;
    Map<String, dynamic> body = {};
    body['pharmacy_id'] = widget.pharamacyId;
    body["medicines"] = JsonEncoder().convert(widget.listData);
    body["amount"] = widget.amount;
    body["payment_type"] = "Stripe";
    body["payment_status"] = 1;
    body["payment_token"] = tokenData!.id;
    body["shipping_at"] = widget.deliveryType;
    body["address_id"] = widget.deliveryType == 'Pharmacy' ? "" : addressId;
    body["delivery_charge"] = widget.deliveryType == 'Pharmacy' ? 0 : widget.strFinalDeliveryCharge;
    if (widget.prescriptionFilePath != "") {
      body["pdf"] = MultipartFile.fromFileSync(widget.prescriptionFilePath!, filename: fileName);
    }
    try {
      print(body);
      setState(() {
        Preferences.onLoading(context);
      });
      response = await RestClient(RetroApi().dioData()).bookMedicineRequest(body);
      if (response.success == true) {
        setState(() {
          Preferences.hideDialog(context);
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        Preferences.hideDialog(context);
        prefs.remove('grandTotal');
        prefs.remove('strFinalDeliveryCharge');
        prefs.remove('pharmacyId');
        prefs.remove('prescriptionFilePath');
        late List<ProductModel> products;
        await dbService.getProducts().then((value) {
          products = value;
        });
        dbService.deleteTable(products[0]).then((value) {
          setState(() {});
        });
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => AllPharamacy()),
          ModalRoute.withName('/'),
        );
      } else {
        setState(() {
          Preferences.hideDialog(context);
        });
      }
    } catch (error) {
      setState(() {
        Preferences.hideDialog(context);
      });
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
