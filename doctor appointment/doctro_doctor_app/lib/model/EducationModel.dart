class EducationModel {
  String? _degree;
  String? _college;
  String? _year;

  get degree => _degree;

  set degree(value) {
    _degree = value;
  }

  get college => _college;

  get year => _year;

  set year(value) {
    _year = value;
  }

  set college(value) {
    _college = value;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['degree'] = this.degree;
    data['college'] = this.college;
    data['year'] = this.year;
    return data;
  }
}
