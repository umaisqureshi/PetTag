import 'package:flutter/material.dart';
import 'package:fsearch/fsearch.dart';
import 'package:pett_tagg/widgets/message_container_search_bar.dart';
import 'package:pett_tagg/widgets/pet_detail_%20list.dart';
import 'package:pett_tagg/widgets/pet_wall_screen.dart';
import '../constant.dart';
import 'pet_detail_screen.dart';
import 'pet_slide_screen.dart';
import 'package:pett_tagg/main.dart';

class PetChatScreen extends StatefulWidget {
  static const String petChatScreenRoute = 'PetChatScreen';

  @override
  _PetChatScreenState createState() => _PetChatScreenState();
}

class _PetChatScreenState extends State<PetChatScreen> {
  InkWell buildAppBarImageIcon(
      {@required String image,
      @required VoidCallback onPressed,
      double width,
      double height}) {
    return InkWell(
      child: Image.asset(
        image,
        width: width,
        height: height,
      ),
      // TODO: implementation left
      onTap: onPressed,
    );
  }

  bool _messages = true;
  bool _petWall = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: sharedPrefs.currentUserPetType == 'Cat'? Colors.blue[600]:appBarBgColor,
          elevation: 0.0,
          // TODO: Implemenetation Left
          leading: GestureDetector(
            child: Container(
                padding: EdgeInsets.only(
                  right: 15,
                  left: 15,
                ),
                child: Image.asset(
                  "assets/2x/dog (1)@2x.png",
                  width: 15,
                  height: 15,
                )),
            onTap: () {
              Navigator.pushNamed(
                  context, PetDetailedScreen.petDetailedScreenRoute);
            },
          ),
          centerTitle: true,
          title: buildAppBarImageIcon(
            image: 'assets/2x/Group 378@2x.png',
            width: 20,
            height: 20,
            onPressed: () {
              Navigator.pushReplacementNamed(
                  context, PetSlideScreen.petSlideScreenRouteName);
            },
          ),
          actions: [
            GestureDetector(
              child: Container(
                  padding: EdgeInsets.only(
                    right: 20,
                    left: 15,
                  ),
                  child: Image.asset(
                    "assets/2x/Icon simple-hipchat@2x.png",
                    width: 22,
                    height: 22,
                  )),
              onTap: () {},
            ),
          ],
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Container(
                height: 50,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FlatButton(
                      onPressed: () {
                        setState(() {
                          _messages = true;
                          _petWall = false;
                        });
                      },
                      splashColor: Colors.transparent,
                      child: Text(
                        "Messages",
                        style: TextStyle(
                            color: _messages ? Colors.black : Colors.brown[100],
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      height: 30,
                      width: 1,
                      color: Colors.pink[100],
                    ),
                    FlatButton(
                      onPressed: () {
                        setState(() {
                          _petWall = true;
                          _messages = false;
                        });
                      },
                      splashColor: Colors.transparent,
                      child: Text(
                        "PetWall",
                        style: TextStyle(
                            color: _petWall ? Colors.black : Colors.brown[200],
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 5),
                height: 1,
                width: MediaQuery.of(context).size.width - 40,
                color: Colors.pink[100],
              ),
              (_messages) ? MessageContainerWithSearchBar() : PetWallScreen(),
            ],
          ),
        ));
  }
}

