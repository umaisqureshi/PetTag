import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SmallActionButtons extends StatelessWidget {
  SmallActionButtons({
    this.icon,
    this.height,
    this.onPressed,
    this.width,
  });

  VoidCallback onPressed;
  Widget icon;
  double height;
  double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        
      ),
      child: RawMaterialButton(
        onPressed: onPressed,
        fillColor: Color(0xFFFDF7F7),
        constraints: BoxConstraints.tightFor(
          height: height,
          width: width,
        ),
        elevation: 3,
        padding: EdgeInsets.all(8),
        shape: CircleBorder(),
        child: Center(child: icon),
      ),
    );
  }
}
