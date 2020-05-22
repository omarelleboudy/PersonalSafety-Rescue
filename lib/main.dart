import 'package:flutter/material.dart';

import 'package:safety_rescue/Auth/logout.dart';
import 'package:safety_rescue/Auth/login.dart';

import 'package:get_it/get_it.dart';
import 'package:safety_rescue/others/GlobalVar.dart';
import 'package:safety_rescue/screens/home.dart';
import 'package:safety_rescue/services/SocketHandler.dart';
import 'package:safety_rescue/services/service_forgetpassword.dart';

import 'others/StaticVariables.dart';
import 'others/StaticVariables.dart';
import 'services/service_login.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'componants/test.dart';

void setupLocator() {
  GetIt.instance.registerLazySingleton(() => LoginService());
  GetIt.instance.registerLazySingleton(() => ForgetPasswordService());
}

Future<void> main() async {
  //SocketHandler.ConnectSocket();
  setupLocator();
  WidgetsFlutterBinding.ensureInitialized();
  await StaticVariables.Init();
  StaticVariables.prefs.setString("requestresult", "");
  StaticVariables.prefs.setInt("activerequestid", -1);
  GlobalVar.Set("anything", "stringValue");
  var token = StaticVariables.prefs.getString('token');
  print(token);
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: token == null ? Logout() : Home()
//home: Login(),

      ));
}
