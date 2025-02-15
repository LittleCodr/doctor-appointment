import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctro_patient/api/retrofit_Api.dart';
import 'package:doctro_patient/api/network_api.dart';
import 'package:doctro_patient/const/app_string.dart';
import 'package:doctro_patient/const/preference.dart';
import 'package:doctro_patient/Screen/Doctor/doctorDetail.dart';
import 'package:doctro_patient/model/doctors_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/base_model.dart';
import '../../api/server_error.dart';
import '../../const/Palette.dart';
import '../../const/prefConstatnt.dart';
import '../../localization/localization_constant.dart';
import '../../model/favorite_doctor_model.dart';

class Specialist extends StatefulWidget {
  @override
  _SpecialistState createState() => _SpecialistState();
}

class _SpecialistState extends State<Specialist> {
  bool loading = false;
  String? _address = "";
  String? _lat = "";
  String? _lang = "";

  List<DoctorModel> doctorList = [];

  List<bool> favoriteDoctor = [];
  List<bool> searchFavoriteDoctor = [];
  int? doctorID = 0;

  TextEditingController _search = TextEditingController();
  List<DoctorModel> _searchResult = [];

  @override
  void initState() {
    super.initState();
    _getAddress();
  }

  _getAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(
      () {
        _address = (prefs.getString('Address'));
        _lat = (prefs.getString('lat'));
        _lang = (prefs.getString('lang'));
      },
    );
    callApiDoctorList();
  }

  Future<bool> onWillPop() {
    Navigator.pushReplacementNamed(context, 'Home');
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    double width;
    double height;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(width, 110),
          child: SafeArea(
            top: true,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _address == null || _address == ""
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
                                  ],
                                ),
                              ),
                            ),
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          size: 22,
                        ),
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, 'Home');
                        },
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
                          hintText: getTranslated(context, AppString.specialist_searchDoctor_hint).toString(),
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
          onRefresh: callApiDoctorList,
          child: ModalProgressHUD(
            child: _searchResult.length > 0 || _search.text.isNotEmpty
                ? _searchResult.length != 0
                    ? Container(
                        child: ListView(
                          scrollDirection: Axis.vertical,
                          children: [
                            GridView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: _searchResult.length,
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 5, childAspectRatio: 0.85),
                              itemBuilder: (context, index) {
                                favoriteDoctor.clear();
                                for (int i = 0; i < _searchResult.length; i++) {
                                  _searchResult[i].isFavorite == false ? favoriteDoctor.add(false) : favoriteDoctor.add(true);
                                }
                                return Column(
                                  children: [
                                    InkWell(
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
                                        width: width * 0.45,
                                        height: width * 0.57,
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                          child: Container(
                                            margin: EdgeInsets.all(width * 0.02),
                                            child: Column(
                                              children: [
                                                Stack(
                                                  children: [
                                                    Container(
                                                      width: width * 0.4,
                                                      height: height * 0.18,
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
                                                      top: 0,
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
                                                                        msg: getTranslated(context, AppString.specialist_pleaseLogin_toast).toString(),
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
                                                Container(
                                                  margin: EdgeInsets.only(top: width * 0.02),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        _searchResult[index].name!,
                                                        textAlign: TextAlign.center,
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 1,
                                                        style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  child: _searchResult[index].treatment != null
                                                      ? Text(
                                                          _searchResult[index].treatment!.name.toString(),
                                                          style: TextStyle(fontSize: width * 0.035, color: Palette.grey),
                                                        )
                                                      : Text(
                                                          getTranslated(context, AppString.specialist_notAvailable).toString(),
                                                          style: TextStyle(fontSize: width * 0.035, color: Palette.grey),
                                                        ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              },
                            )
                          ],
                        ),
                      )
                    : Container(
                        alignment: AlignmentDirectional.center,
                        child: Text(
                          getTranslated(context, AppString.specialist_doctorNotFound).toString(),
                          style: TextStyle(fontSize: width * 0.04, color: Palette.grey, fontWeight: FontWeight.bold),
                        ),
                      )
                : doctorList.length != 0
                    ? Container(
                        child: ListView(
                          scrollDirection: Axis.vertical,
                          children: [
                            GridView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: doctorList.length,
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 0, childAspectRatio: 0.85),
                              itemBuilder: (context, index) {
                                favoriteDoctor.clear();
                                for (int i = 0; i < doctorList.length; i++) {
                                  doctorList[i].isFavorite == false ? favoriteDoctor.add(false) : favoriteDoctor.add(true);
                                }
                                return Column(
                                  children: [
                                    InkWell(
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
                                        width: width * 0.45,
                                        height: width * 0.57,
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                          child: Container(
                                            margin: EdgeInsets.symmetric(vertical: width * 0.02, horizontal: width * 0.02),
                                            child: Column(
                                              children: [
                                                Stack(
                                                  children: [
                                                    Container(
                                                      width: width * 0.4,
                                                      height: height * 0.18,
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
                                                      top: 0,
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
                                                                        msg: getTranslated(context, AppString.specialist_pleaseLogin_toast).toString(),
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
                                                Container(
                                                  margin: EdgeInsets.only(top: height * 0.01),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        doctorList[index].name!,
                                                        textAlign: TextAlign.center,
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 1,
                                                        style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  child: doctorList[index].treatment != null
                                                      ? Text(
                                                          doctorList[index].treatment!.name.toString(),
                                                          style: TextStyle(fontSize: width * 0.035, color: Palette.grey),
                                                        )
                                                      : Text(
                                                          getTranslated(context, AppString.specialist_notAvailable).toString(),
                                                          style: TextStyle(fontSize: width * 0.035, color: Palette.grey),
                                                        ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              },
                            )
                          ],
                        ),
                      )
                    : Container(
                        alignment: AlignmentDirectional.center,
                        child: Text(
                          getTranslated(context, AppString.specialist_doctorNotFound).toString(),
                          style: TextStyle(fontSize: width * 0.04, color: Palette.grey, fontWeight: FontWeight.bold),
                        ),
                      ),
            inAsyncCall: loading,
            opacity: 0.5,
            progressIndicator: SpinKitFadingCircle(
              color: Palette.blue,
              size: 50.0,
            ),
          ),
        ),
      ),
    );
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
        if (response.success == true) {
          setState(() {
            doctorList.clear();
            loading = false;
            doctorList.addAll(response.data!);
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

  Future<BaseModel<FavoriteDoctor>> callApiFavoriteDoctor() async {
    FavoriteDoctor response;
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi().dioData()).favoriteDoctorRequest(doctorID);
      setState(() {
        loading = false;
        if (response.success == true) {
          setState(
            () {
              Fluttertoast.showToast(
                msg: '${response.msg}',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Palette.blue,
                textColor: Palette.white,
              );
              doctorList.clear();
              callApiDoctorList();
            },
          );
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
}
