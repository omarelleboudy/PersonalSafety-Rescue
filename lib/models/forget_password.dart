import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class ForgetPasswordCredentials {
  String email;

  ForgetPasswordCredentials({@required this.email});

  Map<String, dynamic> toJson() {
    return {
      "email": email,
    };
  }
}
