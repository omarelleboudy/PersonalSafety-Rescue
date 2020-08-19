import 'package:shared_preferences/shared_preferences.dart';

class StaticVariables {

  //static const


  static const
  API = 'https://personalsafety.azurewebsites.net/', //Publish
  //API = 'http://192.168.1.4:5000', //Test
      rescuerServerURL = API + "/hubs/rescuer",
      locationServerURL = API + "/hubs/location",
      realtimeServerURL = API + "/hubs/realtime";

  static SharedPreferences prefs;

  static Future<void> Init() async
  {

    prefs = await SharedPreferences.getInstance();

  }

}