class VideoCallHistoryAddModel {
  VideoCallHistoryAddModel({
    bool? success,
  }) {
    _success = success;
  }

  VideoCallHistoryAddModel.fromJson(dynamic json) {
    _success = json['success'];
  }

  bool? _success;

  bool? get success => _success;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = _success;
    return map;
  }
}
