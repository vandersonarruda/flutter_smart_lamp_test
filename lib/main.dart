import 'package:flutter/material.dart';
import 'package:smart_lamp_app/constants.dart';
import 'package:smart_lamp_app/pages/home_page.dart';

void main() {
  runApp(LampApp());
}

class LampApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Lamp',
      theme: ThemeData(
          appBarTheme: AppBarTheme(elevation: 0),
          primaryColor: kPrimaryColor,
          // brightness: Brightness.dark,
          // primarySwatch: Colors.blueGrey,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: "SF"),
      home: HomePage(),
    );
  }
}
