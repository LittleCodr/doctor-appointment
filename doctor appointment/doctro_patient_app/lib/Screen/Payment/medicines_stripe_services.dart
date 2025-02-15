import 'package:doctro_patient/const/app_string.dart';
import 'package:doctro_patient/localization/localization_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../api/base_model.dart';
import '../../const/preference.dart';
import '../../database/db_service.dart';
import '../../model/common_response.dart';
import 'package:doctro_patient/Screen/MedicineAndPharmacy/AllPharamacy.dart';
import 'package:doctro_patient/api/retrofit_Api.dart';
import 'package:doctro_patient/api/network_api.dart';
import 'package:doctro_patient/api/server_error.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../../const/prefConstatnt.dart';
import '../../../models/data_model.dart';

class MedicinesStripePayment extends ChangeNotifier {
  Map<String, dynamic>? paymentIntent;
  String stripeKey = "";
  int addressId = 0;

  Future<void> makePayment({
    required BuildContext context,
    required int? pharamacyId,
    required String? amount,
    required String? deliveryType,
    required String? prescriptionFilePath,
    required String? strFinalDeliveryCharge,
    required List<Map>? listData,
  }) async {
    try {
      addressId = (SharedPreferenceHelper.getInt('addressId'));
      paymentIntent = await createPaymentIntent(amount!, SharedPreferenceHelper.getString(Preferences.currency_code)!);
      stripeKey = SharedPreferenceHelper.getString(Preferences.stripe_secret_key)!;
      //STEP 2: Initialize Payment Sheet
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntent!['client_secret'], //Gotten from payment intent
                  style: ThemeMode.dark,
                  merchantDisplayName: 'Doctro Patient'))
          .then((value) {});

      //STEP 3: Display Payment sheet
      // ignore: use_build_context_synchronously
      displayPaymentSheet(context: context, strFinalDeliveryCharge: strFinalDeliveryCharge, prescriptionFilePath: prescriptionFilePath, pharamacyId: pharamacyId, listData: listData, deliveryType: deliveryType, amount: amount);
    } catch (err) {
      throw Exception(err);
    }
  }

  displayPaymentSheet({
    required BuildContext context,
    required int? pharamacyId,
    required String? amount,
    required String? deliveryType,
    required String? prescriptionFilePath,
    required String? strFinalDeliveryCharge,
    required List<Map>? listData,
  }) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        print("Stripe Token : ${paymentIntent!["id"]}");
        callApiBookMedicine(
            context: context, amount: amount, deliveryType: deliveryType, listData: listData, pharamacyId: pharamacyId, prescriptionFilePath: prescriptionFilePath, strFinalDeliveryCharge: strFinalDeliveryCharge, token: paymentIntent!["id"]);
        paymentIntent = null;
      }).onError((error, stackTrace) {
        throw Exception(error);
      });
    } on StripeException catch (e) {
      print('Error is:---> $e');
      AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children:  [
                Icon(
                  Icons.cancel,
                  color: Colors.red,
                ),
                Text(getTranslated(context, AppString.paymentFailed).toString()),
              ],
            ),
          ],
        ),
      );
    } catch (e) {
      print('$e');
      AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children:  [
                Icon(
                  Icons.cancel,
                  color: Colors.red,
                ),
                Text(getTranslated(context, AppString.paymentFailed).toString()),
              ],
            ),
          ],
        ),
      );
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      //Request body
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
      };

      //Make post request to Stripe
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $stripeKey', // ${dotenv.env['STRIPE_SECRET']}
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      return json.decode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  calculateAmount(String amount) {
    final calculatedAmount = (int.parse(amount)) * 100;
    return calculatedAmount.toString();
  }

  Future<BaseModel<CommonResponse>> callApiBookMedicine(
      {required BuildContext context,
      required int? pharamacyId,
      required String? amount,
      required String? deliveryType,
      required String? prescriptionFilePath,
      required String? strFinalDeliveryCharge,
      required List<Map>? listData,
      required String token}) async {
    DBService dbService = DBService();
    String fileName = prescriptionFilePath!.split('/').last;
    CommonResponse response;
    Map<String, dynamic> body = {};
    body['pharmacy_id'] = pharamacyId;
    body["medicines"] = JsonEncoder().convert(listData);
    body["amount"] = amount;
    body["payment_type"] = "Stripe";
    body["payment_status"] = 1;
    body["payment_token"] = token;
    body["shipping_at"] = deliveryType;
    body["address_id"] = deliveryType == 'Pharmacy' ? "" : addressId;
    body["delivery_charge"] = deliveryType == 'Pharmacy' ? 0 : strFinalDeliveryCharge;
    if (prescriptionFilePath != "") {
      body["pdf"] = MultipartFile.fromFileSync(prescriptionFilePath, filename: fileName);
    }
    try {
      print(body);
      Preferences.onLoading(context);
      notifyListeners();
      response = await RestClient(RetroApi().dioData()).bookMedicineRequest(body);
      if (response.success == true) {
        Preferences.hideDialog(context);
        notifyListeners();
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
          notifyListeners();
        });
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => AllPharamacy()),
          ModalRoute.withName('/'),
        );
      } else {
        Preferences.hideDialog(context);
        notifyListeners();
      }
    } catch (error) {
      Preferences.hideDialog(context);
      notifyListeners();
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
