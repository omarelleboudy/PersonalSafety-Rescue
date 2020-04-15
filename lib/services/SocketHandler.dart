import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signalr_client/signalr_client.dart';
import 'package:http/http.dart' as http;

import '../models/api_response.dart';
import '../others/StaticVariables.dart';

class SocketHandler {

  static bool connectionIsOpen = false;
  static HubConnection _hubConnection;

  static Future<void> ConnectToClientChannel() async {

    print("Trying to connect to rescuer channel..");

    final httpOptions = new HttpConnectionOptions(
        accessTokenFactory: () async => await getAccessToken());

    if (_hubConnection == null) {
      _hubConnection = HubConnectionBuilder()
          .withUrl(StaticVariables.clientServerURL, options: httpOptions)
          .build();
      _hubConnection.onclose((error) => connectionIsOpen = false);
      _hubConnection.on("ConnectionInfoChannel", SaveConnectionID_Rescuer);
      _hubConnection.on("RescuerChannel", UpdateRescuerSOSState);
    }

    if (_hubConnection.state != HubConnectionState.Connected) {
      if (_hubConnection.state != HubConnectionState.Disconnected)
        await _hubConnection.stop();
      await _hubConnection.start();
      connectionIsOpen = true;
      //StartSharingLocation("START_LOCATION_SHARING", 11, 15);
    }
  }

  //#region ClientSOSRequest

  static void SaveConnectionID_Rescuer(List<Object> args) {
    print("Connected to rescuer hub! connection ID is: " + args[0].toString());

    StaticVariables.prefs.setString('connectionid_client', args[0].toString());

  }

  static String token = "";
  static bool result = false;
  static var headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token'
  };

  static void UpdateActiveSOSRequestDetails(int requestID)
  {

    //TODO: Make an API call to get that request's info, and fill fields with it.

    GetSOSRequestDetails(requestID.toString());

  }

  static Future<APIResponse<dynamic>> GetSOSRequestDetails(String requestID) {
    print('*****************');

    return http
        .get(StaticVariables.API + '/api/Rescuer/GetSOSRequestDetails' + '?requestId=' + requestID,
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


  static Future<APIResponse<dynamic>> SolveSOSRequest(int requestID) async {
    //String jsonRequest = await GetSOSRequestJson(requestType);

    print("Calling API SolveSOSRequest with requestID " + requestID.toString() + " ..");

    token = StaticVariables.prefs.getString('token');
    return http
        .put(StaticVariables.API + '/api/Rescuer/SolveSOSRequest',
        headers: headers, body: requestID)
        .then((data) {
      if (data.statusCode == 200) {
        Map userMap = jsonDecode(data.body);
        var APIresult = APIResponse.fromJson(userMap);
        print(APIresult.toString());
        print("Solve SOS SUCCESS");
        print(APIresult.result);
//        var parsedJson = json.decode(APIresult.result);
//        prefs.setString("activerequeststate", parsedJson['requestStateName']);
        return APIresult;
      } else {
        print("Solve SOS Failed");
        print(headers);

        print(data.statusCode);
      }

      return APIResponse<dynamic>(
          hasErrors: true,
          messages:
          "Please make sure that:\n \n \n- Email is not taken and is correct.\n- Password is Complex. \n- National ID is 14 digits. \n- Phone Number is 11 digits.");
    }).catchError((_) => APIResponse<dynamic>(
        hasErrors: true,
        messages:
        "Please make sure that:\n \n \n- Email is not taken and is correct.\n- Password is Complex. \n- National ID is 14 digits. \n- Phone Number is 11 digits."));
  }

  static Future<String> GetSOSRequestJson(int authorityType) async {

    String connID = StaticVariables.prefs.getString('connectionid_client');

    String toReturn = "{ \"authorityType\": " + authorityType.toString();

    toReturn += ", \"longitude\": " + 5.toString();

    toReturn += ", \"latitude\": " + 6.toString();

    toReturn += ", \"connectionId\": \"" + connID + "\" }";

    return toReturn;
  }

  static void UpdateRescuerSOSState(List<Object> args) {
    StaticVariables.prefs.setInt("activerequestid", int.parse(args[0]));
    UpdateActiveSOSRequestDetails(StaticVariables.prefs.getInt("activerequestid"));
  }

  //#endregion

  static void StartSharingLocation(
      String functionName, int longitude, int latitude) {
    _hubConnection.invoke(functionName,
        args: <Object>["0101", "1010", longitude, latitude]);
  }

  static Map<String, String> GetFormattedMap(String long, String lat) {
    Map<String, String> mapString = new Map<String, String>();

    mapString.putIfAbsent("longitude", () => long);
    mapString.putIfAbsent("latitude", () => lat);

    return mapString;
  }

  static Future<String> getAccessToken() async {

    String token = StaticVariables.prefs.getString('token');

    return token;
  }
}
