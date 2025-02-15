import 'package:doctro_patient/VideoCall/videoCall.dart';
import 'package:doctro_patient/const/app_string.dart';
import 'package:doctro_patient/localization/localization_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../const/Palette.dart';

class PhoneScreen extends StatefulWidget {
  final Map<String, dynamic>? additionalData;

  PhoneScreen(this.additionalData);

  @override
  _PhoneScreenState createState() => _PhoneScreenState(additionalData);
}

class _PhoneScreenState extends State<PhoneScreen> {
  Map<String, dynamic>? additionalData;

  _PhoneScreenState(this.additionalData);

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        height: height * 1,
        width: width * 1,
        child: Stack(
          children: [
            Container(
                decoration: new BoxDecoration(
              image: new DecorationImage(
                fit: BoxFit.cover,
                colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.darken),
                image: AssetImage(
                  "assets/images/confident-doctor-half.png",
                ),
              ),
            )),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: EdgeInsets.only(top: height * 0.1),
                  child: Column(
                    children: [
                      Container(child: SvgPicture.asset("assets/icons/logo.svg", width: 90)),
                      SizedBox(height: 50),
                      Text(
                        "${additionalData!['name']}",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Palette.tabBar),
                      ),
                      Text(
                        getTranslated(context, AppString.callingYouViaVideoCall).toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, color: Palette.white),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VideoCall(
                                  doctorId: additionalData!["id"],
                                  flag: "Cut",
                                ),
                              ),
                            );

                            setState(() {});
                          });
                        },
                        child: SvgPicture.asset(
                          'assets/icons/Cut.svg',
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VideoCall(
                                      doctorId: additionalData!["id"],
                                      flag: "InComming",
                                    )),
                          );
                        },
                        child: SvgPicture.asset(
                          'assets/icons/video_call.svg',
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
    );
  }
}
