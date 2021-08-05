import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/model.dart';
import 'package:pett_tagg/constant.dart';
import 'package:pett_tagg/geo_firestore/geo_firestore.dart';
import 'package:pett_tagg/main.dart';
import 'package:pett_tagg/repo/settingRepo.dart';
import 'package:pett_tagg/screens/pet_slide_screen.dart';
import 'package:pett_tagg/screens/signupPlan.dart';
import 'package:pett_tagg/utilities/email_validation/email_validator.dart';
import 'package:pett_tagg/widgets/custom_textfield.dart';
import 'package:pett_tagg/widgets/newUserWidget.dart';
import 'package:pett_tagg/widgets/generic_shadow_button.dart';
import 'package:pett_tagg/utilities/firebase_credentials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pett_tagg/models/owner_model.dart';
import 'package:pett_tagg/screens/addNewProfile.dart';
import 'package:pett_tagg/widgets/signInDialog.dart';
import 'package:location/location.dart' as LocationManager;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pett_tagg/models/address.dart' as address;


class RegisterScreen extends StatefulWidget {
  static const String registerScreenRoute = 'RegisterScreen';

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String interestedIn;
  IconData _visibility = Icons.visibility;
  bool obscure = true;
  bool status = false;
  bool isLoading = false;
  String gender;
  var lat = 0.0;
  var lng = 0.0;
  address.Address _address;

  Person _person;

  ValidateEmail emailValidator = ValidateEmail();

  final GoogleSignIn googleSignIn = GoogleSignIn();

  final fb = FacebookLogin();

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _formKey = GlobalKey<FormState>();
  TextEditingController firstname = TextEditingController();
  TextEditingController lastname = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController interest = TextEditingController();

  checkDoc(id) async {
    var a = await FirebaseFirestore.instance.collection('User').doc(id).get();
    if (a.exists) {
      return true;
    }
    if (!a.exists) {
      return false;
    }
  }

  location() async {
    await getCurrentLocation().then((address.Address value) async {
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
    /*await getCurrentLocation().then((value) async {
      if (value.isUnknown()) {
        await setCurrentLocation().then((value) {
          setState(() {
            this.address = value;
          });
        });
      } else {
        setState(() {
          this.address = value;
        });
      }
    });*/
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
        Navigator.pushReplacementNamed(
            context, PetSlideScreen.petSlideScreenRouteName);
      }
      else{
        final center = await getUserLocation();
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
          'id':firebaseUser.uid,
          'firstName': names[0] ?? null,
          'lastName': names[1] ?? null,
          'email': firebaseUser.email,
          //'location': null,
          'age': 0,
          'description': null,
          'gender' : gender ?? null,
          'interest': interestedIn ?? null,
          'latitude' : center.latitude,
          'longitude' : center.longitude,
          'visible' : true,
          'pet': null,
          'images': [],   //TODO : Put facebook photo url here and test with an account having profile picture.
        }, SetOptions(merge: true)).then((ref) {
          GeoFirestore geoFirestore =
          GeoFirestore(FirebaseCredentials().db.collection('User'));
          geoFirestore
              .setLocation(
              firebaseUser.uid, GeoPoint(_address.latitude, _address.longitude));
          Navigator.pushReplacementNamed(
              context, AddNewProfileScreen.addNewProfileScreenRoute);
        });
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
        }))
            .user;

        if (firebaseUser != null) {
          bool status = await checkDoc(firebaseUser.uid);
          if (status) {
            Navigator.pushReplacementNamed(
                context, PetSlideScreen.petSlideScreenRouteName);
          } else {
            final center = await getUserLocation();
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
              'id' : firebaseUser.uid,
              'firstName': names[0] ?? null,
              'lastName': names[1] ?? null,
              'email': firebaseUser.email,
              'gender' : gender ?? null,
              //'location': null,
              'age': 0,
              'latitude' : center.latitude,
              'longitude' : center.longitude,
              'description': null,
              'interest': interestedIn ?? null,
              'visible' : true,
              'pet': null,
              'images': [],
            }, SetOptions(merge: true)).then((ref) {
              GeoFirestore geoFirestore =
              GeoFirestore(FirebaseCredentials().db.collection('User'));
              geoFirestore
                  .setLocation(
                  FirebaseCredentials().auth.currentUser.uid, GeoPoint(_address.latitude, _address.longitude));
              Navigator.pushReplacementNamed(
                  context, AddNewProfileScreen.addNewProfileScreenRoute);
            });
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



  void signUp() async {
    setState(() {
      status = true;
    });
    final center = await getUserLocation();
    await FirebaseCredentials()
        .auth
        .createUserWithEmailAndPassword(
            email: email.text, password: password.text)
        .then((value) async {
      User user = FirebaseCredentials().auth.currentUser;

      await user.updateProfile(
          displayName: '${firstname.text} ${lastname.text}',
          photoURL: 'default');
      await FirebaseCredentials()
          .db
          .collection('User')
          .doc(value.user.uid)
          .set({
        'id' : value.user.uid,
        'firstName': firstname.text,
        'lastName': lastname.text,
        'email': email.text,
        //'location': null,
        'age': 0,
        'latitude' : center.latitude,
        'longitude' : center.longitude,
        'description': null,
        'interest': interestedIn ?? null,
        'visible' : true,
        'gender' : gender ?? null,
        'pet': null,
        'images': [],
      }, SetOptions(merge: true)).then((ref) {
        GeoFirestore geoFirestore =
        GeoFirestore(FirebaseCredentials().db.collection('User'));
        geoFirestore
            .setLocation(
            value.user.uid, GeoPoint(_address.latitude, _address.longitude));
        Navigator.pushReplacementNamed(
            context, AddNewProfileScreen.addNewProfileScreenRoute);
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    location();
    super.initState();
  }

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
              SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: currentMediaWidth(context),
                      height: currentMediaHeight(context) - 23,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.only(top: 30),
                              width: currentMediaWidth(context),
                              height: MediaQuery.of(context).size.height / 2.5,
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
                                            this.setState(() {
                                              isLoading = true;
                                            });
                                            await showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return SignInDialog();
                                                    })
                                                .then((value) =>
                                                    interestedIn = value);
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
                                          onTap: ()async{
                                            this.setState(() {
                                              isLoading = true;
                                            });
                                            await showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return SignInDialog();
                                                })
                                                .then((value) =>
                                            interestedIn = value);
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
                                  CustomTextField(
                                    text: "First Name",
                                    hintStyle: hintTextStyle,
                                    controller: firstname,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  CustomTextField(
                                    text: "Last Name",
                                    hintStyle: hintTextStyle,
                                    controller: lastname,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
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
                                  Stack(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                1.3,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                      ),
                                      Center(
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              3,
                                          child: DropdownButtonFormField(
                                            isExpanded: false,
                                            decoration: InputDecoration(
                                              fillColor: Colors.white,
                                              filled: true,
                                              hintText: "Interested In",
                                              contentPadding:
                                                  EdgeInsets.all(8.0),
                                              hintStyle: hintTextStyle.copyWith(
                                                color: Colors.black38,
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
                                            value: interestedIn,
                                            items: <String>[
                                              'Dog',
                                              'Cat',
                                              'Both'
                                            ]
                                                .map<DropdownMenuItem<String>>(
                                                    (String value) =>
                                                        DropdownMenuItem(
                                                          child: Text(value),
                                                          value: value,
                                                        ))
                                                .toList(),
                                            onChanged: (value) async{
                                              setState(() {
                                                interestedIn = value;
                                                sharedPrefs.petType = "$interestedIn";
                                              });

                                            },

                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  /*Stack(
                                    children: [
                                      Container(
                                        width:
                                        MediaQuery.of(context).size.width /
                                            1.3,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                          BorderRadius.circular(30),
                                        ),
                                      ),
                                      Center(
                                        child: Container(
                                          width: MediaQuery.of(context)
                                              .size
                                              .width /
                                              3,
                                          child: DropdownButtonFormField(
                                            isExpanded: false,
                                            decoration: InputDecoration(
                                              fillColor: Colors.white,
                                              filled: true,
                                              hintText: "Gender",
                                              contentPadding:
                                              EdgeInsets.all(8.0),
                                              hintStyle: hintTextStyle.copyWith(
                                                color: Colors.black38,
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
                                            value: interestedIn,
                                            items: <String>[
                                              'Male',
                                              'Female'
                                            ]
                                                .map<DropdownMenuItem<String>>(
                                                    (String value) =>
                                                    DropdownMenuItem(
                                                      child: Text(value),
                                                      value: value,
                                                    ))
                                                .toList(),
                                            onChanged: (value) async{
                                              setState(() {
                                                gender = value;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),*/
                                  TextFormField(
                                    controller: password,
                                    textAlign: TextAlign.center,
                                    textInputAction: TextInputAction.next,
                                    validator: (value){
                                      if(value.isEmpty){
                                        return "Password Empty";
                                      }
                                      else
                                        return null;
                                    },
                                    obscureText: _visibility == Icons.visibility
                                        ? true
                                        : false,
                                    decoration: InputDecoration(
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _visibility = _visibility ==
                                                    Icons.visibility_off
                                                ? Icons.visibility
                                                : Icons.visibility_off;
                                          });
                                        },
                                        icon: Icon(
                                          _visibility,
                                          color: Colors.black,
                                        ),
                                      ),
                                      fillColor: Colors.white,
                                      hintText: "Password",
                                      filled: true,
                                      contentPadding: EdgeInsets.only(
                                          left: 55,
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
                                        borderRadius: BorderRadius.circular(30),
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
                                    height: 20,
                                  ),
                                  isLoading
                                      ? Center(
                                          child: CircularProgressIndicator(
                                          backgroundColor: Colors.red,
                                          strokeWidth: 2,
                                        ))
                                      : GenericBShadowButton(
                                          buttonText: 'Register',
                                          onPressed: () async {
                                            if (_formKey.currentState
                                                .validate()) {
                                              this.setState(() {
                                                isLoading = true;
                                              });
                                              try {
                                                signUp();
                                              } on FirebaseAuthException catch (e) {
                                                final snackbar = SnackBar(
                                                  content: Text('${e.message}'),
                                                );
                                                _scaffoldKey.currentState
                                                    .showSnackBar(snackbar);
                                                if (e.code == 'weak-password') {
                                                  print(
                                                      'The password provided is too weak.');
                                                } else if (e.code ==
                                                    'email-already-in-use') {
                                                  print(
                                                      'The account already exists for that email.');
                                                }
                                              } catch (e) {
                                                print(e);
                                              }
                                            }
                                          },
                                        ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  NewUserTextWidget(
                                    userType: "Existing User? ",
                                    action: "Sign In",
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
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
            ],
          ),
        ),
      ),
    );
  }
}
