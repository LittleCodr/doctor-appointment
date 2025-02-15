class AppointmentDetails {
  bool? success;
  Data? data;
  String? msg;

  AppointmentDetails({this.success, this.data, this.msg});

  AppointmentDetails.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['msg'] = this.msg;
    return data;
  }
}

class Data {
  int? id;
  String? appointmentId;
  int? userId;
  int? doctorId;
  String? amount;
  String? paymentType;
  String? appointmentFor;
  String? patientName;
  int? age;
  List<String>? reportImage;
  String? drugEffect;
  String? patientAddress;
  String? phoneNo;
  String? date;
  String? time;
  int? paymentStatus;
  String? appointmentStatus;
  String? illnessInformation;
  String? note;
  String? pdf;
  int? rate;
  int? review;
  User? user;
  int? isInsured;
  String? policyInsurerName;
  String? policyNumber;

  Data(
      {this.id,
      this.appointmentId,
      this.userId,
      this.doctorId,
      this.amount,
      this.paymentType,
      this.appointmentFor,
      this.patientName,
      this.age,
      this.reportImage,
      this.drugEffect,
      this.patientAddress,
      this.phoneNo,
      this.date,
      this.time,
      this.paymentStatus,
      this.appointmentStatus,
      this.illnessInformation,
      this.note,
      this.pdf,
      this.rate,
      this.review,
    this.user,
    this.isInsured,
    this.policyInsurerName,
    this.policyNumber,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    appointmentId = json['appointment_id'];
    userId = json['user_id'];
    doctorId = json['doctor_id'];
    amount = json['amount'];
    paymentType = json['payment_type'];
    appointmentFor = json['appointment_for'];
    patientName = json['patient_name'];
    age = json['age'];
    reportImage = json['report_image'].cast<String>();
    drugEffect = json['drug_effect'];
    patientAddress = json['patient_address'];
    phoneNo = json['phone_no'];
    date = json['date'];
    time = json['time'];
    paymentStatus = json['payment_status'];
    appointmentStatus = json['appointment_status'];
    illnessInformation = json['illness_information'];
    note = json['note'];
    pdf = json['pdf'];
    rate = json['rate'];
    review = json['review'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    isInsured = json['is_insured'];
    policyInsurerName = json['policy_insurer_name'];
    policyNumber = json['policy_number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['appointment_id'] = this.appointmentId;
    data['user_id'] = this.userId;
    data['doctor_id'] = this.doctorId;
    data['amount'] = this.amount;
    data['payment_type'] = this.paymentType;
    data['appointment_for'] = this.appointmentFor;
    data['patient_name'] = this.patientName;
    data['age'] = this.age;
    data['report_image'] = this.reportImage;
    data['drug_effect'] = this.drugEffect;
    data['patient_address'] = this.patientAddress;
    data['phone_no'] = this.phoneNo;
    data['date'] = this.date;
    data['time'] = this.time;
    data['payment_status'] = this.paymentStatus;
    data['appointment_status'] = this.appointmentStatus;
    data['illness_information'] = this.illnessInformation;
    data['note'] = this.note;
    data['pdf'] = this.pdf;
    data['rate'] = this.rate;
    data['review'] = this.review;
    data['is_insured'] = this.isInsured;
    data['policy_insurer_name'] = this.policyInsurerName;
    data['policy_number'] = this.policyNumber;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}

class User {
  int? id;
  String? image;
  String? fullImage;

  User({this.id, this.image, this.fullImage});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    fullImage = json['fullImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['image'] = this.image;
    data['fullImage'] = this.fullImage;
    return data;
  }
}
