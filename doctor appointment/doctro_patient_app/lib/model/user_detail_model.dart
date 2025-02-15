class UserDetail {
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
  String? fullImage;
  String? channelName;
  String? agoraToken;

  UserDetail({
    this.id,
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
    this.fullImage,
    this.channelName,
    this.agoraToken,
  });

  UserDetail.fromJson(Map<String, dynamic> json) {
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
    fullImage = json['fullImage'];
    channelName = json['channel_name'];
    agoraToken = json['agora_token'];
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
    data['fullImage'] = this.fullImage;
    data['channel_name'] = this.channelName;
    data['agora_token'] = this.agoraToken;
    return data;
  }
}
