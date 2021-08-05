import 'package:flutter/material.dart';
import 'package:pett_tagg/constant.dart';
import 'package:pett_tagg/widgets/petFood_icon_appbar.dart';
import 'top_picked_pet.dart';
import 'pet_detail_screen.dart';
import 'pet_chat_screen.dart';
import 'package:pett_tagg/widgets/myTreats.dart';
import 'package:pett_tagg/widgets/treat.dart';
import 'package:pett_tagg/widgets/petDate.dart';
import 'package:pett_tagg/widgets/topPicks.dart';

class TreatScreen extends StatefulWidget {
  static const String treatScreenRoute = 'TreatScreen';

  @override
  _TreatScreenState createState() => _TreatScreenState();
}

class _TreatScreenState extends State<TreatScreen> {
  bool _treat = true;
  bool _topPicks = false;
  bool _petDate = false;
  bool _myTreats = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarBgColor,
        elevation: 0.0,
        leading: GestureDetector(
          child: Container(
              padding: EdgeInsets.only(
                right: 15,
                left: 15,
              ),
              child: Image.asset(
                "assets/2x/dog (1)@2x.png",
                width: 20,
                height: 20,
              )),
          onTap: () {
            Navigator.pushNamed(
                context, PetDetailedScreen.petDetailedScreenRoute);
          },
        ),
        centerTitle: true,
        title: PetFoodIconInAppBar(
          isLeft: false,
        ),
        actions: [
          GestureDetector(
            child: Container(
                padding: EdgeInsets.only(
                  right: 30,
                  left: 15,
                ),
                child: Image.asset(
                  "assets/2x/Icon material-location-on@2x.png",
                  width: 17,
                  height: 17,
                )),
            onTap: () {
              //TODO: NAVIGATE TO THE LOCATION SCREEN
            },
          ),
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
            onTap: () {
              Navigator.pushNamed(context, PetChatScreen.petChatScreenRoute);
            },
          ),
        ],
      ),
      body: Container(
        //height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              
              children: [
                Container(
                  width: MediaQuery.of(context).size.width*0.19,
                  child: FlatButton(
                    onPressed: () {
                      setState(() {
                        _treat = true;
                        _myTreats = false;
                        _petDate = false;
                        _topPicks = false;
                      });
                    },
                    padding: EdgeInsets.all(0),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    splashColor: Colors.transparent,
                    child: Text(
                      "Treat",
                      style: TextStyle(
                          color: _treat ? Colors.black : Colors.brown[100],
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Container(
                  height: 30,
                  width: 1,
                  color: Colors.pink,
                ),
                FlatButton(
                  onPressed: () {
                    setState(() {
                      _treat = false;
                      _myTreats = false;
                      _petDate = false;
                      _topPicks = true;
                    });
                  },
                  
                  splashColor: Colors.transparent,
                  child: Text(
                    "Top Picks",
                    style: TextStyle(
                        color: _topPicks ? Colors.black : Colors.brown[200],
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  height: 30,
                  width: 1,
                  color: Colors.pink,
                ),
                FlatButton(
                  onPressed: () {
                    setState(() {
                      _treat = false;
                      _myTreats = false;
                      _petDate = true;
                      _topPicks = false;
                    });
                  },
                  splashColor: Colors.transparent,
                  child: Text(
                    "PetDate",
                    style: TextStyle(
                        color: _petDate ? Colors.black : Colors.brown[200],
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  height: 30,
                  width: 1,
                  color: Colors.pink,
                ),
                FlatButton(
                  onPressed: () {
                    setState(() {
                      _treat = false;
                      _topPicks = false;
                      _petDate = false;
                      _myTreats = true;
                    });
                  },
                  splashColor: Colors.transparent,
                  child: Text(
                    "My Treats",
                    style: TextStyle(
                        color: _myTreats ? Colors.black : Colors.brown[200],
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(bottom: 5),
              height: 1,
              width: MediaQuery.of(context).size.width - 40,
              color: Colors.pink[300],
            ),
            Container(
              child: (_treat)?Treat():(_topPicks)? TopPicks():(_petDate)? PetDate(): MyTreat(),
            ),
          ],
        ),
      ),
    );
  }
}
