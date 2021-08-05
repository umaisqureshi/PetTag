import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/cupertino.dart';

class EmailNotification extends StatefulWidget {
  static const String emailNotificationScreenRoute = "EmailNotification";
  @override
  _EmailNotificationState createState() => _EmailNotificationState();
}

class _EmailNotificationState extends State<EmailNotification> {
  bool newMatch = false;
  bool newMessage = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          splashColor: Colors.transparent,
          icon: Icon(
            Icons.arrow_back,
            color: Colors.redAccent,
            size: 22,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Notification Settings",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 5,
            ),
            Text(
              "Email Notification",
              style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 17),
            ),
            buildCupertinoOptions(
              text: "New Matches",
              onChanged: (bool value) {
                setState(() {
                  newMatch = value;
                });
              },
              value: newMatch,
            ),
            buildCupertinoOptions(
              text: "New Messages",
              onChanged: (bool value) {
                setState(() {
                  newMessage = value;
                });
              },
              value: newMessage,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCupertinoOptions({String text, onChanged, value}) {
    return Padding(
      padding: const EdgeInsets.only(left: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 15),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.teal,
            inactiveTrackColor: Colors.black26,
          ),
        ],
      ),
    );
  }
}
