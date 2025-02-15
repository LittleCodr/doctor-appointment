import 'package:doctro/constant/common_function.dart';
import 'package:dio/dio.dart' hide Headers;

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
    if (error.response?.statusCode == 401 && error.response?.data['msg'] != null) {
      return CommonFunction.toastMessage('${error.response!.data['msg'].toString()}');
    } else if (error.response?.data['error'] != null) {
      return CommonFunction.toastMessage('${error.response!.data['error']}');
    } else if (error.type == DioExceptionType.badResponse) {
      if (error.response?.data['msg'] != null) {
        print(error.response!.data['msg'].toString());
        return CommonFunction.toastMessage('${error.response!.data['msg'].toString()}');
      } else if (error.response?.data['message'] != null) {
        print(error.response!.data['message'].toString());
        return CommonFunction.toastMessage('${error.response!.data['message'].toString()}');
      }
    } else if (error.type == DioExceptionType.unknown) {
      print(error.response!.data['msg'].toString());
      return CommonFunction.toastMessage('${error.response!.data['msg'].toString()}');
    } else if (error.type == DioExceptionType.cancel) {
      print(error.response!.data['msg'].toString());
      return CommonFunction.toastMessage('Request was cancelled');
    } else if (error.type == DioExceptionType.connectionError) {
      print(error.response!.data['msg'].toString());
      return CommonFunction.toastMessage('Connection failed. Please check internet connection');
    } else if (error.type == DioExceptionType.connectionTimeout) {
      print(error.response!.data['msg'].toString());
      return CommonFunction.toastMessage('Connection timeout');
    } else if (error.type == DioExceptionType.badCertificate) {
      print(error.response!.data['msg'].toString());
      return CommonFunction.toastMessage('${error.response!.data['msg']}');
    } else if (error.type == DioExceptionType.receiveTimeout) {
      print(error.response!.data['msg'].toString());
      return CommonFunction.toastMessage('Receive timeout in connection');
    } else if (error.type == DioExceptionType.sendTimeout) {
      print(error.response!.data['msg'].toString());
      return CommonFunction.toastMessage('Receive timeout in send request');
    } else if (error.response?.data['errors']?['name'] != null) {
      return CommonFunction.toastMessage(error.response!.data['errors']['name'][0]);
    } else if (error.response?.data['errors']?['phone'] != null) {
      return CommonFunction.toastMessage(error.response!.data['errors']['phone'][0]);
    } else if (error.response?.data['errors']?['phone_code'] != null) {
      return CommonFunction.toastMessage(error.response!.data['errors']['phone_code'][0]);
    } else if (error.response?.data['errors']?['password'] != null) {
      return CommonFunction.toastMessage(error.response!.data['errors']['password'][0]);
    } else if (error.response?.data['errors']?['email'] != null) {
      return CommonFunction.toastMessage(error.response!.data['errors']['email'][0]);
    } else if (error.response?.data['errors']?['description'] != null) {
      return CommonFunction.toastMessage(error.response!.data['errors']['description'][0]);
    } else if (error.response?.data['errors']?['old_password'] != null) {
      return CommonFunction.toastMessage(error.response!.data['errors']['old_password'][0]);
    } else if (error.response?.data['errors']?['password'] != null) {
      return CommonFunction.toastMessage(error.response!.data['errors']['password'][0]);
    } else if (error.response?.data['errors']?['password_confirmation'] != null) {
      return CommonFunction.toastMessage(error.response!.data['errors']['password_confirmation'][0]);
    } else if (error.response?.data['errors']?['password_confirmation'] != null) {
      return CommonFunction.toastMessage(error.response!.data['errors']['password_confirmation'][0]);
    }
    return _errorMessage;
  }
}
