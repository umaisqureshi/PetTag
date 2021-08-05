import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pett_tagg/main.dart';
import 'package:pett_tagg/repo/settingRepo.dart';
import 'package:pett_tagg/screens/pet_slide_screen.dart';
import 'package:pett_tagg/screens/sign_in_screen.dart';
import 'about_screen.dart';
import 'dart:async';
import 'package:pett_tagg/utilities/firebase_credentials.dart';
import 'package:pett_tagg/main.dart';

class SplashScreen extends StatefulWidget {
  static const String splashScreenRoute = 'SplashScreen';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animationLogo;
  Animation<double> _animationCat;
  double startPos = 1.0;
  double endPos = -1.0;
  Curve curve = Curves.easeInExpo;
  FirebaseAuth auth= FirebaseAuth.instance;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  updateInterest()async{
    await FirebaseFirestore.instance.collection('User').doc(auth.currentUser.uid).get().then((value){
      sharedPrefs.currentUserPetType = value.data()['interest'];
    });
  }

  navigateAndAnimate() {
    _controller.forward();
    Future.delayed(Duration(seconds: 3)).then((value) =>
        Navigator.pushReplacementNamed(context, AboutScreen.aboutScreenRoute));
  }

  sendTokenToServer()async{
   await firebaseMessaging.getToken().then((value) {
      FirebaseCredentials().db.collection('token').doc(FirebaseAuth.instance.currentUser.uid).set(
          {
            'token': value,
          }, SetOptions(merge: true));
    });
  }

  void _checkFirstTimeScreen() async {
    bool isSeen = sharedPrefs.isSeen;
    _controller.forward();

    print("IS SEEN ::::::::::::::::::::: $isSeen");

    if (isSeen) {
      if (FirebaseCredentials().auth.currentUser == null) {
        Future.delayed(Duration(seconds: 3),
                () => Navigator.pushReplacementNamed(context, SignInScreen.secondScreenRoute));
      } else {
        await sendTokenToServer();
        Future.delayed(Duration(seconds: 3),
                () => Navigator.pushReplacementNamed(context, PetSlideScreen.petSlideScreenRouteName));
      }
    } else {
      Future.delayed(
          Duration(seconds: 3),
              () =>
              Navigator.pushNamed(context, AboutScreen.aboutScreenRoute));
    }
  }

   Future onSelectNotification(String payload) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return Scaffold(body: Container());
    }));
  }

  showNotification(map) async {
    var android = AndroidNotificationDetails(
        'PT', 'PetTag ', 'One to One Chat Notifications',
        priority: Priority.high, importance: Importance.max,);
    var iOS = IOSNotificationDetails();
    var platform = new NotificationDetails(android: android, iOS: iOS);
    await flutterLocalNotificationsPlugin.show(
        0, map['notification']['title'], map['notification']['body'], platform,
        payload: '');
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

  Future notificationOnResume(Map<String, dynamic> message) async {
    await Future.delayed(Duration(seconds: 4));
    onSelectNotification("");
  }

  Future notificationOnLaunch(Map<String, dynamic> message) async {
    await Future.delayed(Duration(seconds: 4));
    onSelectNotification("");
  }

  Future notificationOnMessage(Map<String, dynamic> message) async {
    showNotification(message);
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 3000));
    _animationLogo = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _animationCat = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    //updateInterest();


    var initializationSettingsAndroid =
    AndroidInitializationSettings('ic_launcher');

    var initializationSettingsIOs = IOSInitializationSettings();

    var initSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOs);

    flutterLocalNotificationsPlugin.initialize(initSettings,
        onSelectNotification: onSelectNotification);

    firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    configureFirebase(firebaseMessaging);

    setCurrentLocation();
    _checkFirstTimeScreen();

  }



  @override
  void dispose() {
    _controller.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _animationLogo,
                child: Column(
                  children: [
                    Image.asset(
                      "assets/3x/Group 378@3x.png",
                      height: 120,
                      width: 120,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "PetTag",
                      style: TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                builder: (context, child) {
                  return Container(
                    child: Opacity(
                      opacity: _animationLogo.value,
                      child: child,
                    ),
                  );
                },
              ),
            ),
            Positioned(
              left: 30,
              right: 200,
              bottom: 120,
              child: TweenAnimationBuilder(
                tween: Tween<Offset>(begin: Offset(-1, 0), end: Offset(0, 0)),
                duration: Duration(milliseconds: 1500),
                curve: curve,
                builder: (context, offset, child) {
                  return FractionalTranslation(
                    translation: offset,
                    child: Container(
                      width: double.infinity,
                      child: Center(
                        child: child,
                      ),
                    ),
                  );
                },
                child: Image.asset(
                  "assets/catAnim.png",
                  height: 150,
                  width: 150,
                ),
              ),
            ),
            Positioned(
              left: 200,
              right: 30,
              bottom: 120,
              child: TweenAnimationBuilder(
                tween: Tween<Offset>(begin: Offset(1, 0), end: Offset(0, 0)),
                duration: Duration(milliseconds: 1500),
                curve: curve,
                builder: (context, offset, child) {
                  return FractionalTranslation(
                    translation: offset,
                    child: Container(
                      width: double.infinity,
                      child: Center(
                        child: child,
                      ),
                    ),
                  );
                },
                child: Image.asset(
                  "assets/dogAnim.png",
                  height: 150,
                  width: 150,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
