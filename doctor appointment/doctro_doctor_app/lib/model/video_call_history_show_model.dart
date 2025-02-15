class VideoCallHistoryShowModel {
  VideoCallHistoryShowModel({
    bool? success,
    List<Data>? data,
  }) {
    _success = success;
    _data = data;
  }

  VideoCallHistoryShowModel.fromJson(dynamic json) {
    _success = json['success'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(Data.fromJson(v));
      });
    }
  }

  bool? _success;
  List<Data>? _data;

  bool? get success => _success;

  List<Data>? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = _success;
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Data {
  Data({
    int? id,
    int? userId,
    int? doctorId,
    String? date,
    String? startTime,
    String? duration,
    Doctor? doctor,
    User? user,
  }) {
    _id = id;
    _userId = userId;
    _doctorId = doctorId;
    _date = date;
    _startTime = startTime;
    _duration = duration;
    _doctor = doctor;
    _user = user;
  }

  Data.fromJson(dynamic json) {
    _id = json['id'];
    _userId = json['user_id'];
    _doctorId = json['doctor_id'];
    _date = json['date'];
    _startTime = json['start_time'];
    _duration = json['duration'];
    _doctor = json['doctor'] != null ? Doctor.fromJson(json['doctor']) : null;
    _user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  int? _id;
  int? _userId;
  int? _doctorId;
  String? _date;
  String? _startTime;
  String? _duration;
  Doctor? _doctor;
  User? _user;

  int? get id => _id;

  int? get userId => _userId;

  int? get doctorId => _doctorId;

  String? get date => _date;

  String? get startTime => _startTime;

  String? get duration => _duration;

  Doctor? get doctor => _doctor;

  User? get user => _user;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['user_id'] = _userId;
    map['doctor_id'] = _doctorId;
    map['date'] = _date;
    map['start_time'] = _startTime;
    map['duration'] = _duration;
    if (_doctor != null) {
      map['doctor'] = _doctor?.toJson();
    }
    if (_user != null) {
      map['user'] = _user?.toJson();
    }
    return map;
  }
}

class User {
  User({
    int? id,
    String? name,
    String? fullImage,
  }) {
    _id = id;
    _name = name;
    _fullImage = fullImage;
  }

  User.fromJson(dynamic json) {
    _id = json['id'];
    _name = json['name'];
    _fullImage = json['fullImage'];
  }

  int? _id;
  String? _name;
  String? _fullImage;

  int? get id => _id;

  String? get name => _name;

  String? get fullImage => _fullImage;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    map['fullImage'] = _fullImage;
    return map;
  }
}

class Doctor {
  Doctor({
    int? id,
    String? name,
    String? image,
    String? fullImage,
    dynamic rate,
    int? review,
  }) {
    _id = id;
    _name = name;
    _image = image;
    _fullImage = fullImage;
    _rate = rate;
    _review = review;
  }

  Doctor.fromJson(dynamic json) {
    _id = json['id'];
    _name = json['name'];
    _image = json['image'];
    _fullImage = json['fullImage'];
    _rate = json['rate'];
    _review = json['review'];
  }

  int? _id;
  String? _name;
  String? _image;
  String? _fullImage;
  dynamic _rate;
  int? _review;

  int? get id => _id;

  String? get name => _name;

  String? get image => _image;

  String? get fullImage => _fullImage;

  dynamic get rate => _rate;

  int? get review => _review;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    map['image'] = _image;
    map['fullImage'] = _fullImage;
    map['rate'] = _rate;
    map['review'] = _review;
    return map;
  }
}
