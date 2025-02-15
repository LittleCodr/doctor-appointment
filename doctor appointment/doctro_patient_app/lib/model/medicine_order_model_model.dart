class MedicineOrderModel {
  bool? success;
  String? msg;
  List<Data>? data;

  MedicineOrderModel({this.success, this.msg, this.data});

  MedicineOrderModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    msg = json['msg'];
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
    data['msg'] = this.msg;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? medicineId;
  int? userId;
  String? pdf;
  String? amount;
  String? paymentType;
  String? paymentToken;
  int? paymentStatus;
  int? adminCommission;
  int? pharmacyCommission;
  int? pharmacyId;
  String? shippingAt;
  int? addressId;
  int? deliveryCharge;
  String? createdAt;
  PharmacyDetails? pharmacyDetails;
  List<MedicineName>? medicineName;
  Address? address;

  Data(
      {this.id,
      this.medicineId,
      this.userId,
      this.pdf,
      this.amount,
      this.paymentType,
      this.paymentToken,
      this.paymentStatus,
      this.adminCommission,
      this.pharmacyCommission,
      this.pharmacyId,
      this.shippingAt,
      this.addressId,
      this.deliveryCharge,
      this.createdAt,
      this.pharmacyDetails,
      this.medicineName,
      this.address});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    medicineId = json['medicine_id'];
    userId = json['user_id'];
    pdf = json['pdf'];
    amount = json['amount'].toString();
    paymentType = json['payment_type'];
    paymentToken = json['payment_token'];
    paymentStatus = json['payment_status'];
    adminCommission = json['admin_commission'];
    pharmacyCommission = json['pharmacy_commission'];
    pharmacyId = json['pharmacy_id'];
    shippingAt = json['shipping_at'];
    addressId = json['address_id'];
    deliveryCharge = json['delivery_charge'];
    createdAt = json['created_at'];
    pharmacyDetails = json['pharmacy_details'] != null ? new PharmacyDetails.fromJson(json['pharmacy_details']) : null;
    if (json['medicine_name'] != null) {
      medicineName = [];
      json['medicine_name'].forEach((v) {
        medicineName!.add(new MedicineName.fromJson(v));
      });
    }
    address = json['address'] != null ? new Address.fromJson(json['address']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['medicine_id'] = this.medicineId;
    data['user_id'] = this.userId;
    data['pdf'] = this.pdf;
    data['amount'] = this.amount;
    data['payment_type'] = this.paymentType;
    data['payment_token'] = this.paymentToken;
    data['payment_status'] = this.paymentStatus;
    data['admin_commission'] = this.adminCommission;
    data['pharmacy_commission'] = this.pharmacyCommission;
    data['pharmacy_id'] = this.pharmacyId;
    data['shipping_at'] = this.shippingAt;
    data['address_id'] = this.addressId;
    data['delivery_charge'] = this.deliveryCharge;
    data['created_at'] = this.createdAt;
    if (this.pharmacyDetails != null) {
      data['pharmacy_details'] = this.pharmacyDetails!.toJson();
    }
    if (this.medicineName != null) {
      data['medicine_name'] = this.medicineName!.map((v) => v.toJson()).toList();
    }
    if (this.address != null) {
      data['address'] = this.address!.toJson();
    }
    return data;
  }
}

class PharmacyDetails {
  int? id;
  String? name;
  String? image;
  String? address;
  String? fullImage;

  PharmacyDetails({this.id, this.name, this.image, this.address, this.fullImage});

  PharmacyDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    address = json['address'];
    fullImage = json['fullImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['image'] = this.image;
    data['address'] = this.address;
    data['fullImage'] = this.fullImage;
    return data;
  }
}

class MedicineName {
  int? id;
  int? purchaseMedicineId;
  int? medicineId;
  int? price;
  int? qty;
  String? createdAt;
  String? updatedAt;
  String? name;

  MedicineName({this.id, this.purchaseMedicineId, this.medicineId, this.price, this.qty, this.createdAt, this.updatedAt, this.name});

  MedicineName.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    purchaseMedicineId = json['purchase_medicine_id'];
    medicineId = json['medicine_id'];
    price = json['price'];
    qty = json['qty'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['purchase_medicine_id'] = this.purchaseMedicineId;
    data['medicine_id'] = this.medicineId;
    data['price'] = this.price;
    data['qty'] = this.qty;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['name'] = this.name;
    return data;
  }
}

class Address {
  int? id;
  String? address;
  String? lat;
  String? lang;
  int? userId;
  String? label;
  String? createdAt;
  String? updatedAt;

  Address({this.id, this.address, this.lat, this.lang, this.userId, this.label, this.createdAt, this.updatedAt});

  Address.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    address = json['address'];
    lat = json['lat'];
    lang = json['lang'];
    userId = json['user_id'];
    label = json['label'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['address'] = this.address;
    data['lat'] = this.lat;
    data['lang'] = this.lang;
    data['user_id'] = this.userId;
    data['label'] = this.label;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
