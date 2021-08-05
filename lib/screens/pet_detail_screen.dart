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
import 'userDetails.dart';
import 'pet_slide_screen.dart';
import 'package:pett_tagg/screens/all_profiles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pett_tagg/search_places/searchMapPlaceWidget.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pett_tagg/loc/home.dart';
import 'package:pett_tagg/main.dart';
import 'package:pett_tagg/screens/my_map.dart';

class PetDetailedScreen extends StatefulWidget {
  static const String petDetailedScreenRoute = 'PetDetailedScreen';

  @override
  _PetDetailedScreenState createState() => _PetDetailedScreenState();
}

class _PetDetailedScreenState extends State<PetDetailedScreen> {
  bool petChangingSwitch = false;

  CollectionReference pet;
  final FirebaseAuth auth = FirebaseAuth.instance;
  Stream<QuerySnapshot> snap;
  String id;

  @override
  void initState() {
    super.initState();
    pet = FirebaseFirestore.instance.collection('Pet');
    print(auth.currentUser.uid);
  }

  Stream<QuerySnapshot> getSnap() {
    snap = FirebaseFirestore.instance
        .collection('Pet')
        .where('ownerId', isEqualTo: auth.currentUser.uid)
        .snapshots();
    return snap;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: sharedPrefs.currentUserPetType == 'Cat'
            ? Colors.blue[600]
            : appBarBgColor,
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
                return Home(isChatSide: false,);
              }));*/
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return MyMap(
                  isVisible: true,
                  isChatSide: false,
                );
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
              stream: FirebaseFirestore.instance
                  .collection('Pet')
                  .where('ownerId', isEqualTo: auth.currentUser.uid)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text("Something went wrong");
                }
                if (snapshot.hasData) {
                  Map<String, dynamic> data = snapshot.data.docs[0].data();
                  List<dynamic> image = data['images'] ?? [];
                  id = data['petId'];
                  String ownerId = data['ownerId'];
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
                            ownerId: ownerId,
                            petId: id,
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
                            backgroundColor: Colors.white,
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
                                          id: id,
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
                                      id: id,
                                      ownerId: ownerId,
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
                      GenericBShadowButton(
                        buttonText: 'My PetTag+',
                        onPressed: () async {
                          var res = await showDialog(
                              context: context,
                              builder: (context) {
                                return MySearchDialog();
                              });
                          if (res) {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return AllProfiles();
                            }));
                          }
                        },
                      ),
                      customSizeBox(height: 40),
                    ],
                  );
                }
                return Center(
                    child: CircularProgressIndicator(
                  backgroundColor: Colors.transparent,
                  strokeWidth: 2,
                ));
              }),
        ),
      ),
    );
  }
}

/*SearchMapPlaceWidget(
                  apiKey: 'AIzaSyABFmjpW4zSizocefrOcxVOXjzr0kZNsmM',
                  hintText: 'To',
                  location: LatLng(24.12345, 34.45678),
                  radius: 50 * 1000,
                  hasClearButton: true,
                  strictBounds: true,
                  onSelected: (place) async {
                    /*final geolocation = await place.geolocation;
                    LatLng latLng = geolocation.coordinates;
                    destinationLatitude = latLng.latitude;
                    destinationLongitude = latLng.longitude;
                    destinationLocationLatLng =
                        LatLng(destinationLatitude, destinationLongitude);

                    double totalDistance = distance(
                        userLocationLatLng, destinationLocationLatLng);

                    controller.animateCamera(CameraUpdate.newLatLngZoom(
                        userLocationLatLng,
                        getZoomLevel(totalDistance * 1000)));

                    markers.add(Marker(
                        markerId: MarkerId('2'),
                        position:
                        LatLng(destinationLatitude, destinationLongitude),
                        icon: BitmapDescriptor.defaultMarkerWithHue(0)));

                    _getPolyline();

                    user.totalKilometers = totalDistance;

                    print('******* Total Distance ********');
                    print('Distance in KM : ' + totalDistance.toString());

                    final coordinates = new Coordinates(destinationLatitude, destinationLongitude);
                    var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
                    var first = addresses.first;

                    user.userDestinationAddress = first.locality;//+ ',' + first.subLocality;

                    print('Destination Address : '+user.userDestinationAddress.toString());


                    setState(() {
                      isDestinationSelected = true;
                    });*/
                  },
                );*/
