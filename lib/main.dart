import 'package:flutter/material.dart';
import 'package:flutter_android_pet_tracking_background_service/screens/home.dart';
import 'package:flutter_android_pet_tracking_background_service/services/service_forgetpassword.dart';
import 'package:flutter_android_pet_tracking_background_service/services/service_login.dart';

import 'Auth/logout.dart';
import 'others/GlobalVar.dart';
import 'others/StaticVariables.dart';
import 'package:get_it/get_it.dart';

import 'utils/LatLngWrapper.dart';

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

void setupLocator() {
  GetIt.instance.registerLazySingleton(() => LoginService());
  GetIt.instance.registerLazySingleton(() => ForgetPasswordService());
}
