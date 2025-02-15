class MedicineDetails {
  bool? success;
  Data? data;
  String? msg;

  MedicineDetails({this.success, this.data, this.msg});

  MedicineDetails.fromJson(Map<String, dynamic> json) {
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
  String? image;
  int? pharmacyId;
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

  Data(
      {this.id,
      this.name,
      this.image,
      this.pharmacyId,
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

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    pharmacyId = json['pharamacy_id'];
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
    data['pharamacy_id'] = this.pharmacyId;
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
