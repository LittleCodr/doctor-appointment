class MedicineModel {
  String? _medName;
  String? _medDay;
  bool? _isMorning;
  bool? _isAfternoon;
  bool? _isNight;

  get medName => _medName;

  set medName(value) {
    _medName = value;
  }

  get medDay => _medDay;

  get isNight => _isNight;

  set isNight(value) {
    _isNight = value;
  }

  get isAfternoon => _isAfternoon;

  set isAfternoon(value) {
    _isAfternoon = value;
  }

  get isMorning => _isMorning;

  set isMorning(value) {
    _isMorning = value;
  }

  set medDay(value) {
    _medDay = value;
  }
}
