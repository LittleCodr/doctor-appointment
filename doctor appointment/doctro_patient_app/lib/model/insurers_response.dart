/// success : true
/// data : [{"id":2,"name":"Reliance","status":1},{"id":3,"name":"Kotak Mahindra General Insurance","status":1},{"id":4,"name":"Bajaj Allianz General Insurance","status":1},{"id":5,"name":"Bharti AXA Life","status":1},{"id":6,"name":"HDFC Life Insurance company","status":1},{"id":7,"name":"IFFCO Tokio","status":1},{"id":8,"name":"Future Generali India","status":1},{"id":9,"name":"Max Life Insurance company","status":1},{"id":10,"name":"Aditya Birla General Insurance","status":1}]

class InsurersResponse {
  InsurersResponse({
      this.success, 
      this.data,});

  InsurersResponse.fromJson(dynamic json) {
    success = json['success'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(InsurersData.fromJson(v));
      });
    }
  }
  bool? success;
  List<InsurersData>? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = success;
    if (data != null) {
      map['data'] = data?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// id : 2
/// name : "Reliance"
/// status : 1

class InsurersData {
  InsurersData({
      this.id, 
      this.name, 
      this.status,});

  InsurersData.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    status = json['status'];
  }
  num? id;
  String? name;
  num? status;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['status'] = status;
    return map;
  }

}