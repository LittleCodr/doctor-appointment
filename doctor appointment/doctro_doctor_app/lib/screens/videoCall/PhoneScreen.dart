import 'package:doctro/constant/app_string.dart';
import 'package:doctro/constant/color_constant.dart';
import 'package:doctro/localization/localization_constant.dart';
import 'package:doctro/screens/videoCall/video_Call.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


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
        )
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: EdgeInsets.only(top: height * 0.1),
                  child: Column(
                    children: [
                      Container(
                      child: SvgPicture.asset("assets/icons/appLogo.svg",width: 90)),
                      SizedBox(height:50),
                      Text(
                        "${additionalData!['name']}",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold,color: tabBar),
                      ),
                      Text(
                        getTranslated(context, AppString.callingYouViaVideoCall).toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20,color: colorWhite),
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
                                builder: (context) =>
                                    VideoCall(
                                      callEnd: true,
                                      id: additionalData!["id"],
                                    ),),
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
                                builder: (context) =>
                                    VideoCall(
                                      callEnd: false,
                                      id: additionalData!["id"],
                                    )),
                          );
                        },
                        child: SvgPicture.asset(
                          'assets/icons/call.svg',
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
