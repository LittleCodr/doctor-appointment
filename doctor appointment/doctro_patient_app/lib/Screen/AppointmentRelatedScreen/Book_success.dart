import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../const/Palette.dart';
import '../../const/app_string.dart';
import '../../localization/localization_constant.dart';

class BookSuccess extends StatefulWidget {
  @override
  _BookSuccessState createState() => _BookSuccessState();
}

class _BookSuccessState extends State<BookSuccess> {
  String? passBookDate = "";
  String? passBookTime = "";
  String? passBookID = "";

  @override
  void initState() {
    super.initState();
    getDateTime();
    new Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, 'Appointment');
    });
  }

  getDateTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(
      () {
        passBookDate = prefs.getString('BookDate');
        passBookTime = prefs.getString('BookTime');
        passBookID = prefs.getString('BookID');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double width;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Center(
        child: Container(
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: SingleChildScrollView(
              child: Container(
                child: Column(
                  children: [
                    Container(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/paysuccess.png',
                            height: width * 0.7,
                            width: width * 0.8,
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: width * 0.03),
                      child: Column(
                        children: [
                          Text(
                            getTranslated(context, AppString.bookSuccess_text).toString(),
                            style: TextStyle(fontSize: width * 0.053, color: Palette.blue),
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    ),
                    Container(
                      height: width * 0.12,
                      width: width * 0.27,
                      margin: EdgeInsets.only(top: width * 0.06),
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        color: Palette.blue,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              child: Text(
                                '$passBookDate',
                                style: TextStyle(fontSize: width * 0.03, color: Palette.white),
                              ),
                            ),
                            Container(
                              child: Text(
                                '$passBookTime',
                                style: TextStyle(fontSize: width * 0.028, color: Palette.white),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: width * 0.06),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            child: Text(
                              getTranslated(context, AppString.bookSuccess_bookingId).toString(),
                              style: TextStyle(fontSize: width * 0.035, color: Palette.dark_blue),
                            ),
                          ),
                          Text(
                            ' ' + '$passBookID',
                            style: TextStyle(fontSize: width * 0.035, color: Palette.blue),
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
      ),
    );
  }
}
