import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class LoginCredentials {
  String email;
  String password;

  LoginCredentials({@required this.email, @required this.password});

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "password": password,
    };
  }
}
