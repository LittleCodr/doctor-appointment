class PrescriptionModel {
  bool? success;
  Data? data;
  String? msg;

  PrescriptionModel({this.success, this.data, this.msg});

  PrescriptionModel.fromJson(Map<String, dynamic> json) {
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
  dynamic doctor;
  Prescription? prescription;
  int? rate;
  int? review;

  Data({this.id, this.doctor, this.prescription, this.rate, this.review});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    doctor = json['doctor'];
    prescription = json['prescription'] != null ? new Prescription.fromJson(json['prescription']) : null;
    rate = json['rate'];
    review = json['review'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['doctor'] = this.doctor;
    if (this.prescription != null) {
      data['prescription'] = this.prescription!.toJson();
    }
    data['rate'] = this.rate;
    data['review'] = this.review;
    return data;
  }
}

class Prescription {
  int? id;
  int? appointmentId;
  int? doctorId;
  int? userId;
  String? medicines;
  String? pdf;
  String? createdAt;
  String? updatedAt;
  String? pdfPath;

  Prescription({this.id, this.appointmentId, this.doctorId, this.userId, this.medicines, this.pdf, this.createdAt, this.updatedAt, this.pdfPath});

  Prescription.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    appointmentId = json['appointment_id'];
    doctorId = json['doctor_id'];
    userId = json['user_id'];
    medicines = json['medicines'];
    pdf = json['pdf'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    pdfPath = json['pdfPath'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['appointment_id'] = this.appointmentId;
    data['doctor_id'] = this.doctorId;
    data['user_id'] = this.userId;
    data['medicines'] = this.medicines;
    data['pdf'] = this.pdf;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['pdfPath'] = this.pdfPath;
    return data;
  }
}
