import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PushNotification extends StatefulWidget {
  static const String pushNotificationScreenRoute = "PushNotification";
  @override
  _PushNotificationState createState() => _PushNotificationState();
}

class _PushNotificationState extends State<PushNotification> {
  bool _newMatch = false;
  bool _messages = false;
  bool _treat = false;
  bool _superTreat = false;
  bool _topPick = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              "Push Notification",
              style: TextStyle(
                  color: Colors.pink,
                  fontWeight: FontWeight.bold,
                  fontSize: 17),
            ),
            buildCupertinoOptions(
              text: "New Matches",
              onChanged: (bool value) {
                setState(() {
                  _newMatch = value;
                });
              },
              value: _newMatch,
            ),
            buildCupertinoOptions(
              text: "Messages",
              onChanged: (bool value) {
                setState(() {
                  _messages = value;
                });
              },
              value: _messages,
            ),
            buildCupertinoOptions(
              text: "Treat",
              onChanged: (bool value) {
                setState(() {
                  _treat = value;
                });
              },
              value: _treat,
            ),
            buildCupertinoOptions(
              text: "Super Treat",
              onChanged: (bool value) {
                setState(() {
                  _superTreat = value;
                });
              },
              value: _superTreat,
            ),
            buildCupertinoOptions(
              text: "Top Pick",
              onChanged: (bool value) {
                setState(() {
                  _topPick = value;
                });
              },
              value: _topPick,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCupertinoOptions({String text, onChanged, value}) {
    return Padding(
      padding: const EdgeInsets.only(left:8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(
                color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 15),
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
