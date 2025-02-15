class Appointments {
  bool? success;
  Data? data;
  String? msg;

  Appointments({this.success, this.data, this.msg});

  Appointments.fromJson(Map<String, dynamic> json) {
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
  List<UpcomingAppointment>? upcomingAppointment;
  List<PendingAppointment>? pendingAppointment;
  List<PastAppointment>? pastAppointment;

  Data({this.upcomingAppointment, this.pendingAppointment, this.pastAppointment});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['upcoming_appointment'] != null) {
      upcomingAppointment = <UpcomingAppointment>[];
      json['upcoming_appointment'].forEach((v) {
        upcomingAppointment!.add(new UpcomingAppointment.fromJson(v));
      });
    }
    if (json['pending_appointment'] != null) {
      pendingAppointment = <PendingAppointment>[];
      json['pending_appointment'].forEach((v) {
        pendingAppointment!.add(new PendingAppointment.fromJson(v));
      });
    }
    if (json['past_appointment'] != null) {
      pastAppointment = <PastAppointment>[];
      json['past_appointment'].forEach((v) {
        pastAppointment!.add(new PastAppointment.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.upcomingAppointment != null) {
      data['upcoming_appointment'] = this.upcomingAppointment!.map((v) => v.toJson()).toList();
    }
    if (this.pendingAppointment != null) {
      data['pending_appointment'] = this.pendingAppointment!.map((v) => v.toJson()).toList();
    }
    if (this.pastAppointment != null) {
      data['past_appointment'] = this.pastAppointment!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UpcomingAppointment {
  int? id;
  String? date;
  String? time;
  String? appointmentStatus;
  String? patientName;
  int? doctorId;
  String? appointmentId;
  int? hospitalId;
  Doctor? doctor;
  bool? prescription;
  int? rate;
  int? review;
  Hospital? hospital;

  UpcomingAppointment({this.id, this.date, this.time, this.appointmentStatus, this.patientName, this.doctorId, this.appointmentId, this.hospitalId, this.doctor, this.prescription, this.rate, this.review, this.hospital});

  UpcomingAppointment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    date = json['date'];
    time = json['time'];
    appointmentStatus = json['appointment_status'];
    patientName = json['patient_name'];
    doctorId = json['doctor_id'];
    appointmentId = json['appointment_id'];
    hospitalId = json['hospital_id'];
    doctor = json['doctor'] != null ? new Doctor.fromJson(json['doctor']) : null;
    prescription = json['prescription'];
    rate = json['rate'];
    review = json['review'];
    hospital = json['hospital'] != null ? new Hospital.fromJson(json['hospital']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['date'] = this.date;
    data['time'] = this.time;
    data['appointment_status'] = this.appointmentStatus;
    data['patient_name'] = this.patientName;
    data['doctor_id'] = this.doctorId;
    data['appointment_id'] = this.appointmentId;
    data['hospital_id'] = this.hospitalId;
    if (this.doctor != null) {
      data['doctor'] = this.doctor!.toJson();
    }
    data['prescription'] = this.prescription;
    data['rate'] = this.rate;
    data['review'] = this.review;
    if (this.hospital != null) {
      data['hospital'] = this.hospital!.toJson();
    }
    return data;
  }
}

class PendingAppointment {
  int? id;
  String? date;
  String? time;
  String? appointmentStatus;
  String? patientName;
  int? doctorId;
  String? appointmentId;
  int? hospitalId;
  Doctor? doctor;
  bool? prescription;
  int? rate;
  int? review;
  Hospital? hospital;

  PendingAppointment({this.id, this.date, this.time, this.appointmentStatus, this.patientName, this.doctorId, this.appointmentId, this.hospitalId, this.doctor, this.prescription, this.rate, this.review, this.hospital});

  PendingAppointment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    date = json['date'];
    time = json['time'];
    appointmentStatus = json['appointment_status'];
    patientName = json['patient_name'];
    doctorId = json['doctor_id'];
    appointmentId = json['appointment_id'];
    hospitalId = json['hospital_id'];
    doctor = json['doctor'] != null ? new Doctor.fromJson(json['doctor']) : null;
    prescription = json['prescription'];
    rate = json['rate'];
    review = json['review'];
    hospital = json['hospital'] != null ? new Hospital.fromJson(json['hospital']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['date'] = this.date;
    data['time'] = this.time;
    data['appointment_status'] = this.appointmentStatus;
    data['patient_name'] = this.patientName;
    data['doctor_id'] = this.doctorId;
    data['appointment_id'] = this.appointmentId;
    data['hospital_id'] = this.hospitalId;
    if (this.doctor != null) {
      data['doctor'] = this.doctor!.toJson();
    }
    data['prescription'] = this.prescription;
    data['rate'] = this.rate;
    data['review'] = this.review;
    if (this.hospital != null) {
      data['hospital'] = this.hospital!.toJson();
    }
    return data;
  }
}

class PastAppointment {
  int? id;
  String? date;
  String? time;
  String? appointmentStatus;
  String? patientName;
  int? doctorId;
  String? appointmentId;
  int? hospitalId;
  Doctor? doctor;
  bool? prescription;
  int? rate;
  int? review;
  Hospital? hospital;

  PastAppointment({this.id, this.date, this.time, this.appointmentStatus, this.patientName, this.doctorId, this.appointmentId, this.hospitalId, this.doctor, this.prescription, this.rate, this.review, this.hospital});

  PastAppointment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    date = json['date'];
    time = json['time'];
    appointmentStatus = json['appointment_status'];
    patientName = json['patient_name'];
    doctorId = json['doctor_id'];
    appointmentId = json['appointment_id'];
    hospitalId = json['hospital_id'];
    doctor = json['doctor'] != null ? new Doctor.fromJson(json['doctor']) : null;
    prescription = json['prescription'];
    rate = json['rate'];
    review = json['review'];
    hospital = json['hospital'] != null ? new Hospital.fromJson(json['hospital']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['date'] = this.date;
    data['time'] = this.time;
    data['appointment_status'] = this.appointmentStatus;
    data['patient_name'] = this.patientName;
    data['doctor_id'] = this.doctorId;
    data['appointment_id'] = this.appointmentId;
    data['hospital_id'] = this.hospitalId;
    if (this.doctor != null) {
      data['doctor'] = this.doctor!.toJson();
    }
    data['prescription'] = this.prescription;
    data['rate'] = this.rate;
    data['review'] = this.review;
    if (this.hospital != null) {
      data['hospital'] = this.hospital!.toJson();
    }
    return data;
  }
}

class Doctor {
  int? id;
  String? name;
  String? image;
  int? treatmentId;
  String? fullImage;
  Treatment? treatment;

  Doctor({this.id, this.name, this.image, this.treatmentId, this.fullImage, this.treatment});

  Doctor.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    treatmentId = json['treatment_id'];
    fullImage = json['fullImage'];
    treatment = json['treatment'] != null ? new Treatment.fromJson(json['treatment']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['image'] = this.image;
    data['treatment_id'] = this.treatmentId;
    data['fullImage'] = this.fullImage;
    if (this.treatment != null) {
      data['treatment'] = this.treatment!.toJson();
    }
    return data;
  }
}

class Treatment {
  int? id;
  String? name;
  String? fullImage;

  Treatment({this.id, this.name, this.fullImage});

  Treatment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    fullImage = json['fullImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['fullImage'] = this.fullImage;
    return data;
  }
}

class Hospital {
  int? id;
  String? address;
  String? name;

  Hospital({this.id, this.address, this.name});

  Hospital.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    address = json['address'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['address'] = this.address;
    data['name'] = this.name;
    return data;
  }
}
