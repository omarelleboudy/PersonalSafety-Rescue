import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:safety_rescue/Auth/logout.dart';
import 'package:safety_rescue/componants/mediaQuery.dart';
import 'package:safety_rescue/componants/theme.dart';
import 'package:safety_rescue/componants/title_text.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:math';

import 'package:safety_rescue/componants/color.dart';

class Home extends StatefulWidget {
  Home({Key key, this.title}) : super(key: key);

  final String title;
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
                  text: 'Personal Safety',
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

  Widget _appBar() {
    return Container(
      padding: AppTheme.padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          RotatedBox(
            quarterTurns: 4,
            child: IconButton(
              icon: Icon(
                Icons.dehaze,
              ),
              color: Colors.black54,
//              onPressed: () {
//                _drawer();
//              },
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(13)),
            child: Container(
                decoration: BoxDecoration(
                    color: greyIcon, borderRadius: BorderRadius.circular(20)),
                child: IconButton(
                  icon: Icon(Icons.lock),
                  onPressed: () async {
                    //_save("0");
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.remove('token');
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Logout()));
                  },
                )),
          )
        ],
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
              padding: const EdgeInsets.only(top: 15.0, left: 15),
              child: Text(
                "Agent John Doe",
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
            padding: const EdgeInsets.only(top:20,left:300),
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

  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: _appBar(),
          ),
          _title(),
          _rescuerData(),
        ],
      ),
    );
  }
}
