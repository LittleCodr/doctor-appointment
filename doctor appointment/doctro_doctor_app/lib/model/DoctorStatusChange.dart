class DoctorStatusChange {
  bool? success;
  String? msg;

  DoctorStatusChange({this.success, this.msg});

  DoctorStatusChange.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['msg'] = this.msg;
    return data;
  }
}
