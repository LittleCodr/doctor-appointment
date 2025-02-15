import 'package:dio/dio.dart';
import 'package:doctro_patient/const/prefConstatnt.dart';
import 'package:doctro_patient/const/preference.dart';

class RetroApi {
  Dio dioData() {
    final dio = Dio();
    String? token = SharedPreferenceHelper.getString(Preferences.auth_token);
    dio.options.headers["Accept"] = "application/json"; // config your dio headers globally
    dio.options.followRedirects = false;
    dio.options.connectTimeout = Duration(seconds: 30);
    dio.options.receiveTimeout = Duration(seconds: 30);
    if (token != "N_A") {
      dio.options.headers["Authorization"] = "Bearer " + token!;
    }
    return dio;
  }
}

class RetroApi2 {
  Dio dioData2() {
    final dio = Dio();
    dio.options.headers["Accept"] = "application/json"; // config your dio headers globally
    dio.options.followRedirects = false;
    dio.options.connectTimeout = Duration(seconds: 30);
    dio.options.receiveTimeout = Duration(seconds: 30);
    return dio;
  }
}
