import 'package:flutter_android_pet_tracking_background_service/models/api_response.dart';
import 'package:flutter_android_pet_tracking_background_service/models/forget_password.dart';
import 'package:flutter_android_pet_tracking_background_service/others/StaticVariables.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgetPasswordService {
  static var result = '';
  // static const API = 'https://personalsafety.azurewebsites.net/';
  static const headers = {'Content-Type': 'application/json'};

  // Logging In
  Future<APIResponse<dynamic>> forgetPassword(ForgetPasswordCredentials item) {
    print('*****************');

    return http
        .get(
            StaticVariables.API +
                '/api/Account/ForgotPassword' +
                '?mail=' +
                item.email,
            headers: headers)
        .then((data) {
      print('??????????????????????');
      if (data.statusCode == 200) {
        Map userMap = jsonDecode(data.body);
        var APIresult = APIResponse.fromJson(userMap);
        print(APIresult.status);
        print(APIresult.result);
        //result = APIresult.result;
        print(APIresult.hasErrors);
        return APIresult;
      } else {
        print('============================');
        print(data.statusCode);
        print("-----------------------------");
      }
      return APIResponse<dynamic>(
          hasErrors: true, messages: "An Error Has Occured");
    }).catchError((_) => APIResponse<dynamic>(
            hasErrors: true, messages: "An Error Has Occured"));
  }
}
