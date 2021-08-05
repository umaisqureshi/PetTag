import 'package:flutter/material.dart';

import '../constant.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  CustomTextField(
      {this.containerHeight: 0,
      this.containerWidth: 0,
      this.paddingLeft: 0,
      this.paddingRight: 0,
      this.paddingTop: 0,
      this.paddingBottom: 0,
      this.textFieldFontSize: 0,
      this.hintText,
      this.hintTextColor});

  final double containerHeight;
  final double containerWidth;
  final double paddingLeft;
  final double paddingRight;
  final double paddingTop;
  final double paddingBottom;
  final double textFieldFontSize;
  final String hintText;
  final Color hintTextColor;

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.containerHeight,
      padding: EdgeInsets.only(
        top: widget.paddingTop,
        bottom: widget.paddingBottom,
        left: widget.paddingLeft,
        right: widget.paddingRight,
      ),
      //padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Theme(
        data: ThemeData(inputDecorationTheme: InputDecorationTheme()),
        child: TextField(
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
          decoration: customInputDecoration(
              hintText: widget.hintText, hintTextColor: widget.hintTextColor),
        ),
      ),
    );
  }
}
