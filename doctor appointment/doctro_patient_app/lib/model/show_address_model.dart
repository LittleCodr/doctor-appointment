class ShowAddress {
  bool? success;
  List<ShowAddressData>? data;
  String? msg;

  ShowAddress({this.success, this.data, this.msg});

  ShowAddress.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(new ShowAddressData.fromJson(v));
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

class ShowAddressData {
  int? id;
  String? address;
  String? lat;
  String? lang;
  String? label;

  ShowAddressData({this.id, this.address, this.lat, this.lang, this.label});

  ShowAddressData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    address = json['address'];
    lat = json['lat'];
    lang = json['lang'];
    label = json['label'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['address'] = this.address;
    data['lat'] = this.lat;
    data['lang'] = this.lang;
    data['label'] = this.label;
    return data;
  }
}
