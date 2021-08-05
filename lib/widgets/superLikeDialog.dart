import 'package:flutter/material.dart';
import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:pett_tagg/widgets/localBouncingWidget.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:pett_tagg/constant.dart';

class SuperLikeDialog extends StatefulWidget {
  @override
  _SuperLikeDialogState createState() => _SuperLikeDialogState();
}

class _SuperLikeDialogState extends State<SuperLikeDialog>
    with TickerProviderStateMixin {
  AnimationController _controller;
  Tween<double> _tween = Tween(begin: 0.75, end: 2);
  double h1 = 110;
  double w1 = 110;
  double h2 = 110;
  double w2 = 110;
  double h3 = 110;
  double w3 = 110;
  int _currentPos = 0;

  List<String> listPaths = [
    "assets/dogsAndCats/dog4.png",
    "assets/dogsAndCats/dog3.png",
    "assets/dogsAndCats/dog2.png",
    "assets/dogsAndCats/dog5.png",
    "assets/dogsAndCats/dog6.png",
    "assets/dogsAndCats/dog7.png",
    "assets/dogsAndCats/dog8.png",
    "assets/dogsAndCats/dog9.png",

  ];

  List<String> planList = [
    "Out of Super Likes!",
    "Get 1 Boost every month",
    "Choose Who Sees You",
    "Control Your Profile",
    "Unlimited Likes",
    "Swipe Aroubd The World",
    "Unlimited Rewind",
    "Turn Off Ads",
  ];

  List<String> supportingText = [
    "Get 5 Free Superlikes a day & more",
    "Skip the line & get more matches!",
    "Only be shown to the people you've liked",
    "Limit what other sees with PetTag Plus",
    "Swipe right as much as you can",
    "Passprt to anywhere",
    "Go back and swipe again",
    "Have fu n swiping",
  ];

  bool visibility1 =false;
  bool visibility2 =false;
  bool visibility3 =false;

  initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 700));
  }

  _onPressed(BuildContext context) {
    print("CLICK");
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 2,
      backgroundColor: Color(0xFFFFF6F7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        height: 530,
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 10),
                      padding: EdgeInsets.all(16),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20)),
                        color: Colors.deepPurpleAccent,
                      ),
                      child: Container(
                        width: double.infinity,
                        child: Column(
                          children: [
                            CarouselSlider.builder(
                            itemCount: 8,
                            itemBuilder: (context, index) {
                              return Container(
                                width: double.infinity,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(100),
                                        border: Border.all(
                                            color: Colors.white, width: 2),
                                      ),
                                      child: CircleAvatar(
                                        backgroundImage:
                                            AssetImage(listPaths[index]),
                                        radius: 45,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 1,
                                    ),
                                    Text(
                                      "${planList[index]}",
                                      style: dialogTitle.copyWith(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "${supportingText[index]}",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            options: CarouselOptions(
                                autoPlay: true,
                                enlargeCenterPage: true,
                                autoPlayCurve: Curves.elasticInOut,
                                autoPlayAnimationDuration: Duration(seconds: 1),
                                pageSnapping: true,
                                viewportFraction: 0.9,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    _currentPos = index;
                                  });
                                }),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: listPaths.map((url) {
                              int index = listPaths.indexOf(url);
                              return Container(
                                width: 8.0,
                                height: 8.0,
                                margin: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 2.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentPos == index
                                      ? Color.fromRGBO(255, 255, 255, 0.9)
                                      : Color.fromRGBO(255, 255, 255, 0.4),
                                ),
                              );
                            }).toList(),
                          ),
                            SizedBox(
                              height: 110,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            h3 = 110;
                            h2 = 110;
                            h1 = 120;
                            visibility1=true;
                            visibility2=false;
                            visibility3=false;
                          });
                        },
                        child: AnimatedContainer(
                          duration: Duration(seconds: 1),
                          curve: Curves.elasticOut,
                          height: h1,
                          decoration: BoxDecoration(
                            border: visibility1 ? Border.all(color: Colors.blue[700], width: 2): null, 
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    "1",
                                    style: TextStyle(
                                        fontSize: 25,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text("Boost",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold)),
                                  Text("PKR961.10/ea",
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            h3 = 110;
                            h2 = 120;
                            h1 = 110;
                            visibility1=false;
                            visibility2=true;
                            visibility3=false;
                          });
                        },
                        child: AnimatedContainer(
                          duration: Duration(seconds: 1),
                          curve: Curves.elasticOut,
                          decoration: BoxDecoration(
                            border: visibility2 ? Border.all(color: Colors.blue[700], width: 2): null, 
                          ),
                          child: Container(
                            height: h2,
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    "1",
                                    style: TextStyle(
                                        fontSize: 25,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text("Boost",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold)),
                                  Text("PKR961.10/ea",
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            h3 = 120;
                            h2 = 110;
                            h1 = 110;
                            visibility1=false;
                            visibility2=false;
                            visibility3=true;
                          });
                        },
                        child: Expanded(
                          child: AnimatedContainer(
                            duration: Duration(seconds: 1),
                            curve: Curves.elasticOut,
                            decoration: BoxDecoration(
                            border: visibility3 ? Border.all(color: Colors.blue[700], width: 2): null, 
                          ),
                            child: Container(
                              height: h3,
                              decoration: BoxDecoration(
                                color: Colors.white,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      "1",
                                      style: TextStyle(
                                          fontSize: 25,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text("Boost",
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold)),
                                    Text("PKR961.10/ea",
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              height: MediaQuery.of(context).size.height / 4.3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 2,
                    height: 50,
                    child: RaisedButton(
                      color: Colors.blue[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: Text(
                        "BOOST ME",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {},
                    ),
                  ),
                  Container(
                    height: 20,
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          height: 2,
                          width: MediaQuery.of(context).size.width / 3.5,
                          color: Colors.black12,
                        ),
                        Text(
                          "or",
                          style: TextStyle(color: Colors.black12),
                        ),
                        Container(
                          height: 2,
                          width: MediaQuery.of(context).size.width / 3.5,
                          color: Colors.black12,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 2,
                    height: 50,
                    child: FlatButton(
                      onPressed: () {},
                      height: 50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(color: Colors.blue[700], width: 2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Get PetTag+ Plus",
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          Text(
                            "(1 free Boost every month)",
                            style: TextStyle(
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
