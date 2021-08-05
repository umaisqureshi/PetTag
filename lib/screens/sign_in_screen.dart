import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/model.dart';
import 'package:pett_tagg/geo_firestore/geo_firestore.dart';
import 'package:pett_tagg/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pett_tagg/constant.dart';
import 'package:pett_tagg/repo/settingRepo.dart';
import 'package:pett_tagg/screens/addNewProfile.dart';
import 'package:pett_tagg/screens/pet_slide_screen.dart';
import 'package:pett_tagg/screens/register_screen.dart';
import 'package:pett_tagg/utilities/firebase_credentials.dart';
import 'package:pett_tagg/widgets/newUserWidget.dart';
import 'package:pett_tagg/widgets/generic_shadow_button.dart';
import 'package:pett_tagg/screens/signupPlan.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pett_tagg/utilities/email_validation/email_validator.dart';
import 'package:pett_tagg/widgets/signInDialog.dart';
import 'package:location/location.dart' as LocationManager;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pett_tagg/models/address.dart' as address;

class SignInScreen extends StatefulWidget {
  static const String secondScreenRoute = 'SignInScreen';

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  IconData _visibility = Icons.visibility;
  bool obscure = true;
  bool _isLogin;
  bool _isVisibleCat = false;
  bool _isVisibleDog = false;
  String interestedIn;
  address.Address _address;

  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  User _user;
  final fb = FacebookLogin();
  bool isLoading = false;
  var lat = 0.0;
  var lng = 0.0;
  var center;

  ValidateEmail emailValidator = ValidateEmail();

  final _formKey = GlobalKey<FormState>();

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    location();
    super.initState();
    checkConnection();

  }

  location() async {
    getCurrentLocation().then((address.Address value) async {
      setState(() {
        _address = value;
      });
      final coordinates = new Coordinates(value.latitude, value.longitude);
      var addresses =
      await Geocoder.local.findAddressesFromCoordinates(coordinates);
      var first = addresses.first;
      setState(() {
        String area = '${first.subLocality ?? ''} ${first.locality ?? ''}';
      });
    });
  }

  sendTokenToServer()async{
    await firebaseMessaging.getToken().then((value) {
      FirebaseCredentials().db.collection('token').doc(FirebaseAuth.instance.currentUser.uid).set(
          {
            'token': value,
          }, SetOptions(merge: true));
    });
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

  checkConnection() async {
    try {
      await InternetAddress.lookup("google.com");
    } on SocketException catch (e) {
      Fluttertoast.showToast(
          msg: "Check Your Internet Connection",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 16.0);
    }
  }



  checkDoc(id) async{
    var a = await FirebaseFirestore.instance.collection('User').doc(id).get();
    if(a.exists){
      return true;
    }
    if(!a.exists){
      return false;
    }

  }

  signinWithGoogle()async{
    print("Starting Google Signin");
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    User firebaseUser = (await FirebaseAuth.instance
        .signInWithCredential(credential)
        .catchError((e) {
      print(e is SocketException
          ? "Check your internet connection"
          : e.toString());
      this.setState(() {
        isLoading = false;
      });
    })).user;
    if (firebaseUser != null) {
      bool status = await checkDoc(firebaseUser.uid);
      if(status){
        await sendTokenToServer();
        await FirebaseFirestore.instance.collection('Pet').where("ownerId", isEqualTo: firebaseUser.uid).get().then((value) {
          sharedPrefs.currentUserPetType = value.docs[0].data()["type"];
        });
        Navigator.pushReplacementNamed(
            context, PetSlideScreen.petSlideScreenRouteName);
      }
      else{
        final snackbar = SnackBar(
          content:
          Text('${"Register your account first."}'),
        );
        _scaffoldKey.currentState
            .showSnackBar(snackbar);
        /*final center = await getUserLocation();
        User user = FirebaseCredentials().auth.currentUser;
        interestedIn = await sharedPrefs.petType;
        List<String> names = firebaseUser.displayName.split(" ");
        await user.updateProfile(
            displayName: '${firebaseUser.displayName}',
            photoURL: '${firebaseUser.photoURL}');
        await FirebaseCredentials()
            .db
            .collection('User')
            .doc(firebaseUser.uid)
            .set({
          'firstName': names[0] ?? null,
          'lastName': names[1] ?? null,
          'email': firebaseUser.email,
          //'location': null,
          'visible' : true,
          'age': 0,
          'description': null,
          'interest': interestedIn ?? null,
          'latitude' : center.latitude,
          'longitude' : center.longitude,
          'pet': null,
          'images': [],   //TODO : Put facebook photo url here and test with an account having profile picture.
        }, SetOptions(merge: true)).then((ref) async {
          GeoFirestore geoFirestore =
          GeoFirestore(FirebaseCredentials().db.collection('User'));
          geoFirestore
              .setLocation(
              firebaseUser.uid, GeoPoint(_address.latitude, _address.longitude));
          await sendTokenToServer();
          Navigator.pushReplacementNamed(
              context, AddNewProfileScreen.addNewProfileScreenRoute);
        });*/
      }
    }
    this.setState(() {
      isLoading = false;
    });
  }

  loginFacebook() async {
    print('Starting Facebook Login');
    final res = await fb.logIn(permissions: [
      FacebookPermission.publicProfile,
      FacebookPermission.email,
    ]);
    print('${res.status} ${res.error}');
    switch (res.status) {
      case FacebookLoginStatus.Success:
        final FacebookAccessToken fbToken = res.accessToken;
        final AuthCredential credential =
            FacebookAuthProvider.credential(fbToken.token);
        User firebaseUser = (await FirebaseAuth.instance
                .signInWithCredential(credential)
                .catchError((e) {
          print(e is SocketException
              ? "Check your internet connection"
              : e.toString());
          this.setState(() {
            isLoading = false;
          });
        })).user;
        if (firebaseUser != null) {
          bool status = await checkDoc(firebaseUser.uid);
          if(status){
            await sendTokenToServer();
            await FirebaseFirestore.instance.collection('Pet').where("ownerId", isEqualTo: firebaseUser.uid).get().then((value) {
              sharedPrefs.currentUserPetType = value.docs[0].data()["type"];
            });
            Navigator.pushReplacementNamed(
                context, PetSlideScreen.petSlideScreenRouteName);
          }
          else{
            final snackbar = SnackBar(
              content:
              Text('${"Register your account first."}'),
            );
            _scaffoldKey.currentState
                .showSnackBar(snackbar);

            /*final center = await getUserLocation();
            User user = FirebaseCredentials().auth.currentUser;
            interestedIn = await sharedPrefs.petType;
            List<String> names = firebaseUser.displayName.split(" ");
            await user.updateProfile(
                displayName: '${firebaseUser.displayName}',
                photoURL: '${firebaseUser.photoURL}');
            await FirebaseCredentials()
                .db
                .collection('User')
                .doc(firebaseUser.uid)
                .set({
              'id': firebaseUser.uid,
              'firstName': names[0] ?? null,
              'lastName': names[1] ?? null,
              'email': firebaseUser.email,
              'location': null,
              'age': 0,
              'description': null,
              'interest': interestedIn ?? null,
              'latitude' : center.latitude,
              'visible' : true,
              'longitude' : center.longitude,
              'pet': null,
              'images': [],   //TODO : Put facebook photo url here and test with an account having profile picture.
            }, SetOptions(merge: true)).then((ref) async {
              await sendTokenToServer();
              GeoFirestore geoFirestore =
              GeoFirestore(FirebaseCredentials().db.collection('User'));
              geoFirestore
                  .setLocation(
                  firebaseUser.uid, GeoPoint(_address.latitude, _address.longitude));
              Navigator.pushReplacementNamed(
                  context, AddNewProfileScreen.addNewProfileScreenRoute);
            });*/
          }
        }
        this.setState(() {
          isLoading = false;
        });
        break;
      case FacebookLoginStatus.Cancel:
        print('The user canceled the login');
        this.setState(() {
          isLoading = false;
        });
        break;
      case FacebookLoginStatus.Error:
        print('There was an error');
        this.setState(() {
          isLoading = false;
        });
        break;
    }
  }

  Container buildImageButtons(
      BuildContext context, isVisible, imagePath, text) {
    return Container(
      height: 100,
      width: 70,
      child: Column(
        children: [
          Stack(
            children: [
              Visibility(
                visible: isVisible,
                child: Container(
                  height: 80,
                  width: MediaQuery.of(context).size.width / 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                    border: Border.all(
                      color: Colors.pink[900],
                      width: 2,
                    ),
                  ),
                ),
              ),
              Center(
                child: Image.asset(
                  imagePath,
                  height: 70,
                ),
              )
            ],
          ),
          Text(
            text,
            style:
                TextStyle(color: Colors.pink[900], fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
              SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        width: currentMediaWidth(context),
                        height: currentMediaHeight(context),
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.only(top: 30),
                                width: currentMediaWidth(context),
                                height:
                                    MediaQuery.of(context).size.height / 2.5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 70,
                                      height: 70,
                                      child: Image.asset(
                                        'assets/2x/Group 378@2x.png',
                                      ),
                                    ),
                                    customSizeBox(height: 30),
                                    Text(
                                      'Connect with Social Media',
                                      style: TextStyle(
                                          color: Colors.white.withOpacity(0.7)),
                                    ),
                                    customSizeBox(height: 15),
                                    Flexible(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          GestureDetector(
                                            onTap: () async {
                                              //await _handleLogin();
                                              this.setState(() {
                                                isLoading = true;
                                              });
                                              /*await showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return SignInDialog();
                                                      })
                                                  .then((value) =>
                                                      interestedIn = value);*/
                                              loginFacebook();
                                            },
                                            child: getHomeScreenImage(
                                                'assets/2x/Group 246@2x.png',
                                                circleRadius: 70,
                                                imageWidth: 47,
                                                imageHeight: 47,
                                                circleSize: 25,
                                                isFullOpacity: true),
                                          ),
                                          customSizeBox(height: 30),
                                          InkWell(
                                            onTap: (){
                                              this.setState(() {
                                                isLoading = true;
                                              });
                                              signinWithGoogle();
                                            },
                                            child: getHomeScreenImage(
                                                'assets/googleIcon.png',
                                                circleRadius: 70,
                                                imageWidth: 47,
                                                imageHeight: 47,
                                                circleSize: 25,

                                                isFullOpacity: true),
                                          ),
                                        ],
                                      ),
                                    ),
                                    customSizeBox(height: 15),
                                    // showing heart image
                                    getHomeScreenImage(
                                      'assets/2x/Group 249@2x.png',
                                      isFullOpacity: true,
                                      circleSize: 20,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width / 1.3,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: email,
                                      validator: (value) {
                                        if (emailValidator
                                            .validateEmail(value)) {
                                          return null;
                                        } else {
                                          return 'Wrong Email';
                                        }
                                      },
                                      textAlign: TextAlign.center,
                                      textInputAction: TextInputAction.next,
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        fillColor: Colors.white,
                                        hintText: "Email",
                                        filled: true,
                                        contentPadding: EdgeInsets.all(8.0),
                                        hintStyle: hintTextStyle,
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          borderSide: BorderSide(
                                            color: Colors.transparent,
                                          ),
                                        ),
                                        errorStyle: TextStyle(
                                          color: Colors.white,
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          borderSide: BorderSide(
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          borderSide: BorderSide(
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            borderSide: BorderSide(
                                              color: Colors.transparent,
                                            )),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    TextFormField(
                                      controller: password,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Password is required';
                                        } else
                                          return null;
                                      },
                                      textAlign: TextAlign.center,
                                      textInputAction: TextInputAction.next,
                                      obscureText:
                                          _visibility == Icons.visibility
                                              ? true
                                              : false,
                                      decoration: InputDecoration(
                                        suffixIcon: InkWell(
                                          onTap: () {
                                            setState(() {
                                              _visibility = _visibility ==
                                                      Icons.visibility_off
                                                  ? Icons.visibility
                                                  : Icons.visibility_off;
                                            });
                                          },
                                          child: Icon(
                                            _visibility,
                                            color: Colors.black,
                                          ),
                                        ),
                                        fillColor: Colors.white,
                                        hintText: "Password",
                                        filled: true,
                                        contentPadding: EdgeInsets.only(
                                            left: 8,
                                            right: 8,
                                            top: 8,
                                            bottom: 8),
                                        hintStyle: hintTextStyle,
                                        errorStyle: TextStyle(
                                          color: Colors.white,
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          borderSide: BorderSide(
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          borderSide: BorderSide(
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          borderSide: BorderSide(
                                            color: Colors.transparent,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            borderSide: BorderSide(
                                              color: Colors.transparent,
                                            )),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    InkWell(
                                      child: Text(
                                        "Forgot Password?",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                            fontSize: 12),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    isLoading
                                        ? Center(
                                            child: CircularProgressIndicator(
                                            backgroundColor: Colors.red,
                                            strokeWidth: 2,
                                          ))
                                        : GenericBShadowButton(
                                            buttonText: "Sign In",
                                            onPressed: () async {
                                              if (_formKey.currentState.validate()) {
                                                this.setState(() {
                                                  isLoading = true;
                                                });
                                                try {
                                                  UserCredential
                                                      userCredential =
                                                      await FirebaseAuth
                                                          .instance
                                                          .signInWithEmailAndPassword(
                                                              email: email.text,
                                                              password: password
                                                                  .text);
                                                  if (userCredential != null) {
                                                    await sendTokenToServer();
                                                    await FirebaseFirestore.instance.collection('Pet').where("ownerId", isEqualTo: _auth.currentUser.uid).get().then((value) {
                                                      value.docs.length == 0 ? Navigator.pushReplacementNamed(context, AddNewProfileScreen.addNewProfileScreenRoute) :
                                                      sharedPrefs.currentUserPetType = value.docs[0].data()["type"];
                                                    });
                                                    Navigator.pushReplacementNamed(
                                                        context,
                                                        SignUpPlan
                                                            .singUpPlanRoute);
                                                  }

                                                } on FirebaseAuthException catch (e) {
                                                  this.setState(() {
                                                    isLoading = false;
                                                  });
                                                  final snackbar = SnackBar(
                                                    content:
                                                        Text('${e.message}'),
                                                  );
                                                  _scaffoldKey.currentState
                                                      .showSnackBar(snackbar);
                                                  if (e.code ==
                                                      'user-not-found') {
                                                    print(
                                                        'No user found for that email.');
                                                  } else if (e.code ==
                                                      'wrong-password') {
                                                    print(
                                                        'Wrong password provided for that user.');
                                                  }
                                                }
                                              }
                                            },
                                          ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    NewUserTextWidget(
                                      onTap: () {
                                        Navigator.pushReplacementNamed(context,
                                            RegisterScreen.registerScreenRoute);
                                      },
                                      userType: "New User?",
                                      action: " Sign Up",
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
/*Dialog(
                                                      child: Container(
                                                        height: 330,
                                                        width: 200,
                                                        padding:
                                                            EdgeInsets.all(8),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                          children: [
                                                            Text(
                                                              "Interested In",
                                                              style: TextStyle(
                                                                  fontSize: 17,
                                                                  color: Colors
                                                                          .pink[
                                                                      900],
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            SizedBox(
                                                              height: 5,
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceEvenly,
                                                              children: [
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      _isVisibleCat =
                                                                          true;
                                                                      _isVisibleDog =
                                                                          false;
                                                                      interestedIn =
                                                                          'Cat';
                                                                    });
                                                                  },
                                                                  child: buildImageButtons(
                                                                      context,
                                                                      _isVisibleCat,
                                                                      'assets/newimg.png',
                                                                      "Cat"),
                                                                ),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      _isVisibleDog =
                                                                          true;
                                                                      _isVisibleCat =
                                                                          false;
                                                                      interestedIn =
                                                                          'Dog';
                                                                    });
                                                                  },
                                                                  child: buildImageButtons(
                                                                      context,
                                                                      _isVisibleDog,
                                                                      'assets/dogArt.png',
                                                                      "Dog"),
                                                                ),
                                                              ],
                                                            ),
                                                            /*TextField(
                                                              decoration:
                                                                  InputDecoration(
                                                                contentPadding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            50),
                                                                hintText:
                                                                    "Enter Your Email-id",
                                                                hintStyle: TextStyle(
                                                                    color: Colors
                                                                        .black38),
                                                                border:
                                                                    InputBorder
                                                                        .none,
                                                              ),
                                                            ),*/
                                                            GenericBShadowButton(
                                                              buttonText:
                                                                  "Submit",
                                                              onPressed: () {
                                                                (_isVisibleCat ||
                                                                        _isVisibleDog)
                                                                    ? Navigator.pop(
                                                                        context)
                                                                    : null;
                                                              },
                                                            ),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    )*/
