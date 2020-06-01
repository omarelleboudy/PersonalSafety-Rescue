import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_android_pet_tracking_background_service/communication/android_communication.dart';
import 'package:flutter_android_pet_tracking_background_service/utils/AndroidCall.dart';
import 'package:flutter_android_pet_tracking_background_service/utils/LatLngWrapper.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_android_pet_tracking_background_service/models/api_response.dart';
import 'package:flutter_android_pet_tracking_background_service/others/GlobalVar.dart';
import 'package:flutter_android_pet_tracking_background_service/services/SocketHandler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

import '../componants/color.dart';
import '../componants/mediaQuery.dart';
import '../others/StaticVariables.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_android_pet_tracking_background_service/Auth/logout.dart';
import 'package:flutter_android_pet_tracking_background_service/componants/mediaQuery.dart';
import 'package:flutter_android_pet_tracking_background_service/componants/theme.dart';
import 'package:flutter_android_pet_tracking_background_service/componants/title_text.dart';
import 'package:flutter_svg/svg.dart';

import 'dart:math';

class Home extends StatefulWidget {
  Home({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _HomeState createState() => _HomeState();

}

class _HomeState extends State<Home> with TickerProviderStateMixin {

  static const methodChannel = const MethodChannel(METHOD_CHANNEL);
  bool isTrackingEnabled = false;
  bool isServiceBounded = false;
  List<LatLng> latLngList = [];
  final Set<Polyline> _polylines = {};
  AndroidCommunication androidCommunication = AndroidCommunication();

  GoogleMapController googleMapController;

  LatLng _center = const LatLng(45.521563, -122.677433);

  @override
  void initState() {

    super.initState();

    //_invokeServiceInAndroid();

    //_stopServiceInAndroid();

    _setAndroidMethodCallHandler();
    //_isServiceBound();
    _invokeServiceInAndroid();

    SocketHandler.ConnectToClientChannel();
    SocketHandler.ConnectToLocationChannel();

    Timer timer;

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if(GlobalVar.Get("activerequeststate", "") == "Cancelled") {
        timer.cancel();
      }
      DoSearchAnimation();
    });
  }

//  @override
//  Widget build(BuildContext context) {
//    return MaterialApp(
//      title: 'Background Service',
//      home: Scaffold(
//          body: !isServiceBounded
//              ? CircularProgressIndicator()
//              : getInitialWidget(context)),
//      debugShowCheckedModeBanner: false,
//    );
//  }

  Center getInitialWidget(BuildContext context) {
    return Center(
      heightFactor: 50,
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 500,
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                initialCameraPosition:
                CameraPosition(target: _center, zoom: 2.0),
                polylines: _polylines,
                compassEnabled: true,
              ),
            ),
            !isTrackingEnabled
                ? RaisedButton(
              child: Text('Track my pet'),
              onPressed: () {
                _invokeServiceInAndroid();
              },
            )
                : RaisedButton(
              child: Text('Stop tracking my pet'),
              onPressed: () {
                _stopServiceInAndroid();
              },
            )
          ],
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController googleMapController) {
    this.googleMapController = googleMapController;
  }

  void _invokeServiceInAndroid() {
    androidCommunication.invokeServiceInAndroid().then((onValue) {
      setState(() {
        isTrackingEnabled = true;
      });
    });
  }

  void _stopServiceInAndroid() {
    androidCommunication.stopServiceInAndroid().then((onValue) {
      setState(() {
        isTrackingEnabled = false;
      });
    });
  }

  Future _isPetTrackingEnabled() async {
    if (Platform.isAndroid) {
      bool result = await methodChannel.invokeMethod("isPetTrackingEnabled");
      setState(() {
        isTrackingEnabled = result;
      });
      debugPrint("Pet Tracking Status - $isTrackingEnabled");
    }
  }

  Future _isServiceBound() async {
    if (Platform.isAndroid) {
      debugPrint("ServiceBound Called from init");
      bool result = await methodChannel.invokeMethod("serviceBound");
      debugPrint("Result from ServiceBound call - $result");
      setState(() {
        isServiceBounded = result;
        if (isServiceBounded) {
          _isPetTrackingEnabled();
        }
      });
      debugPrint("Pet Tracking Status - $isTrackingEnabled");
    }
  }

  Future<dynamic> _androidMethodCallHandler(MethodCall call) async {
    switch (call.method) {
      case AndroidCall.PATH_LOCATION:
        var pathLocation = jsonDecode(call.arguments);
        LatLng latLng = LatLngWrapper.fromAndroidJson(pathLocation);
        latLngList.add(latLng);
        if (latLngList.isNotEmpty) {
          setState(() {
            if (latLngList.length > 2) {
              var bounds = LatLngBounds(
                  southwest: latLngList.first, northeast: latLngList.last);
              var cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 25.0);
              googleMapController.animateCamera(cameraUpdate);
            }
            _polylines.add(Polyline(
              polylineId: PolylineId(latLngList.first.toString()),
              visible: true,
              points: latLngList,
              color: Colors.green,
              width: 2,
            ));
            _center = latLngList.last;
          });
        }
        debugPrint("Wrapper here --> $latLng");

        print("Called SendLocationToServer from native Android code.");
        SocketHandler.SendLocationToServer(latLng.latitude, latLng.longitude);
        break;

    }
  }

  void _setAndroidMethodCallHandler() {
    methodChannel.setMethodCallHandler(_androidMethodCallHandler);
  }

  //-------------------------------------------------------------------------------

  int circle1Radius = 110, circle2Radius = 130, circle3Radius = 150;

  AnimationController _circle1FadeController, _circle1SizeController;
  Animation<double> _radiusAnimation, _fadeAnimation;

  String clientName = "Walter White", clientEmail = "Heisenberg@ABQ.com",
      clientPhoneNumber = "01000000991", clientBloodType = "A+",
      clientMedicalHistory = "Lung Cancer",
      clientHomeAddress = "308 Negra Arroyo Lane, Albuquerque,"
          " New Mexico, 87104";

  int clientAge = 51;

  Timer periodicalTimer;

  void PeriodicallyUpdateInfo()
  {

    periodicalTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      try {
        FillRequestData(GlobalVar.Get("requestresult", new APIResponse()));
      }
      catch(Exception) {
        //print("Couldn't fill info. \n Exception is: " + Exception.toString());
      }
    });

  }

  @override
  Widget _icon(IconData icon, {Color color = LightColor.iconColor}) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(13)),
      ),
      child: Icon(
        icon,
        color: color,
      ),
    );
  }

  Widget _appBar() {
    return Container(
      padding: AppTheme.padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
//          RotatedBox(
//            quarterTurns: 4,
//            child: IconButton(
//              icon: Icon(
//                Icons.dehaze,
//              ),
//              color: Colors.black54,
////              onPressed: () {
////                _drawer();
////              },
//            ),
//          ),
          Padding(
            padding: const EdgeInsets.only(top:50, left: 300),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(13)),
              child: Container(
                  decoration: BoxDecoration(
                      color: greyIcon, borderRadius: BorderRadius.circular(20)),
                  child: IconButton(
                    icon: Icon(Icons.lock),
                    onPressed: () async {
                      //_save("0");
                      StaticVariables.prefs.remove('token');
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Logout()));
                    },
                  )),
            ),
          )
        ],
      ),
    );
  }

  Widget _requestsListView(BuildContext context)
  {

    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 100,
                maxHeight: 400
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  _SOSElementData("User Depressito", "Near 26th St.", "15/4/2020"),
                  _SOSElementData("User Depressito", "Near 26th St.", "15/4/2020"),
                  _SOSElementData("User Depressito", "Near 26th St.", "15/4/2020"),

                ],
              ),
            ),
          );
        },
      ),
    );

//    return ListView.builder(
//      itemCount: 5,
//      itemBuilder: (context, index) {
//        return ListTile(
//          title: _SOSElementData(),
//        );
//      },
//    );

  }

  Widget _requestView()
  {

    return Padding(
      padding: const EdgeInsets.only(top: 250),
      child: Container(
        height: displayHeight(context) * .68,
        width: displayWidth(context) * .9,
        decoration: BoxDecoration(
          color: Color(0xff3d4256),
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Stack(
          children: <Widget>[

            Container(
              height: displayHeight(context) * .02,
              width: displayWidth(context) * .9,
              decoration: BoxDecoration(
                color: Color(0xffF18C08),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              ),
              child: Stack(
                children: <Widget>[


                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top:35, left: 30),
              child: Text(
                "Current Mission",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,)
                ,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 100, left: 25),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50.0),
                child: Image(
                  width: 50,
                  image: AssetImage('assets/images/ww.png'),
                ),
              )
            ),
            Padding(
              padding: const EdgeInsets.only(top: 105, left: 90),
              child: Text(
                clientName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white
                )
              ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 128, left: 90),
              child: Text(
                  clientEmail,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: Color(0xffb7b7b7)
                  )
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 105, left: 250),
              child: Container(
                height: displayHeight(context) * .04,
                width: displayWidth(context) * .2,
                decoration: BoxDecoration(
                  color: Color(0xff3d4256),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xff6b7499),
                      blurRadius: 0.5, // has the effect of softening the shadow
                      spreadRadius: 0.5, // has the effect of extending the shadow
                      offset: Offset(
                        0, // horizontal, move right 10
                        0, // vertical, move down 10
                      ),
                    )],
                ),
                child: Stack(
                  children: <Widget>[
                Center(
                  child: Text(
                    clientAge.toString() + " Years",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          color: Colors.white
                      )
                  ),
                )

                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 175, left: 50, right: 50),
              child: Container(
                height: displayHeight(context) * .004,
                width: displayWidth(context) * .8,
                decoration: BoxDecoration(
                  color: Color(0xff3d4256),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xff303444),
                      blurRadius: 0.5, // has the effect of softening the shadow
                      spreadRadius: 0.5, // has the effect of extending the shadow
                      offset: Offset(
                        0.5, // horizontal, move right 10
                        0.5, // vertical, move down 10
                      ),
                    )],
                ),
                child: Stack(
                  children: <Widget>[


                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 205, left: 30),
              child: Text(
                  "Phone Number",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white
                  )
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 230, left: 30),
              child: Text(
                  clientPhoneNumber,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff9da0ad)
                  )
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(top: 200, left: 280),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Color(0xff303444),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 0.5, // has the effect of softening the shadow
                          spreadRadius: 0.5, // has the effect of extending the shadow
                          offset: Offset(
                            0.5, // horizontal, move right 10
                            0.5, // vertical, move down 10
                          ),
                        )],
                    ),
                    child: Stack(
                      children: <Widget>[
                        Center(
                          child: Image(
                            width: 20,
                            image: AssetImage('assets/images/whitephone.png'),
                          ),
                        ),

                      ],
                    ),
                  )
                )
            ),
            Padding(
              padding: const EdgeInsets.only(top: 270, left: 30),
              child: Text(
                  "Blood Type",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white
                  )
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 295, left: 30),
              child: Text(
                  clientBloodType,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff9da0ad)
                  )
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 335, left: 30),
              child: Text(
                  "Medical History",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white
                  )
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 360, left: 30),
              child: Text(
                  clientMedicalHistory,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff9da0ad)
                  )
              ),

            ),
            Padding(
              padding: const EdgeInsets.only(top: 400, left: 30),
              child: Text(
                  "Home Address",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white
                  )
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 425, left: 30, right: 100),
              child: Text(
                  clientHomeAddress,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff9da0ad)
                  )
              ),

            ),
            Padding(
                padding: const EdgeInsets.only(top: 400, left: 280),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Color(0xff303444),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 0.5, // has the effect of softening the shadow
                            spreadRadius: 0.5, // has the effect of extending the shadow
                            offset: Offset(
                              0.5, // horizontal, move right 10
                              0.5, // vertical, move down 10
                            ),
                          )],
                      ),
                      child: Stack(
                        children: <Widget>[
                          Center(
                            child: Image(
                              width: 15,
                              image: AssetImage('assets/images/locationwhite.png'),
                            ),
                          ),

                        ],
                      ),
                    )
                )
            ),
            Padding(
              padding: const EdgeInsets.only(top: 500),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    height: 50,
                    width: 310,
                    child: Center(
                      child: ButtonTheme(
                        height: 50,
                        minWidth: 300,
                        child: RaisedButton(
                            child: Text(
                                "ARRIVED",
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white
                                )
                            ),
                          color: Color(0xff494f68),
//                          disabledColor: Color(0x777fa3),
                          onPressed: SocketHandler.SolveSOSRequest,
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            ),
          ],
        ),
      ),
    );

  }

  Widget _rescuerData() {
    return Container(
      height: displayHeight(context) * .1,
      width: displayWidth(context) * .9,
      decoration: BoxDecoration(
        color: Color(0xff006E90),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Stack(
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.only(top: 20.0, left: 15),
              child: Text(
                "Agent Jesse Pinkman",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              )),
          Padding(
              padding: const EdgeInsets.only(top: 45, left: 15),
              child: Text(
                "Online",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                    color: Colors.white),
              )),

          Padding(
            padding: const EdgeInsets.only(top:20,left:290),
            child: Container(
                height:50,
                width: 50,

                child: SvgPicture.asset("assets/images/badge.svg")


            ),
          )
        ],
      ),
    );
  }

  Widget _SOSElementData(String requestTypeName, String areaName, String date) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 5, right: 5),
      child: Container(
        height: displayHeight(context) * .1,
        width: displayWidth(context) * .9,
        decoration: BoxDecoration(
          color: Color(0xfff4f4f4),
          boxShadow: [
            BoxShadow(
              color: Color(0xff545454),
              blurRadius: 5.0, // has the effect of softening the shadow
              spreadRadius: 1.0, // has the effect of extending the shadow
              offset: Offset(
                2.0, // horizontal, move right 10
                2.0, // vertical, move down 10
          ),
            )],
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top:20,left:10),
              child: Container(
                  height:50,
                  width: 50,

                  child: SvgPicture.asset("assets/images/badge.svg")


              ),
      ),
            Padding(
                padding: const EdgeInsets.only(top: 15.0, left: 70),
                child: Text(
                  requestTypeName,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                )),
            Padding(
                padding: const EdgeInsets.only(top: 45, left: 70),
                child: Text(
                  areaName + " • " + date,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w300,
                      color: Color(0xff777777)),
                ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Never called
    print("Disposing search page");
    _circle1FadeController.dispose();
    _circle1SizeController.dispose();
    super.dispose();

  }

  Widget _title() {
    return Container(
        margin: AppTheme.padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TitleText(
                  text: 'Personal Rescuer',
                  fontSize: 27,
                  fontWeight: FontWeight.w400,
                ),
                TitleText(
                  text: 'Rescuer Client',
                  fontSize: 15,
                  color: greyIcon,
                  fontWeight: FontWeight.w300,
                ),
              ],
            ),
          ],
        ));
  }

  alertDialog() {
    return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        backgroundColor: GetColorBasedOnState(),
        content: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Waiting",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    )),
              ],
            ),
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Container(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Waiting for an SOS request...",
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w300),
                      )),
                ),
              ],
            ),
          ],
        ));
  }

  Future<bool> _onBackPressed() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Accent1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            title: Text('Exit Application?', style: TextStyle(color: primaryColor)),
            content: Text('You are going to exit the application.',
                style: TextStyle(color: primaryColor)),
            actions: <Widget>[
              FlatButton(
                child: Text('NO', style: TextStyle(color: primaryColor)),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              FlatButton(
                child: Text('YES', style: TextStyle(color: primaryColor)),
                onPressed: () {
                  SystemNavigator.pop();
                },
              ),
            ],
          );
        });
  }

  bool RequestsAreEmpty()
  {

    try {

      //print("activerequestid is: " + GlobalVar.Get("activerequestid", -1).toString());

      if ((GlobalVar.Get("activerequestid", -1)) == -1)
        return true;

      return false;

    }
    catch(ex)
    {
      print("Error getting request ID from prefs. \n Exception: " + ex.toString());
      return true;
    }

  }

  void FillRequestData(APIResponse result)
  {
    this.setState(() {

      clientName = result.result['userFullName'];
      clientHomeAddress = result.result['userSavedAddress'];
      clientMedicalHistory = result.result['userMedicalHistoryNotes'];
      clientBloodType = result.result['userBloodTypeName'];
      clientPhoneNumber = result.result['userPhoneNumber'];
      clientEmail = result.result['userEmail'];
      clientAge = result.result['userAge'];

    });

  }

  double beginValue = 100, endValue = 150, beginFade = 1, endFade = 0.2, tmpValue, tmpValue2;

  Color GetColorBasedOnState()
  {

    Color toReturn = Color(0xff04a1d1);

    return toReturn;

  }

  Color requestColor = Color.fromRGBO(255, 43, 86, 1.0);

  void DoSearchAnimation() async
  {

    if (GlobalVar.Get("activerequeststate", "") != "Cancelled") {
      _circle1FadeController = new AnimationController(duration: new Duration(
          milliseconds: 2000
      ),
          vsync: this);

      _circle1SizeController = new AnimationController(duration: new Duration(
          milliseconds: 2000
      ),
          vsync: this);

      _radiusAnimation =
          new Tween<double>(begin: beginValue, end: endValue).animate(
              new CurvedAnimation(curve: Curves.easeInSine,
                  parent: _circle1SizeController)
          );

      _fadeAnimation =
          new Tween<double>(begin: beginFade, end: endFade).animate(
              new CurvedAnimation(curve: Curves.easeInSine,
                  parent: _circle1FadeController)
          );

      _circle1SizeController.addListener(() {
        if (this.mounted) {
          this.setState(() {});
        }
      });

      _circle1FadeController.addListener(() {
        if (this.mounted) {
          this.setState(() {});
        }
      });

      _circle1FadeController.forward();
      _circle1SizeController.forward();

      tmpValue = beginValue;
      beginValue = endValue;
      endValue = tmpValue;

      tmpValue2 = beginFade;
      beginFade = endFade;
      endFade = tmpValue2;
    }

  }


  @override
  int _cIndex = 0;

  void _incrementTab(index) {
    if (this.mounted) {
      this.setState(() {});
      setState(() {
        _cIndex = index;
      });
    }
  }

  Widget build(BuildContext context) {
    PeriodicallyUpdateInfo();
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
          body: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: _appBar(),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 70),
                child: _title(),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 150, left: 20, right: 20),
                child: _rescuerData(),
              ),
              Center(
                child: Visibility(
                  visible: RequestsAreEmpty(),
                    child: Container(
                      child: CircleAvatar(
                        child: SvgPicture.asset(
                          "assets/images/place-24px.svg",
                          color: Colors.white,
                          width: 100,
                          height: 150,
                        ),
                        radius: _radiusAnimation == null? beginValue : _radiusAnimation.value,
                        backgroundColor: GetColorBasedOnState().withOpacity(_fadeAnimation == null? 1 : _fadeAnimation.value),
                      ),
                    ),
                ),
              ),
              Center(
                child: Visibility(
                  visible: !RequestsAreEmpty(),
                  child: _requestView(),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 600),
                child: Visibility(
                  visible: RequestsAreEmpty(),
                    child: Container(
                      height: 200,
                      alignment: Alignment.bottomCenter,
                      child: alertDialog(),
                    ),
                  ),
              ),
              ],
              ),
          ),
    );
  }
}
