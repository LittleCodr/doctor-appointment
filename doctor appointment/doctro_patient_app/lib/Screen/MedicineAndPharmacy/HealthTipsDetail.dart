import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctro_patient/api/network_api.dart';
import 'package:doctro_patient/api/retrofit_Api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../../api/base_model.dart';
import '../../api/server_error.dart';
import '../../const/Palette.dart';
import '../../const/app_string.dart';
import '../../localization/localization_constant.dart';
import '../../model/health_tip_detail_model.dart';

class HealthTipsDetail extends StatefulWidget {
  final int? id;

  HealthTipsDetail({this.id});

  @override
  _HealthTipsDetailState createState() => _HealthTipsDetailState();
}

class _HealthTipsDetailState extends State<HealthTipsDetail> {
  bool loading = false;
  int? id = 0;
  String? title = "";
  String? desc = "";
  String? blogRef = "";
  String? fullImage = "";

  @override
  void initState() {
    super.initState();
    id = widget.id;
    callApiHealthTipDetail();
  }

  @override
  Widget build(BuildContext context) {
    double width;
    double height;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return ModalProgressHUD(
      inAsyncCall: loading,
      opacity: 0.5,
      progressIndicator: SpinKitFadingCircle(
        color: Palette.blue,
        size: 50.0,
      ),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              size: 20,
              color: Palette.dark_blue,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          centerTitle: true,
          backgroundColor: Palette.white,
          title: Text(
            getTranslated(context, AppString.healthTipsDetail_title).toString(),
            style: TextStyle(fontSize: 18, color: Palette.dark_blue, fontWeight: FontWeight.bold),
          ),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: width,
                  color: Palette.white,
                  margin: EdgeInsets.symmetric(vertical: height * 0.015),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      getTranslated(context, AppString.healthTipsDetail_subtitle).toString(),
                      style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Container(
                        width: width * 1,
                        height: width * 0.5,
                        child: CachedNetworkImage(
                          alignment: Alignment.center,
                          imageUrl: '$fullImage',
                          fit: BoxFit.cover,
                          placeholder: (context, url) => SpinKitFadingCircle(
                            color: Palette.blue,
                          ),
                          errorWidget: (context, url, error) => Image.asset(
                            "assets/images/white_img.jpg",
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.symmetric(horizontal: width * 0.05),
                  child: Column(
                    children: [
                      Text(
                        '$title',
                        style: TextStyle(fontSize: height * 0.022, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: width * 0.01),
                  child: Column(
                    children: [
                      Text(
                        '$blogRef',
                        style: TextStyle(fontSize: height * 0.017, color: Palette.grey),
                      )
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.all(
                    width * 0.05,
                  ),
                  child: Column(
                    children: [
                      Html(data: "$desc"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<BaseModel<HealthTipDetails>> callApiHealthTipDetail() async {
    HealthTipDetails response;
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi2().dioData2()).healthTipDetailRequest(id);
      setState(() {
        setState(() {
          loading = false;
          if (response.success == true) {
            title = response.data!.title;
            desc = response.data!.desc;
            blogRef = response.data!.blogRef;
            fullImage = response.data!.fullImage;
          }
        });
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
}
