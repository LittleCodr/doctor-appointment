import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctro_patient/Screen/MedicineAndPharmacy/PharamacyDetail.dart';
import 'package:doctro_patient/api/retrofit_Api.dart';
import 'package:doctro_patient/api/network_api.dart';
import 'package:doctro_patient/const/app_string.dart';
import 'package:doctro_patient/model/pharmacys_model.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/base_model.dart';
import '../../api/server_error.dart';
import '../../const/Palette.dart';
import '../../localization/localization_constant.dart';

class AllPharamacy extends StatefulWidget {
  @override
  _AllPharamacyState createState() => _AllPharamacyState();
}

class _AllPharamacyState extends State<AllPharamacy> {
  bool loading = false;
  String? address = "";

  List<Data> pharamacy = [];

  TextEditingController _search = TextEditingController();
  List<Data> _searchResult = [];

  @override
  void initState() {
    super.initState();
    _getAddress();
    callApiPharamacy();
  }

  _getAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(
      () {
        address = (prefs.getString('Address'));
      },
    );
  }

  Future<bool> onWillPop() {
    Navigator.pushReplacementNamed(context, 'Home');
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
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
                      address == null || address == ""
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
                                      text: '$address',
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
                        textAlign: TextAlign.left,
                        textCapitalization: TextCapitalization.words,
                        textAlignVertical: TextAlignVertical.center,
                        onChanged: onSearchTextChanged,
                        decoration: InputDecoration(
                          hintText: getTranslated(context, AppString.allPharamacy_searchPharamacy).toString(),
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
        body: ModalProgressHUD(
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
            child: _searchResult.length > 0 || _search.text.isNotEmpty
                ? _searchResult.length != 0
                    ? SingleChildScrollView(
                        child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _searchResult.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 17),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        height: 100,
                                        width: 100,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(5),
                                          ),
                                          child: CachedNetworkImage(
                                            alignment: Alignment.center,
                                            height: 100,
                                            width: 100,
                                            fit: BoxFit.cover,
                                            imageUrl: _searchResult[index].fullImage!,
                                            placeholder: (context, url) => SpinKitFadingCircle(
                                              color: Palette.blue,
                                            ),
                                            errorWidget: (context, url, error) => ClipRRect(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(5),
                                              ),
                                              child: Image.asset(
                                                "assets/images/no_image.jpg",
                                                height: 100,
                                                width: 100,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: 15,
                                                ),
                                                Text(
                                                  _searchResult[index].name!,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: width * 0.04,
                                                    fontWeight: FontWeight.bold,
                                                    color: Palette.dark_blue,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.location_on,
                                                  size: 15,
                                                  color: Palette.dark_grey1,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    _searchResult[index].address!,
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                    style: TextStyle(
                                                      fontSize: width * 0.035,
                                                      fontWeight: FontWeight.bold,
                                                      color: Palette.dark_grey1,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              children: [
                                                Spacer(),
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => PharamacyDetail(id: _searchResult[index].id),
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Palette.blue,
                                                      borderRadius: BorderRadius.all(
                                                        Radius.circular(5),
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                                      child: Text(
                                                        getTranslated(context, AppString.allPharamacy_book_button).toString(),
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.bold,
                                                          color: Palette.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    child: DottedLine(
                                      direction: Axis.horizontal,
                                      lineLength: double.infinity,
                                      lineThickness: 1.0,
                                      dashLength: 4.0,
                                      dashColor: Palette.blue,
                                      dashRadius: 0.0,
                                      dashGapLength: 4.0,
                                      dashGapColor: Palette.transparent,
                                      dashGapRadius: 0.0,
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    : Container(
                        alignment: AlignmentDirectional.center,
                        child: Text(
                          getTranslated(context, AppString.allPharamacy_pharmacyNotFound).toString(),
                          style: TextStyle(fontSize: width * 0.04, color: Palette.grey, fontWeight: FontWeight.bold),
                        ),
                      )
                : pharamacy.length != 0
                    ? SingleChildScrollView(
                        child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: pharamacy.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 17),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        height: 100,
                                        width: 100,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(5),
                                          ),
                                          child: CachedNetworkImage(
                                            alignment: Alignment.center,
                                            height: 100,
                                            width: 100,
                                            fit: BoxFit.cover,
                                            imageUrl: pharamacy[index].fullImage!,
                                            placeholder: (context, url) => SpinKitFadingCircle(
                                              color: Palette.blue,
                                            ),
                                            errorWidget: (context, url, error) => ClipRRect(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(5),
                                              ),
                                              child: Image.asset(
                                                "assets/images/no_image.jpg",
                                                height: 100,
                                                width: 100,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: 15,
                                                ),
                                                Text(
                                                  pharamacy[index].name!,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: width * 0.04,
                                                    fontWeight: FontWeight.bold,
                                                    color: Palette.dark_blue,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.location_on,
                                                  size: 15,
                                                  color: Palette.dark_grey1,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    pharamacy[index].address!,
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                    style: TextStyle(
                                                      fontSize: width * 0.035,
                                                      fontWeight: FontWeight.bold,
                                                      color: Palette.dark_grey1,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              children: [
                                                Spacer(),
                                                GestureDetector(
                                                  onTap: () {
                                                    print("Pharamacy Id:" + pharamacy[index].id.toString());
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => PharamacyDetail(id: pharamacy[index].id),
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Palette.blue,
                                                      borderRadius: BorderRadius.all(
                                                        Radius.circular(5),
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                                      child: Text(
                                                        getTranslated(context, AppString.allPharamacy_book_button).toString(),
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.bold,
                                                          color: Palette.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    child: DottedLine(
                                      direction: Axis.horizontal,
                                      lineLength: double.infinity,
                                      lineThickness: 1.0,
                                      dashLength: 4.0,
                                      dashColor: Palette.blue,
                                      dashRadius: 0.0,
                                      dashGapLength: 4.0,
                                      dashGapColor: Palette.transparent,
                                      dashGapRadius: 0.0,
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    : Container(
                        alignment: Alignment.center,
                        child: Text(
                          getTranslated(context, AppString.allPharamacy_pharmacyNotFound).toString(),
                          style: TextStyle(fontSize: width * 0.04, color: Palette.grey, fontWeight: FontWeight.bold),
                        ),
                      ),
          ),
        ),
      ),
    );
  }

  Future<BaseModel<pharmacyModel>> callApiPharamacy() async {
    pharmacyModel response;

    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi2().dioData2()).pharmacyRequest();
      setState(() {
        if (response.success == true) {
          loading = false;
          pharamacy.addAll(response.data!);
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

    pharamacy.forEach((appointmentData) {
      if (appointmentData.name!.toLowerCase().contains(text.toLowerCase())) _searchResult.add(appointmentData);
    });

    setState(() {});
  }
}
