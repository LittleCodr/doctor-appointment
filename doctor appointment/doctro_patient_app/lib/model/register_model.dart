class Register {
  bool? success;
  Data? data;
  String? msg;

  Register({this.success, this.data, this.msg});

  Register.fromJson(Map<String, dynamic> json) {
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
  String? name;
  String? email;
  int? verify;
  String? phone;
  String? phoneCode;
  String? image;
  int? status;
  String? updatedAt;
  String? createdAt;
  int? id;
  int? otp;
  String? fullImage;

  Data({this.name, this.email, this.verify, this.phone, this.phoneCode, this.image, this.status, this.updatedAt, this.createdAt, this.id, this.otp, this.fullImage});

  Data.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    verify = json['verify'];
    phone = json['phone'];
    phoneCode = json['phone_code'];
    image = json['image'];
    status = json['status'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    id = json['id'];
    otp = json['otp'];
    fullImage = json['fullImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['email'] = this.email;
    data['verify'] = this.verify;
    data['phone'] = this.phone;
    data['phone_code'] = this.phoneCode;
    data['image'] = this.image;
    data['status'] = this.status;
    data['updated_at'] = this.updatedAt;
    data['created_at'] = this.createdAt;
    data['id'] = this.id;
    data['otp'] = this.otp;
    data['fullImage'] = this.fullImage;
    return data;
  }
}
