import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctro_patient/model/show_favorite_doctor_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../../../api/retrofit_Api.dart';
import '../../../api/network_api.dart';
import 'doctorDetail.dart';
import '../../api/base_model.dart';
import '../../api/server_error.dart';
import '../../const/Palette.dart';
import '../../const/app_string.dart';
import '../../localization/localization_constant.dart';
import '../../model/favorite_doctor_model.dart';

class FavoriteDoctorScreen extends StatefulWidget {
  @override
  _FavoriteDoctorScreenState createState() => _FavoriteDoctorScreenState();
}

class _FavoriteDoctorScreenState extends State<FavoriteDoctorScreen> {
  bool loading = false;

  List<Data> favoriteDoctorList = [];
  int? doctorID = 0;

  @override
  void initState() {
    super.initState();
    callApiFavoriteDoctorList();
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
      child: ModalProgressHUD(
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
                Navigator.pushReplacementNamed(context, 'Home');
              },
            ),
            centerTitle: true,
            backgroundColor: Palette.white,
            title: Text(
              getTranslated(context, AppString.favoriteDoctor_title).toString(),
              style: TextStyle(fontSize: 18, color: Palette.dark_blue, fontWeight: FontWeight.bold),
            ),
          ),
          body: favoriteDoctorList.length != 0
              ? SingleChildScrollView(
                  child: InkWell(
                    child: Container(
                      height: height * 0.9,
                      margin: EdgeInsets.only(top: 10),
                      child: ListView(
                        scrollDirection: Axis.vertical,
                        children: [
                          GridView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: favoriteDoctorList.length,
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 0, childAspectRatio: 0.85),
                            itemBuilder: (context, index) {
                              return favoriteDoctorList.length != 0
                                  ? Column(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => DoctorDetail(
                                                  id: favoriteDoctorList[index].id,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            height: width * 0.57,
                                            width: width * 0.45,
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
                                                            borderRadius: BorderRadius.all(
                                                              Radius.circular(10),
                                                            ),
                                                            child: CachedNetworkImage(
                                                              alignment: Alignment.center,
                                                              imageUrl: favoriteDoctorList[index].fullImage!,
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
                                                            child: IconButton(
                                                              onPressed: () {
                                                                setState(
                                                                  () {
                                                                    doctorID = favoriteDoctorList[index].id;
                                                                    setState(() {
                                                                      callApiFavoriteDoctor();
                                                                    });
                                                                  },
                                                                );
                                                              },
                                                              icon: Icon(
                                                                Icons.favorite_outlined,
                                                                size: 25,
                                                                color: Palette.red,
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
                                                            favoriteDoctorList[index].name!,
                                                            style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      child: favoriteDoctorList[index].treatment != null
                                                          ? Text(
                                                              favoriteDoctorList[index].treatment!.name.toString(),
                                                              style: TextStyle(fontSize: width * 0.035, color: Palette.grey),
                                                            )
                                                          : Text(
                                                              getTranslated(context, AppString.favoriteDoctor_notAvailable).toString(),
                                                              style: TextStyle(
                                                                fontSize: width * 0.035,
                                                                color: Palette.grey,
                                                              ),
                                                            ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  : Center(
                                      child: Text(
                                        getTranslated(context, AppString.favoriteDoctor_doctorNotAvailable).toString(),
                                      ),
                                    );
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                )
              : Container(
                  child: Center(
                    child: Text(
                      getTranslated(context, AppString.favoriteDoctor_noFavoriteDoctor).toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Palette.dark_blue,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Future<BaseModel<ShowFavoriteDoctor>> callApiFavoriteDoctorList() async {
    ShowFavoriteDoctor response;
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi().dioData()).showFavoriteDoctorRequest();
      setState(() {
        if (response.success == true) {
          loading = false;
          favoriteDoctorList.clear();
          setState(() {
            favoriteDoctorList.addAll(response.data!);
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
          setState(() {
            callApiFavoriteDoctorList();
            Fluttertoast.showToast(
              msg: '${response.msg}',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Palette.blue,
              textColor: Palette.white,
            );
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
}
