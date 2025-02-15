class DisplayOffer {
  bool? success;
  List<OfferModel>? data;
  String? msg;

  DisplayOffer({this.success, this.data, this.msg});

  DisplayOffer.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(new OfferModel.fromJson(v));
      });
    }
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['msg'] = this.msg;
    return data;
  }
}

class OfferModel {
  int? id;
  String? name;
  String? image;
  String? offerCode;
  int? discount;
  int? isFlat;
  String? discountType;
  int? flatDiscount;
  String? fullImage;

  OfferModel({this.id, this.name, this.image, this.offerCode, this.discount, this.isFlat, this.discountType, this.flatDiscount, this.fullImage});

  OfferModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    offerCode = json['offer_code'];
    discount = json['discount'];
    isFlat = json['is_flat'];
    discountType = json['discount_type'];
    flatDiscount = json['flatDiscount'];
    fullImage = json['fullImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['image'] = this.image;
    data['offer_code'] = this.offerCode;
    data['discount'] = this.discount;
    data['is_flat'] = this.isFlat;
    data['discount_type'] = this.discountType;
    data['flatDiscount'] = this.flatDiscount;
    data['fullImage'] = this.fullImage;
    return data;
  }
}
