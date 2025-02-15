import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctro_patient/Screen/AppointmentRelatedScreen/BookAppointment.dart';
import 'package:doctro_patient/api/retrofit_Api.dart';
import 'package:doctro_patient/api/network_api.dart';
import 'package:doctro_patient/const/prefConstatnt.dart';
import 'package:doctro_patient/const/preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Chat/chat.dart';
import '../../model/doctor_detail_model.dart';
import '../../VideoCall/videoCall.dart';
import '../../VideoCall/overlay_handler.dart';
import '../../VideoCall/overlay_service.dart';
import '../../api/base_model.dart';
import '../../api/server_error.dart';
import '../../const/Palette.dart';
import '../../const/app_string.dart';
import '../../database/form_helper.dart';
import '../../localization/localization_constant.dart';

class DoctorDetail extends StatefulWidget {
  final int? id;

  DoctorDetail({this.id});

  @override
  _DoctorDetailState createState() => _DoctorDetailState();
}

class _DoctorDetailState extends State<DoctorDetail> with TickerProviderStateMixin {
  bool loading = false;
  TabController? _tabController;
  int? id = 0;
  int? doctorId = 0;
  String? name = "";
  String? expertise = "";
  String? appointmentFees = "";
  String? experience = "";
  dynamic rate = 0.0;
  String? desc = "";
  String education = "";
  String certificate = "";
  String? fullImage = "";
  String? treatmentName = "";
  bool videoCall = false;

  String? mobileNo = "";

  List<String?> degree = [];
  List<String?> collage = [];
  List<String?> degreeYear = [];
  List<String?> award = [];
  List<String?> awardYear = [];
  List<HospitalId> hospitalDetail = [];
  HospitalId? hospitalDetailData;
  int hospitalIndex = 0;
  List<Reviews> reviews = [];
  List<HospitalGallery> hospitalGallery = [];
  String? token = "";
  String? channelName = "";
  String? _lat = "";
  String? _lang = "";

  void initState() {
    print("InitState");
    id = widget.id;
    hospitalIndex = 0;
    _getAddress();
    _tabController = TabController(vsync: this, length: 3, initialIndex: 0);

    super.initState();
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  _getAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(
      () {
        _lat = prefs.getString('lat');
        _lang = prefs.getString('lang');
        callApiDoctorDetail();
      },
    );
  }

  _addVideoOverlay(BuildContext context) {
    OverlayService().addVideosOverlay(
      context,
      VideoCall(
        doctorId: widget.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width;
    double height;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async {
        if (Provider.of<OverlayHandlerProvider>(context, listen: false).overlayActive) {
          Provider.of<OverlayHandlerProvider>(context, listen: false).enablePip(1.8);
          return false;
        }
        return true;
      },
      child: DefaultTabController(
        // Added
        length: 3, // Added
        initialIndex: 0,
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
              getTranslated(context, AppString.doctorDetail_title).toString(),
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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                            top: 20,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext bc) {
                                      return SafeArea(
                                        child: Container(
                                          child: new Wrap(
                                            children: <Widget>[
                                              new ListTile(
                                                leading: new Icon(Icons.phone_in_talk),
                                                title: new Text(
                                                  getTranslated(context, "call").toString(),
                                                ),
                                                onTap: () {
                                                  if (SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true) {
                                                    Navigator.of(context).pop();
                                                    launchUrl(Uri.parse("tel:$mobileNo"));
                                                  } else {
                                                    Navigator.of(context).pop();
                                                    FormHelper.showMessage(
                                                      context,
                                                      getTranslated(context, "call").toString(),
                                                      getTranslated(context, "call_alert").toString(),
                                                      getTranslated(context, AppString.cancel).toString(),
                                                      () {
                                                        Navigator.of(context).pop();
                                                      },
                                                      buttonText2: getTranslated(context, AppString.login).toString(),
                                                      isConfirmationDialog: true,
                                                      onPressed2: () {
                                                        Navigator.pushNamed(context, 'SignIn');
                                                      },
                                                    );
                                                  }
                                                },
                                              ),
                                              new ListTile(
                                                leading: new Icon(Icons.videocam),
                                                title: new Text(
                                                  getTranslated(context, "videoCall").toString(),
                                                ),
                                                onTap: () {
                                                  setState(
                                                    () {
                                                      if (SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true) {
                                                        Navigator.of(context).pop();
                                                        if (videoCall == true) {
                                                          _addVideoOverlay(context);
                                                        } else {
                                                          Fluttertoast.showToast(msg: "Doctor has not allowed direct video call", toastLength: Toast.LENGTH_SHORT);
                                                        }
                                                      } else {
                                                        Navigator.of(context).pop();
                                                        FormHelper.showMessage(
                                                          context,
                                                          getTranslated(context, "videoCall").toString(),
                                                          getTranslated(context, "videoCall_alert").toString(),
                                                          getTranslated(context, AppString.cancel).toString(),
                                                          () {
                                                            Navigator.of(context).pop();
                                                          },
                                                          buttonText2: getTranslated(context, AppString.login).toString(),
                                                          isConfirmationDialog: true,
                                                          onPressed2: () {
                                                            Navigator.pushNamed(context, 'SignIn');
                                                          },
                                                        );
                                                      }
                                                    },
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                  child: SvgPicture.asset(
                                    'assets/icons/call.svg',
                                  ),
                                ),
                              ),
                              Container(
                                width: width * 0.3,
                                height: width * 0.3,
                                child: CachedNetworkImage(
                                  alignment: Alignment.center,
                                  imageUrl: '$fullImage',
                                  imageBuilder: (context, imageProvider) => CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Palette.blue,
                                    child: CircleAvatar(
                                      radius: 50,
                                      backgroundImage: imageProvider,
                                    ),
                                  ),
                                  placeholder: (context, url) => SpinKitFadingCircle(color: Palette.blue),
                                  errorWidget: (context, url, error) => ClipRRect(
                                    borderRadius: BorderRadius.circular(60),
                                    child: Image.asset(
                                      "assets/images/no_image.jpg",
                                      width: width * 0.3,
                                      height: width * 0.3,
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                                      ? Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Chat(
                                              doctorId: doctorId!,
                                              where: 'DoctorDetail',
                                            ),
                                          ),
                                        )
                                      : FormHelper.showMessage(
                                          context,
                                          getTranslated(context, "doctorDetail_chat_alert_title").toString(),
                                          getTranslated(context, "doctorDetail_chat_alert_text").toString(),
                                          getTranslated(context, AppString.cancel).toString(),
                                          () {
                                            Navigator.of(context).pop();
                                          },
                                          buttonText2: getTranslated(context, AppString.login).toString(),
                                          isConfirmationDialog: true,
                                          onPressed2: () {
                                            Navigator.pushNamed(context, 'SignIn');
                                          },
                                        );
                                },
                                child: Container(
                                  child: SvgPicture.asset(
                                    'assets/icons/msg.svg',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          '$name',
                          style: TextStyle(
                            fontSize: 20,
                            color: Palette.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          '$treatmentName',
                          style: TextStyle(
                            fontSize: 16,
                            color: Palette.grey,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  getTranslated(context, AppString.doctorDetail_appointmentFees).toString(),
                                  style: TextStyle(fontSize: 14, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  SharedPreferenceHelper.getString(Preferences.currency_symbol).toString() + '$appointmentFees',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Palette.dark_blue,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  getTranslated(context, AppString.doctorDetail_doctorExperience).toString(),
                                  style: TextStyle(fontSize: 14, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '$experience  ' + getTranslated(context, AppString.doctorDetail_year).toString(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Palette.dark_blue,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              child: Column(
                                children: [
                                  Text(
                                    getTranslated(context, AppString.doctorDetail_doctorRates).toString(),
                                    style: TextStyle(fontSize: 14, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                                  ),
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/hart.svg',
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 5, right: 5),
                                        child: Text(
                                          '$rate',
                                          style: TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  // height: size.height * 0.1,
                  color: Palette.dark_white,
                  padding: EdgeInsets.all(10),
                  child: TabBar(
                    labelColor: Palette.blue,
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorColor: Palette.transparent,
                    tabs: [
                      Tab(
                        child: Text(
                          getTranslated(context, AppString.doctorDetail_tab1_title).toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Tab(
                        child: Text(
                          getTranslated(context, AppString.doctorDetail_tab2_title).toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Tab(
                        child: Text(
                          getTranslated(context, AppString.doctorDetail_tab3_title).toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    unselectedLabelColor: Palette.dark_blue,
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        ///tab 1
                        SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          physics: AlwaysScrollableScrollPhysics(),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 17),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// Personal Bio ///
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  getTranslated(context, AppString.doctorDetail_personalBio).toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Palette.dark_blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 5),
                                  child: Text(
                                    '$desc',
                                    style: TextStyle(fontSize: 12, color: Palette.grey),
                                    textAlign: TextAlign.justify,
                                    maxLines: 4,
                                  ),
                                ),

                                /// Education ///
                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  getTranslated(context, AppString.doctorDetail_education).toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Palette.dark_blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: degree.length,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 5),
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Container(
                                            alignment: AlignmentDirectional.topStart,
                                            child: Text(
                                              degree[index]!.toUpperCase(),
                                              style: TextStyle(fontSize: 12, color: Palette.dark_blue),
                                            ),
                                          ),
                                          Container(
                                            alignment: AlignmentDirectional.topStart,
                                            child: Text(
                                              collage[index]! + '.',
                                              style: TextStyle(fontSize: 12, color: Palette.grey),
                                            ),
                                          ),
                                          Container(
                                            alignment: AlignmentDirectional.topStart,
                                            child: Text(
                                              degreeYear[index]!,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Palette.grey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),

                                /// Certificate ///
                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  getTranslated(context, AppString.doctorDetail_certificate).toString(),
                                  style: TextStyle(fontSize: 16, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                                ),
                                ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: award.length,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 5),
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                award[index]!,
                                                style: TextStyle(fontSize: 12, color: Palette.dark_blue),
                                              ),
                                              Text(
                                                '.  ' + awardYear[index]!,
                                                style: TextStyle(fontSize: 12, color: Palette.grey),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),

                                /// Specialization ///
                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  getTranslated(context, AppString.doctorDetail_specialization).toString(),
                                  style: TextStyle(fontSize: 16, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 5),
                                  child: Text(
                                    '$expertise',
                                    style: TextStyle(fontSize: 12, color: Palette.grey),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        ///tab 2
                        ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          physics: BouncingScrollPhysics(),
                          itemCount: 1,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 17),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// Hospital Name ///
                                  Row(
                                    children: [
                                      Container(
                                        width: width * 0.35,
                                        child: Text(
                                          getTranslated(context, AppString.doctorDetail_hospitalName).toString(),
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Palette.dark_blue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: width * 0.5,
                                        child: DropdownButtonFormField(
                                          hint: Text(
                                            hospitalDetail[hospitalIndex].hospitalDetails!.name!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Palette.dark_blue,
                                            ),
                                          ),
                                          value: hospitalDetailData,
                                          isExpanded: true,
                                          iconSize: 25,
                                          onSaved: (dynamic value) {
                                            setState(() {
                                              hospitalDetailData = value;
                                              print("$hospitalDetailData");
                                            });
                                          },
                                          onChanged: (HospitalId? newValue) {
                                            setState(
                                              () {
                                                print("${hospitalDetail.indexOf(newValue!)}");
                                                hospitalIndex = hospitalDetail.indexOf(newValue);
                                                setState(() {});
                                              },
                                            );
                                          },
                                          validator: (dynamic value) => value == null ? getTranslated(context, AppString.bookAppointment_patientAddress_validator1).toString() : null,
                                          items: hospitalDetail.map((location) {
                                            return DropdownMenuItem<HospitalId>(
                                              child: new Text(
                                                location.hospitalDetails!.name!,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Palette.dark_blue,
                                                ),
                                              ),
                                              value: location,
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(
                                    height: 15,
                                  ),

                                  /// Phone No. ///
                                  Row(
                                    children: [
                                      Container(
                                        width: width * 0.35,
                                        child: Text(
                                          getTranslated(context, AppString.doctorDetail_phoneNumber).toString(),
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Palette.dark_blue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        child: Text(
                                          SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true ? hospitalDetail[hospitalIndex].hospitalDetails!.phone! : "Login to see",
                                          // "9876543210",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Palette.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(
                                    height: 15,
                                  ),

                                  /// Address ///
                                  Row(
                                    children: [
                                      Container(
                                        width: width * 0.35,
                                        child: Text(
                                          getTranslated(context, AppString.doctorDetail_address).toString(),
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Palette.dark_blue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                        ),
                                      ),
                                      Container(
                                        width: width * 0.55,
                                        child: Text(
                                          hospitalDetail[hospitalIndex].hospitalDetails!.address!,
                                          // "Rajkot",
                                          style: TextStyle(fontSize: 12, color: Palette.grey),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(
                                    height: 15,
                                  ),

                                  /// Facility ///
                                  Row(
                                    children: [
                                      Container(
                                        width: width * 0.35,
                                        child: Text(
                                          getTranslated(context, AppString.doctorDetail_facility).toString(),
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Palette.dark_blue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: width / 3,
                                        child: Text(
                                          hospitalDetail[hospitalIndex].hospitalDetails!.facility!,
                                          // "2 Bed",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Palette.grey,
                                          ),
                                          maxLines: 4,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(
                                    height: 15,
                                  ),

                                  /// Hospital Gallery Image ///
                                  hospitalDetail[hospitalIndex].hospitalGallery!.length != 0
                                      ? Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              getTranslated(context, AppString.doctorDetail_image).toString(),
                                              style: TextStyle(fontSize: 16, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Container(
                                              width: width,
                                              child: GridView.builder(
                                                physics: NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                scrollDirection: Axis.vertical,
                                                itemCount: hospitalDetail[hospitalIndex].hospitalGallery!.length,
                                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 3,
                                                ),
                                                itemBuilder: (context, imageIndex) {
                                                  return Card(
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      child: Container(
                                                        height: 100,
                                                        width: 100,
                                                        margin: EdgeInsets.all(5),
                                                        child:
                                                            // FullScreenWidget(
                                                            ClipRRect(
                                                          borderRadius: BorderRadius.circular(10),
                                                          child: CachedNetworkImage(
                                                            alignment: Alignment.center,
                                                            imageUrl: hospitalDetail[hospitalIndex].hospitalGallery![imageIndex].fullImage!,
                                                            placeholder: (context, url) => SpinKitFadingCircle(color: Palette.blue),
                                                            errorWidget: (context, url, error) => Image.asset("assets/images/NoImage.png"),
                                                            height: height * 0.2,
                                                            width: width * 0.3,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      )
                                                      // ),
                                                      );
                                                },
                                              ),
                                            ),
                                          ],
                                        )
                                      : SizedBox(),
                                ],
                              ),
                            );
                          },
                        ),

                        ///tab 3
                        reviews.length != 0
                            ? SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                physics: AlwaysScrollableScrollPhysics(),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 17),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        child: Text(
                                          getTranslated(context, AppString.doctorDetail_review).toString(),
                                          style: TextStyle(
                                            fontSize: width * 0.04,
                                            color: Palette.dark_blue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      reviews.length != 0
                                          ? ListView.builder(
                                              physics: NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              scrollDirection: Axis.vertical,
                                              itemCount: reviews.length,
                                              itemBuilder: (context, index) {
                                                String date = DateUtil().formattedDate(DateTime.parse(reviews[index].createdAt!));
                                                return Container(
                                                  width: width,
                                                  // height: height * 0.1,
                                                  child: Column(
                                                    children: <Widget>[
                                                      ListTile(
                                                        isThreeLine: true,
                                                        leading: SizedBox(
                                                          child: Container(
                                                            height: height * 0.062,
                                                            width: width * 0.125,
                                                            decoration: new BoxDecoration(
                                                              shape: BoxShape.circle,
                                                              boxShadow: [
                                                                new BoxShadow(
                                                                  color: Palette.blue,
                                                                  blurRadius: 1.0,
                                                                ),
                                                              ],
                                                            ),
                                                            child: CachedNetworkImage(
                                                              alignment: Alignment.center,
                                                              imageUrl: reviews[index].user!.fullImage!,
                                                              imageBuilder: (context, imageProvider) => CircleAvatar(
                                                                radius: 50,
                                                                backgroundColor: Palette.white,
                                                                child: CircleAvatar(
                                                                  radius: 20,
                                                                  backgroundImage: imageProvider,
                                                                ),
                                                              ),
                                                              placeholder: (context, url) => SpinKitFadingCircle(color: Palette.dark_blue),
                                                              errorWidget: (context, url, error) => ClipRRect(
                                                                borderRadius: BorderRadius.circular(50),
                                                                child: Image.asset(
                                                                  "assets/images/no_image.jpg",
                                                                  fit: BoxFit.fitHeight,
                                                                  width: 60,
                                                                  height: 60,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        title: Column(
                                                          children: [
                                                            Container(
                                                              alignment: AlignmentDirectional.topStart,
                                                              margin: EdgeInsets.only(
                                                                top: height * 0.01,
                                                              ),
                                                              child: Text(
                                                                reviews[index].user!.name!,
                                                                style: TextStyle(fontSize: width * 0.03, fontWeight: FontWeight.bold),
                                                              ),
                                                            ),
                                                            Container(
                                                              alignment: AlignmentDirectional.topStart,
                                                              child: Text(
                                                                '$date',
                                                                style: TextStyle(fontSize: 11, color: Palette.grey),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        trailing: Container(
                                                          child: RatingBarIndicator(
                                                            rating: reviews[index].rate!.toDouble(),
                                                            itemBuilder: (context, index) => Icon(
                                                              Icons.star,
                                                              color: Palette.blue,
                                                            ),
                                                            itemCount: 5,
                                                            itemSize: width * 0.04,
                                                            direction: Axis.horizontal,
                                                          ),
                                                        ),
                                                        subtitle: Container(
                                                          margin: EdgeInsets.only(top: width * 0.015),
                                                          alignment: AlignmentDirectional.topStart,
                                                          child: Text(
                                                            reviews[index].review!,
                                                            style: TextStyle(fontSize: 12, color: Palette.grey),
                                                            overflow: TextOverflow.ellipsis,
                                                            maxLines: 2,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            )
                                          : SizedBox(),
                                    ],
                                  ),
                                ),
                              )
                            : Container(
                                alignment: AlignmentDirectional.center,
                                child: Text(
                                  getTranslated(context, AppString.doctorDetail_noReview).toString(),
                                  style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            height: width * 0.12,
            child: ElevatedButton(
              child: Text(
                getTranslated(context, AppString.doctorDetail_bookAppointment).toString(),
                style: TextStyle(fontSize: width * 0.04, color: Palette.white),
                textAlign: TextAlign.center,
              ),
              onPressed: () {
                SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                    ? Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookAppointment(id: id),
                        ),
                      )
                    : FormHelper.showMessage(
                        context,
                        getTranslated(context, AppString.doctorDetail_appointmentBook_alert_title).toString(),
                        getTranslated(context, AppString.doctorDetail_appointmentBook_alert_text).toString(),
                        getTranslated(context, AppString.cancel).toString(),
                        () {
                          Navigator.of(context).pop();
                        },
                        buttonText2: getTranslated(context, AppString.login).toString(),
                        isConfirmationDialog: true,
                        onPressed2: () {
                          Navigator.pushNamed(context, 'SignIn');
                        },
                      );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<BaseModel<DoctorDetailModel>> callApiDoctorDetail() async {
    DoctorDetailModel response;
    Map<String, dynamic> body = {
      "lat": _lat,
      "lang": _lang,
    };
    setState(() {
      loading = true;
    });
    print(body);
    try {
      response = await RestClient(RetroApi2().dioData2()).doctorDetailRequest(id, body);
      if (response.success == true) {
        setState(
          () {
            loading = false;
            id = response.data!.id;
            doctorId = response.data!.userId;
            name = response.data!.name;
            rate = response.data!.rate!.toDouble();
            experience = response.data!.experience;
            appointmentFees = response.data!.appointmentFees;
            desc = response.data!.desc;
            expertise = response.data!.expertise!.name;
            fullImage = response.data!.fullImage;
            treatmentName = response.data!.treatment!.name;
            reviews.addAll(response.data!.reviews!);
            videoCall = response.data!.patientVideoCall == 0 ? false : true;
            hospitalDetail.addAll(response.data!.hospitalId!);
            var convertDegree = json.decode(response.data!.education!);
            degree.clear();
            collage.clear();
            degreeYear.clear();
            for (int i = 0; i < convertDegree.length; i++) {
              degree.add(convertDegree[i]['degree']);
              collage.add(convertDegree[i]['college']);
              degreeYear.add(convertDegree[i]['year']);
            }
            var convertCertificate = json.decode(response.data!.certificate!);
            award.clear();
            awardYear.clear();
            for (int i = 0; i < convertCertificate.length; i++) {
              award.add(convertCertificate[i]['certificate']);
              awardYear.add(convertCertificate[i]['certificate_year']);
            }
          },
        );
      }
    } catch (error, stacktrace) {
      setState(() {
        loading = false;
      });
      print("Exception occur: $error stackTra_column = 23ce: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
