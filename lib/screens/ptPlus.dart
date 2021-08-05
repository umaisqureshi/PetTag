import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pett_tagg/screens/pet_chat_screen.dart';
import 'package:pett_tagg/screens/settings_screen.dart';
import 'package:pett_tagg/widgets/generic_shadow_button.dart';
import 'package:pett_tagg/widgets/petFood_icon_appbar.dart';
import 'edit_info.dart';
import 'edit_profile.dart';
import '../constant.dart';
import 'package:pett_tagg/widgets/mySearchDialog.dart';
import 'my_map.dart';
import 'userDetails.dart';
import 'pet_slide_screen.dart';
import 'package:pett_tagg/widgets/anotherDialog.dart';
import 'package:pett_tagg/loc/home.dart';
import 'package:pett_tagg/utilities/firebase_credentials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PTPlus extends StatefulWidget {
  static const String ptPlusScreenRoute = 'ptPlusScreen';
  String petId;
  String ownerId;

  PTPlus({this.ownerId, this.petId});

  @override
  _PTPlusState createState() => _PTPlusState();
}

class _PTPlusState extends State<PTPlus> {
  bool petChangingSwitch = false;

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
                context, PetSlideScreen.petSlideScreenRouteName);
          },
        ),
        centerTitle: true,
        title: PetFoodIconInAppBar(
          isLeft: true,
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
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return MyMap(isChatSide: false,isVisible: true,);
              }));
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
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: StreamBuilder(
              stream: FirebaseCredentials()
                  .db
                  .collection('Pet')
                  .doc(widget.petId)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasData) {
                  Map<String, dynamic> data = snapshot.data.data();
                  print("${widget.petId}");
                  List<dynamic> image = data['images'] ?? [];
                  //id = data['petId'];
                  //String ownerId = data['ownerId'];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        height: 40,
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return UserDetails(
                            ownerId: widget.ownerId,
                            petId: widget.petId,
                            isMyProfile: true,
                          );
                        })),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.pink, width: 2),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: CircleAvatar(
                            radius: 70,
                            backgroundColor: Colors.blue,
                            backgroundImage: image.isNotEmpty
                                ? NetworkImage(data['images'][0])
                                : AssetImage('assets/profile.png'),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        data['name'],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "",
                            style:
                                TextStyle(color: Colors.black26, fontSize: 13),
                          ),
                        ],
                      ),
                      Spacer(
                        flex: 1,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              /*InkWell(
                              child: Container(
                                padding: EdgeInsets.all(5),
                                height: 70,
                                width: 70,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(100),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                        offset: Offset(0, 0),
                                      ),
                                    ]),
                                child: Center(
                                  child: Text("PT+",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25,
                                        foreground: Paint()..shader = linearGradient,
                                      )),
                                ),
                              ),
                              onTap: () async {
                                var res = await showDialog(
                                    context: context,
                                    builder: (context) {
                                      return MySearchDialog();
                                    });
                                if (res) {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                                    return AllProfiles();
                                  }));
                                }
                              },
                            ),*/
                              InkWell(
                                child: Container(
                                  padding: EdgeInsets.all(15),
                                  height: 70,
                                  width: 70,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(100),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                          spreadRadius: 1,
                                          offset: Offset(0, 0),
                                        ),
                                      ]),
                                  child: Image.asset(
                                    "assets/2x/Icon ionic-ios-settings@2x.png",
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pushNamed(context,
                                      SettingsScreen.settingsScreenRoute);
                                },
                              ),
                              Stack(
                                children: [
                                  InkWell(
                                    //radius: 30,
                                    child: Container(
                                      width: 70,
                                      height: 70,
                                      padding: EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                          color: Color(0xFFF22C6D),
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 4,
                                              spreadRadius: 1,
                                              offset: Offset(0, 0),
                                            ),
                                          ]),
                                      child: Image.asset(
                                          "assets/2x/Icon material-linked-camera@2x.png"),
                                    ),
                                    onTap: () {
                                      //Navigator.pushNamed(context, EditProfileScreen.editProfileScreenRoute);
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return EditProfileScreen(
                                          id: widget.petId,
                                        );
                                      }));
                                    },
                                  ),
                                  Positioned(
                                    bottom: 2,
                                    right: 2,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      child: Image.asset(
                                          "assets/2x/Icon feather-plus-circle@2x.png"),
                                    ),
                                  ),
                                ],
                              ),
                              InkWell(
                                child: Container(
                                  height: 70,
                                  width: 70,
                                  padding: EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(100),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                          spreadRadius: 1,
                                          offset: Offset(0, 0),
                                        ),
                                      ]),
                                  child: SizedBox(
                                    height: 30,
                                    width: 30,
                                    child: Image.asset(
                                      "assets/2x/Icon awesome-pencil-alt@2x.png",
                                    ),
                                  ),
                                ),
                                onTap: () async {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return EditInfoScreen(
                                      id: widget.petId,
                                    );
                                  }));
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Spacer(
                        flex: 1,
                      ),
                      /*GenericBShadowButton(
                    buttonText: "View All Profiles",
                    onPressed: (){

                    },
                  ),
                  Spacer(
                    flex: 1,
                  ),*/
                      GenericBShadowButton(
                        buttonText: 'My PetTag+',
                        onPressed: () {
                          print('functionality');
                          showDialog(
                            context: context,
                            builder: (context) {
                              return MySearchDialog();
                            },
                          );
                        },
                      ),
                      customSizeBox(height: 40),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text(
                    "Something Went Wrong",
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black45),
                  );
                } else
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.pink,
                      strokeWidth: 2,
                    ),
                  );
              }),
        ),
      ),
    );
  }
}
