import 'dart:io';
import 'package:doctro_patient/api/apis.dart';
import 'package:doctro_patient/api/network_api.dart';
import 'package:doctro_patient/api/retrofit_Api.dart';
import 'package:doctro_patient/model/detail_setting_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Check pattern of baseUrl in Apis',
        () {
      // Define the regex pattern for the URL
      var pattern1 = RegExp(r'^https:\/\/.*\/api\/$');
      var pattern2 = RegExp(r'^http:\/\/.*\/api\/$');

      // Check if the baseUrl matches the pattern
      expect(
        ((pattern1.hasMatch(Apis.baseUrl) || pattern2.hasMatch(Apis.baseUrl)) &&
            Apis.baseUrl != "https://ENTER_YOUR_BASE_URL/api/"),
        isTrue,
        reason: 'The baseUrl does not match the required pattern',
      );
    },
  );

  test(
    'network_api.g.dart file exists',
        () {
      var filePath = 'lib/api/network_api.g.dart';

      // Check if the file exists
      expect(File(filePath).existsSync(), isTrue,
          reason: 'network_api.g.dart file does not exist/\n'
              'Please run the command: flutter pub run build_runner build --delete-conflicting-outputs');
    },
  );

  test(
    'Check if [Apis.setting] endpoint is giving response',
        () async {
          DetailSetting response;
      response = await RestClient(RetroApi().dioData()).settingRequest();
      expect(response.success, true,
          reason: 'The response from ${Apis.setting} is not successful');
    },
  );
}