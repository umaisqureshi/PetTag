import 'package:flutter/material.dart';

class NewUserTextWidget extends StatelessWidget {
  NewUserTextWidget({
    this.action,
    this.userType,
    this.onTap,
  });

  VoidCallback onTap;
  final String userType;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          child: Text.rich(
            TextSpan(
                text: userType,
                style: TextStyle(
                  color: Colors.white54,
                ),
                children: [
                  TextSpan(
                    text: action,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 15),
                  )
                ]),
          ),
          onTap: onTap,
        ),
      ],
    );
  }
}
