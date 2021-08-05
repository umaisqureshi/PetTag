import 'package:flutter/material.dart';
import 'package:pett_tagg/constant.dart';
import 'package:pett_tagg/repo/paymentRepo.dart';
import 'package:pett_tagg/screens/pet_slide_screen.dart';
import 'package:pett_tagg/screens/pet_chat_screen.dart';
import 'package:pett_tagg/widgets/petFood_icon_appbar.dart';
import 'package:pett_tagg/screens/addNewProfile.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pett_tagg/repo/paymentRepo.dart' as repo;
import 'package:pett_tagg/models/packageDetail.dart';
import 'package:pett_tagg/widgets/mySearchDialog.dart';
import 'my_map.dart';
import 'ptPlus.dart';
import 'package:pett_tagg/loc/home.dart';
import 'package:pett_tagg/utilities/firebase_credentials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllProfiles extends StatefulWidget {
  static const String allProfilesScreenRoute = "AllProfiles";

  @override
  _AllProfilesState createState() => _AllProfilesState();
}

class _AllProfilesState extends State<AllProfiles> {
  int itemsCount = 0;
  int limit;
  int remaining;
  bool lockStatus = false;
  List<ResponsiveGridCol> profileWidgetList = List<ResponsiveGridCol>();

  @override
  void initState() {
    super.initState();
    getPackage();
    repo.pkg.addListener(() {
      print(repo.pkg.value.remaining);
      updateProfile(repo.pkg.value);
    });
  }

  updateProfile(PackageDetail value) {
    profileWidgetList.clear();
    for (int i = 0; i <= (value.profileCount - value.remaining); i++) {
      profileWidgetList.add(ResponsiveGridCol(
        xs: 6,
        md: 3,
        child: Container(
          height: 100,
          margin: EdgeInsets.all(5),
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                //    color: Theme.of(context).focusColor.withOpacity(0.2),
              ),
              borderRadius: BorderRadius.circular(4)),
          child: FutureBuilder(
              future: FirebaseCredentials().db.collection('Pet').where('ownerId', isEqualTo: FirebaseCredentials().auth.currentUser.uid).get(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if(snapshot.hasData){
                  print("Length of List : ${snapshot.data.docs[i].data().length}");
                  Map<String, dynamic> data = snapshot.data.docs[i].data();
                  String ownerId = data['ownerId'];
                  String petId = data['petId'];
                  bool lock = data.containsKey('lockStatus') ? data['lockStatus'] : true;
                  lockStatus = lock;

                  //print("PetId To Be Sent To PTPlus : $petId");
                  return InkWell(
                    onTap: (){
                      lock ? showDialog(
                          context: context,
                          builder: (context) {
                        return MySearchDialog();
                      },
                      ): Navigator.push(context, MaterialPageRoute(
                          builder: (context){
                            return PTPlus(ownerId: ownerId, petId: petId,);
                          }
                      ));
                    },
                    child: lock ? Icon(Icons.lock, size: 40, color: Colors.black38,):Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(
                            data['images'][0],
                          ),
                        ),
                        Text(data['name'], style: TextStyle(color: Colors.pink, fontSize: 20)),
                      ],
                    ),
                  );
                }
                else{
                  return Container();
                }
            }
          ),
        ),
      ));
    }
    /*profileWidgetList.add(ResponsiveGridCol(
      xs: 6,
      md: 3,
      child: Container(
        height: 100,
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              //    color: Theme.of(context).focusColor.withOpacity(0.2),
            ),
            borderRadius: BorderRadius.circular(4)),
        child: FutureBuilder(
            future: FirebaseCredentials().db.collection('Pet').where('ownerId', isEqualTo: FirebaseCredentials().auth.currentUser.uid).get(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if(snapshot.hasData){
                Map<String, dynamic> data = snapshot.data.docs[0].data();
                String ownerId = data['ownerId'];
                String petId = data['petId'];
                print("PetId To Be Sent To PTPlus : $petId");
                return InkWell(
                  onTap: ()async{
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context){
                        return PTPlus(ownerId: ownerId, petId: petId,);
                      }
                    ));
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                          data['images'][0],
                        ),
                      ),
                      Text(data['name'], style: TextStyle(color: Colors.pink, fontSize: 20)),
                    ],
                  ),
                );
              }
              else{
                return Container();
              }
            }
        )
      ),
    ));*/
    profileWidgetList.add(ResponsiveGridCol(
      xs: 6,
      md: 3,
      child: Container(
        height: 100,
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              //   color: Theme.of(context).focusColor.withOpacity(0.2),
            ),
            borderRadius: BorderRadius.circular(4)),
        child: InkWell(
            onTap: () async {
              if (repo.pkg.value.isNonZero()) {
                lockStatus ? showDialog(
                  context: context,
                  builder: (context) {
                    return MySearchDialog();
                  },
                ): await Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return AddNewProfileScreen(
                    package: repo.pkg.value,
                  );
                }));
                setState(() {

                });
              } else {
                showDialog(
                  context: context,
                  builder: (context) {
                    return MySearchDialog();
                  },
                );
              }
            },
            child: Center(child: Icon(Icons.add))),
      ),
    ));
    if (mounted) {
      setState(() {});
    }
  }

  getPackage() async {
    await repo.getPkgInfo().then((value) {
      repo.pkg.value = value;
      // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
      repo.pkg.notifyListeners();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              /*Navigator.push(context, MaterialPageRoute(builder: (context) {
                return Home();
              }));*/
              Navigator.push(context, MaterialPageRoute(builder: (context){
                return MyMap(isVisible: true,);
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
      body: SingleChildScrollView(
        child: Container(
            padding: EdgeInsets.all(16),
            child: ResponsiveGridRow(
                children: profileWidgetList.isEmpty
                    ? [
                  ResponsiveGridCol(
                    xs: 6,
                    md: 3,
                    child: Container(
                      height: 100,
                      margin: EdgeInsets.all(5),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Theme.of(context)
                                .focusColor
                                .withOpacity(0.2),
                          ),
                          borderRadius: BorderRadius.circular(4)),
                      child: InkWell(
                          onTap: () async {
                            if (repo.pkg.value.isNonZero()) {
                              lockStatus ? showDialog(
                                context: context,
                                builder: (context) {
                                  return MySearchDialog();
                                },
                              ) : Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                    return AddNewProfileScreen(
                                      package: repo.pkg.value,
                                    );
                                  }));
                            }
                            /* if (package.isFirst()) {
                          limit = package.remaining;
                        } else {
                          if (package.isNonZero()) {
                            limit = package.remaining - 1;
                          }
                          setState(() {});
                          print(limit);
                        }*/
                            // storeProfileInfo('')
                          },
                          child: Center(child: Icon(Icons.add))),
                    ),
                  )
                ]
                    : profileWidgetList)),
      ),
    );
  }
}

class Cards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {}
}
