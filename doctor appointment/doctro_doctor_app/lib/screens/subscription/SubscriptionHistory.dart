import 'package:doctro/retrofit/api_header.dart';
import 'package:doctro/retrofit/base_model.dart';
import 'package:doctro/retrofit/network_api.dart';
import 'package:doctro/constant/app_string.dart';
import 'package:doctro/constant/color_constant.dart';
import 'package:doctro/localization/localization_constant.dart';
import 'package:doctro/model/FinanceDetails.dart';
import 'package:doctro/retrofit/server_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class SubscriptionHistory extends StatefulWidget {
  const SubscriptionHistory({Key? key}) : super(key: key);

  @override
  _SubscriptionHistoryState createState() => _SubscriptionHistoryState();
}

class _SubscriptionHistoryState extends State<SubscriptionHistory> {

  //Set Loader
  Future? purchaseReq;

  //Set Height/Width Using MediaQuery
  late double width;
  late double height;

  //Add List Data
  List<PurchaseDetails> purchaseDetail = [];

  //Search Data
  TextEditingController _search = TextEditingController();
  List<PurchaseDetails> _searchResult = [];
  List<PurchaseDetails> _subscriptionHistory = [];

  @override
  void initState() {
    purchaseReq = purchaseDetailsFunction();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size(20, 200),
          child: SafeArea(
              top: true,
              child: Column(children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: width * 0.06, right: width * 0.04, top: height * 0.01),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            getTranslated(context, AppString.subscription_history_heading).toString(),
                            style: TextStyle(fontSize: width * 0.05, color: hintColor),
                          ),
                          Container(
                            margin: EdgeInsets.only(),
                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.arrow_back_ios),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: height * 0.01),
                  padding: EdgeInsets.all(10),
                  child: Card(
                    color: colorWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Container(
                        height: height * 0.06,
                        alignment: AlignmentDirectional.center,
                        margin: EdgeInsets.only(left: width * 0.05, right: width * 0.05),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              height: height * 0.07,
                              width: width * 0.7,
                              child: TextField(
                                controller: _search,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: getTranslated(context, AppString.subscription_search_history).toString(),
                                  hintStyle: TextStyle(
                                    fontSize: width * 0.045,
                                    color: hintColor.withOpacity(0.3),
                                  ),
                                ),
                                onChanged: onSearchTextChanged,
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Container(
                              child: SvgPicture.asset(
                                'assets/icons/dSearch.svg',
                                height: 20,
                              ),
                            ),
                          ],
                        )),
                  ),
                ),
                Container(
                  color: divider,
                  width: width * 1.0,
                  child: Container(
                    height: height * 0.05,
                    margin: EdgeInsets.only(left: width * 0.06, right: width * 0.06),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          getTranslated(context, AppString.subscription_history_heading).toString(),
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          "${purchaseDetail.length} " + getTranslated(context, AppString.subscription_title).toString(),
                          style: TextStyle(fontSize: width * 0.035, color: loginButton),
                        ),
                      ],
                    ),
                  ),
                ),
              ]))),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: FutureBuilder(
            future: purchaseReq,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return _search.text.isNotEmpty
                    ? _searchResult.length  > 0 ?ListView.builder(
                  shrinkWrap: true,
                  // physics: NeverScrollableScrollPhysics(),
                  itemCount: _searchResult.length,
                  itemBuilder: (context, i) {
                    return Container(
                      height: 160,
                      width: width * 0.87,
                      child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                            Container(
                              child: ListTile(
                                isThreeLine: true,
                                title: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text( getTranslated(context, AppString.subscription_plan).toString()+ ":"+ _searchResult[i].subscription!.name!, style: TextStyle(fontSize: 16.0)),
                                  ],
                                ),
                                trailing: _searchResult[i].status == 1
                                    ? Card(
                                    color:green,
                                    child: Container(
                                      width: 50,
                                      child: Text(
                                          getTranslated(context, AppString.subscription_active_button).toString(),
                                        style: TextStyle(color: colorWhite),
                                        textAlign: TextAlign.center,
                                      ),
                                    ))
                                    : Container(
                                    margin: EdgeInsets.only(top: height * 0.008),
                                    child: Card(
                                        color:red,
                                        child: Container(
                                            width: 50,
                                            child: Text(getTranslated(context, AppString.subscription_expired).toString(), style: TextStyle(color: colorWhite), textAlign: TextAlign.center)))),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    _searchResult[i].amount == null
                                        ? Container(
                                      child: Text(
                                        getTranslated(context, AppString.subscription_free).toString(),
                                        style: TextStyle(color: text),
                                      ),
                                    )
                                        : Text(
                                      getTranslated(context, AppString.subscription_payment).toString() + ":" + _searchResult[i].amount.toString(),
                                      style: TextStyle(fontSize: 14, color: hintColor),
                                    ),
                                    _searchResult[i].paymentType == null
                                        ? Container()
                                        : Text(
                                      getTranslated(context, AppString.subscription_payment_type).toString() + _searchResult[i].paymentType!,
                                      style: TextStyle(fontSize: 14, color: hintColor),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Divider(
                              color: divider,
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text( getTranslated(context, AppString.subscription_start_end).toString(), style: TextStyle(fontSize: 14, color: passwordVisibility)),
                                      Row(
                                        children: [
                                          Text(_searchResult[i].startDate!,
                                              style: TextStyle(fontSize: 14, color: hintColor)),
                                          SizedBox(width: 5),
                                          Text(_searchResult[i].endDate!,
                                              style: TextStyle(fontSize: 14, color: hintColor)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(right: width * 0.02),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(getTranslated(context, AppString.subscription_doctor_name).toString(), style: TextStyle(fontSize: 14, color: passwordVisibility)),
                                        Container(
                                          margin: EdgeInsets.only(),
                                          child: Text(_searchResult[i].doctorName!, style: TextStyle(fontSize: 14, color: hintColor)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ])),
                    );
                  },
                ) : Center(child: Container(child: Text(getTranslated(context, AppString.result_not_found).toString()),))
                    : ListView.builder(
                        shrinkWrap: false,
                        physics: AlwaysScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemCount: purchaseDetail.length,
                        itemBuilder: (context, index) {

                          String startDate = DateUtil().formattedDate(DateTime.parse(purchaseDetail[index].startDate!));
                          String endDate = DateUtil().formattedDate(DateTime.parse(purchaseDetail[index].endDate!));

                          return Container(
                            height: 160,
                            width: width * 0.87,
                            child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                                  Container(
                                    child: ListTile(
                                      isThreeLine: true,
                                      title: Text(getTranslated(context, AppString.subscription_plan).toString()+ ":" + purchaseDetail[index].subscription!.name!, style: TextStyle(fontSize: 16.0)),
                                      trailing: purchaseDetail[index].status == 1
                                          ? Card(
                                              color:green,
                                              child: Container(
                                                width: 50,
                                                child: Text(
                                                  getTranslated(context, AppString.subscription_active_button).toString(),
                                                  style: TextStyle(color: colorWhite),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ))
                                          : Container(
                                              margin: EdgeInsets.only(top: height * 0.008),
                                              child: Card(
                                                  color:red,
                                                  child: Container(
                                                      width: 50,
                                                      child: Text(getTranslated(context, AppString.subscription_expired).toString(), style: TextStyle(color: colorWhite), textAlign: TextAlign.center)))),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          purchaseDetail[index].amount == null
                                              ? Container(
                                                  child: Text(
                                      getTranslated(context, AppString.subscription_free).toString(),
                                                    style: TextStyle(color: text),
                                                  ),
                                                )
                                              : Text(
                                            getTranslated(context, AppString.subscription_payment).toString() + ":" + purchaseDetail[index].amount.toString(),
                                                  style: TextStyle(fontSize: 14, color: hintColor),
                                                ),
                                              purchaseDetail[index].paymentType == null
                                              ? Container()
                                              : Text(
                                                getTranslated(context, AppString.subscription_payment_type).toString() + ":" + purchaseDetail[index].paymentType!,
                                                  style: TextStyle(fontSize: 14, color: hintColor),
                                                ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Divider(
                                    color: divider,
                                  ),
                                  Container(
                                    margin: EdgeInsets.symmetric(horizontal: 20),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(getTranslated(context, AppString.subscription_start_end).toString(), style: TextStyle(fontSize: 14, color: passwordVisibility)),
                                            Row(
                                              children: [
                                                Text('$startDate',
                                                    style: TextStyle(fontSize: 14, color: hintColor)),
                                                SizedBox(width: 5),
                                                Text('$endDate',
                                                    style: TextStyle(fontSize: 14, color: hintColor)),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(right: width * 0.02),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(getTranslated(context, AppString.subscription_doctor_name).toString(), style: TextStyle(fontSize: 14, color: passwordVisibility)),
                                              Container(
                                                margin: EdgeInsets.only(),
                                                child:
                                                    Text(purchaseDetail[index].doctorName!, style: TextStyle(fontSize: 14, color: hintColor)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ])),
                          );
                        },
                      );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      ),
    );
  }

  Future<BaseModel<FinanceDetails>> purchaseDetailsFunction() async {

    FinanceDetails response;
    try {
      response = await RestClient(RetroApi().dioData()).purchaseDetailsRequest();
      setState(() {
        purchaseDetail.addAll(response.data!);
        _subscriptionHistory.addAll(response.data!);
      });
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    _subscriptionHistory.forEach((subscriptionHistory) {
      if (subscriptionHistory.doctorName!.toLowerCase().contains(text.toLowerCase()) || subscriptionHistory.subscription!.name!.toLowerCase().contains(text.toLowerCase()))
        _searchResult.add(subscriptionHistory);
    });

    setState(() {});
  }
}

class DateUtil {
  static const DATE_FORMAT = 'dd-MM-yyyy';

  String formattedDate(DateTime dateTime) {
    return DateFormat(DATE_FORMAT).format(dateTime);
  }
}
