import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:doctro_patient/VideoCall/videoCall.dart';
import 'package:doctro_patient/api/retrofit_Api.dart';
import 'package:doctro_patient/api/network_api.dart';
import 'package:doctro_patient/const/prefConstatnt.dart';
import 'package:doctro_patient/const/preference.dart';
import 'package:doctro_patient/model/banner_model.dart';
import 'package:doctro_patient/model/treatments_model.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../VideoCall/PhoneScreen.dart';
import '../Doctor/TreatmentSpecialist.dart';
import '../../../database/form_helper.dart';
import '../Doctor/doctorDetail.dart';
import '../../../model/appointments_model.dart';
import '../../../model/display_offer_model.dart';
import '../../FirebaseProviders/auth_provider.dart';
import '../../FirebaseProviders/home_provider.dart';
import '../../api/base_model.dart';
import '../../api/server_error.dart';
import '../../const/Palette.dart';
import '../../const/app_string.dart';
import '../../localization/localization_constant.dart';
import '../../model/detail_setting_model.dart';
import '../../model/favorite_doctor_model.dart';
import '../../model/user_detail_model.dart';
import '../../model/doctors_model.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? _address = "";
  String? _lat = "";
  String? _lang = "";

  String? name = "";
  String? email = "";
  String? phoneNo = "";
  String? image = "";

  String userPhoneNo = "";
  String userEmail = "";
  String userName = "";

  bool loading = false;
  AuthProvider? authProvider;

  List<DoctorModel> doctorList = [];
  List<TreatmentData> treatmentList = [];

  List<Add> banner = [];

  int treatmentId = 0;

  List<bool> favoriteDoctor = [];
  int? doctorID = 0;

  List<OfferModel> offerList = [];

  List<UpcomingAppointment> upcomingAppointment = [];

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  int current = 0;
  List<String?> imgList = [];

  // Search //
  TextEditingController _search = TextEditingController();
  List<DoctorModel> _searchResult = [];

  late LocationData _locationData;
  Location location = new Location();

  late HomeProvider homeProvider;

  @override
  void initState() {
    super.initState();
    getLocation();
    callApiSetting();
    getLiveLocation();
    homeProvider = context.read<HomeProvider>();
    if (SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true) {
      callApiForUserDetail();
      Future.delayed(
        const Duration(seconds: 5),
        () {
          print("UID ${FirebaseAuth.instance.currentUser!.uid}");
          homeProvider.updateDataFirestore(FirestoreConstants.pathUserCollection, FirebaseAuth.instance.currentUser!.uid, {'pushToken': SharedPreferenceHelper.getString(Preferences.notificationRegisterKey)!});
          print("Message TOKEN ${SharedPreferenceHelper.getString(Preferences.notificationRegisterKey)}");
        },
      );
    }
    if (SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true) {
      callApiAppointment();
      Timer.periodic(Duration(minutes: 10), (Timer t) => callApiAppointment());
    }
    if (SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true) {
      getOneSingleToken();
    }
    callApiBanner();
  }

  Future<void> getLocation() async {
    await Permission.location.request();
    await Permission.storage.request();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? checkLat = prefs.getString('lat');
    if (checkLat != "" && checkLat != null) {
      _getAddress();
    } else {
      _locationData = await location.getLocation();
      setState(
        () {
          prefs.setString('lat', _locationData.latitude.toString());
          prefs.setString('lang', _locationData.longitude.toString());
          print("${_locationData.latitude.toString()}  ${_locationData.longitude.toString()}");
        },
      );
      _getAddress();
    }
  }

  getLiveLocation() async {
    _locationData = await location.getLocation();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('latLive', _locationData.latitude.toString());
    prefs.setString('langLive', _locationData.longitude.toString());
    print("Live Location Lat & Long ==   ${_locationData.latitude.toString()}  ${_locationData.longitude.toString()}");
  }

  _getAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(
      () {
        _address = prefs.getString('Address');
        _lat = prefs.getString('lat');
        _lang = prefs.getString('lang');
        callApiDoctorList();
        callApiTreatment();
        callApIDisplayOffer();
      },
    );
  }

  _passDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userPhoneNo = '$phoneNo';
      userEmail = '$email';
      userName = '$name';
    });
    prefs.setString('phone_no', userPhoneNo);
    prefs.setString('email', userEmail);
    prefs.setString('name', userName);
  }

  _passIsWhere() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('isWhere', "Home");
  }

  DateTime? currentBackPressTime;

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null || now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(
        msg: getTranslated(context, AppString.exit_app).toString(),
      );
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    authProvider = Provider.of<AuthProvider>(context);
    double width;
    double height;

    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: onWillPop,
      child: ModalProgressHUD(
        inAsyncCall: loading,
        opacity: 0.5,
        progressIndicator: SpinKitFadingCircle(
          color: Palette.blue,
          size: 50.0,
        ),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Scaffold(
            key: _scaffoldKey,

            /// Drawer ///
            drawer: Drawer(
              child: Column(
                children: [
                  SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                      ? DrawerHeader(
                          margin: EdgeInsets.zero,
                          child: Container(
                            width: width * 0.8,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 60,
                                  height: 80,
                                  alignment: AlignmentDirectional.center,
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
                                    imageUrl: image!,
                                    imageBuilder: (context, imageProvider) => CircleAvatar(
                                      radius: 50,
                                      backgroundColor: Palette.white,
                                      child: CircleAvatar(
                                        radius: 30,
                                        backgroundImage: imageProvider,
                                      ),
                                    ),
                                    placeholder: (context, url) => SpinKitFadingCircle(color: Palette.blue),
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
                                Container(
                                  width: width * 0.4,
                                  height: height * 0.11,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '$name',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Palette.dark_blue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '$email',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Palette.grey,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '$phoneNo',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Palette.grey,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context, 'Profile');
                                    },
                                    child: SvgPicture.asset(
                                      'assets/icons/edit.svg',
                                      height: 20,
                                      width: 20,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      : DrawerHeader(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, 'SignIn');
                                },
                                child: Container(
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(width * 0.06),
                                    ),
                                    color: Palette.white,
                                    shadowColor: Palette.grey,
                                    elevation: 5,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                      child: Text(
                                        getTranslated(context, AppString.home_signIn_button).toString(),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Palette.dark_blue,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, 'SignUp');
                                },
                                child: Container(
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(width * 0.06),
                                    ),
                                    color: Palette.white,
                                    shadowColor: Palette.grey,
                                    elevation: 5,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                      child: Text(
                                        getTranslated(context, AppString.home_signUp_button).toString(),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Palette.dark_blue,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ListTile(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pushReplacementNamed(context, 'Specialist');
                            },
                            title: Text(
                              getTranslated(context, AppString.home_book_appointment).toString(),
                              style: TextStyle(
                                fontSize: 16,
                                color: Palette.dark_blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                            child: Column(
                              children: [
                                DottedLine(
                                  direction: Axis.horizontal,
                                  lineLength: double.infinity,
                                  lineThickness: 1.0,
                                  dashLength: 3.0,
                                  dashColor: Palette.dash_line,
                                  dashRadius: 0.0,
                                  dashGapLength: 1.0,
                                  dashGapColor: Palette.transparent,
                                  dashGapRadius: 0.0,
                                )
                              ],
                            ),
                          ),
                          ListTile(
                            onTap: () {
                              SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                                  ? Navigator.popAndPushNamed(context, 'Appointment')
                                  : FormHelper.showMessage(
                                      context,
                                      getTranslated(context, AppString.home_medicineOrder_alert_title).toString(),
                                      getTranslated(context, AppString.home_medicineOrder_alert_text).toString(),
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
                            title: Text(
                              getTranslated(context, AppString.home_appointments).toString(),
                              style: TextStyle(
                                fontSize: 16,
                                color: Palette.dark_blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                            child: Column(
                              children: [
                                DottedLine(
                                  direction: Axis.horizontal,
                                  lineLength: double.infinity,
                                  lineThickness: 1.0,
                                  dashLength: 3.0,
                                  dashColor: Palette.dash_line,
                                  dashRadius: 0.0,
                                  dashGapLength: 1.0,
                                  dashGapColor: Palette.transparent,
                                  dashGapRadius: 0.0,
                                )
                              ],
                            ),
                          ),
                          ListTile(
                            onTap: () {
                              SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                                  ? Navigator.popAndPushNamed(context, 'FavoriteDoctorScreen')
                                  : FormHelper.showMessage(
                                      context,
                                      getTranslated(context, AppString.home_favoriteDoctor_alert_title).toString(),
                                      getTranslated(context, AppString.home_favoriteDoctor_alert_text).toString(),
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
                            title: Text(
                              getTranslated(context, AppString.home_favoritesDoctor).toString(),
                              style: TextStyle(
                                fontSize: 16,
                                color: Palette.dark_blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                            child: Column(
                              children: [
                                DottedLine(
                                  direction: Axis.horizontal,
                                  lineLength: double.infinity,
                                  lineThickness: 1.0,
                                  dashLength: 3.0,
                                  dashColor: Palette.dash_line,
                                  dashRadius: 0.0,
                                  dashGapLength: 1.0,
                                  dashGapColor: Palette.transparent,
                                  dashGapRadius: 0.0,
                                )
                              ],
                            ),
                          ),
                          ListTile(
                            onTap: () {
                              SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                                  ? Navigator.popAndPushNamed(context, 'VideoCallHistory')
                                  : FormHelper.showMessage(
                                      context,
                                      getTranslated(context, AppString.home_favoriteDoctor_alert_title).toString(),
                                      getTranslated(context, AppString.home_favoriteDoctor_alert_text).toString(),
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
                            title: Text(
                              getTranslated(context, AppString.call_history).toString(),
                              style: TextStyle(
                                fontSize: 16,
                                color: Palette.dark_blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                            child: Column(
                              children: [
                                DottedLine(
                                  direction: Axis.horizontal,
                                  lineLength: double.infinity,
                                  lineThickness: 1.0,
                                  dashLength: 3.0,
                                  dashColor: Palette.dash_line,
                                  dashRadius: 0.0,
                                  dashGapLength: 1.0,
                                  dashGapColor: Palette.transparent,
                                  dashGapRadius: 0.0,
                                )
                              ],
                            ),
                          ),
                          ListTile(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pushReplacementNamed(context, 'AllPharamacy');
                            },
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  getTranslated(context, AppString.home_medicineBuy).toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Palette.dark_blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pushNamed(context, 'AddToCart');
                                  },
                                  icon: Icon(
                                    Icons.shopping_cart_outlined,
                                    color: Palette.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                            child: Column(
                              children: [
                                DottedLine(
                                  direction: Axis.horizontal,
                                  lineLength: double.infinity,
                                  lineThickness: 1.0,
                                  dashLength: 3.0,
                                  dashColor: Palette.dash_line,
                                  dashRadius: 0.0,
                                  dashGapLength: 1.0,
                                  dashGapColor: Palette.transparent,
                                  dashGapRadius: 0.0,
                                )
                              ],
                            ),
                          ),
                          ListTile(
                            onTap: () {
                              SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                                  ? Navigator.popAndPushNamed(context, 'MedicineOrder')
                                  : FormHelper.showMessage(
                                      context,
                                      getTranslated(context, AppString.home_medicineBuy_alert_title).toString(),
                                      getTranslated(context, AppString.home_medicineBuy_alert_text).toString(),
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
                            title: Text(
                              getTranslated(context, AppString.home_orderHistory).toString(),
                              style: TextStyle(
                                fontSize: 16,
                                color: Palette.dark_blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                            child: Column(
                              children: [
                                DottedLine(
                                  direction: Axis.horizontal,
                                  lineLength: double.infinity,
                                  lineThickness: 1.0,
                                  dashLength: 3.0,
                                  dashColor: Palette.dash_line,
                                  dashRadius: 0.0,
                                  dashGapLength: 1.0,
                                  dashGapColor: Palette.transparent,
                                  dashGapRadius: 0.0,
                                )
                              ],
                            ),
                          ),
                          ListTile(
                            onTap: () {
                              Navigator.popAndPushNamed(context, 'HealthTips');
                            },
                            title: Text(
                              getTranslated(context, AppString.home_healthTips).toString(),
                              style: TextStyle(
                                fontSize: 16,
                                color: Palette.dark_blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                            child: Column(
                              children: [
                                DottedLine(
                                  direction: Axis.horizontal,
                                  lineLength: double.infinity,
                                  lineThickness: 1.0,
                                  dashLength: 3.0,
                                  dashColor: Palette.dash_line,
                                  dashRadius: 0.0,
                                  dashGapLength: 1.0,
                                  dashGapColor: Palette.transparent,
                                  dashGapRadius: 0.0,
                                )
                              ],
                            ),
                          ),
                          ListTile(
                            onTap: () {
                              Navigator.popAndPushNamed(context, 'Offer');
                            },
                            title: Text(
                              getTranslated(context, AppString.home_offers).toString(),
                              style: TextStyle(
                                fontSize: 16,
                                color: Palette.dark_blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                            child: Column(
                              children: [
                                DottedLine(
                                  direction: Axis.horizontal,
                                  lineLength: double.infinity,
                                  lineThickness: 1.0,
                                  dashLength: 3.0,
                                  dashColor: Palette.dash_line,
                                  dashRadius: 0.0,
                                  dashGapLength: 1.0,
                                  dashGapColor: Palette.transparent,
                                  dashGapRadius: 0.0,
                                )
                              ],
                            ),
                          ),
                          ListTile(
                            onTap: () {
                              SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                                  ? Navigator.popAndPushNamed(context, 'Notifications')
                                  : FormHelper.showMessage(
                                      context,
                                      getTranslated(context, AppString.home_notification_alert_title).toString(),
                                      getTranslated(context, AppString.home_notification_alert_text).toString(),
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
                            title: Text(
                              getTranslated(context, AppString.home_notification).toString(),
                              style: TextStyle(
                                fontSize: 16,
                                color: Palette.dark_blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                            child: Column(
                              children: [
                                DottedLine(
                                  direction: Axis.horizontal,
                                  lineLength: double.infinity,
                                  lineThickness: 1.0,
                                  dashLength: 3.0,
                                  dashColor: Palette.dash_line,
                                  dashRadius: 0.0,
                                  dashGapLength: 1.0,
                                  dashGapColor: Palette.transparent,
                                  dashGapRadius: 0.0,
                                )
                              ],
                            ),
                          ),
                          ListTile(
                            onTap: () {
                              Navigator.popAndPushNamed(context, 'Setting');
                            },
                            title: Text(
                              getTranslated(context, AppString.home_settings).toString(),
                              style: TextStyle(
                                fontSize: 16,
                                color: Palette.dark_blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                            child: Column(
                              children: [
                                DottedLine(
                                  direction: Axis.horizontal,
                                  lineLength: double.infinity,
                                  lineThickness: 1.0,
                                  dashLength: 2.0,
                                  dashColor: Palette.dash_line,
                                  dashRadius: 0.0,
                                  dashGapLength: 1.0,
                                  dashGapColor: Palette.transparent,
                                  dashGapRadius: 0.0,
                                )
                              ],
                            ),
                          ),
                          ListTile(
                            title: SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                                ? GestureDetector(
                                    onTap: () {
                                      FormHelper.showMessage(
                                        context,
                                        getTranslated(context, AppString.home_logout_alert_title).toString(),
                                        getTranslated(context, AppString.home_logout_alert_text).toString(),
                                        getTranslated(context, AppString.cancel).toString(),
                                        () {
                                          Navigator.of(context).pop();
                                        },
                                        buttonText2: getTranslated(context, AppString.home_logout_alert_title).toString(),
                                        isConfirmationDialog: true,
                                        onPressed2: () {
                                          Preferences.checkNetwork().then((value) => value == true ? logoutUser() : print('No int'));
                                        },
                                      );
                                    },
                                    child: Text(
                                      getTranslated(context, AppString.home_logout).toString(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Palette.dark_blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : Text(
                                    '',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Palette.dark_blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),

            /// AppBar ///
            appBar: PreferredSize(
              preferredSize: Size(width, 120),
              child: SafeArea(
                top: true,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            child: TextButton(
                              onPressed: () {
                                _passIsWhere();
                                SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                                    ? Navigator.pushNamed(context, 'ShowLocation')
                                    : SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                                        ? Navigator.popAndPushNamed(context, 'MedicineOrder')
                                        : FormHelper.showMessage(
                                            context,
                                            getTranslated(context, AppString.home_selectAddress_alert_title).toString(),
                                            getTranslated(context, AppString.home_selectAddress_alert_text).toString(),
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
                              child: _address == null || _address == ""
                                  ? Container(
                                      width: width * 0.6,
                                      child: RichText(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        text: TextSpan(
                                          children: [
                                            WidgetSpan(
                                              alignment: PlaceholderAlignment.middle,
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                                child: Container(
                                                  height: 20,
                                                  width: 20,
                                                  child: SvgPicture.asset(
                                                    'assets/icons/location.svg',
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TextSpan(
                                              text: getTranslated(context, AppString.home_selectAddress).toString(),
                                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 15),
                                            ),
                                            WidgetSpan(
                                              alignment: PlaceholderAlignment.middle,
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                                child: Icon(
                                                  Icons.keyboard_arrow_down,
                                                  size: 25,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: width * 0.6,
                                      child: RichText(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        text: TextSpan(
                                          children: [
                                            WidgetSpan(
                                              alignment: PlaceholderAlignment.middle,
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                                child: Container(
                                                  height: 20,
                                                  width: 20,
                                                  child: SvgPicture.asset(
                                                    'assets/icons/location.svg',
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TextSpan(
                                              text: '$_address',
                                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 15),
                                            ),
                                            WidgetSpan(
                                              alignment: PlaceholderAlignment.middle,
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                                child: Icon(
                                                  Icons.keyboard_arrow_down,
                                                  size: 25,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(right: 10, left: 10),
                            child: IconButton(
                              onPressed: () {
                                _scaffoldKey.currentState!.openDrawer();
                              },
                              icon: SvgPicture.asset(
                                'assets/icons/menu.svg',
                                height: 15,
                                width: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Palette.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(30),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Palette.black.withOpacity(0.1),
                              blurRadius: 5,
                            )
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextField(
                            textCapitalization: TextCapitalization.words,
                            textAlignVertical: TextAlignVertical.center,
                            onChanged: onSearchTextChanged,
                            decoration: InputDecoration(
                              hintText: getTranslated(context, AppString.home_searchDoctor).toString(),
                              hintStyle: TextStyle(
                                fontSize: width * 0.04,
                                color: Palette.dark_blue,
                              ),
                              suffixIcon: Padding(
                                padding: const EdgeInsets.all(12),
                                child: SvgPicture.asset(
                                  'assets/icons/SearchIcon.svg',
                                  height: 15,
                                  width: 15,
                                ),
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: RefreshIndicator(
              onRefresh: refresh,
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
                child: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: [
                        /// Upcoming Appointment ///
                        upcomingAppointment.length != 0
                            ? Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                                        alignment: AlignmentDirectional.topStart,
                                        child: Column(
                                          children: [
                                            Text(
                                              getTranslated(context, AppString.home_upcomingAppointment).toString(),
                                              style: TextStyle(
                                                fontSize: width * 0.04,
                                                color: Palette.dark_blue,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(context, 'Appointment');
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(top: 15, left: 20, right: 20),
                                          alignment: AlignmentDirectional.topStart,
                                          child: Column(
                                            children: [
                                              Text(
                                                getTranslated(context, AppString.home_viewAll).toString(),
                                                style: TextStyle(fontSize: width * 0.035, color: Palette.blue),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(15),
                                      ),
                                      child: Stack(
                                        children: <Widget>[
                                          CarouselSlider(
                                            options: CarouselOptions(
                                              height: 190,
                                              viewportFraction: 1.0,
                                              onPageChanged: (index, index1) {
                                                setState(
                                                  () {
                                                    current = index;
                                                  },
                                                );
                                              },
                                            ),
                                            items: upcomingAppointment.map((appointmentData) {
                                              var statusColor = Palette.green.withOpacity(0.5);
                                              if (appointmentData.appointmentStatus!.toUpperCase() == getTranslated(context, AppString.home_pending).toString()) {
                                                statusColor = Palette.dark_blue;
                                              } else if (appointmentData.appointmentStatus!.toUpperCase() == getTranslated(context, AppString.home_cancel).toString()) {
                                                statusColor = Palette.red;
                                              } else if (appointmentData.appointmentStatus!.toUpperCase() == getTranslated(context, AppString.home_approve).toString()) {
                                                statusColor = Palette.green.withOpacity(0.5);
                                              }
                                              return Builder(
                                                builder: (BuildContext context) {
                                                  return Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                                    child: Card(
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(10.0),
                                                      ),
                                                      elevation: 2,
                                                      color: Palette.white,
                                                      child: Column(
                                                        children: [
                                                          Container(
                                                            margin: EdgeInsets.only(top: 10, left: 12, right: 12),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                  children: [
                                                                    Container(
                                                                      child: Text(
                                                                        getTranslated(context, AppString.home_bookingId).toString(),
                                                                        style: TextStyle(fontSize: 14, color: Palette.blue, fontWeight: FontWeight.bold),
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      appointmentData.appointmentId!,
                                                                      style: TextStyle(fontSize: 14, color: Palette.black, fontWeight: FontWeight.bold),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Container(
                                                                  child: Text(
                                                                    appointmentData.appointmentStatus!.toUpperCase(),
                                                                    style: TextStyle(fontSize: 14, color: statusColor, fontWeight: FontWeight.bold),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            margin: EdgeInsets.only(
                                                              top: 10,
                                                            ),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Container(
                                                                  width: width * 0.15,
                                                                  child: Column(
                                                                    children: [
                                                                      Container(
                                                                        width: 40,
                                                                        height: 40,
                                                                        decoration: new BoxDecoration(shape: BoxShape.circle, boxShadow: [
                                                                          new BoxShadow(
                                                                            color: Palette.blue,
                                                                            blurRadius: 1.0,
                                                                          ),
                                                                        ]),
                                                                        child: CachedNetworkImage(
                                                                          alignment: Alignment.center,
                                                                          imageUrl: appointmentData.doctor!.fullImage!,
                                                                          imageBuilder: (context, imageProvider) => CircleAvatar(
                                                                            radius: 50,
                                                                            backgroundColor: Palette.white,
                                                                            child: CircleAvatar(
                                                                              radius: 18,
                                                                              backgroundImage: imageProvider,
                                                                            ),
                                                                          ),
                                                                          placeholder: (context, url) => SpinKitFadingCircle(color: Palette.blue),
                                                                          errorWidget: (context, url, error) => Image.asset("assets/images/no_image.jpg"),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                                Container(
                                                                  width: width * 0.75,
                                                                  // color: Colors.red,
                                                                  child: Column(
                                                                    children: [
                                                                      Container(
                                                                        alignment: AlignmentDirectional.topStart,
                                                                        child: Column(
                                                                          children: [
                                                                            Text(
                                                                              appointmentData.doctor!.name!,
                                                                              style: TextStyle(
                                                                                fontSize: 16,
                                                                                color: Palette.dark_blue,
                                                                              ),
                                                                              overflow: TextOverflow.ellipsis,
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      appointmentData.hospital != null
                                                                          ? Column(
                                                                              children: [
                                                                                Container(
                                                                                  alignment: AlignmentDirectional.topStart,
                                                                                  margin: EdgeInsets.only(top: 3),
                                                                                  child: Column(
                                                                                    children: [Text(appointmentData.hospital!.name!, style: TextStyle(fontSize: 12, color: Palette.grey), overflow: TextOverflow.ellipsis)],
                                                                                  ),
                                                                                ),
                                                                                Container(
                                                                                  alignment: AlignmentDirectional.topStart,
                                                                                  margin: EdgeInsets.only(top: 3),
                                                                                  child: Column(
                                                                                    children: [Text(appointmentData.hospital!.address!, style: TextStyle(fontSize: 12, color: Palette.grey), overflow: TextOverflow.ellipsis)],
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            )
                                                                          : SizedBox(),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            margin: EdgeInsets.only(top: 10),
                                                            child: Column(
                                                              children: [
                                                                Divider(
                                                                  height: 2,
                                                                  color: Palette.dark_grey,
                                                                  thickness: width * 0.001,
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                                            child: Column(
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Container(
                                                                      child: Text(
                                                                        getTranslated(context, AppString.home_dateTime).toString(),
                                                                        style: TextStyle(
                                                                          fontSize: 12,
                                                                          color: Palette.grey,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      child: Text(
                                                                        getTranslated(context, AppString.home_patientName).toString(),
                                                                        style: TextStyle(
                                                                          fontSize: 12,
                                                                          color: Palette.grey,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Container(
                                                                      child: Text(
                                                                        appointmentData.date! + '  ' + appointmentData.time!,
                                                                        style: TextStyle(fontSize: 12, color: Palette.dark_blue),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      child: Text(
                                                                        appointmentData.patientName!,
                                                                        style: TextStyle(fontSize: 12, color: Palette.dark_blue),
                                                                        overflow: TextOverflow.ellipsis,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : SizedBox(),

                        /// Doctor Specialist List ///
                        Column(
                          children: [
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(left: width * 0.05, right: width * 0.05),
                                    alignment: AlignmentDirectional.topStart,
                                    child: Row(
                                      children: [
                                        Text(
                                          getTranslated(context, AppString.home_specialist).toString(),
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Palette.dark_blue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, 'Specialist');
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(right: width * 0.04, left: width * 0.04),
                                      child: Text(
                                        getTranslated(context, AppString.home_viewAll).toString(),
                                        style: TextStyle(fontSize: width * 0.035, color: Palette.blue),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: height * 0.27,
                              width: width * 1,
                              margin: EdgeInsets.symmetric(horizontal: width * 0.03),
                              child: _searchResult.length > 0 || _search.text.isNotEmpty
                                  ? ListView(
                                      scrollDirection: Axis.horizontal,
                                      physics: BouncingScrollPhysics(),
                                      children: [
                                        ListView.builder(
                                          physics: NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: _searchResult.length,
                                          scrollDirection: Axis.horizontal,
                                          itemBuilder: (context, index) {
                                            favoriteDoctor.clear();
                                            for (int i = 0; i < _searchResult.length; i++) {
                                              _searchResult[i].isFavorite == false ? favoriteDoctor.add(false) : favoriteDoctor.add(true);
                                            }
                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => DoctorDetail(
                                                      id: _searchResult[index].id,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                width: width * 0.4,
                                                child: Card(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10.0),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Column(
                                                        children: [
                                                          Stack(
                                                            children: [
                                                              Container(
                                                                margin: EdgeInsets.all(width * 0.02),
                                                                width: width * 0.35,
                                                                height: height * 0.15,
                                                                child: ClipRRect(
                                                                  borderRadius: BorderRadius.all(
                                                                    Radius.circular(10),
                                                                  ),
                                                                  child: CachedNetworkImage(
                                                                    alignment: Alignment.center,
                                                                    imageUrl: _searchResult[index].fullImage!,
                                                                    fit: BoxFit.cover,
                                                                    placeholder: (context, url) => SpinKitFadingCircle(color: Palette.blue),
                                                                    errorWidget: (context, url, error) => Image.asset("assets/images/no_image.jpg"),
                                                                  ),
                                                                ),
                                                              ),
                                                              Positioned(
                                                                top: 5,
                                                                right: 0,
                                                                child: Container(
                                                                  child: SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                                                                      ? IconButton(
                                                                          onPressed: () {
                                                                            setState(
                                                                              () {
                                                                                favoriteDoctor[index] == false ? favoriteDoctor[index] = true : favoriteDoctor[index] = false;
                                                                                doctorID = _searchResult[index].id;
                                                                                callApiFavoriteDoctor();
                                                                              },
                                                                            );
                                                                          },
                                                                          icon: Icon(
                                                                            Icons.favorite_outlined,
                                                                            size: 25,
                                                                            color: favoriteDoctor[index] == false ? Palette.white : Palette.red,
                                                                          ),
                                                                        )
                                                                      : IconButton(
                                                                          onPressed: () {
                                                                            setState(
                                                                              () {
                                                                                Fluttertoast.showToast(
                                                                                  msg: getTranslated(context, AppString.home_pleaseLogin_toast).toString(),
                                                                                  toastLength: Toast.LENGTH_SHORT,
                                                                                  gravity: ToastGravity.BOTTOM,
                                                                                  backgroundColor: Palette.blue,
                                                                                  textColor: Palette.white,
                                                                                );
                                                                              },
                                                                            );
                                                                          },
                                                                          icon: Icon(
                                                                            Icons.favorite_outlined,
                                                                            size: 25,
                                                                            color: favoriteDoctor[index] == false ? Palette.white : Palette.red,
                                                                          ),
                                                                        ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      Container(
                                                        width: width * 0.4,
                                                        margin: EdgeInsets.only(top: width * 0.02),
                                                        child: Column(
                                                          children: [
                                                            Text(
                                                              _searchResult[index].name!,
                                                              style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                              textAlign: TextAlign.center,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        width: width * 0.4,
                                                        child: Column(
                                                          children: [
                                                            _searchResult[index].treatment != null
                                                                ? Text(
                                                                    _searchResult[index].treatment!.name.toString(),
                                                                    style: TextStyle(fontSize: width * 0.035, color: Palette.grey),
                                                                    maxLines: 1,
                                                                    overflow: TextOverflow.ellipsis,
                                                                  )
                                                                : Text(
                                                                    getTranslated(context, AppString.home_notAvailable).toString(),
                                                                    style: TextStyle(fontSize: width * 0.035, color: Palette.grey),
                                                                  ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                      ],
                                    )
                                  : doctorList.length > 0
                                      ? ListView(
                                          scrollDirection: Axis.horizontal,
                                          physics: BouncingScrollPhysics(),
                                          children: [
                                            ListView.builder(
                                              physics: NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount: 3 <= doctorList.length ? 3 : doctorList.length,
                                              scrollDirection: Axis.horizontal,
                                              itemBuilder: (context, index) {
                                                favoriteDoctor.clear();
                                                for (int i = 0; i < doctorList.length; i++) {
                                                  doctorList[i].isFavorite == false ? favoriteDoctor.add(false) : favoriteDoctor.add(true);
                                                }

                                                return GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => DoctorDetail(
                                                          id: doctorList[index].id,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    width: width * 0.4,
                                                    child: Card(
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(10.0),
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          Column(
                                                            children: [
                                                              Stack(
                                                                children: [
                                                                  Container(
                                                                    margin: EdgeInsets.all(width * 0.02),
                                                                    width: width * 0.35,
                                                                    height: height * 0.15,
                                                                    child: ClipRRect(
                                                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                                                      child: CachedNetworkImage(
                                                                        alignment: Alignment.center,
                                                                        imageUrl: doctorList[index].fullImage!,
                                                                        fit: BoxFit.cover,
                                                                        placeholder: (context, url) => SpinKitFadingCircle(color: Palette.blue),
                                                                        errorWidget: (context, url, error) => Image.asset("assets/images/no_image.jpg"),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Positioned(
                                                                    top: 5,
                                                                    right: 0,
                                                                    child: Container(
                                                                      child: SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                                                                          ? IconButton(
                                                                              onPressed: () {
                                                                                setState(
                                                                                  () {
                                                                                    favoriteDoctor[index] == false ? favoriteDoctor[index] = true : favoriteDoctor[index] = false;
                                                                                    doctorID = doctorList[index].id;
                                                                                    callApiFavoriteDoctor();
                                                                                  },
                                                                                );
                                                                              },
                                                                              icon: Icon(
                                                                                Icons.favorite_outlined,
                                                                                size: 25,
                                                                                color: favoriteDoctor[index] == false ? Palette.white : Palette.red,
                                                                              ),
                                                                            )
                                                                          : IconButton(
                                                                              onPressed: () {
                                                                                setState(
                                                                                  () {
                                                                                    Fluttertoast.showToast(
                                                                                      msg: getTranslated(context, AppString.home_pleaseLogin_toast).toString(),
                                                                                      toastLength: Toast.LENGTH_SHORT,
                                                                                      gravity: ToastGravity.BOTTOM,
                                                                                      backgroundColor: Palette.blue,
                                                                                      textColor: Palette.white,
                                                                                    );
                                                                                  },
                                                                                );
                                                                              },
                                                                              icon: Icon(
                                                                                Icons.favorite_outlined,
                                                                                size: 25,
                                                                                color: favoriteDoctor[index] == false ? Palette.white : Palette.red,
                                                                              ),
                                                                            ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                          Container(
                                                            width: width * 0.4,
                                                            margin: EdgeInsets.only(top: width * 0.02),
                                                            child: Column(
                                                              children: [
                                                                Text(
                                                                  doctorList[index].name!,
                                                                  style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  textAlign: TextAlign.center,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            width: width * 0.4,
                                                            child: Column(
                                                              children: [
                                                                doctorList[index].treatment != null
                                                                    ? Text(
                                                                        doctorList[index].treatment!.name.toString(),
                                                                        style: TextStyle(fontSize: width * 0.035, color: Palette.grey),
                                                                        maxLines: 1,
                                                                        overflow: TextOverflow.ellipsis,
                                                                      )
                                                                    : Text(
                                                                        getTranslated(context, AppString.home_notAvailable).toString(),
                                                                        style: TextStyle(fontSize: width * 0.035, color: Palette.grey),
                                                                      ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            )
                                          ],
                                        )
                                      : Center(
                                          child: Container(
                                            child: Text(
                                              getTranslated(context, AppString.home_notAvailable).toString(),
                                              style: TextStyle(fontSize: width * 0.05, color: Palette.grey, fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                            ),
                          ],
                        ),

                        SizedBox(
                          height: 10,
                        ),

                        /// Treatments  ///
                        Column(
                          children: [
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                      left: width * 0.05,
                                      right: width * 0.05,
                                    ),
                                    alignment: AlignmentDirectional.topStart,
                                    child: Row(
                                      children: [
                                        Text(
                                          getTranslated(context, AppString.home_treatments).toString(),
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Palette.dark_blue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, 'Treatment');
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(right: width * 0.04, left: width * 0.04),
                                      child: Text(
                                        getTranslated(context, AppString.home_viewAll).toString(),
                                        style: TextStyle(fontSize: width * 0.035, color: Palette.blue),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            treatmentList.length != 0
                                ? Container(
                                    height: 125,
                                    width: width,
                                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    child: ListView(
                                      physics: BouncingScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      children: [
                                        ListView.builder(
                                          itemCount: 4 <= treatmentList.length ? 4 : treatmentList.length,
                                          physics: NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          itemBuilder: (context, index) {
                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => TreatmentSpecialist(
                                                      id: treatmentList[index].id,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                // color: Colors.teal,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      height: 80,
                                                      alignment: AlignmentDirectional.center,
                                                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                                      child: CachedNetworkImage(
                                                        alignment: Alignment.center,
                                                        imageUrl: treatmentList[index].fullImage!,
                                                        fit: BoxFit.cover,
                                                        placeholder: (context, url) =>
                                                            // CircularProgressIndicator(),
                                                            SpinKitFadingCircle(
                                                          color: Palette.blue,
                                                        ),
                                                        errorWidget: (context, url, error) => Image.asset("assets/images/no_image.jpg"),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 70,
                                                      height: 35,
                                                      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                                                      child: Text(
                                                        treatmentList[index].name!,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Palette.dark_blue,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 2,
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  )
                                : Center(
                                    child: Container(
                                      height: 125,
                                      width: width,
                                      alignment: AlignmentDirectional.center,
                                      child: Text(
                                        getTranslated(context, AppString.home_notAvailable).toString(),
                                        style: TextStyle(fontSize: width * 0.05, color: Palette.grey, fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                          ],
                        ),

                        SizedBox(
                          height: 10,
                        ),

                        /// looking For ///
                        Column(
                          children: [
                            Container(
                              alignment: AlignmentDirectional.topStart,
                              margin: EdgeInsets.only(
                                left: 20,
                                right: 20,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    getTranslated(context, AppString.home_lookingFor).toString(),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Palette.dark_blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            //banners
                            Container(
                              height: 210,
                              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15),
                                ),
                                child: Stack(
                                  children: <Widget>[
                                    CarouselSlider(
                                      options: CarouselOptions(
                                        height: 200,
                                        viewportFraction: 1.0,
                                        autoPlay: true,
                                        onPageChanged: (index, index1) {
                                          setState(
                                            () {
                                              current = index;
                                            },
                                          );
                                        },
                                      ),
                                      items: banner.map((bannerData) {
                                        return Builder(
                                          builder: (BuildContext context) {
                                            return InkWell(
                                              onTap: () async {
                                                // await launch(bannerData.link!);
                                                Uri _url = Uri.parse(bannerData.link!);
                                                launchUrl(_url);
                                              },
                                              child: Container(
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.all(
                                                    Radius.circular(15),
                                                  ),
                                                  child: CachedNetworkImage(
                                                    imageUrl: bannerData.fullImage!,
                                                    fit: BoxFit.fitHeight,
                                                    placeholder: (context, url) => SpinKitFadingCircle(color: Palette.blue),
                                                    errorWidget: (context, url, error) => Image.asset(
                                                      "assets/images/no_image.jpg",
                                                      width: width,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(
                          height: 10,
                        ),

                        /// Offer ///
                        offerList.length != 0
                            ? Column(
                                children: [
                                  Container(
                                    alignment: AlignmentDirectional.topStart,
                                    margin: EdgeInsets.only(left: width * 0.05, right: width * 0.05),
                                    child: Column(
                                      children: [
                                        Text(
                                          getTranslated(context, AppString.home_offers).toString(),
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Palette.dark_blue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: 200,
                                    width: width * 1,
                                    child: ListView.builder(
                                      itemCount: offerList.length,
                                      physics: BouncingScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                          child: Container(
                                            height: 160,
                                            width: 175,
                                            child: Card(
                                              color: index % 2 == 0 ? Palette.light_blue.withOpacity(0.9) : Palette.offer_card.withOpacity(0.9),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10.0),
                                              ),
                                              child: Column(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                                                    child: Container(
                                                      height: 40,
                                                      margin: EdgeInsets.symmetric(vertical: 5),
                                                      child: Center(
                                                        child: Text(
                                                          offerList[index].name!,
                                                          style: TextStyle(fontSize: 16, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                                                          textAlign: TextAlign.center,
                                                          overflow: TextOverflow.ellipsis,
                                                          maxLines: 1,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                                                    child: Column(
                                                      children: [
                                                        DottedLine(
                                                          direction: Axis.horizontal,
                                                          lineLength: double.infinity,
                                                          lineThickness: 1.0,
                                                          dashLength: 3.0,
                                                          dashColor: index % 2 == 0 ? Palette.light_blue.withOpacity(0.9) : Palette.offer_card.withOpacity(0.9),
                                                          dashRadius: 0.0,
                                                          dashGapLength: 1.0,
                                                          dashGapColor: Palette.transparent,
                                                          dashGapRadius: 0.0,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  if (offerList[index].discountType == "amount" && offerList[index].isFlat == 0)
                                                    Container(
                                                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                      child: Text(
                                                        getTranslated(context, AppString.home_flat).toString() + ' ' + SharedPreferenceHelper.getString(Preferences.currency_symbol).toString() + offerList[index].discount.toString(),
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight: FontWeight.bold,
                                                          color: Palette.dark_blue,
                                                        ),
                                                      ),
                                                    ),
                                                  if (offerList[index].discountType == "percentage" && offerList[index].isFlat == 0)
                                                    Container(
                                                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                      // alignment: Alignment.topLeft,
                                                      child: Text(
                                                        offerList[index].discount.toString() + getTranslated(context, AppString.home_discount).toString(),
                                                        textAlign: TextAlign.center,
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 2,
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight: FontWeight.bold,
                                                          color: Palette.dark_blue,
                                                        ),
                                                      ),
                                                    ),
                                                  if (offerList[index].discountType == "amount" && offerList[index].isFlat == 1)
                                                    Container(
                                                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                      child: Text(
                                                        getTranslated(context, AppString.home_flat).toString() + SharedPreferenceHelper.getString(Preferences.currency_symbol).toString() + offerList[index].flatDiscount.toString(),
                                                        textAlign: TextAlign.center,
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 2,
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight: FontWeight.bold,
                                                          color: Palette.dark_blue,
                                                        ),
                                                      ),
                                                    ),
                                                  Container(
                                                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                    decoration: BoxDecoration(color: Palette.white, borderRadius: BorderRadius.circular(10)),
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8),
                                                      child: SelectableText(
                                                        offerList[index].offerCode!,
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          // fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<BaseModel<Treatments>> callApiTreatment() async {
    Treatments response;
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi2().dioData2()).treatmentsRequest();
      setState(() {
        loading = false;
        if (response.success == true) {
          setState(() {
            treatmentList.addAll(response.data!);
          });
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

  Future<BaseModel<Doctors>> callApiDoctorList() async {
    Doctors response;
    Map<String, dynamic> body = {
      "lat": _lat,
      "lang": _lang,
    };
    setState(() {
      loading = true;
    });
    try {
      SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true ? response = await RestClient(RetroApi().dioData()).doctorList(body) : response = await RestClient(RetroApi2().dioData2()).doctorList(body);
      setState(() {
        loading = false;
        doctorList.clear();
        doctorList.addAll(response.data!.reversed);
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

  // Logout Api //
  Future logoutUser() async {
    setState(() {
      SharedPreferenceHelper.clearPref();
      authProvider!.handleSignOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => Home()),
        ModalRoute.withName('SplashScreen'),
      );
    });
  }

  Future<BaseModel<UserDetail>> callApiForUserDetail() async {
    UserDetail response;
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi().dioData()).userDetailRequest();
      setState(() {
        loading = false;
        name = response.name;
        email = response.email;
        phoneNo = response.phone;
        image = response.fullImage;
        _passDetail();
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

  Future<BaseModel<Banners>> callApiBanner() async {
    Banners response;
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi2().dioData2()).bannerRequest();
      setState(() {
        loading = false;
        if (response.data!.length != 0) {
          imgList.clear();
          for (int i = 0; i < response.data!.length; i++) {
            imgList.add(response.data![i].fullImage);
          }
        }
        banner.addAll(response.data!);
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

  Future<BaseModel<FavoriteDoctor>> callApiFavoriteDoctor() async {
    FavoriteDoctor response;
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi().dioData()).favoriteDoctorRequest(doctorID);
      setState(() {
        loading = false;
        Fluttertoast.showToast(
          msg: '${response.msg}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Palette.blue,
          textColor: Palette.white,
        );
        doctorList.clear();
        callApiDoctorList();
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

  Future<BaseModel<DisplayOffer>> callApIDisplayOffer() async {
    DisplayOffer response;
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi2().dioData2()).displayOfferRequest();
      setState(() {
        loading = false;
        offerList.addAll(response.data!);
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

  Future<BaseModel<Appointments>> callApiAppointment() async {
    Appointments response;
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi().dioData()).appointmentsRequest();
      setState(() {
        loading = false;
        upcomingAppointment.addAll(response.data!.upcomingAppointment!);
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

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    doctorList.forEach((appointmentData) {
      if (appointmentData.name!.toLowerCase().contains(text.toLowerCase())) _searchResult.add(appointmentData);
    });
    setState(() {});
  }

  Future<BaseModel<DetailSetting>> callApiSetting() async {
    DetailSetting response;
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi().dioData()).settingRequest();
      setState(() {
        loading = false;
        if (SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true) {
          if (response.data!.paypalClientId.toString() != "null") {
            SharedPreferenceHelper.setString(Preferences.paypal_Client_Id, response.data!.paypalClientId.toString());
          }
          if (response.data!.paypalSecretKey.toString() != "null") {
            SharedPreferenceHelper.setString(Preferences.paypal_Secret_key, response.data!.paypalSecretKey.toString());
          }
          if (response.data!.patientAppId! != "null") {
            SharedPreferenceHelper.setString(Preferences.patientAppId, response.data!.patientAppId!);
            // SharedPreferenceHelper.setString(Preferences.patientAppId, response.data!.doctorAppId!);
          }
          if (response.data!.currencySymbol! != "null") {
            SharedPreferenceHelper.setString(Preferences.currency_symbol, response.data!.currencySymbol!);
          }
          if (response.data!.currencyCode! != "null") {
            SharedPreferenceHelper.setString(Preferences.currency_code, response.data!.currencyCode!);
          }
          if (response.data!.cod.toString() != "null") {
            SharedPreferenceHelper.setString(Preferences.cod, response.data!.cod.toString());
          }
          if (response.data!.stripe.toString() != "null") {
            SharedPreferenceHelper.setString(Preferences.stripe, response.data!.stripe.toString());
          }
          if (response.data!.paypal.toString() != "null") {
            SharedPreferenceHelper.setString(Preferences.paypal, response.data!.paypal.toString());
          }
          if (response.data!.razor.toString() != "null") {
            SharedPreferenceHelper.setString(Preferences.razor, response.data!.razor.toString());
          }
          if (response.data!.flutterwave.toString() != "null") {
            SharedPreferenceHelper.setString(Preferences.flutterWave, response.data!.flutterwave.toString());
          }
          if (response.data!.payStack.toString() != "null") {
            SharedPreferenceHelper.setString(Preferences.payStack, response.data!.payStack.toString());
          }
          if (response.data!.stripePublicKey! != "null") {
            SharedPreferenceHelper.setString(Preferences.stripe_public_key, response.data!.stripePublicKey!);
          }
          if (response.data!.stripeSecretKey! != "null") {
            SharedPreferenceHelper.setString(Preferences.stripe_secret_key, response.data!.stripeSecretKey!);
          }
          if (response.data!.paypalSandboxKey != null) {
            SharedPreferenceHelper.setString(Preferences.paypal_sandbox_key, response.data!.paypalSandboxKey!);
          }
          if (response.data!.paypalProductionKey != null) {
            SharedPreferenceHelper.setString(Preferences.paypal_production_key, response.data!.paypalProductionKey!);
          }
          if (response.data!.razorKey! != "null") {
            SharedPreferenceHelper.setString(Preferences.razor_key, response.data!.razorKey!);
          }
          if (response.data!.flutterwaveKey! != "null") {
            SharedPreferenceHelper.setString(Preferences.flutterWave_key, response.data!.flutterwaveKey!);
          }
          if (response.data!.flutterwaveEncryptionKey != null) {
            SharedPreferenceHelper.setString(Preferences.flutterWave_encryption_key, response.data!.flutterwaveEncryptionKey!);
          }
          if (response.data!.payStackPublicKey! != "null") {
            SharedPreferenceHelper.setString(Preferences.payStack_public_key, response.data!.payStackPublicKey!);
          }
          if (response.data!.agoraAppId != null) {
            SharedPreferenceHelper.setString(Preferences.agoraAppId, response.data!.agoraAppId!);
          }
        } else {
          if (response.data!.patientAppId! != "null") {
            SharedPreferenceHelper.setString(Preferences.patientAppId, response.data!.patientAppId!);
            // SharedPreferenceHelper.setString(Preferences.patientAppId, response.data!.doctorAppId!);
          }
          if (response.data!.currencySymbol! != "null") {
            SharedPreferenceHelper.setString(Preferences.currency_symbol, response.data!.currencySymbol!);
          }
          if (response.data!.currencyCode! != "null") {
            SharedPreferenceHelper.setString(Preferences.currency_code, response.data!.currencyCode!);
          }
          if (response.data!.cod.toString() != "null") {
            SharedPreferenceHelper.setString(Preferences.cod, response.data!.cod.toString());
          }
          if (response.data!.stripe.toString() != "null") {
            SharedPreferenceHelper.setString(Preferences.stripe, response.data!.stripe.toString());
          }
          if (response.data!.paypal.toString() != "null") {
            SharedPreferenceHelper.setString(Preferences.paypal, response.data!.paypal.toString());
          }
          if (response.data!.razor.toString() != "null") {
            SharedPreferenceHelper.setString(Preferences.razor, response.data!.razor.toString());
          }
          if (response.data!.flutterwave.toString() != "null") {
            SharedPreferenceHelper.setString(Preferences.flutterWave, response.data!.flutterwave.toString());
          }
          if (response.data!.payStack.toString() != "null") {
            SharedPreferenceHelper.setString(Preferences.payStack, response.data!.payStack.toString());
          }
          if (response.data!.isLiveKey.toString() != "null") {
            SharedPreferenceHelper.setString(Preferences.isLiveKey, response.data!.isLiveKey.toString());
          }
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

  Future<void> refresh() async {
    setState(() {
      callApiDoctorList();
    });
  }

  Future<void> getOneSingleToken() async {
    try {
      OneSignal.Notifications.addClickListener((event) async {
        if (event.result.actionId == "") {
        } else if (event.result.actionId == "decline") {
          setState(() {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoCall(
                  doctorId: event.notification.additionalData!["id"],
                  flag: "Cut",
                ),
              ),
            );
          });
          setState(() {});
        } else if (event.result.actionId == "accept") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoCall(
                doctorId: event.notification.additionalData!["id"],
                flag: "InComming",
              ),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PhoneScreen(event.notification.additionalData)),
          );
        }
      });
    } catch (e) {}
  }
}
