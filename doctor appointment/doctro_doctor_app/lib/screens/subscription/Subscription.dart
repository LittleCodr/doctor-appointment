import 'dart:convert';
import 'package:doctro/constant/app_string.dart';
import 'package:doctro/constant/color_constant.dart';
import 'package:doctro/constant/prefConstatnt.dart';
import 'package:doctro/constant/preferences.dart';
import 'package:doctro/localization/localization_constant.dart';
import 'package:doctro/retrofit/api_header.dart';
import 'package:doctro/retrofit/base_model.dart';
import 'package:doctro/retrofit/server_error.dart';
import 'package:doctro/screens/paymentScreen/PaymentGateway.dart';
import 'package:doctro/retrofit/network_api.dart';
import 'package:doctro/model/Subscription.dart';
import 'package:flutter/material.dart';

class SubSubscription extends StatefulWidget {
  @override
  _SubSubscriptionState createState() => _SubSubscriptionState();
}

class _SubSubscriptionState extends State<SubSubscription> {

  //Set Height/Width Using MediaQuery
  late double width;
  late double height;

  //Set Custom Size
  double customContainerSize = 123;
  double customListViewSize = 50;

  late bool customContainerSizeBool;

  //Set Loader
  Future? subscriptions;
  bool incrementBool = true;

  //Set RadioButton
  List<bool> radioSelectionBool = [];
  int? value;

  @override
  void initState() {
    subscriptions = subscribe();
    value = 0;
    super.initState();
  }
  setSelectedRadio(int val) {
    setState(() {
      value = val;
    });
  }

  List<Data> subscribeReq = [];

  List<PaymentData> pD = <PaymentData>[];

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(width * 0.05, height * 0.05),
          child: SafeArea(
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    alignment: AlignmentDirectional.topStart,
                    margin: EdgeInsets.only(top: height * 0.025, left: width * 0.05,right: width * 0.05),
                    child: GestureDetector(
                      child: Icon(Icons.arrow_back_ios),
                      onTap: () {
                        Navigator.pushReplacementNamed(context, 'loginHome');
                      },
                    )),
                Container(
                  margin: EdgeInsets.only(
                    left: width * 0.15,
                    top: height * 0.02,
                  ),
                  child: Text(
                    getTranslated(context, AppString.choose_your_best_plan).toString(),
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: hintColor),
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
          ),
        ),
        body: FutureBuilder(
            future: subscriptions,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return SingleChildScrollView(
                  child: Center(
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                itemCount: subscribeReq.length,
                                itemBuilder: (context, index) {
                                  List parseData = json.decode(subscribeReq[index].plan!);
                                  if( incrementBool == true){
                                  if(1 >= parseData.length ) {
                                    for (int i = 0; i < parseData.length; i++) {
                                     customContainerSize += height * 0.05;
                                     customListViewSize += height * 0.04;
                                    }
                                  }
                                  incrementBool = false;
                                  }

                                  1 >= parseData.length? customContainerSizeBool = false:customContainerSizeBool = true;
                                  for (int i = 0; i < parseData.length; i++) {
                                    if(i==0){
                                      radioSelectionBool.add(true);
                                    }else{
                                      radioSelectionBool.add(false);
                                    }
                                  }
                                  return Container(
                                    margin: EdgeInsets.only(top: width * 0.06),
                                    height: customContainerSizeBool ? customContainerSize: height * 0.15,
                                    width: width * 0.95,
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15.0),
                                      ),
                                      color: cardBorder,
                                      child: Container(
                                        margin: EdgeInsets.only(
                                          top: width * 0.04,
                                        ),
                                        alignment: AlignmentDirectional.topStart,
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: width * 0.25,
                                                  height: width * 0.15,
                                                  child: Card(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(15.0),
                                                    ),
                                                    color: card,
                                                    child: Container(
                                                      alignment: AlignmentDirectional.center,
                                                      child: Text(
                                                        subscribeReq[index].name!,
                                                        style: TextStyle(
                                                            fontSize: width * 0.035,
                                                            color: colorWhite,
                                                            fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Column(
                                                  children: [
                                                    Text(
                                                      subscribeReq[index]
                                                              .totalAppointment
                                                              .toString() + getTranslated(context, AppString.total_booking).toString(),
                                                      style: TextStyle(
                                                          fontSize: width * 0.04,
                                                          color: cardText),
                                                      textAlign: TextAlign.start,
                                                    ),
                                                    SizedBox(
                                                      height: 4,
                                                    ),
                                                    1 >= parseData.length
                                                        ?  Row(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              parseData[0]['month']  != null ?
                                                              Row(
                                                                children: [
                                                                        SharedPreferenceHelper.getString(
                                                                                    Preferences.currency_symbol) !=
                                                                                "N_A"
                                                                            ? Text(
                                                                                "${SharedPreferenceHelper.getString(Preferences.currency_symbol)} ${parseData[0]['price']} /",
                                                                                style: TextStyle(
                                                                      fontWeight: FontWeight.bold,
                                                                      fontSize: 14,
                                                                      color: colorBlack),) :  Text("${parseData[0]['price']} /", style: TextStyle(
                                                                      fontWeight: FontWeight.bold,
                                                                      fontSize: 14,
                                                                      color: colorBlack),),
                                                                  Text(
                                                                    '${parseData[0]['month']} MONTH  ',
                                                                    style: TextStyle(
                                                                        fontWeight: FontWeight.bold,
                                                                        fontSize: 12,
                                                                        color: colorBlack),
                                                                    textAlign: TextAlign.start,
                                                                  ),
                                                                ],
                                                              )
                                                                  :
                                                              Column(
                                                                children: [
                                                                  Text(
                                                                    getTranslated(context, AppString.free_validity).toString(),
                                                                    style: TextStyle(
                                                                        fontWeight: FontWeight.bold,
                                                                        fontSize: 14,
                                                                        color: cardText),
                                                                    textAlign: TextAlign.start,
                                                                  ),
                                                                  Text(
                                                                    getTranslated(context, AppString.edit_or_delete).toString(),
                                                                    style: TextStyle(
                                                                        fontSize: 12,
                                                                        color: cardText),
                                                                    textAlign: TextAlign.start,
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          )
                                                        : Container(
                                                            height: customListViewSize,
                                                            width: width * 0.5,
                                                            child: ListView.builder(
                                                              physics: NeverScrollableScrollPhysics(),
                                                              itemCount: parseData.length,
                                                              itemBuilder: (context, index) =>
                                                                  Container(
                                                                    height: 40,
                                                                    child: RadioListTile(
                                                                      value: index,
                                                                      groupValue: value,
                                                                      onChanged: (dynamic ind) => setState(() => value = ind),
                                                                      title: Row(
                                                                        children: [
                                                                        SharedPreferenceHelper.getString(
                                                                                    Preferences.currency_symbol) !=
                                                                                "N_A"
                                                                            ? Text(
                                                                                "${SharedPreferenceHelper.getString(Preferences.currency_symbol)} ${parseData[index]['price']} /",
                                                                                style: TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 14,
                                                                              color: colorBlack),) :  Text("${parseData[index]['price']} /", style: TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 14,
                                                                              color: colorBlack),),
                                                                          Text('${parseData[index]['month']} MONTH', style: TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 12,
                                                                              color: colorBlack),),
                                                                        ],
                                                                      ),
                                                                    )
                                                                  ),
                                                            ),
                                                          ),
                                                  ],
                                                ),
                                               Container(
                                                  margin: EdgeInsets.only(
                                                      left: width * 0.02, right: width * 0.02),
                                                  child: OutlinedButton(
                                                    onPressed: (){
                                                   subscribeReq[index].name == 'free' ? Container() :   Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) => PaymentGatewayScreen(
                                                                  plan:subscribeReq[index].plan,value:value,id:subscribeReq[index].id,name: subscribeReq[index].name)));
                                                    },
                                                    child: Container(
                                                      padding: EdgeInsets.all(5),
                                                      child: Text(
                                                        getTranslated(context, AppString.subscription_buy).toString(),
                                                        style: TextStyle(
                                                          fontSize: width * 0.035,
                                                          color: card,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            }));
  }

  Future<BaseModel<SubscriptionPlan>> subscribe() async {

    SubscriptionPlan response;
    try {
      response = await RestClient(RetroApi().dioData()).subscriptionRequest();
      setState(() {
        subscribeReq.addAll(response.data!);
      });
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}

class PaymentData {
  int? id;
  String? name;
  String? plan;
  int? totalAppointment;

  PaymentData({this.id, this.name, this.plan, this.totalAppointment});

  PaymentData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    plan = json['plan'];
    totalAppointment = json['total_appointment'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['plan'] = this.plan;
    data['total_appointment'] = this.totalAppointment;
    return data;
  }
}