import 'package:flutter/material.dart';
import 'package:pett_tagg/constant.dart';
import 'package:pett_tagg/main.dart';
import 'package:pett_tagg/screens/sign_in_screen.dart';
import 'package:pett_tagg/widgets/generic_shadow_button.dart';
import 'sign_in_screen.dart';
import 'package:pett_tagg/widgets/generic_next_sign_register_button.dart';
import 'package:pett_tagg/main.dart';

class HomeScreen extends StatefulWidget {
  static const String homeScreenRoute = 'HomeScreen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isCatSelected = false;
  bool isDogSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFF774D),
                      Color(0xFFF14B57),
                    ],
                    begin: Alignment.topRight,
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                height: MediaQuery.of(context).size.height / 2.1,
                width: MediaQuery.of(context).size.width,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        "assets/clip_art.png",
                      ),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Container(
                //alignment: Alignment.center,
                padding: EdgeInsets.only(top: 20, left: 0, right: 0, bottom: 0),
                decoration: BoxDecoration(),
                child: Column(
                  children: [
                    SizedBox(
                      height: 50,
                    ),
                    Container(
                      width: 100,
                      height: 100,
                      child: Image.asset('assets/3x/Group 378@3x.png',
                          width: 100, height: 100),
                    ),
                    SizedBox(height: 20),
                    SizedBox(height: 20),
                    Text(
                      'Hey,',
                      style: kwordStyle().copyWith(fontSize: 25),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'You are creating an account for',
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 60),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                getHomeScreenCircularImage(
                                  'assets/newimg.png',
                                ),
                                SizedBox(width: 20),
                                Checkbox(
                                  value: isCatSelected,
                                  checkColor: Colors.black45,
                                  activeColor:
                                      Colors.grey[700].withOpacity(0.3),
                                  onChanged: (value) {
                                    setState(() {
                                      isCatSelected = value;
                                      isDogSelected = value ? false : true;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                getHomeScreenCircularImage('assets/dogArt.png'),
                                SizedBox(width: 20),
                                Checkbox(
                                  value: isDogSelected,
                                  checkColor: Colors.black45,
                                  activeColor:
                                      Colors.grey[700].withOpacity(0.3),
                                  onChanged: (value) {
                                    setState(() {
                                      isDogSelected = value;
                                      isCatSelected = value ? false : true;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 60,
                    ),
                    GenericBShadowButton(
                      buttonText: 'Next',
                      onPressed: () async{
                        if(isCatSelected || isDogSelected){
                          if(isCatSelected){
                            sharedPrefs.petType = "Cat";
                            sharedPrefs.currentUserPetType = "Cat";
                          }
                          else{
                            sharedPrefs.petType = "Dog";
                            sharedPrefs.currentUserPetType = "Dog";
                          }
                          print("PetType : ${sharedPrefs.petType}");
                          print("IsSeen : ${sharedPrefs.isSeen}");
                          //sharedPrefs.isSeen
                          Navigator.pushNamed(
                              context, SignInScreen.secondScreenRoute);
                        }

                      },
                    ),
                    SizedBox(
                      height: 40,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
