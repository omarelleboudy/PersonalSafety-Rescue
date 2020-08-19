import 'package:flutter_android_pet_tracking_background_service/models/api_response.dart';
import 'package:flutter_android_pet_tracking_background_service/models/login.dart';
import 'package:flutter_android_pet_tracking_background_service/others/StaticVariables.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:developer';

class LoginService {
  static var token = '';

  Future<bool> saveTokenPreference(String token, String key) async {
    final prefs = await SharedPreferences.getInstance();
    final value = token;
    prefs.setString(key, value);
  }

  // Logging In
  Future<APIResponse<dynamic>> Login(LoginCredentials item) {
    String finalString = StaticVariables.API + '/api/Account/Login';

    print("Trying to login to " + finalString);

    const headers = {'Content-Type': 'application/json'};

    return http
        .post(finalString, headers: headers, body: json.encode(item.toJson()))
        .then((data) {
      if (data.statusCode == 200) {
        Map userMap = jsonDecode(data.body);
//        APIResponse<LoginResponse> test =
        var APIresult = APIResponse.fromJson(userMap);
        var retrievedToken =
        userMap['result']['authenticationDetails']['token'];
        var loginName =
        userMap['result']['accountDetails']['fullName'];
        StaticVariables.prefs.setString("fullname", loginName);
        saveTokenPreference(retrievedToken, "token");

        print('From Login Service:  ${APIresult.status}');

        token = retrievedToken;
        print(" retrieved token from login service:  " + token);
        print('From Login Service:  ${APIresult.hasErrors}');

        return APIresult;
      } else {
        print("Tried to login but failed ;_;");
      }
      return APIResponse<dynamic>(
          hasErrors: true, messages: "An Error Has Occured");
    }).catchError((_) => APIResponse<dynamic>(
        hasErrors: true, messages: "An Error Has Occured"));
  }
}
