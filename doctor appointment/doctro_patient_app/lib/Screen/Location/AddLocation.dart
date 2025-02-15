import 'dart:async';
import 'package:doctro_patient/Screen/Location/ShowLocation.dart';
import 'package:doctro_patient/api/retrofit_Api.dart';
import 'package:doctro_patient/api/network_api.dart';
import 'package:doctro_patient/const/prefConstatnt.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../../api/base_model.dart';
import '../../api/server_error.dart';
import '../../const/Palette.dart';
import '../../const/app_string.dart';
import '../../localization/localization_constant.dart';
import '../../model/common_response.dart';

class AddLocation extends StatefulWidget {
  final double? currentLat;
  final double? currentLong;

  AddLocation({
    this.currentLat,
    this.currentLong,
  });

  @override
  _AddLocationState createState() => _AddLocationState();
}

class _AddLocationState extends State<AddLocation> {
  bool loading = false;

  BitmapDescriptor? sourceIcon;
  BitmapDescriptor? destinationIcon;

  String address = "";
  double selectLat = 0.0;
  double selectLang = 0.0;

  double? liveLat = 0.0;
  double? liveLang = 0.0;

  LatLng? _initialCameraPosition;
  GoogleMapController? _controller;
  BitmapDescriptor _markerIcon = BitmapDescriptor.defaultMarker;

  TextEditingController _textFullAddress = new TextEditingController();
  TextEditingController _textAddressLabel = new TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  @override
  void initState() {
    super.initState();
    _initialCameraPosition = LatLng(widget.currentLat!, widget.currentLong!);
    _determinePosition();
  }

  void _onMapCreated(GoogleMapController _cnTlr) {
    _controller = _cnTlr;
  }

  Set<Marker> _createMarker() {
    return <Marker>{
      Marker(
        markerId: MarkerId("marker_1"),
        position: _initialCameraPosition!,
        icon: _markerIcon,
      ),
    };
  }

  Future<bool> onWillPop() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ShowLocation(),
      ),
    );
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: ModalProgressHUD(
            inAsyncCall: loading,
            opacity: 0.5,
            progressIndicator: SpinKitFadingCircle(
              color: Palette.blue,
              size: 50.0,
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 5,
                  child: Stack(
                    children: [
                      GoogleMap(
                        myLocationEnabled: false,
                        markers: _createMarker(),
                        mapType: MapType.normal,
                        initialCameraPosition: CameraPosition(target: _initialCameraPosition!, zoom: 13),
                        onMapCreated: _onMapCreated,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ShowLocation(),
                              ),
                            );
                          },
                          child: Icon(
                            Icons.arrow_back_ios,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Scaffold(
                    resizeToAvoidBottomInset: false,
                    body: GestureDetector(
                      onTap: () {
                        FocusScope.of(context).requestFocus(new FocusNode());
                      },
                      child: Form(
                        key: formKey,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    Prediction? p = await PlacesAutocomplete.show(
                                      context: context,
                                      mode: Mode.overlay,
                                      apiKey: Preferences.map_key,
                                      offset: 0,
                                      radius: 1000,
                                      types: [],
                                      strictbounds: false,
                                      components: [],
                                    );
                                    displayPrediction(p);
                                    setState(
                                      () {
                                        address = '${p!.description}';
                                        _textFullAddress.text = address;
                                      },
                                    );
                                  },
                                  child: Container(
                                    alignment: AlignmentDirectional.centerStart,
                                    height: 40,
                                    decoration: BoxDecoration(color: Palette.dark_white, borderRadius: BorderRadius.circular(10)),
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          WidgetSpan(
                                            child: Padding(
                                              padding: EdgeInsets.only(right: 10, left: 10),
                                              child: SvgPicture.asset(
                                                'assets/icons/Map_Search.svg',
                                                width: 15,
                                                height: 15,
                                              ),
                                            ),
                                          ),
                                          address == "null" || address == ""
                                              ? TextSpan(
                                                  text: getTranslated(context, AppString.addLocation_searchLocation).toString(),
                                                  // 'Search Location',
                                                  style: TextStyle(color: Palette.blue, fontWeight: FontWeight.bold, fontSize: 14),
                                                )
                                              : TextSpan(
                                                  text: '$address',
                                                  style: TextStyle(color: Palette.dark_grey, fontWeight: FontWeight.bold, fontSize: 16),
                                                )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: Text(
                                    getTranslated(context, AppString.addLocation_attachLabel).toString(),
                                    // 'Attach Label',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Container(
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 2),
                                        child: TextFormField(
                                          controller: _textAddressLabel,
                                          textCapitalization: TextCapitalization.words,
                                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]'))],
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.only(left: 10),
                                            hintText: getTranslated(context, AppString.addLocation_attachLabel_hint).toString(),
                                            hintStyle: TextStyle(
                                              fontSize: 16,
                                              color: Palette.dark_grey,
                                            ),
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                            ),
                                            filled: true,
                                            fillColor: Palette.white,
                                          ),
                                          validator: (String? value) {
                                            if (value!.isEmpty) {
                                              return getTranslated(context, AppString.addLocation_attachLabel_validator).toString();
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Text(
                                    getTranslated(context, AppString.addLocation_address).toString(),
                                    // 'House No./Flat No./Floor/Building',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Container(
                                    height: 100,
                                    child: Card(
                                      elevation: 3,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextFormField(
                                          controller: _textFullAddress,
                                          keyboardType: TextInputType.text,
                                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9,]'))],
                                          decoration: InputDecoration(contentPadding: EdgeInsets.only(left: 10), hintText: getTranslated(context, AppString.addLocation_address_hint).toString(), border: InputBorder.none),
                                          maxLines: 3,
                                          style: TextStyle(fontSize: 16, color: Palette.dark_grey),
                                          validator: (String? value) {
                                            if (value!.isEmpty) {
                                              return getTranslated(context, AppString.addLocation_address_validator).toString();
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 20),
                                  child: Container(
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (formKey.currentState!.validate()) {
                                          if (selectLat != 0.0 && selectLang != 0.0) {
                                            callApiAddAddress();
                                          } else {
                                            Fluttertoast.showToast(
                                              msg: "Please Search Address & Select",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              backgroundColor: Palette.blue,
                                              textColor: Palette.white,
                                            );
                                          }
                                        }
                                      },
                                      style: ButtonStyle(
                                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15.0),
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        getTranslated(context, AppString.addLocation_addAddress_button).toString(),
                                        // 'Add Address'
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<Null> displayPrediction(Prediction? p) async {
    if (p != null) {
      GoogleMapsPlaces _places = GoogleMapsPlaces(
        apiKey: Preferences.map_key,
        apiHeaders: await GoogleApiHeaders().getHeaders(),
      );

      PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId!);

      double lat = detail.result.geometry!.location.lat;
      double lng = detail.result.geometry!.location.lng;

      selectLang = double.parse('$lng');
      selectLat = double.parse('$lat');

      setState(() {
        _controller!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: LatLng(selectLat, selectLang), zoom: 18),
          ),
        );
        _initialCameraPosition = LatLng(selectLat, selectLang);
        _createMarker();
      });
    }
  }

  Future<BaseModel<CommonResponse>> callApiAddAddress() async {
    CommonResponse response;
    Map<String, dynamic> body = {
      "address": _textFullAddress.text,
      "label": _textAddressLabel.text,
      "lat": '$selectLat',
      "lang": '$selectLang',
    };
    try {
      response = await RestClient(RetroApi().dioData()).addAddressRequest(body);
      if (response.success == true) {
        setState(
          () {
            Fluttertoast.showToast(
              msg: getTranslated(context, AppString.addLocation_successFullyAddAddress_toast).toString(),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Palette.blue,
              textColor: Palette.white,
            );
            Navigator.pushReplacementNamed(context, "ShowLocation");
          },
        );
      }
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
