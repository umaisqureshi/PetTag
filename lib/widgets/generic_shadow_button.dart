import 'package:flutter/material.dart';

class GenericBShadowButton extends StatelessWidget {
  GenericBShadowButton({this.buttonText, this.onPressed,this.width,this.height});
  final String buttonText;
  final VoidCallback onPressed;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Container(
        alignment: Alignment.center,
        width: width??MediaQuery.of(context).size.width/2.5,
        height: height ?? 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(0, 4),
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFFFF1432),
              Color(0xFFFE9315),
            ],
          ),
        ),
        child: Text(
          buttonText ?? 'no text',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      onPressed: onPressed,
    );
  }
}
