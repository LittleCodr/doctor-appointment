class Login {
  bool? success;
  Data? data;
  String? msg;
  String? message;

  Login({this.success, this.data, this.msg, this.message});

  Login.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    msg = json['msg'];
    message = json['message'];
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
  String? name;
  String? email;
  String? emailVerifiedAt;
  String? phone;
  String? phoneCode;
  int? verify;
  int? otp;
  String? dob;
  String? gender;
  String? image;
  int? status;
  int? doctorId;
  String? deviceToken;
  String? createdAt;
  String? updatedAt;
  String? token;
  String? fullImage;
  List<String>? roles;

  Data(
      {this.id,
      this.name,
      this.email,
      this.emailVerifiedAt,
      this.phone,
      this.phoneCode,
      this.verify,
      this.otp,
      this.dob,
      this.gender,
      this.image,
      this.status,
      this.doctorId,
      this.deviceToken,
      this.createdAt,
      this.updatedAt,
      this.token,
      this.fullImage,
      this.roles});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    emailVerifiedAt = json['email_verified_at'].toString();
    phone = json['phone'];
    phoneCode = json['phone_code'];
    verify = json['verify'];
    otp = json['otp'];
    dob = json['dob'];
    gender = json['gender'];
    image = json['image'];
    status = json['status'];
    doctorId = json['doctor_id'];
    deviceToken = json['device_token'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    token = json['token'];
    fullImage = json['fullImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['email_verified_at'] = this.emailVerifiedAt;
    data['phone'] = this.phone;
    data['phone_code'] = this.phoneCode;
    data['verify'] = this.verify;
    data['otp'] = this.otp;
    data['dob'] = this.dob;
    data['gender'] = this.gender;
    data['image'] = this.image;
    data['status'] = this.status;
    data['doctor_id'] = this.doctorId;
    data['device_token'] = this.deviceToken;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['token'] = this.token;
    data['fullImage'] = this.fullImage;
    return data;
  }
}
