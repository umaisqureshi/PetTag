import 'package:flutter/material.dart';
import 'package:pett_tagg/constant.dart';

// class CustomAppBar extends AppBar implements PreferredSizeWidget
class CustomAppBar extends AppBar implements PreferredSizeWidget {
  CustomAppBar(
      {this.backgroundColor: Colors.white,
      this.elevation: 0.0,
      this.context,
      this.appBarHeight});
  Color backgroundColor;
  double elevation;
  BuildContext context;
  double appBarHeight;

  @override
  AppBar build(context) {
    return AppBar(
      backgroundColor: appBarBgColor,
      elevation: elevation,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBarHeight ?? 35.0);
}
// preferredSize = new Size.fromHeight(kToolbarHeight + (bottom?.preferredSize?.height ?? 0.0)),
