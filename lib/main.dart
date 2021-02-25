import 'package:flutter/material.dart';
import 'package:smart_lamp_app/pages/home_page.dart';

void main() {
  runApp(LampApp());
}

class LampApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // final String themeDevice =
    // MediaQuery.of(context).platformBrightness == Brightness.light
    //     ? "light"
    //     : "dark";

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Lamp',
      theme: ThemeData(
          appBarTheme: AppBarTheme(elevation: 0),
          primaryColor: Color(0xFF22232C),
          //brightness: Brightness.dark,
          //scaffoldBackgroundColor: Color(0xFFF2F2F7),
          scaffoldBackgroundColor: Color(0xFF22232C),
          // primarySwatch: Colors.blueGrey,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: "SF"),
      home: HomePage(),
    );
  }
}
