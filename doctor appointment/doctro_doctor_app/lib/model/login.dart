class Login {
  bool? success;
  Data? data;
  String? msg;

  Login({this.success, this.data, this.msg});

  Login.fromJson(Map<String, dynamic> json) {
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
  String? name;
  String? email;
  String? phone;
  String? phoneCode;
  int? verify;
  int? otp;
  String? image;
  String? deviceToken;
  String? language;
  String? createdAt;
  String? updatedAt;
  int? isFilled;
  int? subscriptionStatus;
  String? token;
  String? fullImage;
  List<Roles>? roles;

  Data({this.id, this.name, this.email, this.phone, this.phoneCode, this.verify, this.otp, this.image, this.deviceToken, this.language, this.createdAt, this.updatedAt, this.isFilled, this.subscriptionStatus, this.token, this.fullImage, this.roles});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    phoneCode = json['phone_code'];
    verify = json['verify'];
    otp = json['otp'];
    image = json['image'];
    deviceToken = json['device_token'];
    language = json['language'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    isFilled = json['is_filled'];
    subscriptionStatus = json['subscription_status'];
    token = json['token'];
    fullImage = json['fullImage'];
    if (json['roles'] != null) {
      roles = [];
      json['roles'].forEach((v) {
        roles!.add(new Roles.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['phone_code'] = this.phoneCode;
    data['verify'] = this.verify;
    data['otp'] = this.otp;
    data['image'] = this.image;
    data['device_token'] = this.deviceToken;
    data['language'] = this.language;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['is_filled'] = this.isFilled;
    data['subscription_status'] = this.subscriptionStatus;
    data['token'] = this.token;
    data['fullImage'] = this.fullImage;
    if (this.roles != null) {
      data['roles'] = this.roles!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Roles {
  int? id;
  String? name;
  String? guardName;
  String? createdAt;
  String? updatedAt;
  Pivot? pivot;

  Roles({this.id, this.name, this.guardName, this.createdAt, this.updatedAt, this.pivot});

  Roles.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    guardName = json['guard_name'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    pivot = json['pivot'] != null ? new Pivot.fromJson(json['pivot']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['guard_name'] = this.guardName;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.pivot != null) {
      data['pivot'] = this.pivot!.toJson();
    }
    return data;
  }
}

class Pivot {
  int? modelId;
  int? roleId;
  String? modelType;

  Pivot({this.modelId, this.roleId, this.modelType});

  Pivot.fromJson(Map<String, dynamic> json) {
    modelId = json['model_id'];
    roleId = json['role_id'];
    modelType = json['model_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['model_id'] = this.modelId;
    data['role_id'] = this.roleId;
    data['model_type'] = this.modelType;
    return data;
  }
}
