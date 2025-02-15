import 'package:doctro_patient/const/prefConstatnt.dart';
import 'package:doctro_patient/const/preference.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'language_localization.dart';

String? getTranslated(BuildContext context, String key) {
  return LanguageLocalization.of(context)!.getTranslateValue(key);
}

const String ENGLISH = "en";
const String SPANISH = "es";
const String ARABIC = "ar";

Future<Locale> setLocale(String languageCode) async {
  SharedPreferenceHelper.setString(Preferences.current_language_code, languageCode);
  return _locale(languageCode);
}

Locale _locale(String languageCode) {
  Locale _temp;
  switch (languageCode) {
    case ENGLISH:
      _temp = Locale(languageCode, 'US');
      break;
    case SPANISH:
      _temp = Locale(languageCode, 'ES');
      break;
    case ARABIC:
      _temp = Locale(languageCode, 'AE');
      break;
    default:
      _temp = Locale(ENGLISH, 'US');
  }
  return _temp;
}

Future<Locale> getLocale() async {
  String? languageCode = SharedPreferenceHelper.getString(Preferences.current_language_code);
  return _locale(languageCode!);
}
