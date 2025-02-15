class Expertise {
  bool? _success;
  List<Expert>? _expertiseData;
  String? _msg;

  bool? get success => _success;

  List<Expert>? get expertiseData => _expertiseData;

  String? get msg => _msg;

  Expertise({bool? success, List<Expert>? data, String? msg}) {
    _success = success;
    _expertiseData = data;
    _msg = msg;
  }

  Expertise.fromJson(dynamic json) {
    _success = json["success"];
    if (json["data"] != null) {
      _expertiseData = [];
      json["data"].forEach((v) {
        _expertiseData!.add(Expert.fromJson(v));
      });
    }
    _msg = json["msg"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["success"] = _success;
    if (_expertiseData != null) {
      map["data"] = _expertiseData!.map((v) => v.toJson()).toList();
    }
    map["msg"] = _msg;
    return map;
  }
}

class Expert {
  int? _id;
  String? _name;

  int? get id => _id;

  String? get name => _name;

  Expert({int? id, String? name}) {
    _id = id;
    _name = name;
  }

  Expert.fromJson(dynamic json) {
    _id = json["id"];
    _name = json["name"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = _id;
    map["name"] = _name;
    return map;
  }
}
