import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart' show Placemark, placemarkFromCoordinates;
import 'package:pett_tagg/widgets/small_action_buttons.dart';
import 'package:pett_tagg/widgets/reportDialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:maps_toolkit/maps_toolkit.dart' as mp;
import 'package:share/share.dart';

class PetProfileScreen extends StatefulWidget {
  static const String petProfileScreenRouteName = 'PetProfileScreen';
  String docId;
  String ownerId;

  PetProfileScreen({this.docId, this.ownerId});

  @override
  _PetProfileScreenState createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends State<PetProfileScreen> {
  String _linkMessage;
  bool _isCreatingLink = false;
  List<Address> placemarks = [Address(locality: "-", countryName: "-")];


  createUrl() async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
          shortDynamicLinkPathLength: ShortDynamicLinkPathLength.unguessable),
      uriPrefix: 'https://socialapppettag.page.link',
      link: Uri.parse("https://pettag-2c3da.web.app?id=asasas"),
      androidParameters: AndroidParameters(
        packageName: "com.utechware.socialapppettag",
      ),
      iosParameters: IosParameters(
        bundleId: "com.utechware.socialapppettag",
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: "pettttttta",
        imageUrl: Uri.parse("https://miro.medium.com/max/990/1*GFdAHl_f7UtFXdg77bxnBw.png"),
      ),
    );
    await parameters.buildShortLink().then((ShortDynamicLink value) async {
      if (value != null) {
        await FlutterShare.share(
            title: "pettttttta",
            linkUrl: value.shortUrl.toString(),
            chooserTitle: 'Share with');
      }
    });
  }

  getAddress(Map<String, dynamic> data) async {
   var _lat = data['latitude'];
   var _lng = data['longitude'];
    final coordinates = new Coordinates(_lat, _lng);
   placemarks =  await Geocoder.local.findAddressesFromCoordinates(coordinates);
    setState(() {});
  }



  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
          final Uri deepLink = dynamicLink?.link;
          if (deepLink != null) {
            print("onLink${deepLink.queryParameters["id"]}");
            // Navigator.of(context).push(ShopInfoModel(deepLink.queryParameters["id"]));
          }
        }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });

    await FirebaseDynamicLinks.instance.getInitialLink().then((value) {
      final Uri deepLink = value?.link;
      if (deepLink != null) {
        print("initialLink${deepLink.queryParameters["id"]}");
        // Navigator.of(context).push(ShopInfoModel(deepLink.queryParameters["id"]));
      }
    }).catchError((error) {
      print('initialLinkError $error');
    });
  }


  final List imgList = [
    'assets/3x/Icon awesome-star@3x.png',
    'assets/3x/Icon awesome-heart@3x.png',
    'assets/2x/cross-sign@2x.png'
  ];
  var lat = 0.0;
  var lng = 0.0;
  double distance = 0.0;
  String ownerName;
  FirebaseAuth auth = FirebaseAuth.instance;
  updateInteraction({status}) {
    FirebaseFirestore.instance
        .collection('Pet')
        .doc(widget.docId)
        .set({auth.currentUser.uid: status}, SetOptions(merge: true));
  }

  calculateDistance(lat2, lon2, lat1, lon1) {
    /*Geolocator geo = Geolocator();
    distance =  await geo.distanceBetween(lat2, lon2,
        lat1, lon1);*/
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  getLatLng() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('User')
        .doc(auth.currentUser.uid)
        .get();
    Map<String, dynamic> data = snap.data();
    lat = data['latitude'];
    lng = data['longitude'];
    ownerName = data['firstName'];
    getAddress(data);


  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLatLng();
    this.initDynamicLinks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: 30,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                color: Colors.white,
                blurRadius: 15,
                spreadRadius: 15,
                offset: Offset(1, 1),
              )
            ]),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SmallActionButtons(
                onPressed: () {
                  //updateInteraction(status: 0);
                  Navigator.pop(context, true);
                },
                height: 50,
                width: 50,
                icon: Container(
                  height: 40,
                  width: 40,
                  padding: EdgeInsets.all(2),
                  child: Image.asset("assets/2x/cross-sign@2x.png"),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              SmallActionButtons(
                onPressed: () {
                  //updateInteraction(status: 2);
                  Navigator.pop(context, true);
                },
                height: 50,
                width: 50,
                icon: Container(
                  height: 40,
                  width: 40,
                  padding: EdgeInsets.all(2),
                  child: Image.asset("assets/3x/Icon awesome-star@3x.png"),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              SmallActionButtons(
                width: 50,
                height: 50,
                onPressed: () {
                  //updateInteraction(status: 1);
                  Navigator.pop(context, true);
                },
                icon: Container(
                  width: 40,
                  height: 40,
                  padding: EdgeInsets.all(2),
                  child: Image.asset("assets/3x/Icon awesome-heart@3x.png"),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('Pet')
                      .doc(widget.docId)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      Map<String, dynamic> data = snapshot.data.data();
                      List<dynamic> images = data['images'] ?? [];
                      if (data.containsKey('Latitude') ||
                          data.containsKey('longitude')) {
                        distance = mp.SphericalUtil.computeDistanceBetween(
                          mp.LatLng(data['latitude'], data['longitude']),
                          mp.LatLng(lat, lng),
                        );
                        //distance = calculateDistance(lat, lng, data['latitude'], data['longitude']);
                        distance = (distance / 1000);
                      }
                      return Stack(
                        children: [
                          Column(
                            children: [
                              Container(
                                height: 500,
                                width: double.infinity,
                                child: Swiper(
                                  loop: false,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return new Image.network(
                                      images[index],
                                      fit: BoxFit.cover,
                                    );
                                  },
                                  autoplay: false,
                                  itemCount: images.length,
                                  scrollDirection: Axis.horizontal,
                                ),
                                /* child: Image.network(
                                images[0],
                                fit: BoxFit.cover,
                              ),*/
                              ),
                              Container(
                                height: 500,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16.0, right: 16.0, top: 16.0),
                                      child: RichText(
                                        text: TextSpan(
                                            text: '${data['name']}, ',
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 30,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: '${data['age']}',
                                                  style: TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 25,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ))
                                            ]),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16.0,
                                          right: 16.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 13,
                                            color: Colors.black38,
                                          ),
                                          Text(
                                            "${distance.toStringAsFixed(1)} km away",
                                            style: TextStyle(
                                                color: Colors.black45,
                                                fontSize: 15),
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only( left: 16.0,
                                          right: 16.0,
                                          top: 10.0),
                                      child: Text(
                                        "${placemarks.first.locality} ${placemarks.first.countryName}",
                                        style: TextStyle(
                                            color: Colors.black45,
                                            fontSize: 15),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Divider(
                                        color: Colors.black38,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Container(
                                        child: Text(
                                          "\"${data['description']}\"",
                                          style: TextStyle(
                                              color: Colors.black45,
                                              fontSize: 15),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Divider(
                                        color: Colors.black38,
                                      ),
                                    ),
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Text(
                                                "SHARE ${data['name']}'s PROFILE",
                                                style: TextStyle(
                                                    color: Colors.redAccent,
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            InkWell(
                                              onTap: () {
                                                createUrl();
                                              },
                                              child: Text(
                                                "SEE WHAT A FRIEND THINKS",
                                                style: TextStyle(
                                                    color: Colors.redAccent,
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Divider(
                                        color: Colors.black38,
                                      ),
                                    ),
                                    Center(
                                      child: InkWell(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return ReportDialog();
                                            },
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text("Report",
                                              style: TextStyle(
                                                  color: Colors.black45,
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Divider(
                                        color: Colors.black38,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          Positioned(
                            right: 16,
                            bottom: 2,
                            top: 1,
                            child: FloatingActionButton(
                              backgroundColor: Colors.redAccent,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Image.asset(
                                  "assets/icon/down-arrow.png",
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return CircularProgressIndicator(
                      strokeWidth: 2,
                      backgroundColor: Colors.pinkAccent,
                    );
                  }),

            ],
          ),
        ),
      ),
    );
  }

  RichText buildRichText(String key, String value) {
    return RichText(
      text: TextSpan(
        text: key,
        style: TextStyle(
          color: Colors.black,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        children: <TextSpan>[
          TextSpan(
            text: value,
            style: TextStyle(
              color: Colors.pink[900],
            ),
          ),
        ],
      ),
    );
  }

  Row buildRowActionButton(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //mainAxisSize: MainAxisSize.max,
      children: [
        /*SmallActionButtons(
          onPressed: () {},
          height: 40,
          width: 40,
          icon: Container(
            height: 30,
            width: 30,
            padding: EdgeInsets.all(2),
            child: Icon(
              FontAwesomeIcons.redo,
              color: Colors.black26,
            ),
          ),
        ),*/
        SmallActionButtons(
          onPressed: () {},
          height: 40,
          width: 40,
          icon: Container(
            height: 40,
            width: 40,
            padding: EdgeInsets.all(2),
            child: Image.asset("assets/2x/cross-sign@2x.png"),
          ),
        ),
        SmallActionButtons(
          onPressed: () {},
          height: 40,
          width: 40,
          icon: Container(
            height: 40,
            width: 40,
            padding: EdgeInsets.all(2),
            child: Image.asset("assets/3x/Icon awesome-star@3x.png"),
          ),
        ),
        SmallActionButtons(
          onPressed: () {},
          height: 40,
          width: 40,
          icon: Container(
            width: 40,
            height: 40,
            padding: EdgeInsets.all(2),
            child: Image.asset("assets/icon/Group 381.png"),
            //child: Image.asset("assets/3x/Icon awesome-heart@3x.png"),
          ),
        ),
        /*SmallActionButtons(
          onPressed: () {},
          height: 40,
          width: 40,
          icon: Container(
            padding: EdgeInsets.all(2),
            child: Image.asset("assets/2x/flash@2x.png"),
          ),
        ),*/
      ],
    );
  }
}
