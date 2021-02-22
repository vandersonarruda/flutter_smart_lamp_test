import 'package:flutter/material.dart';

import '../constants.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({
    Key key,
    this.title,
    this.body,
    this.icon,
  }) : super(key: key);

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 50,
        ),
        SizedBox(height: 30),
        Text(
          title,
          style: kTitleMessageStyle,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        Text(
          body,
          style: kBodyMessageStyle,
          textAlign: TextAlign.center,
        ),
      ],
    ));
  }
}
