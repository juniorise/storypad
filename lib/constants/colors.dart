import 'package:flutter/material.dart';

/// ref: http://fashioncambodia.blogspot.com/2015/11/7-colors-for-every-single-day-of-week.html
const Map<int, Color> colorsByDay = {
  DateTime.monday: Color(0xFFE38A41),
  DateTime.tuesday: Color(0xFF9341B1),
  DateTime.wednesday: Color(0xFFA3AA49),
  DateTime.thursday: Color(0xFF397C2D),
  DateTime.friday: Color(0xFF5080D7),
  DateTime.saturday: Color(0xFF6E183B),
  DateTime.sunday: Color(0xFFE5333A),
};

const List<ColorSwatch> materialColors = const <ColorSwatch>[
  Colors.red,
  Colors.pink,
  Colors.purple,
  Colors.deepPurple,
  Colors.indigo,
  Colors.blue,
  Colors.lightBlue,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.lightGreen,
  Colors.lime,
  Colors.yellow,
  Colors.amber,
  Colors.orange,
  Colors.deepOrange,
  Colors.brown,
  Colors.grey,
  Colors.blueGrey,
];

const List<ColorSwatch> accentColors = const <ColorSwatch>[
  Colors.redAccent,
  Colors.pinkAccent,
  Colors.purpleAccent,
  Colors.deepPurpleAccent,
  Colors.indigoAccent,
  Colors.blueAccent,
  Colors.lightBlueAccent,
  Colors.cyanAccent,
  Colors.tealAccent,
  Colors.greenAccent,
  Colors.lightGreenAccent,
  Colors.limeAccent,
  Colors.yellowAccent,
  Colors.amberAccent,
  Colors.orangeAccent,
  Colors.deepOrangeAccent,
];

const List<ColorSwatch> fullMaterialColors = const <ColorSwatch>[
  const ColorSwatch(0xFFFFFFFF, {500: Colors.white}),
  const ColorSwatch(0xFF000000, {500: Colors.black}),
  Colors.red,
  Colors.redAccent,
  Colors.pink,
  Colors.pinkAccent,
  Colors.purple,
  Colors.purpleAccent,
  Colors.deepPurple,
  Colors.deepPurpleAccent,
  Colors.indigo,
  Colors.indigoAccent,
  Colors.blue,
  Colors.blueAccent,
  Colors.lightBlue,
  Colors.lightBlueAccent,
  Colors.cyan,
  Colors.cyanAccent,
  Colors.teal,
  Colors.tealAccent,
  Colors.green,
  Colors.greenAccent,
  Colors.lightGreen,
  Colors.lightGreenAccent,
  Colors.lime,
  Colors.limeAccent,
  Colors.yellow,
  Colors.yellowAccent,
  Colors.amber,
  Colors.amberAccent,
  Colors.orange,
  Colors.orangeAccent,
  Colors.deepOrange,
  Colors.deepOrangeAccent,
  Colors.brown,
  Colors.grey,
  Colors.blueGrey
];
