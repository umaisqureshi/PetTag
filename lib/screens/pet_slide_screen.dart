import 'dart:async';
import 'dart:convert';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as localNotification;
import 'package:http/http.dart';
import 'package:pett_tagg/constant.dart';
import 'package:pett_tagg/screens/pet_profile.dart';
import 'package:pett_tagg/widgets/myTreats.dart';
import 'package:pett_tagg/widgets/petDate.dart';
import 'package:pett_tagg/widgets/small_action_buttons.dart';
import 'package:pett_tagg/screens/pet_chat_screen.dart';
import 'package:pett_tagg/widgets/topPicks.dart';
import 'package:pett_tagg/widgets/treat.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pet_detail_screen.dart';
import 'pet_chat_screen.dart';
import 'package:pett_tagg/widgets/boostDialog.dart';
import 'package:pett_tagg/widgets/superLikeDialog.dart';
import 'package:pett_tagg/screens/all_profiles.dart';
import 'package:pett_tagg/repo/paymentRepo.dart' as repo;
import 'package:pett_tagg/models/packageDetail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pett_tagg/widgets/mySearchDialog.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter/scheduler.dart';
import 'package:pett_tagg/utilities/tinder_card.dart';
import 'package:pett_tagg/enums/enums.dart';
import 'package:pett_tagg/main.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mp;

class PetSlideScreen extends StatefulWidget {
  static const String petSlideScreenRouteName = 'PetSlideScreen';

  bool isLeft = true;

  @override
  _PetSlideScreenState createState() => _PetSlideScreenState();
}

class _PetSlideScreenState extends State<PetSlideScreen>
    with TickerProviderStateMixin {
  CardController controller;
  PackageDetail package;
  PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  int _index;
  double minAge;
  double maxAge;
  int preferableDistance;
  String preferableGender;
  bool isShuffled = false;
  bool isLeft = false;
  bool isRight = false;
  bool _action = false;
  bool isTop = false;
  double leftPos = 20;
  double rightPos = 20;
  String text = "GRAWL";
  bool _noCardVisibility = false;
  Color containerColor = Colors.red;
  bool _treat = true;
  bool _topPicks = false;
  bool _petDate = false;
  bool _myTreats = false;
  var subscription;
  var connectionStatus;
  String currentPetId;
  String petId;
  String _petType;
  var lat = 0.0;
  var lng = 0.0;
  double distance = 0.0;
  int endTime;
  bool likesLimit = true;
  String whichPackage;
  int superLikeEndTime;
  bool superLikesLimit = true;
  bool lastCard = false;
  bool isOffilne = false;
  String myPetId;
  String myPetImage;
  String myPetName;

  CountdownTimerController timeController;
  CountdownTimerController timeControllerDay;
  CountdownTimerController boostedTimeController;

  int boostEndTimer;

  localNotification.FlutterLocalNotificationsPlugin
      flutterLocalNotificationsPlugin =
      localNotification.FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging();

  InterstitialAd _interstitialAd;
  bool _isInterstitialAdReady = false;

  final FirebaseAuth auth = FirebaseAuth.instance;

  List<String> cardImages = [
    'assets/dogsAndCats/doggy.png',
    'assets/dogsAndCats/doggy1.jpg',
    'assets/dogsAndCats/doggy1.jpg',
  ];
  List<QueryDocumentSnapshot> profiles = [];

  boostedOnEnd(){
      FirebaseFirestore.instance.collection("Pet").doc(myPetId).update(
          {
            "boosted" : false,
          });
      setState((){});
    }


  Future<bool> getLimit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('likeCount')
        ? prefs.getInt("likeCount") < 25
            ? true
            : false
        : true;
  }

  getPrefs() async {}

  getProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("ProfileType")) {
      return prefs.getString("ProfileType");
    } else {
      return "";
    }
  }

  void _loadInterstitialAd() {
    _interstitialAd.load();
  }

  void _onInterstitialAdEvent(MobileAdEvent event) {
    switch (event) {
      case MobileAdEvent.loaded:
        _isInterstitialAdReady = true;
        print('AA Load an interstitial ad');
        break;
      case MobileAdEvent.failedToLoad:
        _isInterstitialAdReady = false;
        print('AA Failed to load an interstitial ad');
        break;
      case MobileAdEvent.closed:
        print('AA Closed an interstitial ad');
        FirebaseAdMob.instance.initialize(appId: FirebaseAdMob.testAppId);
        _interstitialAd = InterstitialAd(
          adUnitId: /*AdManager.interstitialAdUnitId*/ InterstitialAd
              .testAdUnitId,
          listener: _onInterstitialAdEvent,
        );
        _loadInterstitialAd();
        break;
      default:
      // do nothing
    }
  }

  // ignore: missing_return
  Future onSelectNotification(String payload) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return Scaffold(body: Container());
    }));
  }

  Future notificationOnResume(Map<String, dynamic> message) async {
    await Future.delayed(Duration(seconds: 4));
    onSelectNotification("");
  }

  Future notificationOnLaunch(Map<String, dynamic> message) async {
    await Future.delayed(Duration(seconds: 4));
    onSelectNotification("");
  }

  showNotification(map) async {
    var android = localNotification.AndroidNotificationDetails(
      'PT',
      'PetTag ',
      'You Have a PetDate',
      priority: localNotification.Priority.high,
      importance: localNotification.Importance.max,
    );
    var iOS = localNotification.IOSNotificationDetails();
    var platform =
        new localNotification.NotificationDetails(android: android, iOS: iOS);
    await flutterLocalNotificationsPlugin.show(
        0, map['notification']['title'], map['notification']['body'], platform,
        payload: '');
  }

  Future notificationOnMessage(Map<String, dynamic> message) async {
    showNotification(message);
  }

  void configureFirebase(FirebaseMessaging _firebaseMessaging) {
    try {
      _firebaseMessaging.configure(
        onMessage: notificationOnMessage,
        onLaunch: notificationOnLaunch,
        onResume: notificationOnResume,
      );
    } catch (e) {
      print(e);
      print('Error Config Firebase!!!');
    }
  }

  callOnFcmApiSendPushNotifications(userToken) async {
    final postUrl = 'https://fcm.googleapis.com/fcm/send';

    final data = {
      "notification": {"body": "You have a new PetDate.", "title": "PetDate"},
      "priority": "high",
      "data": {"click_action": "FLUTTER_NOTIFICATION_CLICK", "status": "done"},
      "to": "$userToken"
    };

    final headers = {
      'content-type': 'application/json',
      'Authorization':
          'key=AAAAiTi4Ky4:APA91bHOEj1tSQUQC2Op27Z1Fdwh4j6FwmT1IlvvGRp99SFU1oX6wAbo20lyZ4Q9HpJ2wnLiBuN20luSYlQO-0IwyzI3a5qm3q4YVebwB3xmAdCuEb0K8c371Ishr_dr3n8Q9b709pbA'
      // 'key=YOUR_SERVER_KEY'
    };

    try {
      final response = await post(postUrl,
          body: json.encode(data),
          encoding: Encoding.getByName('utf-8'),
          headers: headers);

      if (response.statusCode == 200) {
        print('CFM Succeed');
        return true;
      } else {
        print(response.body);
        return false;
      }
    } catch (e) {
      print(e.message);
    }
  }

  updateInteraction({status, petId, petImage, petName}) {
    if (status == 1) {
      DocumentReference doc =
          FirebaseFirestore.instance.collection('Pet').doc(currentPetId);
      doc.set({
        auth.currentUser.uid: status,
        'likedBy': FieldValue.arrayUnion([
          {
            'user_id': auth.currentUser.uid,
            'petId': myPetId,
            "petImage": myPetImage,
            "petName": myPetName
          }
        ])
      }, SetOptions(merge: true)).then((value) async {
        List<String> userIds = [];
        await doc.get().then((value) {
          value.data()["likedBy"].forEach((element) {
            userIds.add(element["user_id"]);
          });
        });
        print("UserIds : $userIds");
        List<DocumentSnapshot> snapshots = [];
        for (int i = 0; i < userIds.length; i++) {
          await FirebaseFirestore.instance
              .collection("token")
              .doc(userIds[i])
              .get()
              .then((value) {
            if (value.exists) {
              callOnFcmApiSendPushNotifications(value.data()["token"]);
              snapshots.add(value);
            }
            print("Shit Id : ${value.id}");
          });
        }
        print("Length de snaps : ${snapshots.length}");
      });
      FirebaseFirestore.instance.collection('Pet').doc(petId).set({
        'likes': FieldValue.arrayUnion([currentPetId])
      }, SetOptions(merge: true));
    } else if (status == 2) {
      FirebaseFirestore.instance.collection('Pet').doc(currentPetId).set({
        auth.currentUser.uid: status,
        'superLikedBy': FieldValue.arrayUnion([
          {
            'user_id': auth.currentUser.uid,
            'petId': myPetId,
            "petImage": myPetImage,
            "petName": myPetName
          }
        ])
      }, SetOptions(merge: true));
      FirebaseFirestore.instance.collection('Pet').doc(petId).set({
        'likes': FieldValue.arrayUnion([currentPetId])
      }, SetOptions(merge: true));
    } else {
      FirebaseFirestore.instance.collection('Pet').doc(currentPetId).set({
        auth.currentUser.uid: status,
      }, SetOptions(merge: true));
    }
  }

  updateDummyInteraction({status}) {
    FirebaseFirestore.instance
        .collection('Pet')
        .doc(currentPetId)
        .set({auth.currentUser.uid: status}, SetOptions(merge: true));
  }

  getPreferableAge() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    minAge = prefs.getDouble('minAge') ?? 0;
    maxAge = prefs.getDouble('maxAge') ?? 30;
    print("Min : $minAge ---- Max : $maxAge");
  }

  getPreferableDistance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    preferableDistance = prefs.getInt('radius') ?? 1;
    print("Distance : $preferableDistance");
  }

  getPreferableGender() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    preferableGender = prefs.getString('preferredGender');
    print("Gender : $preferableGender");
  }

  getPetType() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('User')
        .doc(auth.currentUser.uid)
        .get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data();
      if (data.isNotEmpty) {
        print("Interest : ${data['interest']}");
        _petType = data['interest'];
        print("PetType : ${_petType}");
      }
    }
  }

  getLatLng() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('User')
        .doc(auth.currentUser.uid)
        .get();
    Map<String, dynamic> data = snap.data();
    lat = data['latitude'];
    lng = data['longitude'];
  }

  setTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(
        "likesTime", DateTime.now().millisecondsSinceEpoch + 1000 * 28800);
  }

  setSuperLikeTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(
        "superLikesTime", DateTime.now().millisecondsSinceEpoch + 1000 * 86400);
  }

  Future<int> getSuperLikeTimer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("superLikesTime")) {
      return prefs.getInt("superLikesTime");
    } else {
      await setSuperLikeTime();
      return prefs.getInt("superLikesTime");
    }
  }

  Future<int> getTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('likesTime')) {
      return prefs.getInt("likesTime");
    } else {
      await setTime();
      return prefs.getInt("likesTime");
    }
  }

  Future<bool> superLikeCounter(counter) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('superLikesCount')) {
      if (prefs.getInt('superLikesCount') == counter) {
        print("SuperLikes Counter is greater than 1");
        return false;
      } else {
        prefs.setInt('superLikesCount', prefs.getInt('superLikesCount') + 1);
        return true;
      }
    } else {
      prefs.setInt("superLikesCount", 1);
      return true;
    }
  }

  Future<bool> likeCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('likeCount')) {
      if (prefs.getInt('likeCount') >= 25) {
        print("Likes Counter is greater than 2");
        return false;
      } else {
        prefs.setInt('likeCount', prefs.getInt('likeCount') + 1);
        return true;
      }
    } else {
      prefs.setInt("likeCount", 1);
      return true;
    }
  }

  void onEnd() async {
    await setTime();
    await getTime().then((value) async {
      endTime = value;
      print("WTF IS HAPPENING");
      timeController.endTime = endTime;
      timeController.start();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('likeCount')) {
        prefs.remove('likeCount');
      }
      setState(() {
        likesLimit = true;
      });
    });
  }

  onEndSuperLike() async {
    await setSuperLikeTime();
    await getSuperLikeTimer().then((value) async {
      superLikeEndTime = value;
      print("WTF IS HAPPENING HERE");
      timeControllerDay.endTime = superLikeEndTime;
      timeControllerDay.start();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('superLikesCount')) {
        prefs.remove('superLikesCount');
      }
      setState(() {
        superLikesLimit = true;
      });
    });
  }

  Packages packages;

  void setPackageName(Packages packages) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("packageName", packages.name);
  }

  Future<Packages> getPackageName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Packages packages;
    if (prefs.containsKey("packageName")) {
      Packages.values.forEach((element) {
        if (element.name == prefs.getString("packageName")) {
          packages = element;
          return element;
        }
      });
    } else {
      setPackageName(Packages.STANDARD);
      return Packages.STANDARD;
    }
    return packages;
  }

  Future<void> initPlatformState() async {
    appData.isPro = false;

    await Purchases.setDebugLogsEnabled(true);
    await Purchases.setup("gzgzAsBNGojGMkJBZyMcDnSsxiwbbAkF",
        appUserId: auth.currentUser.uid);

    PurchaserInfo purchaserInfo;
    try {
      purchaserInfo = await Purchases.getPurchaserInfo();
      print(purchaserInfo.toString());
      if (purchaserInfo.entitlements.all['pettagplus'] != null) {
        appData.isPro = purchaserInfo.entitlements.all['pettagplus'].isActive;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("packageName", "PETTAGPLUS");
      }
      if (purchaserInfo.entitlements.all['breeder'] != null) {
        appData.isPro = purchaserInfo.entitlements.all['breeder'].isActive;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("packageName", "BREEDER");
      }
      if (purchaserInfo.entitlements.all['rescuer'] != null) {
        appData.isPro = purchaserInfo.entitlements.all['rescuer'].isActive;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("packageName", "RESCUER");
      } else {
        appData.isPro = false;
      }
    } on Platform catch (e) {
      print(e);
    }
    print('#### is user pro? ${appData.isPro}');
  }

  getPetId() async {
    await FirebaseFirestore.instance
        .collection("Pet")
        .where("ownerId", isEqualTo: auth.currentUser.uid)
        .get()
        .then((value) {
      myPetId = value.docs[0].data()['petId'];
      FirebaseFirestore.instance
          .collection('Pet')
          .doc(myPetId)
          .get()
          .then((value) {
        myPetImage = value.data()["images"][0];
        myPetName = value.data()["name"];
        boostEndTimer = DateTime.now().millisecondsSinceEpoch + 1000 * 60;
      });
      isOffline();
    });
  }

  isOffline() async {
    await FirebaseFirestore.instance
        .collection("Pet")
        .doc(myPetId)
        .get()
        .then((value) {
      setState(() {
        isOffilne = value.data()['visible'];
      });
    });
  }

  StreamSubscription iosSubscription;

  @override
  void initState() {
    super.initState();
    initPlatformState();

    if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
        // save the token  OR subscribe to a topic here
      });
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    }
    _fcm.configure(
      onMessage: notificationOnMessage,
      onLaunch: notificationOnLaunch,
      onResume: notificationOnResume,
    );
    boostedTimeController = CountdownTimerController(endTime: DateTime.now().millisecondsSinceEpoch + 1000 * 60, onEnd: boostedOnEnd);

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await getSuperLikeTimer().then((value) async {
        superLikeEndTime = value;
        if (DateTime.now().millisecondsSinceEpoch * 1000 > superLikeEndTime) {
          if (prefs.containsKey('superLikesTime')) {
            prefs.remove('superLikesTime');
          }
          await setSuperLikeTime();
          await getSuperLikeTimer().then((value) {
            superLikeEndTime = value;
          });
        }
        timeControllerDay = CountdownTimerController(
            endTime: superLikeEndTime, onEnd: onEndSuperLike);
      });
      getPackageName().then((value) async {
        if (value.getPackage is StandardPackagesModel) {
          await getTime().then((value) async {
            endTime = value;
            if (DateTime.now().millisecondsSinceEpoch * 1000 > endTime) {
              if (prefs.containsKey('likeCount')) {
                prefs.remove('likeCount');
              }
              await setTime();
              await getTime().then((value) {
                endTime = value;
              });
            }
            timeController =
                CountdownTimerController(endTime: endTime, onEnd: onEnd);
          });
          FirebaseAdMob.instance.initialize(appId: FirebaseAdMob.testAppId);
          _interstitialAd = InterstitialAd(
            adUnitId: InterstitialAd.testAdUnitId,
            listener: _onInterstitialAdEvent,
          );
          _loadInterstitialAd();
          whichPackage = 'STANDARD';
        } else if (value.getPackage is PetTagPlusPackagesModel) {
          setState(() {
            whichPackage = 'PETTAGPLUS';
          });
        } else if (value.getPackage is BreederPackagesModel) {
          setState(() {
            whichPackage = 'BREEDER';
          });
        } else if (value.getPackage is RescuerPackagesModel) {
          setState(() {
            whichPackage = 'RESCUER';
          });
        }
      });
    });
    getPetId();
    getPetType();
    getPreferableAge();
    getPreferableDistance();
    getPreferableGender();
    if (mounted) {
      getPackage();
    }
    checkConnectivity();
    getLatLng();
  }

  getData() async {
    return await FirebaseFirestore.instance
        .collection('Pet')
        .where('interaction', whereIn: [auth.currentUser.uid])
        .snapshots()
        .isEmpty;
  }

  fetchData() {
    if (getData() == null || !getData()) {
      return FirebaseFirestore.instance.collection('Pet').snapshots();
    } else {
      FirebaseFirestore.instance
          .collection('Pet')
          .where('interaction', whereNotIn: [auth.currentUser.uid]).snapshots();
    }
  }

  Future<bool> checkConnectivity() async {
    var connected = false;
    try {
      final googleLookup = await InternetAddress.lookup('google.com');
      if (googleLookup.isNotEmpty && googleLookup[0].rawAddress.isNotEmpty) {
        connected = true;
      } else
        connected = false;
    } on SocketException catch (e) {
      connected = false;
      Fluttertoast.showToast(
          msg: "Check Your Internet Connection",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.pink,
          textColor: Colors.black,
          fontSize: 16.0);
    }
    return connected;
  }

  getPackage() async {
    await repo.getPkgInfo().then((value) => setState(() {
          package = value;
        }));
  }

  calculateDistance(lat1, lon1, lat2, lon2) {
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

  var rightColors;
  var leftColors;
  var leftIconColor;
  var rightIconColor;

  Future<List<DocumentSnapshot>> getDocs()async{
    QuerySnapshot snap;
    List<DocumentSnapshot> docList =[];
    await FirebaseFirestore.instance.collection("Pet").where("boosted", isEqualTo: true).orderBy("boostedTimestamp", descending: true).get().then((value) {
      docList.addAll(value.docs);
    });
    await FirebaseFirestore.instance.collection("Pet").where("ownerId", isNotEqualTo:auth.currentUser.uid).get().then((value) {
      docList.addAll(value.docs);
    });
    print("\n\nLength of DocList : ${docList.length}\n\n");
    //setState((){});
    docList.removeWhere((element) => element.data()["ownerId"] == auth.currentUser.uid);
    return docList;
  }

  @override
  void dispose() {
    super.dispose();
    _interstitialAd?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    CardController controller;
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: sharedPrefs.currentUserPetType == 'Cat'
            ? Colors.blue[600]
            : Color(0xFFFC4048),
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
          onTap: () async {
            if (package.isAvailable()) {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return AllProfiles();
              }));
            } else {
              Navigator.pushNamed(
                  context, PetDetailedScreen.petDetailedScreenRoute);
            }
          },
        ),
        centerTitle: true,
        title: Stack(
          children: [
            Container(
              height: 35,
              width: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            Positioned(
              left: 4,
              top: 4,
              bottom: 4,
              child: InkWell(
                onTap: () {
                  setState(() {
                    leftColors = Colors.pink;
                    widget.isLeft = true;
                    rightColors = Colors.white;
                    rightIconColor = Colors.black12;
                    leftIconColor = Colors.white;
                  });
                  pageController.animateToPage(0,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.fastLinearToSlowEaseIn);
                },
                child: Container(
                  width: 41,
                  height: 33,
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: widget.isLeft
                        ? Colors.pink
                        : Colors.white ?? Colors.pink,
                  ),
                  child: Image.asset(
                    "assets/2x/Group 378@2x.png",
                    height: 15,
                    width: 15,
                    color: leftIconColor ?? Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 4,
              top: 4,
              bottom: 4,
              child: InkWell(
                onTap: () {
                  setState(() {
                    rightColors = Colors.pink;
                    rightIconColor = Colors.white;
                    leftIconColor = Colors.black12;
                    leftColors = Colors.white;
                    widget.isLeft = false;
                  });
                  pageController.animateToPage(1,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.fastLinearToSlowEaseIn);
                },
                child: Container(
                  width: 41,
                  height: 33,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: widget.isLeft
                        ? Colors.white
                        : Colors.pink ?? Colors.white,
                  ),
                  child: Image.asset(
                    sharedPrefs.currentUserPetType == "Cat"
                        ? "assets/2x/tuna-fish.png"
                        : "assets/2x/Path 373@2x.png",
                    height: 15,
                    width: 15,
                    color: rightIconColor ?? Colors.black12,
                    //rightIconColor ?? Colors.black12,
                    //rightColors == Colors.pink || widget.isLeft ? Colors.black12 : Colors.white,
                  ),
                ),
              ),
            ),
          ],
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
            onTap: () {
              Navigator.pushNamed(context, PetChatScreen.petChatScreenRoute);
            },
          ),
        ],
      ),
      body: PageView(
          controller: pageController,
          pageSnapping: false,
          allowImplicitScrolling: false,
          physics: NeverScrollableScrollPhysics(),
          children: [
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height / 1.4,
                    child: Stack(alignment: Alignment.topCenter, children: [
                      Visibility(
                        visible: _noCardVisibility,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("You have no card"),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 5.0, right: 5.0),
                              child: Container(
                                height: 400,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.black, width: 1),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      (whichPackage == 'STANDARD')
                          ? FutureBuilder(
                              future: getDocs(),
                              builder: (context,
                                  AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                                if (snapshot.hasData) {
                                  //sharedPrefs.currentUserPetType = snapshot.data.docs[0].data()['type'];
                                  List list;
                                  if (_petType == "Both") {
                                    list = snapshot.data
                                        .where((element) =>
                                            !(element.data().containsKey(
                                                auth.currentUser.uid)) &&
                                            // (element.data()['type'] == _petType) &&
                                            (element.data()['age'] >= minAge &&
                                                element.data()['age'] <=
                                                    maxAge))
                                        .toList();
                                    print("List Length : ${list.length}");
                                    print(
                                        "Selected Pet Type : ${_petType.toString()}");
                                  } else {
                                    list = snapshot.data
                                        .where((element) =>
                                            !(element.data().containsKey(
                                                auth.currentUser.uid)) &&
                                            (element.data()['type'] ==
                                                _petType) &&
                                            (element.data()['age'] >= minAge &&
                                                element.data()['age'] <=
                                                    maxAge))
                                        .toList();
                                    print("List Length : ${list.length}");
                                    print(
                                        "Selected Pet Type : ${_petType.toString()}");
                                  }

                                  /*if (!isShuffled) {
                                  list.shuffle();
                                  isShuffled = true;
                                }*/
                                  petId = snapshot.data[0].id;

                                  return list.length > 0
                                      ? TinderSwapCard(
                                          cardController: controller =
                                              CardController(),
                                          swipeUp: true,
                                          swipeDown: true,
                                          limit: likesLimit,
                                          superLikeLimit: superLikesLimit,
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.9,
                                          maxHeight: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.9,
                                          minWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.8,
                                          minHeight: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.8,
                                          orientation: AmassOrientation.bottom,
                                          totalNum: list.length,
                                          stackNum: 2,
                                          swipeEdge: 3.0,
                                          cardBuilder: (context, index) {
                                            Map<String, dynamic> data =
                                                list[index].data();
                                            if (data.containsKey('Latitude') ||
                                                data.containsKey('longitude')) {
                                              distance = mp.SphericalUtil
                                                  .computeDistanceBetween(
                                                      mp.LatLng(lat, lng),
                                                      mp.LatLng(
                                                          data['latitude'],
                                                          data['longitude']));
                                              distance = (distance / 1000);
                                            }
                                            currentPetId =
                                                list[index].data()['petId'];
                                            return InkWell(
                                              onTap: () {
                                                Navigator.push(context,
                                                    MaterialPageRoute(
                                                        builder: (context) {
                                                  return PetProfileScreen(
                                                    docId: list[index]
                                                        .data()['petId'],
                                                  );
                                                }));
                                              },
                                              child: Stack(children: [
                                                Card(
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    child: Stack(
                                                      children: [
                                                        ShaderMask(
                                                          shaderCallback:
                                                              (bounds) =>
                                                                  LinearGradient(
                                                            begin: Alignment
                                                                .bottomCenter,
                                                            end: Alignment
                                                                .topCenter,
                                                            tileMode:
                                                                TileMode.mirror,
                                                            colors: [
                                                              Color(0xFFEA4253),
                                                              Colors.pink[50],
                                                            ],
                                                            stops: [
                                                              0.0,
                                                              0.4,
                                                            ],
                                                          ).createShader(
                                                                      bounds),
                                                          blendMode: BlendMode
                                                              .multiply,
                                                          child: Image.network(
                                                            list[index].data()[
                                                                'images'][0],
                                                            fit: BoxFit.cover,
                                                            height: 520,
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width -
                                                                40,
                                                          ),
                                                        ),
                                                        Positioned(
                                                          bottom: 20,
                                                          left: 15,
                                                          child: Column(
                                                            children: [
                                                              Text(
                                                                list[index]
                                                                        .data()[
                                                                    'name'],
                                                                style:
                                                                    storyTitle,
                                                              ),
                                                              SizedBox(
                                                                height: 10,
                                                              ),
                                                              Text(
                                                                "${distance.toStringAsFixed(1)} Km Away",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                isLeft
                                                    ? Visibility(
                                                        visible: _action,
                                                        child: Positioned(
                                                          right: 15,
                                                          top: 50,
                                                          child:
                                                              Transform.rotate(
                                                            angle: 3.14 / 7,
                                                            child: Container(
                                                              height: 50,
                                                              width: 130,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .red,
                                                                    width: 2),
                                                              ),
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(2),
                                                              child: Center(
                                                                child: Text(
                                                                  _petType ==
                                                                          "Both"
                                                                      ? list[index].data()['type'] ==
                                                                              "Cat"
                                                                          ? "Hiss"
                                                                          : "GROWL"
                                                                      : sharedPrefs.currentUserPetType ==
                                                                              "Cat"
                                                                          ? "Hiss"
                                                                          : "GROWL",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .red,
                                                                    fontSize:
                                                                        35,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : isRight
                                                        ? Visibility(
                                                            visible: _action,
                                                            child: Positioned(
                                                              left: 15,
                                                              top: 40,
                                                              child: Transform
                                                                  .rotate(
                                                                angle:
                                                                    -3.14 / 7,
                                                                child:
                                                                    Container(
                                                                  height: 50,
                                                                  width: 110,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(5),
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .green,
                                                                        width:
                                                                            3),
                                                                  ),
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              2),
                                                                  child: Center(
                                                                    child: Text(
                                                                      _petType ==
                                                                              "Both"
                                                                          ? list[index].data()['type'] == "Cat"
                                                                              ? "Purr"
                                                                              : "BARK"
                                                                          : sharedPrefs.currentUserPetType == "Cat"
                                                                              ? "Purr"
                                                                              : "BARK",
                                                                      // sharedPrefs.currentUserPetType ==
                                                                      //         "Cat"
                                                                      //     ? "Purr"
                                                                      //     : "BARK",
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .green,
                                                                        fontSize:
                                                                            35,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        : Visibility(
                                                            visible: _action,
                                                            child: Positioned(
                                                              left: 80,
                                                              right: 80,
                                                              bottom: 100,
                                                              child: Transform
                                                                  .rotate(
                                                                angle:
                                                                    -3.14 / 7,
                                                                child:
                                                                    Container(
                                                                  width: 60,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(5),
                                                                    border: Border.all(
                                                                        color: Colors.blue[
                                                                            700],
                                                                        width:
                                                                            3),
                                                                  ),
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              2),
                                                                  child: Center(
                                                                    child: Text(
                                                                      "SUPER\nLIKE",
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .blue[700],
                                                                        fontSize:
                                                                            35,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                              ]),
                                            );
                                          },
                                          swipeUpdateCallback:
                                              (DragUpdateDetails details,
                                                  Alignment align) {
                                            /// Get swiping card's alignment
                                            if (align.x < -2) {
                                              //setState(() {
                                              _action = true;
                                              isLeft = true;
                                              isRight = false;
                                              isTop = false;
                                              // });
                                              //updateInteraction(status: 0, petId: petId);
                                              //Card is LEFT swiping
                                            } else if (align.x > 2) {
                                              //Card is RIGHT swiping
                                              //setState(() {
                                              _action = true;
                                              isLeft = false;
                                              isRight = true;
                                              isTop = false;
                                              // });
                                              //updateInteraction(status: 1, petId: petId);
                                            }
                                            if (align.y < -2) {
                                              //setState(() {
                                              _action = true;
                                              isTop = true;
                                              isLeft = false;
                                              isRight = false;

                                              // });
                                              //updateInteraction(status: 2, petId: petId);
                                            }
                                          },
                                          swipeCompleteCallback:
                                              (CardSwipeOrientation orientation,
                                                  int index) async {
                                            _index = index - 1;

                                            if (orientation ==
                                                CardSwipeOrientation.right) {
                                              lastCard = false;
                                              if (await likeCounter()) {
                                                updateInteraction(
                                                  status: 1,
                                                  petId: list[index]
                                                      .data()['petId'],
                                                  petName: list[index]
                                                      .data()['name'],
                                                  petImage: list[index]
                                                      .data()['images'][0],
                                                );
                                              } else {
                                                setState(() {
                                                  likesLimit = false;
                                                });
                                              }
                                            } else if (orientation ==
                                                CardSwipeOrientation.down) {
                                              lastCard = true;
                                            } else if (orientation ==
                                                CardSwipeOrientation.left) {
                                              lastCard = true;
                                              //updateInteraction(status: 0, petId: petId);
                                            } else if (orientation ==
                                                CardSwipeOrientation.up) {
                                              lastCard = false;
                                              if (await superLikeCounter(1)) {
                                                updateInteraction(
                                                  status: 2,
                                                  petId: list[index]
                                                      .data()['petId'],
                                                  petName: list[index]
                                                      .data()['name'],
                                                  petImage: list[index]
                                                      .data()['images'][0],
                                                );
                                              } else {
                                                setState(() {
                                                  superLikesLimit = false;
                                                });
                                              }
                                            }
                                            _action = false;
                                            if (index != 0 && index % 10 == 0) {
                                              if (_isInterstitialAdReady) {
                                                _interstitialAd.show();
                                              }
                                            }
                                            if (index == list.length - 1) {
                                              setState(() {
                                                _noCardVisibility = true;
                                              });
                                            }
                                          },
                                        )
                                      : Center(
                                          child: CircularProgressIndicator(
                                            backgroundColor: Colors.pink,
                                            strokeWidth: 2,
                                          ),
                                        );
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      backgroundColor: Colors.pink,
                                      strokeWidth: 2,
                                    ),
                                  );
                                }
                              })
                          : (whichPackage == 'PETTAGPLUS')
                              ? FutureBuilder(
                                  future: getDocs(),
                                  builder: (context,
                                      AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                                    if (snapshot.hasData) {
                                      List list;
                                      if (_petType == "Both") {
                                        list = snapshot.data
                                            .where((element) =>
                                                !(element.data().containsKey(
                                                    auth.currentUser.uid)) &&
                                                // (element.data()['type'] == _petType) &&
                                                (element.data()['age'] >=
                                                        minAge &&
                                                    element.data()['age'] <=
                                                        maxAge) &&
                                                (element.data()['visible']))
                                            .toList();
                                        print("List Length : ${list.length}");
                                        print(
                                            "Selected Pet Type : ${_petType.toString()}");
                                      } else {
                                        list = snapshot.data
                                            .where((element) =>
                                                !(element.data().containsKey(
                                                    auth.currentUser.uid)) &&
                                                (element.data()['type'] ==
                                                    _petType) &&
                                                (element.data()['age'] >=
                                                        minAge &&
                                                    element.data()['age'] <=
                                                        maxAge) &&
                                                (element.data()['visible']))
                                            .toList();
                                        print("List Length : ${list.length}");
                                        print(
                                            "Selected Pet Type : ${_petType.toString()}");
                                      }

                                      // List list = snapshot.data.docs
                                      //     .where((element) =>
                                      //         !(element.data().containsKey(
                                      //             auth.currentUser.uid)) &&
                                      //         (element.data()['type'] ==
                                      //             _petType) &&
                                      //         (element.data()['age'] >= minAge &&
                                      //             element.data()['age'] <=
                                      //                 maxAge))
                                      //     .toList();
                                      // print("List Length : ${list.length}");

                                      if (!isShuffled) {
                                        list.shuffle();
                                        isShuffled = true;
                                      }
                                      petId = snapshot.data[0].id;
                                      return list.length > 0
                                          ? TinderSwapCard(
                                              cardController: controller =
                                                  CardController(),
                                              swipeUp: true,
                                              swipeDown: true,
                                              limit: true,
                                              superLikeLimit: superLikesLimit,
                                              maxWidth: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.9,
                                              maxHeight: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.9,
                                              minWidth: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.8,
                                              minHeight: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.8,
                                              orientation:
                                                  AmassOrientation.bottom,
                                              totalNum: list.length,
                                              stackNum: 2,
                                              swipeEdge: 3.0,
                                              cardBuilder: (context, index) {
                                                Map<String, dynamic> data =
                                                    list[index].data();
                                                if (data.containsKey(
                                                        'Latitude') ||
                                                    data.containsKey(
                                                        'longitude')) {
                                                  distance = mp.SphericalUtil
                                                      .computeDistanceBetween(
                                                          mp.LatLng(lat, lng),
                                                          mp.LatLng(
                                                              data['latitude'],
                                                              data[
                                                                  'longitude']));
                                                  distance = (distance / 1000);
                                                }
                                                currentPetId =
                                                    list[index].data()['petId'];
                                                return InkWell(
                                                  onTap: () {
                                                    Navigator.push(context,
                                                        MaterialPageRoute(
                                                            builder: (context) {
                                                      return PetProfileScreen(
                                                        docId: list[index]
                                                            .data()['petId'],
                                                      );
                                                    }));
                                                  },
                                                  child: Stack(children: [
                                                    Card(
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        child: Stack(
                                                          children: [
                                                            ShaderMask(
                                                              shaderCallback:
                                                                  (bounds) =>
                                                                      LinearGradient(
                                                                begin: Alignment
                                                                    .bottomCenter,
                                                                end: Alignment
                                                                    .topCenter,
                                                                tileMode:
                                                                    TileMode
                                                                        .mirror,
                                                                colors: [
                                                                  Color(
                                                                      0xFFEA4253),
                                                                  Colors
                                                                      .pink[50],
                                                                ],
                                                                stops: [
                                                                  0.0,
                                                                  0.4,
                                                                ],
                                                              ).createShader(
                                                                          bounds),
                                                              blendMode:
                                                                  BlendMode
                                                                      .multiply,
                                                              child:
                                                                  Image.network(
                                                                list[index]
                                                                        .data()[
                                                                    'images'][0],
                                                                fit: BoxFit
                                                                    .cover,
                                                                height: 520,
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width -
                                                                    40,
                                                              ),
                                                            ),
                                                            Positioned(
                                                              bottom: 20,
                                                              left: 15,
                                                              child: Column(
                                                                children: [
                                                                  Text(
                                                                    list[index]
                                                                            .data()[
                                                                        'name'],
                                                                    style:
                                                                        storyTitle,
                                                                  ),
                                                                  SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  Text(
                                                                    "${distance.toStringAsFixed(1)} Km Away",
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          13,
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    isLeft
                                                        ? Visibility(
                                                            visible: _action,
                                                            child: Positioned(
                                                              right: 15,
                                                              top: 50,
                                                              child: Transform
                                                                  .rotate(
                                                                angle: 3.14 / 7,
                                                                child:
                                                                    Container(
                                                                  height: 50,
                                                                  width: 130,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .red,
                                                                        width:
                                                                            2),
                                                                  ),
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              2),
                                                                  child: Center(
                                                                    child: Text(
                                                                      _petType ==
                                                                              "Both"
                                                                          ? list[index].data()['type'] == "Cat"
                                                                              ? "Hiss"
                                                                              : "GROWL"
                                                                          : sharedPrefs.currentUserPetType == "Cat"
                                                                              ? "Hiss"
                                                                              : "GROWL",

                                                                      // sharedPrefs.currentUserPetType ==
                                                                      //         "Cat"
                                                                      //     ? "Hiss"
                                                                      //     : "GROWL",

                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .red,
                                                                        fontSize:
                                                                            35,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        : isRight
                                                            ? Visibility(
                                                                visible:
                                                                    _action,
                                                                child:
                                                                    Positioned(
                                                                  left: 15,
                                                                  top: 40,
                                                                  child: Transform
                                                                      .rotate(
                                                                    angle:
                                                                        -3.14 /
                                                                            7,
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          50,
                                                                      width:
                                                                          110,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(5),
                                                                        border: Border.all(
                                                                            color:
                                                                                Colors.green,
                                                                            width: 3),
                                                                      ),
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              2),
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Text(
                                                                          _petType == "Both"
                                                                              ? list[index].data()['type'] == "Cat"
                                                                                  ? "Purr"
                                                                                  : "BARK"
                                                                              : sharedPrefs.currentUserPetType == "Cat"
                                                                                  ? "Purr"
                                                                                  : "BARK",

                                                                          // sharedPrefs.currentUserPetType ==
                                                                          //         "Cat"
                                                                          //     ? "Purr"
                                                                          //     : "BARK",
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.green,
                                                                            fontSize:
                                                                                35,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                            : Visibility(
                                                                visible:
                                                                    _action,
                                                                child:
                                                                    Positioned(
                                                                  left: 80,
                                                                  right: 80,
                                                                  bottom: 100,
                                                                  child: Transform
                                                                      .rotate(
                                                                    angle:
                                                                        -3.14 /
                                                                            7,
                                                                    child:
                                                                        Container(
                                                                      width: 60,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(5),
                                                                        border: Border.all(
                                                                            color:
                                                                                Colors.blue[700],
                                                                            width: 3),
                                                                      ),
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              2),
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Text(
                                                                          "SUPER\nLIKE",
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.blue[700],
                                                                            fontSize:
                                                                                35,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                  ]),
                                                );
                                              },
                                              swipeUpdateCallback:
                                                  (DragUpdateDetails details,
                                                      Alignment align) {
                                                /// Get swiping card's alignment
                                                if (align.x < -2) {
                                                  //setState(() {
                                                  _action = true;
                                                  isLeft = true;
                                                  isRight = false;
                                                  isTop = false;
                                                  // });
                                                  //updateInteraction(status: 0, petId: petId);
                                                  //Card is LEFT swiping
                                                } else if (align.x > 2) {
                                                  //Card is RIGHT swiping
                                                  //setState(() {
                                                  _action = true;
                                                  isLeft = false;
                                                  isRight = true;
                                                  isTop = false;
                                                  // });
                                                  //updateInteraction(status: 1, petId: petId);
                                                }
                                                if (align.y < -2) {
                                                  //setState(() {
                                                  _action = true;
                                                  isTop = true;
                                                  isLeft = false;
                                                  isRight = false;

                                                  // });
                                                  //updateInteraction(status: 2, petId: petId);
                                                }
                                              },
                                              swipeCompleteCallback:
                                                  (CardSwipeOrientation
                                                          orientation,
                                                      int index) async {
                                                if (orientation ==
                                                    CardSwipeOrientation
                                                        .right) {
                                                  lastCard = false;
                                                  updateInteraction(
                                                      status: 1, petId: petId);
                                                  /*if (await likeCounter()) {
                                    updateInteraction(
                                        status: 1, petId: petId);
                                  } else {
                                    setState(() {
                                      likesLimit = false;
                                    });
                                  }*/
                                                } else if (orientation ==
                                                    CardSwipeOrientation.left) {
                                                  lastCard = false;
                                                  updateInteraction(
                                                      status: 0, petId: petId);
                                                } else if (orientation ==
                                                    CardSwipeOrientation.down) {
                                                  lastCard = true;
                                                } else if (orientation ==
                                                    CardSwipeOrientation.up) {
                                                  lastCard = false;
                                                  if (await superLikeCounter(
                                                      5)) {
                                                    updateInteraction(
                                                        status: 2,
                                                        petId: petId);
                                                  } else {
                                                    setState(() {
                                                      superLikesLimit = false;
                                                    });
                                                  }
                                                }
                                                _action = false;
                                                /*if (index != 0 && index % 2 == 0) {
                                  if (_isInterstitialAdReady) {
                                    _interstitialAd.show();
                                  }
                                }*/
                                                if (index == list.length - 1) {
                                                  setState(() {
                                                    _noCardVisibility = true;
                                                  });
                                                }
                                              },
                                            )
                                          : Center(
                                              child: CircularProgressIndicator(
                                                backgroundColor: Colors.pink,
                                                strokeWidth: 2,
                                              ),
                                            );
                                    } else {
                                      return Center(
                                        child: CircularProgressIndicator(
                                          backgroundColor: Colors.pink,
                                          strokeWidth: 2,
                                        ),
                                      );
                                    }
                                  })
                              /*Center(
                                child: Text(
                                  "PetTagPlus",
                                  style: TextStyle(
                                      fontSize: 22,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              )*/
                              : (whichPackage == 'BREEDER')
                                  ? FutureBuilder(
                                      future: getDocs(),
                                      builder: (context,
                                          AsyncSnapshot<List<DocumentSnapshot>>
                                              snapshot) {
                                        if (snapshot.hasData) {
                                          List list;
                                          if (_petType == "Both") {
                                            list = snapshot.data
                                                .where((element) =>
                                                    !(element
                                                        .data()
                                                        .containsKey(auth
                                                            .currentUser
                                                            .uid)) &&
                                                    // (element.data()['type'] == _petType) &&
                                                    (element.data()['age'] >=
                                                            minAge &&
                                                        element.data()['age'] <=
                                                            maxAge) &&
                                                    (element.data()['visible']))
                                                .toList();
                                            print(
                                                "List Length : ${list.length}");
                                            print(
                                                "Selected Pet Type : ${_petType.toString()}");
                                          } else {
                                            list = snapshot.data
                                                .where((element) =>
                                                    !(element
                                                        .data()
                                                        .containsKey(auth
                                                            .currentUser
                                                            .uid)) &&
                                                    (element.data()['type'] ==
                                                        _petType) &&
                                                    (element.data()['age'] >=
                                                            minAge &&
                                                        element.data()['age'] <=
                                                            maxAge) &&
                                                    (element.data()['visible']))
                                                .toList();
                                            print(
                                                "List Length : ${list.length}");
                                            print(
                                                "Selected Pet Type : ${_petType.toString()}");
                                          }

                                          // List list = snapshot.data.docs
                                          //     .where((element) =>
                                          //         !(element.data().containsKey(
                                          //             auth.currentUser.uid)) &&
                                          //         (element.data()['type'] ==
                                          //             _petType) &&
                                          //         (element.data()['age'] >=
                                          //                 minAge &&
                                          //             element.data()['age'] <=
                                          //                 maxAge))
                                          //     .toList();
                                          // print("List Length : ${list.length}");

                                          if (!isShuffled) {
                                            list.shuffle();
                                            isShuffled = true;
                                          }
                                          petId = snapshot.data[0].id;
                                          return list.length > 0
                                              ? TinderSwapCard(
                                                  cardController: controller =
                                                      CardController(),
                                                  swipeUp: true,
                                                  swipeDown: true,
                                                  limit: true,
                                                  superLikeLimit: true,
                                                  maxWidth:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.9,
                                                  maxHeight:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          0.9,
                                                  minWidth:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.8,
                                                  minHeight:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.8,
                                                  orientation:
                                                      AmassOrientation.bottom,
                                                  totalNum: list.length,
                                                  stackNum: 2,
                                                  swipeEdge: 3.0,
                                                  cardBuilder:
                                                      (context, index) {
                                                    Map<String, dynamic> data =
                                                        list[index].data();
                                                    if (data.containsKey(
                                                            'Latitude') ||
                                                        data.containsKey(
                                                            'longitude')) {
                                                      distance = mp
                                                              .SphericalUtil
                                                          .computeDistanceBetween(
                                                              mp.LatLng(
                                                                  lat, lng),
                                                              mp.LatLng(
                                                                  data[
                                                                      'latitude'],
                                                                  data[
                                                                      'longitude']));
                                                      distance =
                                                          (distance / 1000);
                                                    }
                                                    currentPetId = list[index]
                                                        .data()['petId'];
                                                    return InkWell(
                                                      onTap: () {
                                                        Navigator.push(context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) {
                                                          return PetProfileScreen(
                                                            docId: list[index]
                                                                    .data()[
                                                                'petId'],
                                                          );
                                                        }));
                                                      },
                                                      child: Stack(children: [
                                                        Card(
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            child: Stack(
                                                              children: [
                                                                ShaderMask(
                                                                  shaderCallback:
                                                                      (bounds) =>
                                                                          LinearGradient(
                                                                    begin: Alignment
                                                                        .bottomCenter,
                                                                    end: Alignment
                                                                        .topCenter,
                                                                    tileMode:
                                                                        TileMode
                                                                            .mirror,
                                                                    colors: [
                                                                      Color(
                                                                          0xFFEA4253),
                                                                      Colors.pink[
                                                                          50],
                                                                    ],
                                                                    stops: [
                                                                      0.0,
                                                                      0.4,
                                                                    ],
                                                                  ).createShader(
                                                                              bounds),
                                                                  blendMode:
                                                                      BlendMode
                                                                          .multiply,
                                                                  child: Image
                                                                      .network(
                                                                    list[index]
                                                                            .data()[
                                                                        'images'][0],
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    height: 520,
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width -
                                                                        40,
                                                                  ),
                                                                ),
                                                                Positioned(
                                                                  bottom: 20,
                                                                  left: 15,
                                                                  child: Column(
                                                                    children: [
                                                                      Text(
                                                                        list[index]
                                                                            .data()['name'],
                                                                        style:
                                                                            storyTitle,
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Text(
                                                                        "${distance.toStringAsFixed(1)} Km Away",
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          color:
                                                                              Colors.white,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        isLeft
                                                            ? Visibility(
                                                                visible:
                                                                    _action,
                                                                child:
                                                                    Positioned(
                                                                  right: 15,
                                                                  top: 50,
                                                                  child: Transform
                                                                      .rotate(
                                                                    angle:
                                                                        3.14 /
                                                                            7,
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          50,
                                                                      width:
                                                                          130,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                        border: Border.all(
                                                                            color:
                                                                                Colors.red,
                                                                            width: 2),
                                                                      ),
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              2),
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Text(
                                                                          _petType == "Both"
                                                                              ? list[index].data()['type'] == "Cat"
                                                                                  ? "Hiss"
                                                                                  : "GROWL"
                                                                              : sharedPrefs.currentUserPetType == "Cat"
                                                                                  ? "Hiss"
                                                                                  : "GROWL",

                                                                          // sharedPrefs.currentUserPetType ==
                                                                          //         "Cat"
                                                                          //     ? "Hiss"
                                                                          //     : "GROWL",

                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.red,
                                                                            fontSize:
                                                                                35,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                            : isRight
                                                                ? Visibility(
                                                                    visible:
                                                                        _action,
                                                                    child:
                                                                        Positioned(
                                                                      left: 15,
                                                                      top: 40,
                                                                      child: Transform
                                                                          .rotate(
                                                                        angle:
                                                                            -3.14 /
                                                                                7,
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              50,
                                                                          width:
                                                                              110,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(5),
                                                                            border:
                                                                                Border.all(color: Colors.green, width: 3),
                                                                          ),
                                                                          padding:
                                                                              EdgeInsets.all(2),
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                Text(
                                                                              _petType == "Both"
                                                                                  ? list[index].data()['type'] == "Cat"
                                                                                      ? "Purr"
                                                                                      : "BARK"
                                                                                  : sharedPrefs.currentUserPetType == "Cat"
                                                                                      ? "Purr"
                                                                                      : "BARK",
                                                                              style: TextStyle(
                                                                                color: Colors.green,
                                                                                fontSize: 35,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  )
                                                                : Visibility(
                                                                    visible:
                                                                        _action,
                                                                    child:
                                                                        Positioned(
                                                                      left: 80,
                                                                      right: 80,
                                                                      bottom:
                                                                          100,
                                                                      child: Transform
                                                                          .rotate(
                                                                        angle:
                                                                            -3.14 /
                                                                                7,
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              60,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(5),
                                                                            border:
                                                                                Border.all(color: Colors.blue[700], width: 3),
                                                                          ),
                                                                          padding:
                                                                              EdgeInsets.all(2),
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                Text(
                                                                              "SUPER\nLIKE",
                                                                              style: TextStyle(
                                                                                color: Colors.blue[700],
                                                                                fontSize: 35,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                      ]),
                                                    );
                                                  },
                                                  swipeUpdateCallback:
                                                      (DragUpdateDetails
                                                              details,
                                                          Alignment align) {
                                                    /// Get swiping card's alignment
                                                    if (align.x < -2) {
                                                      //setState(() {
                                                      _action = true;
                                                      isLeft = true;
                                                      isRight = false;
                                                      isTop = false;
                                                      // });
                                                      //updateInteraction(status: 0, petId: petId);
                                                      //Card is LEFT swiping
                                                    } else if (align.x > 2) {
                                                      //Card is RIGHT swiping
                                                      //setState(() {
                                                      _action = true;
                                                      isLeft = false;
                                                      isRight = true;
                                                      isTop = false;
                                                      // });
                                                      //updateInteraction(status: 1, petId: petId);
                                                    }
                                                    if (align.y < -2) {
                                                      //setState(() {
                                                      _action = true;
                                                      isTop = true;
                                                      isLeft = false;
                                                      isRight = false;

                                                      // });
                                                      //updateInteraction(status: 2, petId: petId);
                                                    }
                                                  },
                                                  swipeCompleteCallback:
                                                      (CardSwipeOrientation
                                                              orientation,
                                                          int index) async {
                                                    if (orientation ==
                                                        CardSwipeOrientation
                                                            .right) {
                                                      lastCard = false;
                                                      updateInteraction(
                                                          status: 1,
                                                          petId: petId);
                                                      /*if (await likeCounter()) {
                                    updateInteraction(
                                        status: 1, petId: petId);
                                  } else {
                                    setState(() {
                                      likesLimit = false;
                                    });
                                  }*/
                                                    } else if (orientation ==
                                                        CardSwipeOrientation
                                                            .down) {
                                                      lastCard = true;
                                                    } else if (orientation ==
                                                        CardSwipeOrientation
                                                            .left) {
                                                      lastCard = true;
                                                      updateInteraction(
                                                          status: 0,
                                                          petId: petId);
                                                    } else if (orientation ==
                                                        CardSwipeOrientation
                                                            .up) {
                                                      lastCard = false;
                                                      updateInteraction(
                                                          status: 2,
                                                          petId: petId);
                                                    }
                                                    _action = false;
                                                    /*if (index != 0 && index % 2 == 0) {
                                  if (_isInterstitialAdReady) {
                                    _interstitialAd.show();
                                  }
                                }*/
                                                    if (index ==
                                                        list.length - 1) {
                                                      setState(() {
                                                        _noCardVisibility =
                                                            true;
                                                      });
                                                    }
                                                  },
                                                )
                                              : Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    backgroundColor:
                                                        Colors.pink,
                                                    strokeWidth: 2,
                                                  ),
                                                );
                                        } else {
                                          return Center(
                                            child: CircularProgressIndicator(
                                              backgroundColor: Colors.pink,
                                              strokeWidth: 2,
                                            ),
                                          );
                                        }
                                      })
                                  : (whichPackage == 'RESCUER')
                                      ? FutureBuilder(
                                          future: getDocs(),
                                          builder: (context,
                                              AsyncSnapshot<List<DocumentSnapshot>>
                                                  snapshot) {
                                            if (snapshot.hasData) {
                                              List list;
                                              if (_petType == "Both") {
                                                list = snapshot.data
                                                    .where((element) =>
                                                        !(element
                                                            .data()
                                                            .containsKey(auth
                                                                .currentUser
                                                                .uid)) &&
                                                        // (element.data()['type'] == _petType) &&
                                                        (element.data()[
                                                                    'age'] >=
                                                                minAge &&
                                                            element.data()[
                                                                    'age'] <=
                                                                maxAge) &&
                                                        (element
                                                            .data()['visible']))
                                                    .toList();
                                                print(
                                                    "List Length : ${list.length}");
                                                print(
                                                    "Selected Pet Type : ${_petType.toString()}");
                                              } else {
                                                list = snapshot.data
                                                    .where((element) =>
                                                        !(element
                                                            .data()
                                                            .containsKey(auth
                                                                .currentUser
                                                                .uid)) &&
                                                        (element.data()[
                                                                'type'] ==
                                                            _petType) &&
                                                        (element.data()[
                                                                    'age'] >=
                                                                minAge &&
                                                            element.data()[
                                                                    'age'] <=
                                                                maxAge) &&
                                                        (element
                                                            .data()['visible']))
                                                    .toList();
                                                print(
                                                    "List Length : ${list.length}");
                                                print(
                                                    "Selected Pet Type : ${_petType.toString()}");
                                              }

                                              // List list = snapshot.data.docs
                                              //     .where((element) =>
                                              //         !(element
                                              //             .data()
                                              //             .containsKey(auth
                                              //                 .currentUser
                                              //                 .uid)) &&
                                              //         (element.data()['type'] ==
                                              //             _petType) &&
                                              //         (element.data()['age'] >=
                                              //                 minAge &&
                                              //             element.data()['age'] <=
                                              //                 maxAge))
                                              //     .toList();
                                              // print(
                                              //     "List Length : ${list.length}");

                                              if (!isShuffled) {
                                                list.shuffle();
                                                isShuffled = true;
                                              }
                                              petId = snapshot.data[0].id;
                                              return list.length > 0
                                                  ? TinderSwapCard(
                                                      cardController:
                                                          controller =
                                                              CardController(),
                                                      swipeUp: true,
                                                      swipeDown: true,
                                                      limit: true,
                                                      superLikeLimit: true,
                                                      maxWidth:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.9,
                                                      maxHeight:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.9,
                                                      minWidth:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.8,
                                                      minHeight:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.8,
                                                      orientation:
                                                          AmassOrientation
                                                              .bottom,
                                                      totalNum: list.length,
                                                      stackNum: 2,
                                                      swipeEdge: 3.0,
                                                      cardBuilder:
                                                          (context, index) {
                                                        Map<String, dynamic>
                                                            data =
                                                            list[index].data();
                                                        if (data.containsKey(
                                                                'Latitude') ||
                                                            data.containsKey(
                                                                'longitude')) {
                                                          distance = mp
                                                                  .SphericalUtil
                                                              .computeDistanceBetween(
                                                                  mp.LatLng(
                                                                      lat, lng),
                                                                  mp.LatLng(
                                                                      data[
                                                                          'latitude'],
                                                                      data[
                                                                          'longitude']));
                                                          distance =
                                                              (distance / 1000);
                                                        }
                                                        currentPetId =
                                                            list[index].data()[
                                                                'petId'];
                                                        return InkWell(
                                                          onTap: () {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) {
                                                              return PetProfileScreen(
                                                                docId: list[index]
                                                                        .data()[
                                                                    'petId'],
                                                              );
                                                            }));
                                                          },
                                                          child: Stack(
                                                              children: [
                                                                Card(
                                                                  child:
                                                                      ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                    child:
                                                                        Stack(
                                                                      children: [
                                                                        ShaderMask(
                                                                          shaderCallback: (bounds) =>
                                                                              LinearGradient(
                                                                            begin:
                                                                                Alignment.bottomCenter,
                                                                            end:
                                                                                Alignment.topCenter,
                                                                            tileMode:
                                                                                TileMode.mirror,
                                                                            colors: [
                                                                              Color(0xFFEA4253),
                                                                              Colors.pink[50],
                                                                            ],
                                                                            stops: [
                                                                              0.0,
                                                                              0.4,
                                                                            ],
                                                                          ).createShader(bounds),
                                                                          blendMode:
                                                                              BlendMode.multiply,
                                                                          child:
                                                                              Image.network(
                                                                            list[index].data()['images'][0],
                                                                            fit:
                                                                                BoxFit.cover,
                                                                            height:
                                                                                520,
                                                                            width:
                                                                                MediaQuery.of(context).size.width - 40,
                                                                          ),
                                                                        ),
                                                                        Positioned(
                                                                          bottom:
                                                                              20,
                                                                          left:
                                                                              15,
                                                                          child:
                                                                              Column(
                                                                            children: [
                                                                              Text(
                                                                                list[index].data()['name'],
                                                                                style: storyTitle,
                                                                              ),
                                                                              SizedBox(
                                                                                height: 10,
                                                                              ),
                                                                              Text(
                                                                                "${distance.toStringAsFixed(1)} Km Away",
                                                                                style: TextStyle(
                                                                                  fontSize: 13,
                                                                                  color: Colors.white,
                                                                                  fontWeight: FontWeight.bold,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                isLeft
                                                                    ? Visibility(
                                                                        visible:
                                                                            _action,
                                                                        child:
                                                                            Positioned(
                                                                          right:
                                                                              15,
                                                                          top:
                                                                              50,
                                                                          child:
                                                                              Transform.rotate(
                                                                            angle:
                                                                                3.14 / 7,
                                                                            child:
                                                                                Container(
                                                                              height: 50,
                                                                              width: 130,
                                                                              decoration: BoxDecoration(
                                                                                borderRadius: BorderRadius.circular(10),
                                                                                border: Border.all(color: Colors.red, width: 2),
                                                                              ),
                                                                              padding: EdgeInsets.all(2),
                                                                              child: Center(
                                                                                child: Text(
                                                                                  _petType == "Both"
                                                                                      ? list[index].data()['type'] == "Cat"
                                                                                          ? "Hiss"
                                                                                          : "GROWL"
                                                                                      : sharedPrefs.currentUserPetType == "Cat"
                                                                                          ? "Hiss"
                                                                                          : "GROWL",
                                                                                  // sharedPrefs.currentUserPetType == "Both"
                                                                                  //     ? "Hiss"
                                                                                  //     : "GROWL",
                                                                                  style: TextStyle(
                                                                                    color: Colors.red,
                                                                                    fontSize: 35,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      )
                                                                    : isRight
                                                                        ? Visibility(
                                                                            visible:
                                                                                _action,
                                                                            child:
                                                                                Positioned(
                                                                              left: 15,
                                                                              top: 40,
                                                                              child: Transform.rotate(
                                                                                angle: -3.14 / 7,
                                                                                child: Container(
                                                                                  height: 50,
                                                                                  width: 110,
                                                                                  decoration: BoxDecoration(
                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                    border: Border.all(color: Colors.green, width: 3),
                                                                                  ),
                                                                                  padding: EdgeInsets.all(2),
                                                                                  child: Center(
                                                                                    child: Text(
                                                                                      _petType == "Both"
                                                                                          ? list[index].data()['type'] == "Cat"
                                                                                              ? "Purr"
                                                                                              : "BARK"
                                                                                          : sharedPrefs.currentUserPetType == "Cat"
                                                                                              ? "Purr"
                                                                                              : "BARK",

                                                                                      //sharedPrefs.currentUserPetType == "Cat" ? "Purr" : "BARK",
                                                                                      style: TextStyle(
                                                                                        color: Colors.green,
                                                                                        fontSize: 35,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          )
                                                                        : Visibility(
                                                                            visible:
                                                                                _action,
                                                                            child:
                                                                                Positioned(
                                                                              left: 80,
                                                                              right: 80,
                                                                              bottom: 100,
                                                                              child: Transform.rotate(
                                                                                angle: -3.14 / 7,
                                                                                child: Container(
                                                                                  width: 60,
                                                                                  decoration: BoxDecoration(
                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                    border: Border.all(color: Colors.blue[700], width: 3),
                                                                                  ),
                                                                                  padding: EdgeInsets.all(2),
                                                                                  child: Center(
                                                                                    child: Text(
                                                                                      "SUPER\nLIKE",
                                                                                      style: TextStyle(
                                                                                        color: Colors.blue[700],
                                                                                        fontSize: 35,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                              ]),
                                                        );
                                                      },
                                                      swipeUpdateCallback:
                                                          (DragUpdateDetails
                                                                  details,
                                                              Alignment align) {
                                                        /// Get swiping card's alignment
                                                        if (align.x < -2) {
                                                          //setState(() {
                                                          _action = true;
                                                          isLeft = true;
                                                          isRight = false;
                                                          isTop = false;
                                                          // });
                                                          //updateInteraction(status: 0, petId: petId);
                                                          //Card is LEFT swiping
                                                        } else if (align.x >
                                                            2) {
                                                          //Card is RIGHT swiping
                                                          //setState(() {
                                                          _action = true;
                                                          isLeft = false;
                                                          isRight = true;
                                                          isTop = false;
                                                          // });
                                                          //updateInteraction(status: 1, petId: petId);
                                                        }
                                                        if (align.y < -2) {
                                                          //setState(() {
                                                          _action = true;
                                                          isTop = true;
                                                          isLeft = false;
                                                          isRight = false;

                                                          // });
                                                          //updateInteraction(status: 2, petId: petId);
                                                        }
                                                      },
                                                      swipeCompleteCallback:
                                                          (CardSwipeOrientation
                                                                  orientation,
                                                              int index) async {
                                                        if (orientation ==
                                                            CardSwipeOrientation
                                                                .right) {
                                                          lastCard = false;
                                                          updateInteraction(
                                                              status: 1,
                                                              petId: petId);
                                                          /*if (await likeCounter()) {
                                    updateInteraction(
                                        status: 1, petId: petId);
                                  } else {
                                    setState(() {
                                      likesLimit = false;
                                    });
                                  }*/
                                                        } else if (orientation ==
                                                            CardSwipeOrientation
                                                                .down) {
                                                          lastCard = true;
                                                        } else if (orientation ==
                                                            CardSwipeOrientation
                                                                .left) {
                                                          lastCard = true;
                                                          updateInteraction(
                                                              status: 0,
                                                              petId: petId);
                                                        } else if (orientation ==
                                                            CardSwipeOrientation
                                                                .up) {
                                                          lastCard = false;
                                                          updateInteraction(
                                                              status: 2,
                                                              petId: petId);
                                                        }
                                                        _action = false;
                                                        /*if (index != 0 && index % 2 == 0) {
                                  if (_isInterstitialAdReady) {
                                    _interstitialAd.show();
                                  }
                                }*/
                                                        if (index ==
                                                            list.length - 1) {
                                                          setState(() {
                                                            _noCardVisibility =
                                                                true;
                                                          });
                                                        }
                                                      },
                                                    )
                                                  : Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        backgroundColor:
                                                            Colors.pink,
                                                        strokeWidth: 2,
                                                      ),
                                                    );
                                            } else {
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  backgroundColor: Colors.pink,
                                                  strokeWidth: 2,
                                                ),
                                              );
                                            }
                                          })
                                      : Center(
                                          child: Text(
                                            "Something Went Wrong",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 20),
                                          ),
                                        ),
                    ]),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  whichPackage == "STANDARD"
                      ? Visibility(
                          child: CountdownTimer(
                            controller: timeController,
                            widgetBuilder: (BuildContext context,
                                CurrentRemainingTime time) {
                              return Container();
                            },
                          ),
                          visible: false,
                        )
                      : Container(),
                  Visibility(
                    child: CountdownTimer(
                      controller: timeControllerDay,
                      widgetBuilder:
                          (BuildContext context, CurrentRemainingTime time) {
                        return Container();
                      },
                    ),
                    visible: false,
                  ),
                  Visibility(
                    visible: false,
                    child: CountdownTimer(
                      onEnd: boostedOnEnd(),
                      controller: boostedTimeController,
                      widgetBuilder: (BuildContext context, CurrentRemainingTime time) {
                        return Container();
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SmallActionButtons(
                        onPressed: () async {
                          tri = _index;
                          if (lastCard) {
                            controller.triggerBack();
                          }
                          /*var res = await showDialog(
                            context: context,
                            builder: (context) {
                              return MySearchDialog();
                            });
                        if (res) {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return AllProfiles();
                          }));
                        }*/
                        },
                        height: 40,
                        width: 40,
                        icon: Icon(
                          Icons.refresh_sharp,
                          color: Colors.black26,
                          size: 25,
                        ),
                      ),
                      SmallActionButtons(
                        onPressed: () {
                          //updateInteraction(status: 0, petId: petId);
                          // setState(() {
                          _action = true;
                          isLeft = true;
                          isRight = false;
                          isTop = false;
                          controller.triggerLeft();
                          lastCard = false;
                          //});
                        },
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
                        onPressed: () async {
                          // setState(() {

                          if (whichPackage == 'PETTAGPLUS') {
                            if (await superLikeCounter(1)) {
                              _action = true;
                              isTop = true;
                              isLeft = false;
                              isRight = false;
                              controller.triggerUp();
                              updateInteraction(status: 2, petId: petId);
                            } else {
                              setState(() {
                                superLikesLimit = false;
                              });
                            }
                          } else if (whichPackage == 'BREEDER') {
                            if (await superLikeCounter(5)) {
                              _action = true;
                              isTop = true;
                              isLeft = false;
                              isRight = false;
                              controller.triggerUp();
                              updateInteraction(status: 2, petId: petId);
                            } else {
                              setState(() {
                                superLikesLimit = false;
                              });
                            }
                          } else {
                            _action = true;
                            isTop = true;
                            isLeft = false;
                            isRight = false;
                            controller.triggerUp();
                            lastCard = true;
                          }
                          // });
                          /* if (superLikeCounter == 0) {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return SuperLikeDialog();
                              });
                        } else {

                        }*/
                        },
                        height: 40,
                        width: 40,
                        icon: Container(
                          height: 40,
                          width: 40,
                          padding: EdgeInsets.all(2),
                          child:
                              Image.asset("assets/3x/Icon awesome-star@3x.png"),
                        ),
                      ),
                      SmallActionButtons(
                        width: 40,
                        height: 40,
                        onPressed: () async {
                          //updateInteraction(status: 1, petId: petId);
                          //setState(() {

                          if (whichPackage == 'STANDARD') {
                            if (await likeCounter()) {
                              _action = true;
                              isLeft = false;
                              isRight = true;
                              isTop = false;
                              controller.triggerRight();
                              updateInteraction(status: 1, petId: petId);
                            } else {
                              setState(() {
                                likesLimit = false;
                              });
                            }
                          } else {
                            _action = true;
                            isLeft = false;
                            isRight = true;
                            isTop = false;
                            controller.triggerRight();
                            lastCard = true;
                          }
                          //  });
                        },
                        icon: Container(
                          width: 40,
                          height: 40,
                          padding: EdgeInsets.all(2),
                          child: Image.asset(
                              "assets/3x/Icon awesome-heart@3x.png"),
                        ),
                      ),
                      SmallActionButtons(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return BoostDialog();
                                //return AnotherDialog();
                              });
                        },
                        height: 40,
                        width: 40,
                        icon: Container(
                          padding: EdgeInsets.all(2),
                          child: Image.asset("assets/icon/injection.png"),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
            Container(
              //height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: size.width * 0.15,
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
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          splashColor: Colors.transparent,
                          child: Text(
                            "Treat",
                            style: TextStyle(
                                color:
                                    _treat ? Colors.black : Colors.brown[100],
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
                              color:
                                  _topPicks ? Colors.black : Colors.brown[200],
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
                              color:
                                  _petDate ? Colors.black : Colors.brown[200],
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
                              color:
                                  _myTreats ? Colors.black : Colors.brown[200],
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
                    child: (_treat)
                        ? Treat()
                        : (_topPicks)
                            ? TopPicks()
                            : (_petDate)
                                ? PetDate()
                                : MyTreat(),
                  ),
                ],
              ),
            ),
          ]),
    );
  }
}
