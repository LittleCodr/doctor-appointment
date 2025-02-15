import 'package:doctro_patient/api/retrofit_Api.dart';
import 'package:doctro_patient/api/network_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../MedicineAndPharmacy/MyPrescription.dart';
import '../../api/base_model.dart';
import '../../api/server_error.dart';
import '../../const/Palette.dart';
import '../../const/app_string.dart';
import '../../localization/localization_constant.dart';
import '../../model/review_model.dart';

class Review extends StatefulWidget {
  final String? doctorImage;
  final String? doctorName;
  final String? doctorTreatmentName;
  final String? doctorAddress;
  final String? appointmentTime;
  final String? appointmentDate;
  final String? patientName;
  final int? appointmentId;
  final int? appointmentIdPrescription;

  Review({
    this.doctorImage,
    this.doctorName,
    this.doctorTreatmentName,
    this.doctorAddress,
    this.appointmentTime,
    this.appointmentDate,
    this.patientName,
    this.appointmentId,
    this.appointmentIdPrescription,
  });

  @override
  _ReviewState createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController userReview = TextEditingController();
  int? _userRating;

  @override
  Widget build(BuildContext context) {
    double width;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
          getTranslated(context, AppString.reviewAppointment_title).toString(),
          style: TextStyle(fontSize: 18, color: Palette.dark_blue, fontWeight: FontWeight.bold),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: width,
                      color: Palette.dark_white,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        child: Text(
                          getTranslated(context, AppString.reviewAppointment_review_title).toString(),
                          style: TextStyle(fontSize: width * 0.04, color: Palette.blue, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child: Card(
                        color: Palette.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Container(
                          // height: height * 0.4,
                          width: width * 1,
                          child: Column(
                            children: <Widget>[
                              ListTile(
                                title: TextFormField(
                                  keyboardType: TextInputType.multiline,
                                  controller: userReview,
                                  //Normal textInputField will be displayed
                                  maxLines: 6,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: getTranslated(context, AppString.reviewAppointment_review_hint).toString(),
                                    // 'your review helps patient make better choices',
                                    hintStyle: TextStyle(fontSize: width * 0.035, color: Palette.grey),
                                  ),
                                  validator: (String? value) {
                                    if (value!.isEmpty) {
                                      return getTranslated(context, AppString.reviewAppointment_review_validator).toString();
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: width,
                color: Palette.dark_white,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Text(
                    getTranslated(context, AppString.reviewAppointment_rate_title).toString(),
                    style: TextStyle(fontSize: width * 0.04, color: Palette.blue, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Container(
                width: width,
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  children: [
                    RatingBar.builder(
                      initialRating: 0,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 5.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Palette.blue,
                      ),
                      onRatingUpdate: (rating) {
                        setState(
                          () {
                            _userRating = rating.toInt();
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: width * 0.12,
        child: ElevatedButton(
          child: Text(
            getTranslated(context, AppString.reviewAppointment_submit_button).toString(),
            style: TextStyle(
              color: Palette.white
            ),
          ),
          onPressed: () {
            setState(
              () {
                if (_formKey.currentState!.validate()) {
                  _userRating != null
                      ? callApiReview()
                      : Fluttertoast.showToast(
                          msg: getTranslated(context, AppString.reviewAppointment_giveRate_toast).toString(),
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                        );
                } else {
                  print('Not add Review');
                }
              },
            );
          },
        ),
      ),
    );
  }

  Future<BaseModel<ReviewAppointment>> callApiReview() async {
    ReviewAppointment response;

    Map<String, dynamic> body = {
      "review": userReview.text.toString(),
      "rate": _userRating.toString(),
      "appointment_id": widget.appointmentId.toString(),
    };
    try {
      response = await RestClient(RetroApi().dioData()).addReviewRequest(body);
      if (response.success == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MyPrescription(
              doctorImage: widget.doctorImage,
              appointmentId: widget.appointmentId,
              doctorName: widget.doctorName,
              doctorTreatmentName: widget.doctorTreatmentName,
              doctorAddress: widget.doctorAddress,
              appointmentDate: widget.appointmentDate,
              appointmentTime: widget.appointmentTime,
              patientName: widget.patientName,
              appointmentIdPrescription: widget.appointmentIdPrescription,
              userRating: _userRating,
            ),
          ),
        );
        Fluttertoast.showToast(
          msg: '${response.data}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
