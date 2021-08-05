import 'package:flutter/material.dart';
import 'package:pett_tagg/widgets/signInDialog.dart';
import '../constant.dart';

class ScreenTopSection extends StatelessWidget {
  ScreenTopSection(
      {this.containerWidth, this.containerHeight, this.topPadding: 90});

  double containerHeight;
  double containerWidth;
  double topPadding;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: topPadding),
      // TODO: here dynamic screen setting is left
      width: containerWidth,
      height: containerHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 70,
            height: 70,
            child: Image.asset(
              'assets/2x/Group 378@2x.png',
            ),
          ),
          customSizeBox(height: 30),
          Text(
            'Connect with Social Media',
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
          customSizeBox(height: 15),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context)=>SignInDialog(),
                    );
                  },
                  child: getHomeScreenImage('assets/2x/Group 246@2x.png',
                      circleRadius: 70,
                      imageWidth: 47,
                      imageHeight: 47,
                      circleSize: 25,
                      isFullOpacity: true),
                ),
                customSizeBox(height: 30),
                getHomeScreenImage('assets/2x/Group 247@2x.png',
                    circleRadius: 70,
                    imageWidth: 47,
                    imageHeight: 47,
                    circleSize: 25,
                    isFullOpacity: true),
              ],
            ),
          ),
          customSizeBox(height: 15),
          // showing heart image
          getHomeScreenImage(
            'assets/2x/Group 249@2x.png',
            isFullOpacity: true,
            circleSize: 20,
          ),
        ],
      ),
    );
  }
}
