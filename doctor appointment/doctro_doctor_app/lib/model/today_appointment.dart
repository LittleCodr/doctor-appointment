class TodayAppointment {
  bool? success;
  Data? data;
  String? msg;

  TodayAppointment({this.success, this.data, this.msg});

  TodayAppointment.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['msg'] = this.msg;
    return data;
  }
}

class Data {
  List<Today>? today;
  List<Tomorrow>? tomorrow;
  List<Upcoming>? upcoming;

  Data({this.today, this.tomorrow, this.upcoming});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['today'] != null) {
      today = <Today>[];
      json['today'].forEach((v) {
        today!.add(new Today.fromJson(v));
      });
    }
    if (json['tomorrow'] != null) {
      tomorrow = <Tomorrow>[];
      json['tomorrow'].forEach((v) {
        tomorrow!.add(new Tomorrow.fromJson(v));
      });
    }
    if (json['upcoming'] != null) {
      upcoming = <Upcoming>[];
      json['upcoming'].forEach((v) {
        upcoming!.add(new Upcoming.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.today != null) {
      data['today'] = this.today!.map((v) => v.toJson()).toList();
    }
    if (this.tomorrow != null) {
      data['tomorrow'] = this.tomorrow!.map((v) => v.toJson()).toList();
    }
    if (this.upcoming != null) {
      data['upcoming'] = this.upcoming!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Today {
  int? id;
  int? hospitalId;
  String? time;
  String? date;
  int? age;
  String? patientName;
  String? amount;
  String? patientAddress;
  int? userId;
  int? rate;
  int? review;
  User? user;
  Hospital? hospital;

  Today({this.id, this.hospitalId, this.time, this.date, this.age, this.patientName, this.amount, this.patientAddress, this.userId, this.rate, this.review, this.user, this.hospital});

  Today.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    hospitalId = json['hospital_id'];
    time = json['time'];
    date = json['date'];
    age = json['age'];
    patientName = json['patient_name'];
    amount = json['amount'];
    patientAddress = json['patient_address'];
    userId = json['user_id'];
    rate = json['rate'];
    review = json['review'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    hospital = json['hospital'] != null ? new Hospital.fromJson(json['hospital']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['hospital_id'] = this.hospitalId;
    data['time'] = this.time;
    data['date'] = this.date;
    data['age'] = this.age;
    data['patient_name'] = this.patientName;
    data['amount'] = this.amount;
    data['patient_address'] = this.patientAddress;
    data['user_id'] = this.userId;
    data['rate'] = this.rate;
    data['review'] = this.review;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    if (this.hospital != null) {
      data['hospital'] = this.hospital!.toJson();
    }
    return data;
  }
}

class Tomorrow {
  int? id;
  int? hospitalId;
  String? time;
  String? date;
  int? age;
  String? patientName;
  int? amount;
  String? patientAddress;
  int? userId;
  int? rate;
  int? review;
  User? user;
  Hospital? hospital;

  Tomorrow({this.id, this.hospitalId, this.time, this.date, this.age, this.patientName, this.amount, this.patientAddress, this.userId, this.rate, this.review, this.user, this.hospital});

  Tomorrow.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    hospitalId = json['hospital_id'];
    time = json['time'];
    date = json['date'];
    age = json['age'];
    patientName = json['patient_name'];
    amount = json['amount'];
    patientAddress = json['patient_address'];
    userId = json['user_id'];
    rate = json['rate'];
    review = json['review'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    hospital = json['hospital'] != null ? new Hospital.fromJson(json['hospital']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['hospital_id'] = this.hospitalId;
    data['time'] = this.time;
    data['date'] = this.date;
    data['age'] = this.age;
    data['patient_name'] = this.patientName;
    data['amount'] = this.amount;
    data['patient_address'] = this.patientAddress;
    data['user_id'] = this.userId;
    data['rate'] = this.rate;
    data['review'] = this.review;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    if (this.hospital != null) {
      data['hospital'] = this.hospital!.toJson();
    }
    return data;
  }
}

class Upcoming {
  int? id;
  int? hospitalId;
  String? time;
  String? date;
  int? age;
  String? patientName;
  int? amount;
  String? patientAddress;
  int? userId;
  int? rate;
  int? review;
  User? user;
  Hospital? hospital;

  Upcoming({this.id, this.hospitalId, this.time, this.date, this.age, this.patientName, this.amount, this.patientAddress, this.userId, this.rate, this.review, this.user, this.hospital});

  Upcoming.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    hospitalId = json['hospital_id'];
    time = json['time'];
    date = json['date'];
    age = json['age'];
    patientName = json['patient_name'];
    amount = json['amount'];
    patientAddress = json['patient_address'];
    userId = json['user_id'];
    rate = json['rate'];
    review = json['review'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    hospital = json['hospital'] != null ? new Hospital.fromJson(json['hospital']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['hospital_id'] = this.hospitalId;
    data['time'] = this.time;
    data['date'] = this.date;
    data['age'] = this.age;
    data['patient_name'] = this.patientName;
    data['amount'] = this.amount;
    data['patient_address'] = this.patientAddress;
    data['user_id'] = this.userId;
    data['rate'] = this.rate;
    data['review'] = this.review;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    if (this.hospital != null) {
      data['hospital'] = this.hospital!.toJson();
    }
    return data;
  }
}

class User {
  int? id;
  String? image;
  String? fullImage;

  User({this.id, this.image, this.fullImage});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    fullImage = json['fullImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['image'] = this.image;
    data['fullImage'] = this.fullImage;
    return data;
  }
}

class Hospital {
  int? id;
  String? name;
  String? address;

  Hospital({this.id, this.name, this.address});

  Hospital.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    address = json['address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['address'] = this.address;
    return data;
  }
}
