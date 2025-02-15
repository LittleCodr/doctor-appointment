import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'HealthTipsDetail.dart';
import '../../../api/retrofit_Api.dart';
import '../../../api/network_api.dart';
import '../../../model/health_tip_model.dart';
import '../../api/base_model.dart';
import '../../api/server_error.dart';
import '../../const/Palette.dart';
import '../../const/app_string.dart';
import '../../localization/localization_constant.dart';

class HealthTips extends StatefulWidget {
  @override
  _HealthTipsState createState() => _HealthTipsState();
}

class _HealthTipsState extends State<HealthTips> {
  bool loading = false;
  List<Data> healthTip = [];

  @override
  void initState() {
    super.initState();
    callApiHealthTip();
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
            getTranslated(context, AppString.healthTips_title).toString(),
            style: TextStyle(fontSize: 18, color: Color(0xFF003165), fontWeight: FontWeight.bold),
          ),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: healthTip.length != 0
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          ListView.builder(
                            physics: BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: healthTip.length,
                            itemBuilder: (context, index) {
                              return Container(
                                child: Column(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: width * 0.03,
                                        vertical: height * 0.002,
                                      ),
                                      width: width * 1,
                                      height: 100,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => HealthTipsDetail(
                                                id: healthTip[index].id,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Card(
                                          color: Palette.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          elevation: 5,
                                          child: Row(
                                            children: [
                                              Container(
                                                margin: EdgeInsets.symmetric(
                                                  horizontal: width * 0.015,
                                                  vertical: height * 0.015,
                                                ),
                                                child: Container(
                                                  width: width * 0.2,
                                                  height: 80,
                                                  child: CachedNetworkImage(
                                                    alignment: Alignment.center,
                                                    imageUrl: healthTip[index].fullImage!,
                                                    fit: BoxFit.cover,
                                                    placeholder: (context, url) => SpinKitFadingCircle(
                                                      color: Palette.blue,
                                                    ),
                                                    errorWidget: (context, url, error) => Image.asset(
                                                      "assets/images/no_image.jpg",
                                                      fit: BoxFit.fitHeight,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: width * 0.65,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(5),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        healthTip[index].title!,
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(fontSize: width * 0.045, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                                                      ),
                                                      Text(
                                                        healthTip[index].blogRef!,
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                          fontSize: width * 0.035,
                                                          color: Palette.dark_blue,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                )
              : Container(
                  alignment: AlignmentDirectional.center,
                  margin: EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    getTranslated(context, AppString.healthTips_noTips).toString(),
                    style: TextStyle(fontSize: width * 0.04, color: Palette.grey, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
        ),
      ),
    );
  }

  Future<BaseModel<HealthTip>> callApiHealthTip() async {
    HealthTip response;
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi2().dioData2()).healthTipRequest();
      setState(() {
        loading = false;
        if (response.success == true) {
          healthTip.addAll(response.data!);
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
}
