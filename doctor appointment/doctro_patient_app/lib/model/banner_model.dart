class Banners {
  bool? success;
  List<Add>? data;

  Banners({this.success, this.data});

  Banners.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(new Add.fromJson(v));
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

class Add {
  int? id;
  String? name;
  String? image;
  String? link;
  int? status;
  String? desc;
  String? createdAt;
  String? updatedAt;
  String? fullImage;

  Add({this.id, this.name, this.image, this.link, this.status, this.desc, this.createdAt, this.updatedAt, this.fullImage});

  Add.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    link = json['link'];
    status = json['status'];
    desc = json['desc'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    fullImage = json['fullImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['image'] = this.image;
    data['link'] = this.link;
    data['status'] = this.status;
    data['desc'] = this.desc;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['fullImage'] = this.fullImage;
    return data;
  }
}
