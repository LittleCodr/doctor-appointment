import 'package:doctro_patient/api/base_model.dart';
import 'package:doctro_patient/const/Palette.dart';
import 'package:doctro_patient/model/detail_setting_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../../api/retrofit_Api.dart';
import '../../api/network_api.dart';
import '../../api/server_error.dart';
import '../../const/app_string.dart';
import '../../localization/localization_constant.dart';

class PrivacyPolicy extends StatefulWidget {
  @override
  _PrivacyPolicyState createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  bool loading = false;

  String? privacyPolicy = "";

  @override
  void initState() {
    super.initState();
    appAllDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          getTranslated(context, AppString.privacyPolicy_title).toString(),
          style: TextStyle(fontSize: 18, color: Palette.dark_blue, fontWeight: FontWeight.bold),
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: loading,
        opacity: 0.5,
        progressIndicator: SpinKitFadingCircle(
          color: Palette.blue,
          size: 50.0,
        ),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: privacyPolicy != null
                ? Html(
                    data: '$privacyPolicy',
                  )
                : Container(
                    height: MediaQuery.of(context).size.height * 0.8,
                    alignment: AlignmentDirectional.center,
                    child: Text(
                      getTranslated(context, "noDetail").toString(),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<BaseModel<DetailSetting>> appAllDetail() async {
    DetailSetting response;

    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi2().dioData2()).settingRequest();
      if (response.success == true) {
        setState(() {
          loading = false;
          privacyPolicy = response.data!.privacyPolicy;
        });
      }
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
