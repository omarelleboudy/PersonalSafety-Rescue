import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Rescuer {
  int id;
  Text name;
  Text status;
  SvgPicture image;

  Rescuer({
    this.image, this.name, this.id,this.status
  });

}

class RescueData {
  static List<Rescuer> Resc = [
    Rescuer(
      id: 1,
      image: SvgPicture.asset(
        'assets/images/badge.svg',
        width: 40,
        height: 40,
      ),
      status: Text(
        "Online ",
        style: TextStyle(
            fontSize: 12, color: Colors.white, fontWeight: FontWeight.w300),
      ),
      name: Text(
        "Agent John Doe",
        style: TextStyle(color: Colors.white, fontSize: 25),
      ),

    )
  ];
}