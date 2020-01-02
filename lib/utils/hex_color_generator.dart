import 'package:flutter/material.dart';

class HexColorGenerator extends Color {
  HexColorGenerator({@required this.hexColorString})
      : super(_stringToHex(hexColorString));
  String hexColorString;

  static int _stringToHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }
}
