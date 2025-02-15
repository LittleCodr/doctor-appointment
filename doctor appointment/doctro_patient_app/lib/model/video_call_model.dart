class VideoCallModel {
  VideoCallModel({
    dynamic msg,
    Data? data,
    bool? success,
  }) {
    _msg = msg;
    _data = data;
    _success = success;
  }

  VideoCallModel.fromJson(dynamic json) {
    _msg = json['msg'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
    _success = json['success'];
  }

  dynamic _msg;
  Data? _data;
  bool? _success;

  dynamic get msg => _msg;

  Data? get data => _data;

  bool? get success => _success;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['msg'] = _msg;
    if (_data != null) {
      map['data'] = _data?.toJson();
    }
    map['success'] = _success;
    return map;
  }
}

class Data {
  Data({
    String? token,
    String? cn,
  }) {
    _token = token;
    _cn = cn;
  }

  Data.fromJson(dynamic json) {
    _token = json['token'];
    _cn = json['cn'];
  }

  String? _token;
  String? _cn;

  String? get token => _token;

  String? get cn => _cn;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['token'] = _token;
    map['cn'] = _cn;
    return map;
  }
}
