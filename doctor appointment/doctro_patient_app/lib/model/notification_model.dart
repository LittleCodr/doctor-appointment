class UserNotification {
  bool? success;
  List<Data>? data;

  UserNotification({this.success, this.data});

  UserNotification.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  int? userId;
  int? doctorId;
  String? title;
  String? message;
  String? userType;
  String? createdAt;
  String? updatedAt;
  Doctor? doctor;

  Data({this.id, this.userId, this.doctorId, this.title, this.message, this.userType, this.createdAt, this.updatedAt, this.doctor});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    doctorId = json['doctor_id'];
    title = json['title'];
    message = json['message'];
    userType = json['user_type'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    doctor = json['doctor'] != null ? new Doctor.fromJson(json['doctor']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['doctor_id'] = this.doctorId;
    data['title'] = this.title;
    data['message'] = this.message;
    data['user_type'] = this.userType;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.doctor != null) {
      data['doctor'] = this.doctor!.toJson();
    }
    return data;
  }
}

class Doctor {
  int? id;
  String? name;
  String? image;
  String? fullImage;
  dynamic rate;
  int? review;

  Doctor({this.id, this.name, this.image, this.fullImage, this.rate, this.review});

  Doctor.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    fullImage = json['fullImage'];
    rate = json['rate'];
    review = json['review'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['image'] = this.image;
    data['fullImage'] = this.fullImage;
    data['rate'] = this.rate;
    data['review'] = this.review;
    return data;
  }
}
