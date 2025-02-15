class Payment {
  bool? success;
  List<Payments>? paymentData;

  Payment({this.success, this.paymentData});

  Payment.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      paymentData = [];
      json['data'].forEach((v) {
        paymentData!.add(new Payments.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.paymentData != null) {
      data['data'] = this.paymentData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Payments {
  int? id;
  int? userId;
  String? amount;
  User? user;

  Payments({this.id, this.userId, this.amount, this.user});

  Payments.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    amount = json['amount'].toString();
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['amount'] = this.amount;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}

class User {
  int? id;
  String? name;
  String? fullImage;

  User({this.id, this.name, this.fullImage});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    fullImage = json['fullImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['fullImage'] = this.fullImage;
    return data;
  }
}
