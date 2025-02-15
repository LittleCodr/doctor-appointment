import 'package:dio/dio.dart' hide Headers;
import 'package:fluttertoast/fluttertoast.dart';

class ServerError implements Exception {
  int? _errorCode;
  String _errorMessage = "";

  ServerError.withError({error}) {
    _handleError(error);
  }

  getErrorCode() {
    return _errorCode;
  }

  getErrorMessage() {
    return _errorMessage;
  }

  _handleError(DioException error) {
    if (error.response!.statusCode == 401 && error.response!.data['msg'] != null) {
      return Fluttertoast.showToast(msg: '${error.response!.data['msg'].toString()}');
    } else if (error.response!.data['error'] != null) {
      Fluttertoast.showToast(
        msg: '${error.response!.data['error']}',
      );
      return;
    } else if (error.response!.data['errors']['email'] != null) {
      Fluttertoast.showToast(
        msg: '${error.response!.data['errors']['email'][0]}',
      );
      return;
    } else if (error.response!.data['errors']['name'] != null) {
      Fluttertoast.showToast(msg: '${error.response!.data['errors']['name'][0]}', toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM);
      return;
    } else if (error.response!.data['errors']['phone'] != null) {
      Fluttertoast.showToast(msg: '${error.response!.data['errors']['phone'][0]}', toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM);
      return;
    } else if (error.response!.data['errors']['email'] != null) {
      Fluttertoast.showToast(msg: '${error.response!.data['errors']['email'][0]}', toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM);
      return;
    } else if (error.response!.data['errors']['phone_code'] != null) {
      Fluttertoast.showToast(msg: '${error.response!.data['errors']['phone_code'][0]}', toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM);
      return;
    } else if (error.response!.data['errors']['dob'] != null) {
      Fluttertoast.showToast(msg: '${error.response!.data['errors']['dob'][0]}', toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM);
      return;
    } else if (error.response!.data['errors']['gender'] != null) {
      Fluttertoast.showToast(msg: '${error.response!.data['errors']['gender'][0]}', toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM);
      return;
    } else if (error.response!.data['errors']['password'] != null) {
      Fluttertoast.showToast(msg: '${error.response!.data['errors']['password'][0]}', toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM);
      return;
    } else if (error.response!.data['errors']['time'] != null) {
      Fluttertoast.showToast(msg: '${error.response!.data['errors']['time'][0]}', toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM);
      return;
    } else if (error.response!.data['errors']['date'] != null) {
      Fluttertoast.showToast(msg: '${error.response!.data['errors']['date'][0]}', toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM);
      return;
    } else if (error.response!.data['errors']['payment_type'] != null) {
      Fluttertoast.showToast(msg: '${error.response!.data['errors']['payment_type'][0]}', toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM);
      return;
    } else if (error.response!.data['errors']['review'] != null) {
      Fluttertoast.showToast(msg: '${error.response!.data['errors']['review'][0]}', toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM);
      return;
    } else if (error.response!.data['errors']['rate'] != null) {
      Fluttertoast.showToast(msg: '${error.response!.data['errors']['rate'][0]}', toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM);
      return;
    } else if (error.response!.data['errors']['appointment_id'] != null) {
      Fluttertoast.showToast(msg: '${error.response!.data['errors']['appointment_id'][0]}', toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM);
      return;
    } else if (error.response!.data['errors']['otp'] != null) {
      Fluttertoast.showToast(msg: '${error.response!.data['errors']['otp'][0]}', toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM);
      return;
    } else if (error.response!.data['errors']['appointment_for'] != null) {
      Fluttertoast.showToast(msg: '${error.response!.data['errors']['appointment_for'][0]}', toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM);
      return;
    } else if (error.response!.data['errors']['illness_information'] != null) {
      Fluttertoast.showToast(msg: '${error.response!.data['errors']['illness_information'][0]}', toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM);
      return;
    } else if (error.response!.data['errors']['patient_name'] != null) {
      Fluttertoast.showToast(msg: '${error.response!.data['errors']['patient_name'][0]}', toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM);
      return;
    } else if (error.response!.data['errors']['age'] != null) {
      Fluttertoast.showToast(msg: '${error.response!.data['errors']['age'][0]}', toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM);
      return;
    } else if (error.response!.data['errors']['patient_address'] != null) {
      Fluttertoast.showToast(msg: '${error.response!.data['errors']['patient_address'][0]}', toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM);
      return;
    } else if (error.response!.data['errors']['phone_no'] != null) {
      Fluttertoast.showToast(msg: '${error.response!.data['errors']['phone_no'][0]}', toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM);
      return;
    } else if (error.response!.data['errors']['drug_effect'] != null) {
      Fluttertoast.showToast(msg: '${error.response!.data['errors']['drug_effect'][0]}', toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM);
      return;
    } else if (error.response!.data['errors']['note'] != null) {
      Fluttertoast.showToast(msg: '${error.response!.data['errors']['note'][0]}', toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM);
      return;
    } else if (error.response!.data['errors']['date'] != null) {
      Fluttertoast.showToast(msg: '${error.response!.data['errors']['date'][0]}', toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM);
      return;
    } else if (error.response!.data['errors']['amount'] != null) {
      Fluttertoast.showToast(msg: '${error.response!.data['errors']['amount'][0]}', toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM);
      return;
    } else if (error.response!.data['errors']['image'] != null) {
      Fluttertoast.showToast(msg: '${error.response!.data['errors']['image'][0]}', toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM);
      return;
    } else if (error.response!.data['errors']['medicines'] != null) {
      Fluttertoast.showToast(msg: '${error.response!.data['errors']['medicines'][0]}', toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM);
      return;
    } else if (error.response!.data['errors']['old_password'] != null) {
      Fluttertoast.showToast(msg: '${error.response!.data['errors']['old_password'][0]}', toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM);
      return;
    } else if (error.response!.data['errors']['password_confirmation'] != null) {
      Fluttertoast.showToast(msg: '${error.response!.data['errors']['password_confirmation'][0]}', toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM);
      return;
    } else if (error.response!.data['msg'] != null) {
      Fluttertoast.showToast(msg: '${error.response!.data['msg']}', toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM);
      return;
    } else if (error.response!.data['errors']['phone'] != null) {
      Fluttertoast.showToast(
        msg: '${error.response!.data['errors']['phone'][0]}',
      );
      return;
    } else if (error.response!.data['errors']['confirm'] != null) {
      Fluttertoast.showToast(
        msg: '${error.response!.data['errors']['confirm'][0]}',
      );
      return;
    } else if (error.response!.data['errors']['password'] != null) {
      Fluttertoast.showToast(
        msg: '${error.response!.data['errors']['password'][0]}',
      );
      return;
    } else if (error.type == DioExceptionType.badResponse) {
      if (error.response!.data['msg'] != null) {
        print(error.response!.data['msg'].toString());
        return Fluttertoast.showToast(msg: '${error.response!.data['msg'].toString()}');
      } else if (error.response!.data['message'] != null) {
        print(error.response!.data['message'].toString());
        return Fluttertoast.showToast(msg: '${error.response!.data['message'].toString()}');
      }
    } else if (error.type == DioExceptionType.unknown) {
      print(error.response!.data['msg'].toString());
      return Fluttertoast.showToast(msg: '${error.response!.data['msg'].toString()}');
    } else if (error.type == DioExceptionType.cancel) {
      print(error.response!.data['msg'].toString());
      return Fluttertoast.showToast(msg: 'Request was cancelled');
    } else if (error.type == DioExceptionType.connectionError) {
      print(error.response!.data['msg'].toString());
      return Fluttertoast.showToast(msg: 'Connection failed. Please check internet connection');
    } else if (error.type == DioExceptionType.connectionTimeout) {
      print(error.response!.data['msg'].toString());
      return Fluttertoast.showToast(msg: 'Connection timeout');
    } else if (error.type == DioExceptionType.badCertificate) {
      print(error.response!.data['msg'].toString());
      return Fluttertoast.showToast(msg: '${error.response!.data['msg']}');
    } else if (error.type == DioExceptionType.receiveTimeout) {
      print(error.response!.data['msg'].toString());
      return Fluttertoast.showToast(msg: 'Receive timeout in connection');
    } else if (error.type == DioExceptionType.sendTimeout) {
      print(error.response!.data['msg'].toString());
      return Fluttertoast.showToast(msg: 'Receive timeout in send request');
    }
    return _errorMessage;
  }
}
