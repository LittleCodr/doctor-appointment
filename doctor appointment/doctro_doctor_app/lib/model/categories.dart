class Categories {
  bool? _success;
  List<CategoriesData>? _categoriesData;
  String? _msg;

  bool? get success => _success;

  List<CategoriesData>? get categoriesData => _categoriesData;

  String? get msg => _msg;

  Categories({bool? success, List<CategoriesData>? categoryData, String? msg}) {
    _success = success;
    _categoriesData = categoryData;
    _msg = msg;
  }

  Categories.fromJson(dynamic json) {
    _success = json["success"];
    if (json["data"] != null) {
      _categoriesData = [];
      json["data"].forEach((v) {
        _categoriesData!.add(CategoriesData.fromJson(v));
      });
    }
    _msg = json["msg"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["success"] = _success;
    if (_categoriesData != null) {
      map["data"] = _categoriesData!.map((v) => v.toJson()).toList();
    }
    map["msg"] = _msg;
    return map;
  }
}

class CategoriesData {
  int? _id;
  String? _name;
  String? _fullImage;

  int? get id => _id;

  String? get name => _name;

  String? get fullImage => _fullImage;

  CategoriesData({int? id, String? name, String? fullImage}) {
    _id = id;
    _name = name;
    _fullImage = fullImage;
  }

  CategoriesData.fromJson(dynamic json) {
    _id = json["id"];
    _name = json["name"];
    _fullImage = json["fullImage"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = _id;
    map["name"] = _name;
    map["fullImage"] = _fullImage;
    return map;
  }
}
