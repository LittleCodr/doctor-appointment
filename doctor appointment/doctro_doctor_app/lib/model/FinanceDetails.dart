class FinanceDetails {
  bool? success;
  List<PurchaseDetails>? data;

  FinanceDetails({this.success, this.data});

  FinanceDetails.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(new PurchaseDetails.fromJson(v));
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

class PurchaseDetails {
  int? id;
  int? doctorId;
  int? subscriptionId;
  int? duration;
  String? startDate;
  String? endDate;
  String? paymentType;
  int? amount;
  String? paymentToken;
  int? paymentStatus;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? doctorName;
  Subscription? subscription;

  PurchaseDetails(
      {this.id, this.doctorId, this.subscriptionId, this.duration, this.startDate, this.endDate, this.paymentType, this.amount, this.paymentToken, this.paymentStatus, this.status, this.createdAt, this.updatedAt, this.doctorName, this.subscription});

  PurchaseDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    doctorId = json['doctor_id'];
    subscriptionId = json['subscription_id'];
    duration = json['duration'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    paymentType = json['payment_type'];
    amount = json['amount'];
    paymentToken = json['payment_token'];
    paymentStatus = json['payment_status'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    doctorName = json['doctor_name'];
    subscription = json['subscription'] != null ? new Subscription.fromJson(json['subscription']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['doctor_id'] = this.doctorId;
    data['subscription_id'] = this.subscriptionId;
    data['duration'] = this.duration;
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    data['payment_type'] = this.paymentType;
    data['amount'] = this.amount;
    data['payment_token'] = this.paymentToken;
    data['payment_status'] = this.paymentStatus;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['doctor_name'] = this.doctorName;
    if (this.subscription != null) {
      data['subscription'] = this.subscription!.toJson();
    }
    return data;
  }
}

class Subscription {
  int? id;
  String? name;

  Subscription({this.id, this.name});

  Subscription.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}
