class EducationCertificate {
  String? _certificate;

  String? _certificateYear;

  get certificate => _certificate;

  set certificate(value) {
    _certificate = value;
  }

  get certificateYear => _certificateYear;

  set certificateYear(value) {
    _certificateYear = value;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['certificate'] = this.certificate;
    data['certificate_year'] = this._certificateYear;
    return data;
  }
}
