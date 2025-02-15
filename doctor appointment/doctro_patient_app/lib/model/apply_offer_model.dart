class ApplyOffer {
  bool? success;
  Data? data;
  String? msg;

  ApplyOffer({this.success, this.data, this.msg});

  ApplyOffer.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    msg = json['msg'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['msg'] = this.msg;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  num? id;
  String? name;
  String? offerCode;
  int? discount;
  String? discountType;
  int? isFlat;
  dynamic flatDiscount;
  int? minDiscount;

  Data({this.id, this.name, this.offerCode, this.discount, this.discountType, this.isFlat, this.flatDiscount, this.minDiscount});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    offerCode = json['offer_code'];
    discount = json['discount'];
    discountType = json['discount_type'];
    isFlat = json['is_flat'];
    flatDiscount = json['flatDiscount'];
    minDiscount = json['min_discount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['offer_code'] = this.offerCode;
    data['discount'] = this.discount;
    data['discount_type'] = this.discountType;
    data['is_flat'] = this.isFlat;
    data['flatDiscount'] = this.flatDiscount;
    data['min_discount'] = this.minDiscount;
    return data;
  }
}
