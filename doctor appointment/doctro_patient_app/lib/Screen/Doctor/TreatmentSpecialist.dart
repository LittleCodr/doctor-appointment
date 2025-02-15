import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctro_patient/api/retrofit_Api.dart';
import 'package:doctro_patient/api/network_api.dart';
import 'package:doctro_patient/const/app_string.dart';
import 'package:doctro_patient/model/treatment_wish_doctor_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/base_model.dart';
import '../../api/server_error.dart';
import '../../const/Palette.dart';
import 'doctorDetail.dart';
import '../../localization/localization_constant.dart';

class TreatmentSpecialist extends StatefulWidget {
  final int? id;

  TreatmentSpecialist({this.id});

  @override
  _TreatmentSpecialistState createState() => _TreatmentSpecialistState();
}

class _TreatmentSpecialistState extends State<TreatmentSpecialist> {
  bool loading = false;
  String? _address = "";
  String? _lat = "";
  String? _lang = "";

  int? id = 0;
  List<Data> treatmentSpecialistList = [];
  String treatmentName = "";
  String? treatmentSpecialist = "";

  TextEditingController _search = TextEditingController();
  List<Data> _searchResult = [];

  @override
  void initState() {
    super.initState();
    _getAddress();
    id = widget.id;
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
    callApiTreatmentWishDoctor();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
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
                        Navigator.pop(context);
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
                      controller: _search,
                      textCapitalization: TextCapitalization.words,
                      textAlignVertical: TextAlignVertical.center,
                      onChanged: onSearchTextChanged,
                      decoration: InputDecoration(
                        hintText: getTranslated(context, AppString.treatmentSpecialist_searchDoctor_hint).toString(),
                        hintStyle: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
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
      body: ModalProgressHUD(
        inAsyncCall: loading,
        opacity: 0.5,
        progressIndicator: SpinKitFadingCircle(
          color: Palette.blue,
          size: 50.0,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
          child: Column(
            children: [
              Container(
                width: width,
                color: Palette.dash_line,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                  child: Text(
                    '$treatmentSpecialist' + " " + getTranslated(context, AppString.treatmentSpecialist_specialistDoctor).toString(),
                    style: TextStyle(fontSize: width * 0.045, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              _searchResult.length > 0 || _search.text.isNotEmpty
                  ? _searchResult.length != 0
                      ? GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _searchResult.length,
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 5, childAspectRatio: 0.85),
                          itemBuilder: (context, index) {
                            return _searchResult.length != 0
                                ? Column(
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
                                          height: width * 0.57,
                                          width: width * 0.47,
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10.0),
                                            ),
                                            child: Column(
                                              children: [
                                                Column(
                                                  children: [
                                                    Container(
                                                      margin: EdgeInsets.only(top: width * 0.02),
                                                      width: width * 0.4,
                                                      height: width * 0.4,
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
                                                  ],
                                                ),
                                                Container(
                                                  margin: EdgeInsets.only(top: width * 0.02),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        _searchResult[index].name!,
                                                        style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Column(
                                                  children: [
                                                    _searchResult[index].treatment != null
                                                        ? Text(
                                                            _searchResult[index].treatment!.name.toString(),
                                                            style: TextStyle(fontSize: width * 0.035, color: Palette.grey),
                                                          )
                                                        : Text(
                                                            getTranslated(context, AppString.treatmentSpecialist_notAvailable).toString(),
                                                            style: TextStyle(
                                                              fontSize: width * 0.035,
                                                              color: Palette.grey,
                                                            ),
                                                          ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                : Center(
                                    child: Text(
                                      getTranslated(context, AppString.treatmentSpecialist_treatmentNotAvailable).toString(),
                                    ),
                                  );
                          },
                        )
                      : Container(
                          alignment: AlignmentDirectional.center,
                          margin: EdgeInsets.only(top: 250),
                          child: Text(
                            getTranslated(context, AppString.treatmentSpecialist_doctorNotFound).toString(),
                            style: TextStyle(fontSize: width * 0.04, color: Palette.grey, fontWeight: FontWeight.bold),
                          ),
                        )
                  : treatmentSpecialistList.length != 0
                      ? GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: treatmentSpecialistList.length,
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 5, childAspectRatio: 0.85),
                          itemBuilder: (context, index) {
                            return treatmentSpecialistList.length != 0
                                ? Column(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => DoctorDetail(
                                                id: treatmentSpecialistList[index].id,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          height: width * 0.57,
                                          width: width * 0.47,
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10.0),
                                            ),
                                            child: Column(
                                              children: [
                                                Column(
                                                  children: [
                                                    Container(
                                                      margin: EdgeInsets.only(top: width * 0.02),
                                                      width: width * 0.4,
                                                      height: width * 0.4,
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.all(
                                                          Radius.circular(10),
                                                        ),
                                                        child: CachedNetworkImage(
                                                          alignment: Alignment.center,
                                                          imageUrl: treatmentSpecialistList[index].fullImage!,
                                                          fit: BoxFit.cover,
                                                          placeholder: (context, url) => SpinKitFadingCircle(color: Palette.blue),
                                                          errorWidget: (context, url, error) => Image.asset("assets/images/no_image.jpg"),
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
                                                        treatmentSpecialistList[index].name!,
                                                        style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Column(
                                                  children: [
                                                    treatmentSpecialistList[index].treatment != null
                                                        ? Text(
                                                            treatmentSpecialistList[index].treatment!.name.toString(),
                                                            style: TextStyle(fontSize: width * 0.035, color: Palette.grey),
                                                          )
                                                        : Text(
                                                            getTranslated(context, AppString.treatmentSpecialist_notAvailable).toString(),
                                                            style: TextStyle(fontSize: width * 0.035, color: Palette.grey),
                                                          ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                : Center(
                                    child: Text(
                                      getTranslated(context, AppString.treatmentSpecialist_treatmentNotAvailable).toString(),
                                    ),
                                  );
                          },
                        )
                      : Container(
                          alignment: AlignmentDirectional.center,
                          margin: EdgeInsets.only(top: 250),
                          child: Text(
                            getTranslated(context, AppString.treatmentSpecialist_doctorNotFound).toString(),
                            style: TextStyle(fontSize: width * 0.04, color: Palette.grey, fontWeight: FontWeight.bold),
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Future<BaseModel<TreatmentWishDoctor>> callApiTreatmentWishDoctor() async {
    TreatmentWishDoctor response;
    Map<String, dynamic> body = {
      "lat": _lat,
      "lang": _lang,
    };
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi2().dioData2()).treatmentWishDoctorRequest(id, body);
      setState(() {
        loading = false;
        if (response.success == true) {
          setState(() {
            treatmentSpecialistList.addAll(response.data!);
            for (int i = 0; i < treatmentSpecialistList.length; i++) {
              treatmentSpecialist = treatmentSpecialistList[i].treatment!.name;
            }
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

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    treatmentSpecialistList.forEach((appointmentData) {
      if (appointmentData.name!.toLowerCase().contains(text.toLowerCase())) _searchResult.add(appointmentData);
    });

    setState(() {});
  }
}
