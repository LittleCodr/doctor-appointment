class PharmacyDetailsModel {
  bool? success;
  Data? data;
  String? msg;

  PharmacyDetailsModel({this.success, this.data, this.msg});

  PharmacyDetailsModel.fromJson(Map<String, dynamic> json) {
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
  int? userId;
  String? image;
  String? name;
  String? email;
  String? phone;
  String? address;
  String? lat;
  String? lang;
  String? startTime;
  String? endTime;
  String? commissionAmount;
  String? description;
  int? isShipping;
  String? deliveryCharges;
  int? status;
  String? createdAt;
  String? updatedAt;
  List<Medicine>? medicine;
  String? fullImage;

  Data(
      {this.id,
      this.userId,
      this.image,
      this.name,
      this.email,
      this.phone,
      this.address,
      this.lat,
      this.lang,
      this.startTime,
      this.endTime,
      this.commissionAmount,
      this.description,
      this.isShipping,
      this.deliveryCharges,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.medicine,
      this.fullImage});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    image = json['image'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    address = json['address'];
    lat = json['lat'];
    lang = json['lang'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    commissionAmount = json['commission_amount'].toString();
    description = json['description'];
    isShipping = json['is_shipping'];
    deliveryCharges = json['delivery_charges'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['medicine'] != null) {
      medicine = [];
      json['medicine'].forEach((v) {
        medicine!.add(new Medicine.fromJson(v));
      });
    }
    fullImage = json['fullImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['image'] = this.image;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['address'] = this.address;
    data['lat'] = this.lat;
    data['lang'] = this.lang;
    data['start_time'] = this.startTime;
    data['end_time'] = this.endTime;
    data['commission_amount'] = this.commissionAmount;
    data['description'] = this.description;
    data['is_shipping'] = this.isShipping;
    data['delivery_charges'] = this.deliveryCharges;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.medicine != null) {
      data['medicine'] = this.medicine!.map((v) => v.toJson()).toList();
    }
    data['fullImage'] = this.fullImage;
    return data;
  }
}

class Medicine {
  int? id;
  String? name;
  String? image;
  int? pharamacyId;
  int? medicineCategoryId;
  int? status;
  int? totalStock;
  int? useStock;
  int? incomingStock;
  int? pricePrStrip;
  int? numberOfMedicine;
  String? description;
  String? works;
  int? prescriptionRequired;
  String? metaInfo;
  String? createdAt;
  String? updatedAt;
  String? fullImage;

  Medicine(
      {this.id,
      this.name,
      this.image,
      this.pharamacyId,
      this.medicineCategoryId,
      this.status,
      this.totalStock,
      this.useStock,
      this.incomingStock,
      this.pricePrStrip,
      this.numberOfMedicine,
      this.description,
      this.works,
      this.prescriptionRequired,
      this.metaInfo,
      this.createdAt,
      this.updatedAt,
      this.fullImage});

  Medicine.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    pharamacyId = json['pharamacy_id'];
    medicineCategoryId = json['medicine_category_id'];
    status = json['status'];
    totalStock = json['total_stock'];
    useStock = json['use_stock'];
    incomingStock = json['incoming_stock'];
    pricePrStrip = json['price_pr_strip'];
    numberOfMedicine = json['number_of_medicine'];
    description = json['description'];
    works = json['works'];
    prescriptionRequired = json['prescription_required'];
    metaInfo = json['meta_info'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    fullImage = json['fullImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['image'] = this.image;
    data['pharamacy_id'] = this.pharamacyId;
    data['medicine_category_id'] = this.medicineCategoryId;
    data['status'] = this.status;
    data['total_stock'] = this.totalStock;
    data['use_stock'] = this.useStock;
    data['incoming_stock'] = this.incomingStock;
    data['price_pr_strip'] = this.pricePrStrip;
    data['number_of_medicine'] = this.numberOfMedicine;
    data['description'] = this.description;
    data['works'] = this.works;
    data['prescription_required'] = this.prescriptionRequired;
    data['meta_info'] = this.metaInfo;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['fullImage'] = this.fullImage;
    return data;
  }
}
