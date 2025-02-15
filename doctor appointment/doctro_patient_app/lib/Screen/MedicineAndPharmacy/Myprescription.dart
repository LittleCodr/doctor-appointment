import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctro_patient/api/retrofit_Api.dart';
import 'package:doctro_patient/api/network_api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../AppointmentRelatedScreen/Review_Appointment.dart';
import '../../api/base_model.dart';
import '../../api/server_error.dart';
import '../../const/Palette.dart';
import '../../const/app_string.dart';
import '../../localization/localization_constant.dart';
import '../../model/prescription_model.dart';

class MyPrescription extends StatefulWidget {
  final String? doctorImage;
  final String? doctorName;
  final String? doctorTreatmentName;
  final String? doctorAddress;
  final String? appointmentTime;
  final String? appointmentDate;
  final String? patientName;
  final int? appointmentIdPrescription;
  final int? appointmentId;
  final int? userRating;

  MyPrescription({
    this.doctorImage,
    this.doctorName,
    this.doctorTreatmentName,
    this.doctorAddress,
    this.appointmentTime,
    this.appointmentDate,
    this.patientName,
    this.appointmentIdPrescription,
    this.appointmentId,
    this.userRating,
  });

  @override
  _MyPrescriptionState createState() => _MyPrescriptionState();
}

class _MyPrescriptionState extends State<MyPrescription> {
  bool _loading = false;

  List<String?> medicine = [];
  List<String?> days = [];
  List<int?> morning = [];
  List<int?> afternoon = [];
  List<int?> night = [];

  String? pdfPath = "";

  late var str;
  var parts;
  var startPart;
  var lastPart;

  @override
  void initState() {
    super.initState();
    if (widget.appointmentIdPrescription != 0) {
      callApiPrescription();
    }
  }

  @override
  Widget build(BuildContext context) {
    double width;
    double height;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return ModalProgressHUD(
      inAsyncCall: _loading,
      opacity: 0.5,
      progressIndicator: SpinKitFadingCircle(
        color: Palette.blue,
        size: 50.0,
      ),
      child: Scaffold(
        appBar: AppBar(
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
            getTranslated(context, AppString.myPrescription_title).toString(),
            style: TextStyle(fontSize: 18, color: Palette.dark_blue, fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: height * 0.04, left: width * 0.04, right: width * 0.04),
                  child: Column(
                    children: [
                      Text(
                        getTranslated(context, AppString.myPrescription_completeAppointment).toString(),
                        style: TextStyle(
                          fontSize: width * 0.04,
                          color: Palette.dark_blue,
                        ),
                      )
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: height * 0.02, left: width * 0.028, right: width * 0.028),
                      width: width * 1,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 5,
                        color: Palette.white,
                        child: Column(
                          children: [
                            Container(
                              child: Row(
                                children: [
                                  Container(
                                    width: width * 0.15,
                                    alignment: AlignmentDirectional.center,
                                    margin: EdgeInsets.only(left: width * 0.01, top: width * 0.02, right: width * 0.01),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: width * 0.11,
                                          height: height * 0.055,
                                          child: CachedNetworkImage(
                                            alignment: Alignment.center,
                                            imageUrl: widget.doctorImage!,
                                            imageBuilder: (context, imageProvider) => CircleAvatar(
                                              radius: 50,
                                              backgroundColor: Palette.white,
                                              child: CircleAvatar(
                                                radius: 60,
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
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              alignment: AlignmentDirectional.topStart,
                                              margin: EdgeInsets.only(left: width * 0.02, top: width * 0.02, right: width * 0.02),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    widget.doctorName!,
                                                    style: TextStyle(
                                                      fontSize: width * 0.04,
                                                      color: Palette.dark_blue,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          alignment: AlignmentDirectional.topStart,
                                          margin: EdgeInsets.only(left: width * 0.02, top: width * 0.01, right: width * 0.02),
                                          child: Column(
                                            children: [
                                              Text(
                                                widget.doctorTreatmentName!,
                                                style: TextStyle(fontSize: width * 0.028, color: Palette.grey),
                                              )
                                            ],
                                          ),
                                        ),
                                        Container(
                                          alignment: AlignmentDirectional.topStart,
                                          margin: EdgeInsets.only(left: width * 0.02, top: width * 0.01, right: width * 0.02),
                                          child: Column(
                                            children: [
                                              Text(
                                                widget.doctorAddress! + '     ',
                                                style: TextStyle(
                                                  fontSize: width * 0.03,
                                                  color: Palette.grey,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: height * 0.014),
                              child: Column(
                                children: [
                                  Divider(
                                    height: height * 0.002,
                                    color: Palette.dark_grey,
                                    thickness: width * 0.001,
                                  )
                                ],
                              ),
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(top: height * 0.025),
                                        alignment: Alignment.topLeft,
                                        child: Row(
                                          children: [
                                            Text(
                                              getTranslated(context, AppString.myPrescription_dateTime).toString(),
                                              style: TextStyle(fontSize: width * 0.028, color: Palette.grey),
                                              textAlign: TextAlign.left,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        child: Row(
                                          children: [
                                            Text(
                                              widget.appointmentDate! + "  " + widget.appointmentTime!,
                                              style: TextStyle(fontSize: width * 0.03, color: Palette.dark_blue),
                                              textAlign: TextAlign.left,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(top: height * 0.025),
                                        child: Row(
                                          children: [
                                            Text(
                                              getTranslated(context, AppString.myPrescription_patientName).toString(),
                                              style: TextStyle(fontSize: width * 0.028, color: Palette.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        child: Row(
                                          children: [
                                            Text(
                                              widget.patientName!.toUpperCase(),
                                              style: TextStyle(fontSize: width * 0.03, color: Palette.dark_blue),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: height * 0.025),
                              child: Column(
                                children: [
                                  Divider(
                                    height: height * 0.002,
                                    color: Palette.dark_grey,
                                    thickness: width * 0.001,
                                  )
                                ],
                              ),
                            ),
                            widget.appointmentIdPrescription != 0
                                ? Column(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(top: height * 0.014),
                                        child: Column(
                                          children: [
                                            Text(
                                              getTranslated(context, AppString.myPrescription_patientPrescription).toString(),
                                              style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: height * 0.014),
                                        child: Column(
                                          children: [
                                            Text(
                                              '( ' + getTranslated(context, AppString.myPrescription_medicineAfterMeal).toString() + ' )',
                                              style: TextStyle(fontSize: width * 0.03, color: Palette.red),
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: height * 0.01),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  height: 14,
                                                  width: 14,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(width: 1),
                                                  ),
                                                  child: Icon(Icons.check, size: 12),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 5),
                                                  child: Text(getTranslated(context, AppString.myPrescription_takeMedicine)!),
                                                )
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Container(
                                                  height: 14,
                                                  width: 14,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(width: 1),
                                                  ),
                                                  child: Icon(
                                                    Icons.clear_rounded,
                                                    size: 12,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 5),
                                                  child: Text(getTranslated(context, AppString.myPrescription_notTakeMedicine)!),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        child: ListView.builder(
                                            itemCount: medicine.length,
                                            scrollDirection: Axis.vertical,
                                            shrinkWrap: true,
                                            itemBuilder: (context, index) {
                                              return Container(
                                                margin: EdgeInsets.only(top: height * 0.025),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Container(
                                                      margin: EdgeInsets.only(left: width * 0.05, right: width * 0.05),
                                                      child: Text(
                                                        medicine[index]!,
                                                        style: TextStyle(fontSize: width * 0.03, color: Palette.dark_blue),
                                                      ),
                                                    ),
                                                    Container(
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Container(
                                                            width: width * 0.2,
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                              children: [
                                                                morning[index] == 1
                                                                    ? Container(
                                                                        child: Row(
                                                                          children: [
                                                                            Container(
                                                                                height: 14,
                                                                                width: 14,
                                                                                decoration: BoxDecoration(
                                                                                  border: Border.all(width: 1),
                                                                                ),
                                                                                child: Icon(Icons.check, size: 12)),
                                                                          ],
                                                                        ),
                                                                      )
                                                                    : Container(
                                                                        child: Row(
                                                                          children: [
                                                                            Container(
                                                                                height: 14,
                                                                                width: 14,
                                                                                decoration: BoxDecoration(
                                                                                  border: Border.all(width: 1),
                                                                                ),
                                                                                child: Icon(Icons.clear_rounded, size: 12)),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                afternoon[index] == 1
                                                                    ? Container(
                                                                        child: Row(
                                                                          children: [
                                                                            Container(
                                                                                height: 14,
                                                                                width: 14,
                                                                                decoration: BoxDecoration(
                                                                                  border: Border.all(width: 1),
                                                                                ),
                                                                                child: Icon(Icons.check, size: 12)),
                                                                          ],
                                                                        ),
                                                                      )
                                                                    : Container(
                                                                        child: Row(
                                                                          children: [
                                                                            Container(
                                                                                height: 14,
                                                                                width: 14,
                                                                                decoration: BoxDecoration(
                                                                                  border: Border.all(width: 1),
                                                                                ),
                                                                                child: Icon(Icons.clear_rounded, size: 12)),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                night[index] == 1
                                                                    ? Container(
                                                                        child: Row(
                                                                          children: [
                                                                            Container(
                                                                                height: 14,
                                                                                width: 14,
                                                                                decoration: BoxDecoration(
                                                                                  border: Border.all(width: 1),
                                                                                ),
                                                                                child: Icon(Icons.check, size: 12)),
                                                                          ],
                                                                        ),
                                                                      )
                                                                    : Container(
                                                                        child: Row(
                                                                          children: [
                                                                            Container(
                                                                                height: 14,
                                                                                width: 14,
                                                                                decoration: BoxDecoration(
                                                                                  border: Border.all(width: 1),
                                                                                ),
                                                                                child: Icon(Icons.clear_rounded, size: 12)),
                                                                          ],
                                                                        ),
                                                                      ),
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            margin: EdgeInsets.only(right: width * 0.05, left: width * 0.05),
                                                            child: Row(
                                                              children: [
                                                                Text(
                                                                  days[index]! + getTranslated(context, AppString.myPrescription_days).toString(),
                                                                  style: TextStyle(
                                                                    fontSize: width * 0.03,
                                                                    color: Palette.grey,
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              );
                                            }),
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(vertical: height * 0.03),
                                        child: ElevatedButton(
                                          child: Text(
                                            getTranslated(context, AppString.myPrescription_downloadPdf).toString(),
                                            style: TextStyle(
                                              fontSize: width * 0.03,
                                              color: Palette.dark_blue,
                                            ),
                                          ),
                                          onPressed: () async {
                                            if (await Permission.storage.isDenied) {
                                              Permission.storage.request();
                                            }
                                            if (Platform.isAndroid) {
                                              final Directory? appDirectory = await getExternalStorageDirectory();
                                              str = appDirectory!.path;
                                              parts = str.split("/");
                                              startPart = parts[0].trim() + "/" + parts[1].trim() + "/" + parts[2].trim() + "/" + parts[3].trim();
                                              lastPart = parts.sublist(0).join('/').trim();
                                              final String outputDirectory = '$startPart/Download/Doctro';
                                              await Directory(outputDirectory).create(recursive: true);
                                              final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
                                              downloadFile('$pdfPath', 'Doctro$currentTime.pdf', "$outputDirectory").whenComplete(
                                                () => Fluttertoast.showToast(
                                                  msg: getTranslated(context, AppString.myPrescription_downloadComplete_toast).toString(),
                                                  toastLength: Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.BOTTOM,
                                                ),
                                              );
                                            } else if (Platform.isIOS) {
                                              final Directory? appDirectory = await getApplicationDocumentsDirectory();
                                              str = appDirectory!.path;
                                              parts = str.split("/");
                                              startPart = parts[0].trim() + "/" + parts[1].trim() + "/" + parts[2].trim() + "/" + parts[3].trim();
                                              lastPart = parts.sublist(0).join('/').trim();
                                              final String outputDirectory = '$startPart/Download/Doctro';
                                              await Directory(outputDirectory).create(recursive: true);
                                              final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
                                              downloadFile('$pdfPath', 'Doctro$currentTime.pdf', "$outputDirectory").whenComplete(
                                                () => Fluttertoast.showToast(
                                                  msg: getTranslated(context, AppString.myPrescription_downloadComplete_toast).toString(),
                                                  toastLength: Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.BOTTOM,
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                      Text(
                                        getTranslated(context, AppString.myPrescription_note).toString(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: width * 0.03,
                                          fontWeight: FontWeight.bold,
                                          color: Palette.red,
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(
                                    alignment: AlignmentDirectional.center,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(
                                        getTranslated(context, AppString.myPrescription_noPrescription).toString(),
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Palette.dark_blue),
                                      ),
                                    ),
                                  ),
                            Container(
                              margin: EdgeInsets.only(top: height * 0.01),
                              child: Column(
                                children: [
                                  Divider(
                                    height: height * 0.002,
                                    color: Palette.dark_grey,
                                    thickness: width * 0.001,
                                  )
                                ],
                              ),
                            ),
                            widget.userRating == 0
                                ? GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Review(
                                            appointmentId: widget.appointmentId,
                                            doctorImage: widget.doctorImage,
                                            doctorName: widget.doctorName,
                                            doctorTreatmentName: widget.doctorTreatmentName,
                                            doctorAddress: widget.doctorAddress,
                                            appointmentDate: widget.appointmentDate,
                                            appointmentTime: widget.appointmentTime,
                                            patientName: widget.patientName,
                                            appointmentIdPrescription: widget.appointmentIdPrescription,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      height: 65,
                                      width: width * 0.9,
                                      color: Palette.white,
                                      padding: EdgeInsets.symmetric(horizontal: 20),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            getTranslated(context, AppString.myPrescription_reviewAppointment).toString(),
                                            style: TextStyle(
                                              fontSize: width * 0.04,
                                              fontWeight: FontWeight.bold,
                                              color: Palette.blue,
                                            ),
                                          ),
                                          Container(
                                            child: Icon(
                                              Icons.arrow_forward_rounded,
                                              color: Palette.blue,
                                              size: 25,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(
                                    height: 65,
                                    // width: width * 0.9,
                                    padding: EdgeInsets.symmetric(horizontal: 20),
                                    alignment: AlignmentDirectional.center,
                                    decoration: BoxDecoration(
                                        color: Palette.white,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                      )
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          getTranslated(context, AppString.myPrescription_yourRating).toString(),
                                          style: TextStyle(
                                            fontSize: width * 0.04,
                                            fontWeight: FontWeight.bold,
                                            color: Palette.dark_blue,
                                          ),
                                        ),
                                        RatingBar.builder(
                                          ignoreGestures: true,
                                          initialRating: widget.userRating!.toDouble(),
                                          minRating: 0,
                                          direction: Axis.horizontal,
                                          itemSize: 15,
                                          allowHalfRating: false,
                                          itemCount: 5,
                                          itemBuilder: (context, _) => Icon(
                                            Icons.star,
                                            color: Palette.blue,
                                          ),
                                          onRatingUpdate: (double value) {},
                                        ),
                                      ],
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<BaseModel<PrescriptionModel>> callApiPrescription() async {
    PrescriptionModel response;
    setState(() {
      _loading = true;
    });
    try {
      response = await RestClient(RetroApi().dioData()).prescriptionRequest(widget.appointmentIdPrescription);
      if (response.success == true) {
        setState(() {
          _loading = false;
          var convertPrescription = json.decode(response.data!.prescription!.medicines!);
          for (int i = 0; i < convertPrescription.length; i++) {
            medicine.add(convertPrescription[i]['medicine']);
            days.add(convertPrescription[i]['days']);
            morning.add(convertPrescription[i]['morning']);
            afternoon.add(convertPrescription[i]['afternoon']);
            night.add(convertPrescription[i]['night']);
          }
          pdfPath = response.data!.prescription!.pdfPath;
        });
      }
    } catch (error, stacktrace) {
      setState(() {
        _loading = false;
      });
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<String> downloadFile(String url, String fileName, String dir) async {
    HttpClient httpClient = new HttpClient();
    File file;
    String filePath = '';
    String myUrl = '';
    try {
      myUrl = url;
      var request = await httpClient.getUrl(Uri.parse(myUrl));
      var response = await request.close();
      if (response.statusCode == 200) {
        var bytes = await consolidateHttpClientResponseBytes(response);
        filePath = '$dir/$fileName';
        file = File(filePath);
        await file.writeAsBytes(bytes);
      } else
        filePath = 'Error code: ' + response.statusCode.toString();
    } catch (ex) {
      filePath = 'Can not fetch url';
    }
    return filePath;
  }
}
