import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:safety_rescue/models/api_response.dart';
import 'package:safety_rescue/models/forget_password.dart';
import 'package:safety_rescue/others/StaticVariables.dart';

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
