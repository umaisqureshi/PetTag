import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  CustomCard({
    this.width,
    this.height,
    this.child,
  });

  final double height;
  final double width;
  Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      child: Card(
        color: Colors.white,
        elevation: 6,
        shadowColor: Colors.black,
        child: child,
      ),
    );
  }
}
