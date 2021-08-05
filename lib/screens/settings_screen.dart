import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pett_tagg/screens/email_notification.dart';
import 'package:pett_tagg/screens/push_notification.dart';
import 'package:pett_tagg/screens/sign_in_screen.dart';
import 'package:pett_tagg/widgets/customCard.dart';
import 'package:pett_tagg/widgets/termsAndCondDialog.dart';
import '../constant.dart';
import 'package:pett_tagg/widgets/changePasswordDialog.dart';
import 'package:pett_tagg/widgets/privacy_policy_dialog.dart';
import 'package:flutter_snackbar/flutter_snackbar.dart';
import 'package:pett_tagg/widgets/mySearchDialog.dart';
import 'package:pett_tagg/utilities/firebase_credentials.dart';
import 'package:location/location.dart' as LocationManager;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pett_tagg/main.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';

class SettingsScreen extends StatefulWidget {
  static const String settingsScreenRoute = 'SettingsScreen';

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _haveMyPet = true;
  bool superTreatPurchase = false;
  String interestedIn;
  String gender;
  int age = 5;
  int distance = 1;
  double locationContainerHeight;
  RangeValues preferableAge = RangeValues(1, 30);
  RangeValues ownerAge = RangeValues(15, 100);
  double _height = 80;
  bool _isVisible = false;
  var lat = 0.0;
  var lng = 0.0;
  bool isAgeChanged = false;
  bool isLoading = false;
  String distanceUnit = "Km";

  GlobalKey<SnackBarWidgetState> _globalKey = GlobalKey();

  StreamSubscription _purchaseUpdatedSubscription;
  StreamSubscription _purchaseErrorSubscription;
  List<String> productIds = [
    'treats',
    'super_treats',
  ];
  List<IAPItem> _items = [];
  List<PurchasedItem> _purchases = [];
  IAPItem purchaseIt;

  Future<void> initPlatformState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prepare
    var result = await FlutterInappPurchase.instance.initConnection;
    print('result: $result');

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    // refresh items for android
    // String msg = await FlutterInappPurchase.instance.consumeAllItems;
    // print('consumeAllItems: $msg');
    try {
      String msg = await FlutterInappPurchase.instance.consumeAllItems;
      print('consumeAllItems: $msg');
    } catch (err) {
      print('consumeAllItems error: $err');
    }

    _purchaseUpdatedSubscription =
        FlutterInappPurchase.purchaseUpdated.listen((productItem) {
      print('purchase-updated: $productItem');
      if (superTreatPurchase) {
        prefs.setInt('superLikesCount', prefs.getInt('superLikesCount') + 5);
      } else {
        FirebaseFirestore.instance
            .collection("User")
            .doc(FirebaseAuth.instance.currentUser.uid)
            .update({
          'treats': 15,
        });
      }
    });

    _purchaseErrorSubscription =
        FlutterInappPurchase.purchaseError.listen((purchaseError) {
      print('purchase-error: $purchaseError');
    });
    await _getProduct();
  }

  Future<Null> _getProduct() async {
    List<IAPItem> items =
        await FlutterInappPurchase.instance.getProducts(productIds);
    for (var item in items) {
      print('${item.toString()}');
      this._items.add(item);
    }
    setState(() {
      this._items = items;
    });
  }

  Future<Null> _buyProduct(IAPItem item) async {
    try {
      PurchasedItem purchased =
          await FlutterInappPurchase.instance.requestPurchase(item.productId);
      PurchaseState state = purchased.purchaseStateAndroid;
      print("\n\n\nState of purchase : $state");
      String msg = await FlutterInappPurchase.instance.consumeAllItems;
      print('consumeAllItems: $msg');
    } catch (error) {
      print('$error');
    }
  }

  updateInterestFilter() {
    sharedPrefs.currentUserPetType = "$interestedIn";
    FirebaseCredentials()
        .db
        .collection('User')
        .doc(FirebaseCredentials().auth.currentUser.uid)
        .update({
      'interest': interestedIn,
    }).then((value) {
      setState(() {
        isLoading = false;
      });
    });
  }

  updateGenderFilter(gender) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('preferredGender', gender);
  }

  setRadius(int radius) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('radius', radius);
  }

  setDistanceUnit(String unit)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('distUnit', unit);
  }

  updatePreferableAge(start, end) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('minAge', start);
    prefs.setDouble('maxAge', end);
  }

  Future<LatLng> getUserLocation() async {
    final location = LocationManager.Location();
    LocationManager.LocationData locationData;
    try {
      locationData = await location.getLocation();
      lat = locationData.latitude;
      lng = locationData.longitude;
      final center = LatLng(lat, lng);
      return center;
    } on Exception {
      locationData = null;
      return null;
    }
  }

  getPetType() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('User')
        .doc(FirebaseCredentials().auth.currentUser.uid)
        .get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data();
      if (data.isNotEmpty) {
        print("Interest : ${data['interest']}");
        interestedIn = data['interest'];
        setState(() {});
        print("PetType : ${interestedIn}");
      }
    }
  }

  getPreviousData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('minAge') && prefs.containsKey('maxAge')) {
      preferableAge =
          RangeValues(prefs.getDouble('minAge'), prefs.getDouble('maxAge'));
    }
    if (prefs.containsKey('radius')) {
      distance = prefs.getInt('radius');
    }
    if (prefs.containsKey('preferredGender')) {
      gender = prefs.getString('preferredGender');
    }
    if(prefs.containsKey("distUnit")){
      distanceUnit = prefs.getString("distUnit");
    }
    await getPetType();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initPlatformState();
    getPreviousData();
  }

  @override
  Future<void> dispose() async {
    // TODO: implement dispose
    super.dispose();
    await FlutterInappPurchase.instance.endConnection;
    _purchaseUpdatedSubscription.cancel();
    _purchaseErrorSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          splashColor: Colors.transparent,
          icon: Icon(
            Icons.arrow_back,
            size: 22,
            color: Colors.pink,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Settings",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
      ),
      body: SnackBarWidget(
        key: _globalKey,
        margin: EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: Colors.redAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        duration: Duration(seconds: 2),
        textBuilder: (String message) {
          return Text(message ?? "",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold));
        },
        text: Text(""),
        content: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return MySearchDialog();
                      },
                    );
                  },
                  child: CustomCard(
                    height: 90,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          //crossAxisAlignment: CrossAxisAlignment.baseline,
                          children: [
                            Image.asset(
                              "assets/logo@3xUpdated.png",
                              height: 25,
                              width: 25,
                              color: Colors.pink,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            RichText(
                              text: TextSpan(
                                text: 'PetTag',
                                style: TextStyle(
                                    fontSize: 22,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: '+',
                                      style: TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 25)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "Receive a booster shot to increase matches.",
                          style: TextStyle(
                            color: Colors.black38,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _globalKey.currentState.show(
                        "You have to purchase subscription package to boost your profile");
                  },
                  child: CustomCard(
                    height: 90,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                offset: Offset(0, 0),
                                spreadRadius: 2,
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            "assets/icon/injection.png",
                            height: 25,
                            width: 25,
                            color: Colors.pink,
                          ),
                        ),
                        Text(
                          "Get Boosts to increase Your Matches!",
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () async {
                        await _buyProduct(_items[1]);
                        setState(() {
                          superTreatPurchase = false;
                        });
                      },
                      child: CustomCard(
                        width: MediaQuery.of(context).size.width / 2 - 20,
                        height: 110,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              padding: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(100),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    offset: Offset(0, 0),
                                    spreadRadius: 2,
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                "assets/2x/Icon awesome-heart@2x.png",
                              ),
                            ),
                            Text(
                              "Get 15 Treat",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            Container(
                              height: 20,
                              width: 50,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.pink[50].withOpacity(0.2),
                              ),
                              child: Text(
                                "\$3",
                                style: TextStyle(
                                  backgroundColor:
                                      Colors.pink[50].withOpacity(0.5),
                                  fontSize: 17,
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        await _buyProduct(_items[0]);
                        setState(() {
                          superTreatPurchase = true;
                        });
                      },
                      child: CustomCard(
                        width: MediaQuery.of(context).size.width / 2 - 20,
                        height: 110,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              padding: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(100),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    offset: Offset(0, 0),
                                    spreadRadius: 2,
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                "assets/2x/Icon awesome-star@2x.png",
                              ),
                            ),
                            Text(
                              "Get 5 Super-Treat",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            Container(
                              height: 20,
                              width: 50,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.pink[50].withOpacity(0.2),
                              ),
                              child: Text(
                                "\$2.50",
                                style: TextStyle(
                                  backgroundColor:
                                      Colors.pink[50].withOpacity(0.5),
                                  fontSize: 17,
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    "Discovery Settings",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      fontSize: 19,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isVisible = _isVisible ? false : true;
                    });
                  },
                  child: AnimatedContainer(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0, 2),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ]),
                    duration: Duration(seconds: 2),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            children: [
                              Text(
                                "Location",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                              Spacer(),
                              Text(
                                "My Current Location",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        /*Visibility(
                          visible: _isVisible,
                          child: FlatButton(
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            padding: EdgeInsets.all(0),
                            child: Text(
                              "Add New Location",
                              style: TextStyle(
                                color: Colors.brown[400],
                              ),
                            ),
                            onPressed: () {},
                          ),
                        ),*/
                        Visibility(
                          visible: _isVisible,
                          child: FlatButton(
                            onPressed: () async {
                              final center = await getUserLocation();
                              if (center.longitude != null &&
                                  center.latitude != null) {
                                await FirebaseCredentials()
                                    .db
                                    .collection('User')
                                    .doc(FirebaseCredentials()
                                        .auth
                                        .currentUser
                                        .uid)
                                    .update({
                                  'latitude': center.latitude,
                                  'longitude': center.longitude,
                                });
                              }
                            },
                            padding: EdgeInsets.all(0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  FontAwesomeIcons.mapMarkerAlt,
                                  color: Colors.blue,
                                  size: 15,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Use My Current Location",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: Text(
                    "Change your location to see Pets in other cities.",
                    style: TextStyle(
                      color: Colors.black38,
                      fontSize: 12,
                    ),
                  ),
                ),
                CustomCard(
                  width: MediaQuery.of(context).size.width,
                  height: 130,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Have My Pet",
                          style: pinkHeadingStyle,
                        ),
                        Row(
                          children: [
                            Radio(
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              value: true,
                              activeColor: Colors.black54,
                              focusColor: Colors.black,
                              groupValue: _haveMyPet,
                              onChanged: (bool value) {
                                setState(() {
                                  _haveMyPet = value;
                                });
                              },
                            ),
                            Text(
                              "Yes",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Colors.black54,
                                fontSize: 15,
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Radio(
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              value: false,
                              toggleable: true,
                              activeColor: Colors.black54,
                              groupValue: _haveMyPet,
                              onChanged: (bool value) {
                                setState(() {
                                  _haveMyPet = value;
                                });
                              },
                            ),
                            Text(
                              "No",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Colors.black54,
                                fontSize: 15,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                CustomCard(
                  width: MediaQuery.of(context).size.width,
                  height: 92,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15.0, left: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Interested In",
                          style: pinkHeadingStyle,
                        ),
                        DropdownButtonFormField(
                          isExpanded: false,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            hintText: interestedIn ?? "Cat",
                            contentPadding: EdgeInsets.all(8.0),
                            hintStyle: hintTextStyle.copyWith(
                              color: Colors.black87,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(
                                  color: Colors.transparent,
                                )),
                          ),
                          value: interestedIn,
                          items: <String>['Dog', 'Cat', 'Both']
                              .map<DropdownMenuItem<String>>(
                                  (String value) => DropdownMenuItem(
                                        child: Text(value),
                                        value: value,
                                      ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              interestedIn = value;
                              //updateInterestFilter();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                CustomCard(
                  width: MediaQuery.of(context).size.width,
                  height: 92,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15.0, left: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Show Me",
                          style: pinkHeadingStyle,
                        ),
                        DropdownButtonFormField(
                          isExpanded: false,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            hintText: gender ?? "Female",
                            contentPadding: EdgeInsets.all(8.0),
                            hintStyle: hintTextStyle.copyWith(
                              color: Colors.black87,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(
                                  color: Colors.transparent,
                                )),
                          ),
                          value: gender,
                          items: <String>['Male', 'Female', 'Both']
                              .map<DropdownMenuItem<String>>(
                                  (String value) => DropdownMenuItem(
                                        child: Text(value),
                                        value: value,
                                      ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              gender = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                CustomCard(
                  width: MediaQuery.of(context).size.width,
                  height: 92,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15.0, left: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Show Me Owner",
                          style: pinkHeadingStyle,
                        ),
                        DropdownButtonFormField(
                          isExpanded: false,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            hintText: gender ?? "Female",
                            contentPadding: EdgeInsets.all(8.0),
                            hintStyle: hintTextStyle.copyWith(
                              color: Colors.black87,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(
                                  color: Colors.transparent,
                                )),
                          ),
                          value: gender,
                          items: <String>['Male', 'Female', 'Both']
                              .map<DropdownMenuItem<String>>(
                                  (String value) => DropdownMenuItem(
                                        child: Text(value),
                                        value: value,
                                      ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              gender = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                CustomCard(
                  width: MediaQuery.of(context).size.width,
                  height: 92,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15.0, left: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Select Distance Units",
                          style: pinkHeadingStyle,
                        ),
                        DropdownButtonFormField(
                          isExpanded: false,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            hintText: distanceUnit ?? "Km",
                            contentPadding: EdgeInsets.all(8.0),
                            hintStyle: hintTextStyle.copyWith(
                              color: Colors.black87,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(
                                  color: Colors.transparent,
                                )),
                          ),
                          value: distanceUnit,
                          items: <String>['Km', 'Miles']
                              .map<DropdownMenuItem<String>>(
                                  (String value) => DropdownMenuItem(
                                child: Text(value),
                                value: value,
                              ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              distanceUnit = value;
                              if (distanceUnit == 'Miles') {
                                double temp = distance * 0.6213711922;
                                distance = temp.toInt();
                              } else {
                                double temp = distance * 1.609344;
                                distance = temp.toInt();
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                CustomCard(
                  height: 95,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 15.0, right: 15, left: 12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              "Pet Age",
                              style: pinkHeadingStyle,
                            ),
                            Spacer(),
                            Text(
                              "${preferableAge.start.toInt()} - ${preferableAge.end.toInt()}",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.redAccent,
                            trackHeight: 1,
                            inactiveTrackColor: Colors.black26,
                            thumbColor: Colors.redAccent,
                            //overlayColor: Color(0x29EB1555),
                            thumbShape:
                                RoundSliderThumbShape(enabledThumbRadius: 10.0),
                            overlayShape:
                                RoundSliderOverlayShape(overlayRadius: 25.0),
                          ),
                          child: RangeSlider(
                              min: 1,
                              max: 30,
                              values: preferableAge,
                              onChanged: (value) {
                                setState(() {
                                  preferableAge = value;
                                  isAgeChanged = true;
                                  print("Preferable Age : $preferableAge");
                                });
                              }),
                        )
                      ],
                    ),
                  ),
                ),
                CustomCard(
                  height: 95,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 15.0, right: 15, left: 12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              "Owner Age",
                              style: pinkHeadingStyle,
                            ),
                            Spacer(),
                            Text(
                              "${ownerAge.start.toInt()} - ${ownerAge.end.toInt()}",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.redAccent,
                            trackHeight: 1,
                            inactiveTrackColor: Colors.black26,
                            thumbColor: Colors.redAccent,
                            //overlayColor: Color(0x29EB1555),
                            thumbShape:
                                RoundSliderThumbShape(enabledThumbRadius: 10.0),
                            overlayShape:
                                RoundSliderOverlayShape(overlayRadius: 25.0),
                          ),
                          child: RangeSlider(
                              min: 15,
                              max: 100,
                              values: ownerAge,
                              onChanged: (value) {
                                setState(() {
                                  ownerAge = value;
                                  isAgeChanged = true;
                                  print("Owner Age : $ownerAge");
                                });
                              }),
                        )
                      ],
                    ),
                  ),
                ),
                CustomCard(
                  height: 95,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 15.0, right: 15, left: 12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              "Maximum Distance",
                              style: pinkHeadingStyle,
                            ),
                            Spacer(),
                            Text(
                              "${distance.toString()} $distanceUnit",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.redAccent,
                            inactiveTrackColor: Colors.black26,
                            thumbColor: Colors.redAccent,
                            trackHeight: 1,
                            thumbShape:
                                RoundSliderThumbShape(enabledThumbRadius: 10.0),
                            overlayShape:
                                RoundSliderOverlayShape(overlayRadius: 25.0),
                          ),
                          child: Slider(
                            value: distance.toDouble(),
                            min: 0,
                            max: 1000,
                            onChanged: (double newValue) async {
                              setState(() {
                                distance = newValue.ceil();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                CustomCard(
                  width: MediaQuery.of(context).size.width,
                  height: 120,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 15.0, left: 13.0, bottom: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Notification Settings",
                          style: pinkHeadingStyle,
                        ),
                        SizedBox(
                          height: 1,
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context,
                              EmailNotification.emailNotificationScreenRoute),
                          child: Text(
                            "Email",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context,
                              PushNotification.pushNotificationScreenRoute),
                          child: Text(
                            "Push Notification",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                CustomCard(
                  width: MediaQuery.of(context).size.width,
                  height: 120,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 15.0, left: 13.0, bottom: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Legal",
                          style: pinkHeadingStyle,
                        ),
                        SizedBox(
                          height: 1,
                        ),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return CustomTermsAndCondDialog();
                              },
                            );
                          },
                          child: Text(
                            "Terms and Conditions",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return PrivacyPolicyDialog();
                              },
                            );
                          },
                          child: Text(
                            "Privacy Policy",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Spacer(),
                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return ChangePasswordDialog();
                          },
                        );
                      },
                      child: CustomCard(
                        width: 160,
                        height: 50,
                        child: Center(
                          child: Text(
                            "Change Password",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                  ],
                ),
                InkWell(
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    sharedPrefs.clearPetType();

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => SignInScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  child: CustomCard(
                    width: MediaQuery.of(context).size.width,
                    height: 60,
                    child: Center(
                      child: Text(
                        "Log-out",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 17),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () {
                    if (interestedIn != null) {
                      setState(() {
                        isLoading = true;
                      });
                      updateInterestFilter();
                    }
                    if (gender != null) {
                      updateGenderFilter(gender);
                    }
                    if (distance > 1) {
                      setRadius(distance);
                      setDistanceUnit(distanceUnit);
                    }
                    if (isAgeChanged) {
                      updatePreferableAge(
                          preferableAge.start, preferableAge.end);
                    }
                    //Navigator.pop(context);
                  },
                  child: CustomCard(
                    height: 60,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: Text(
                        "Save Changes",
                        style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
