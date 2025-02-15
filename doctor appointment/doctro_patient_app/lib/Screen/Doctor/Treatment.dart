import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctro_patient/api/retrofit_Api.dart';
import 'package:doctro_patient/api/network_api.dart';
import 'package:doctro_patient/model/treatments_model.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/base_model.dart';
import '../../api/server_error.dart';
import '../../const/Palette.dart';
import '../../const/app_string.dart';
import '../../localization/localization_constant.dart';
import 'TreatmentSpecialist.dart';

class Treatment extends StatefulWidget {
  @override
  _TreatmentState createState() => _TreatmentState();
}

class _TreatmentState extends State<Treatment> {
  List<TreatmentData> treatmentList = [];

  bool loading = false;

  String? _address = "";

  TextEditingController _search = TextEditingController();
  List<TreatmentData> _searchResult = [];

  @override
  void initState() {
    super.initState();
    callApiTreatment();
    _getAddress();
  }

  _getAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(
      () {
        _address = (prefs.getString('Address'));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return ModalProgressHUD(
      inAsyncCall: loading,
      opacity: 0.5,
      progressIndicator: SpinKitFadingCircle(
        color: Palette.blue,
        size: 50.0,
      ),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(width * 0.3, 110),
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
                          hintText: getTranslated(context, AppString.treatment_searchTreatment).toString(),
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
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: _searchResult.length > 0 || _search.text.isNotEmpty
              ? _searchResult.length != 0
                  ? ListView.builder(
                      itemCount: _searchResult.length,
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TreatmentSpecialist(
                                        id: _searchResult[index].id,
                                      ),
                                    ),
                                  );
                                },
                                child: ListTile(
                                  title: Row(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 40,
                                        alignment: AlignmentDirectional.center,
                                        child: CachedNetworkImage(
                                          alignment: Alignment.center,
                                          imageUrl: _searchResult[index].fullImage!,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => SpinKitFadingCircle(
                                            color: Palette.blue,
                                          ),
                                          errorWidget: (context, url, error) => Image.asset("assets/images/no_image.jpg"),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(horizontal: width * 0.05),
                                        child: Text(
                                          _searchResult[index].name!,
                                          style: TextStyle(
                                            fontSize: width * 0.045,
                                            color: Palette.dark_grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                              child: Column(
                                children: [
                                  DottedLine(
                                    direction: Axis.horizontal,
                                    lineLength: double.infinity,
                                    lineThickness: 1.0,
                                    dashLength: 2.0,
                                    dashColor: Palette.blue,
                                    dashRadius: 1.0,
                                    dashGapLength: 3.0,
                                    dashGapColor: Palette.transparent,
                                    dashGapRadius: 0.0,
                                  )
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  : Container(
                      alignment: AlignmentDirectional.center,
                      child: Text(
                        getTranslated(context, AppString.treatment_notFound).toString(),
                        style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                      ),
                    )
              : treatmentList.length != 0
                  ? ListView.builder(
                      itemCount: treatmentList.length,
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: GestureDetector(
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
                                child: ListTile(
                                  title: Row(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 40,
                                        alignment: AlignmentDirectional.center,
                                        child: CachedNetworkImage(
                                          alignment: Alignment.center,
                                          imageUrl: treatmentList[index].fullImage!,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => SpinKitFadingCircle(
                                            color: Palette.blue,
                                          ),
                                          errorWidget: (context, url, error) => Image.asset("assets/images/no_image.jpg"),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(horizontal: width * 0.05),
                                        child: Text(
                                          treatmentList[index].name!,
                                          style: TextStyle(
                                            fontSize: width * 0.045,
                                            color: Palette.dark_grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                              child: Column(
                                children: [
                                  DottedLine(
                                    direction: Axis.horizontal,
                                    lineLength: double.infinity,
                                    lineThickness: 1.0,
                                    dashLength: 2.0,
                                    dashColor: Palette.blue,
                                    dashRadius: 1.0,
                                    dashGapLength: 3.0,
                                    dashGapColor: Palette.transparent,
                                    dashGapRadius: 0.0,
                                  )
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  : Container(
                      alignment: AlignmentDirectional.center,
                      child: Text(
                        getTranslated(context, AppString.treatment_notFound).toString(),
                        style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
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

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    treatmentList.forEach((appointmentData) {
      if (appointmentData.name!.toLowerCase().contains(text.toLowerCase())) _searchResult.add(appointmentData);
    });

    setState(() {});
  }
}
