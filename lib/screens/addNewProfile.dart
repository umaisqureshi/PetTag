import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pett_tagg/constant.dart';
import 'package:pett_tagg/main.dart';
import 'package:pett_tagg/models/packageDetail.dart';
import 'package:pett_tagg/widgets/uploadImageDialog.dart';
import 'package:pett_tagg/widgets/customCard.dart';
import 'package:pett_tagg/widgets/generic_shadow_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pett_tagg/repo/paymentRepo.dart' as repo;
import 'package:pett_tagg/models/owner_model.dart';
import 'package:pett_tagg/utilities/firebase_credentials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pett_tagg/screens/pet_slide_screen.dart';
import 'package:path/path.dart' as Path;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:pett_tagg/screens/all_profiles.dart';

class AddNewProfileScreen extends StatefulWidget {
  static const String addNewProfileScreenRoute = "AddNewProfileScreen";

  AddNewProfileScreen({this.package});

  final PackageDetail package;

  @override
  _AddNewProfileScreenState createState() => _AddNewProfileScreenState();
}

class _AddNewProfileScreenState extends State<AddNewProfileScreen> {
  int age = 1;
  int index=0;
  String gender;
  String petSize;
  String petVal;
  String type;
  double val = 0;
  File petImage1;
  File petImage2;
  File petImage3;
  File petImage4;
  File petImage5;
  File petImage6;
  File petImage7;
  File petImage8;
  File petImage9;
  bool isLoading = false;
  var lat = 0.0;
  var lng = 0.0;

  List<File> _images = [];
  List<String> urls = [];

  ImagePicker imagePicker = ImagePicker();

  Person _person;
  Pet _pet = Pet();

  final FirebaseAuth auth = FirebaseAuth.instance;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<String> uploadedImages = List();

  final TextEditingController userFirstname = TextEditingController();
  final TextEditingController userLastname = TextEditingController();
  final TextEditingController userDescription = TextEditingController();
  final TextEditingController petName = TextEditingController();
  final TextEditingController petAge = TextEditingController();
  final TextEditingController petBreed = TextEditingController();
  final TextEditingController petBehaviour = TextEditingController();
  final TextEditingController petDescription = TextEditingController();

  storeRemaining(int remaining) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("Remaining", remaining);
  }

  getPetType()async{
    type = await sharedPrefs.petType;
  }

  getLatLng()async{
    DocumentSnapshot snap = await FirebaseFirestore.instance.collection('User').doc(auth.currentUser.uid).get();
    Map<String, dynamic> data = snap.data();
    lat = data['latitude'];
    lng = data['longitude'];
  }

  deleteCurrentUser()async{
    await FirebaseFirestore.instance.collection("User").doc(FirebaseAuth.instance.currentUser.uid).delete();
    await FirebaseAuth.instance.currentUser.delete();
  }

  Future<bool> _onWillPop() async {
    return widget.package == null ? (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('Do you want to exit an App'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text('No'),
          ),
          TextButton(
            onPressed: ()async{
              if(widget.package==null){
                await deleteCurrentUser();
                Navigator.of(context).pop(true);
              }
            },
            child: new Text('Yes'),
          ),
        ],
      ),
    )) : false;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPetType();
    getLatLng();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            splashColor: Colors.transparent,
            icon: Icon(
              Icons.arrow_back,
              color: Colors.pink,
              size: 22,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            "Add New Profile",
            style: TextStyle(
                fontSize: 20, color: Colors.black54, fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: CustomScrollView(
              slivers: <Widget>[
                SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Add Pet Details",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          foreground: Paint()..shader = linearGradient,
                        ),
                      ),
                    ),
                    CustomCard(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12.0, top: 14),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pet Name",
                              style: pinkHeadingStyle,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 4.0, right: 10),
                              child: TextFormField(
                                controller: petName,
                                validator: (value){
                                  return value.isEmpty ? "Required Field" : null;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    _pet.name = value;
                                  });
                                },
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                    hintText: "Pet-Name",
                                    hintStyle: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                    border: InputBorder.none),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    CustomCard(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding:
                            const EdgeInsets.only(top: 14.0, right: 15, left: 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Pet Age",
                                  style: pinkHeadingStyle,
                                ),
                                Spacer(),
                                Text(
                                  "${age.toDouble().toString()} yr.",
                                  style: TextStyle(
                                    color: Colors.black38,
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
                                thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: 10.0),
                                overlayShape:
                                    RoundSliderOverlayShape(overlayRadius: 25.0),
                              ),
                              child: Slider(
                                value: age.toDouble(),
                                min: 1,
                                max: 29,
                                onChanged: (double newValue) {
                                  setState(() {
                                    _pet.age = newValue.round();
                                    age = newValue.round();
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    CustomCard(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 14.0, left: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pet Sex",
                              style: pinkHeadingStyle,
                            ),
                            DropdownButtonFormField(
                              isExpanded: false,
                              validator: (value){
                                return value==null ? "Required Field" : null;
                              },
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                filled: true,
                                hintText: "Pet-Gender",
                                contentPadding: EdgeInsets.all(8.0),
                                hintStyle: hintTextStyle.copyWith(
                                  color: Colors.black87,
                                ),
                                border: InputBorder.none,
                              ),
                              value: gender,
                              items: ['Male', 'Female']
                                  .map<DropdownMenuItem<String>>(
                                      (String value) => DropdownMenuItem(
                                            child: Text(value),
                                            value: value,
                                          ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _pet.sex = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    CustomCard(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 14.0, left: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pet Size",
                              style: pinkHeadingStyle,
                            ),
                            DropdownButtonFormField(
                              isExpanded: false,
                              validator: (value){
                                return value == null ? "Required Field" : null;
                              },
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                filled: true,
                                hintText: "Select",
                                contentPadding: EdgeInsets.all(8.0),
                                hintStyle: hintTextStyle.copyWith(
                                  color: Colors.black87,
                                ),
                                border: InputBorder.none,

                              ),
                              value: petSize,
                              items: [
                                'Small',
                                'Medium',
                                'Large',
                                'Extra-Large'
                              ]
                                  .map<DropdownMenuItem<String>>(
                                      (String value) => DropdownMenuItem(
                                            child: Text(value),
                                            value: value,
                                          ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _pet.size = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    CustomCard(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 14.0, left: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pet Type",
                              style: pinkHeadingStyle,
                            ),
                            DropdownButtonFormField(
                              isExpanded: false,
                              validator: (value){
                                return value == null ? "Required Field" : null;
                              },
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                filled: true,
                                hintText: "Dog",
                                contentPadding: EdgeInsets.all(8.0),
                                hintStyle: hintTextStyle.copyWith(
                                  color: Colors.black87,
                                ),
                                border: InputBorder.none,
                              ),
                              value: petSize,
                              items: [
                                'Dog',
                                'Cat'
                              ]
                                  .map<DropdownMenuItem<String>>(
                                      (String value) => DropdownMenuItem(
                                    child: Text(value),
                                    value: value,
                                  ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _pet.type = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    CustomCard(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12.0, top: 14),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pet Breed",
                              style: pinkHeadingStyle,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 4.0, right: 10),
                              child: TextFormField(
                                controller: petBreed,
                                validator: (value){
                                  return value.isEmpty ? "Required Field" : null;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    _pet.breed = value;
                                  });
                                },
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                    hintText: "Pet-Breed",
                                    hintStyle: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                    border: InputBorder.none),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    CustomCard(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12.0, top: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pet Behaviour",
                              style: pinkHeadingStyle,
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 4.0, right: 10),
                              child: TextFormField(
                                controller: petBehaviour,
                                validator: (value){
                                  return value.isEmpty ? "Required Field" : null;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    _pet.behaviour = value;
                                  });
                                },
                                textInputAction: TextInputAction.next,
                                maxLength: 100,
                                buildCounter: (context,
                                        {currentLength, isFocused, maxLength}) =>
                                    null,
                                decoration: InputDecoration(
                                    hintText:
                                        "Pet-Behaviour (Max 100 characters)",
                                    hintStyle: TextStyle(
                                      fontWeight: FontWeight.normal,
                                    ),
                                    border: InputBorder.none),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    CustomCard(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pet Description",
                              style: pinkHeadingStyle,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 4.0, right: 10),
                              child: TextFormField(
                                controller: petDescription,
                                validator: (value){
                                  return value.isEmpty ? "Required Field" : null;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    _pet.description = value;
                                  });
                                },
                                textInputAction: TextInputAction.next,
                                maxLength: 100,
                                buildCounter: (context,
                                        {currentLength, isFocused, maxLength}) =>
                                    null,
                                decoration: InputDecoration(
                                    hintText:
                                        "Enter Description (Max 100 characters)",
                                    hintStyle: TextStyle(
                                      fontWeight: FontWeight.normal,
                                    ),
                                    border: InputBorder.none),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Add Pet Media",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          foreground: Paint()..shader = linearGradient,
                        ),
                      ),
                    ),
                  ]),
                ),
                SliverGrid.count(
                  crossAxisCount: 3,
                  childAspectRatio: 4 / 3,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  children: [
                    InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                backgroundColor: Colors.white,
                                elevation: 5,
                                insetPadding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 24.0),
                                child: Container(
                                  height: 150,
                                //  width: double.infinity,
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10.0, top: 10),
                                        child: Text(
                                          "Upload Image",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10.0),
                                        child: Text(
                                          "Select a Photo..",
                                          style: TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          FlatButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            padding: EdgeInsets.all(0),
                                            child: Text(
                                              "CANCEL",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          FlatButton(
                                            onPressed: () async {
                                              var pickedFile =
                                                  await imagePicker.getImage(
                                                      source:
                                                          ImageSource.gallery);
                                              this.setState(() {
                                                if (pickedFile != null) {
                                                  petImage1 =
                                                      File(pickedFile.path);
                                                  _images.add(petImage1);
                                                } else {
                                                  print('No image selected.');
                                                }
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            padding: EdgeInsets.all(0),
                                            child: Text(
                                              "GALLERY",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          FlatButton(
                                            onPressed: () async {
                                              var pickedFile =
                                                  await imagePicker.getImage(
                                                      source: ImageSource.camera);
                                              this.setState(() {
                                                if (pickedFile != null) {
                                                  petImage1 =
                                                      File(pickedFile.path);
                                                  _images.add(petImage1);
                                                } else {
                                                  print('No image captured.');
                                                }
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            padding: EdgeInsets.all(0),
                                            child: Text(
                                              "CAMERA",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            });
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black45,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: petImage1 != null
                              ? Image.file(
                                  petImage1,
                                  fit: BoxFit.cover,
                                )
                              : Icon(
                                  Icons.add,
                                  color: Colors.black,
                                  size: 30,
                                ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                backgroundColor: Colors.white,
                                elevation: 5,
                                child: Container(
                                  height: 150,
                                  width: 350,
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10.0, top: 10),
                                        child: Text(
                                          "Upload Image",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10.0),
                                        child: Text(
                                          "Select a Photo..",
                                          style: TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      Row(
                                        children: [
                                          FlatButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            padding: EdgeInsets.all(0),
                                            child: Text(
                                              "CANCEL",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          Spacer(),
                                          FlatButton(
                                            onPressed: () async {
                                              var pickedFile =
                                                  await imagePicker.getImage(
                                                      source:
                                                          ImageSource.gallery);
                                              this.setState(() {
                                                if (pickedFile != null) {
                                                  petImage2 =
                                                      File(pickedFile.path);
                                                  _images.add(petImage2);
                                                } else {
                                                  print('No image selected.');
                                                }
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            padding: EdgeInsets.all(0),
                                            child: Text(
                                              "GALLERY",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          FlatButton(
                                            onPressed: () async {
                                              var pickedFile =
                                                  await imagePicker.getImage(
                                                      source: ImageSource.camera);
                                              this.setState(() {
                                                if (pickedFile != null) {
                                                  petImage2 =
                                                      File(pickedFile.path);
                                                  _images.add(petImage2);
                                                } else {
                                                  print('No image captured.');
                                                }
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            padding: EdgeInsets.all(0),
                                            child: Text(
                                              "CAMERA",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            });
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black45,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: petImage2 != null
                              ? Image.file(
                                  petImage2,
                                  fit: BoxFit.cover,
                                )
                              : Icon(
                                  Icons.add,
                                  color: Colors.black,
                                  size: 30,
                                ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                backgroundColor: Colors.white,
                                elevation: 5,
                                child: Container(
                                  height: 150,
                                  width: 350,
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10.0, top: 10),
                                        child: Text(
                                          "Upload Image",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10.0),
                                        child: Text(
                                          "Select a Photo..",
                                          style: TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      Row(
                                        children: [
                                          FlatButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            padding: EdgeInsets.all(0),
                                            child: Text(
                                              "CANCEL",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          Spacer(),
                                          FlatButton(
                                            onPressed: () async {
                                              var pickedFile =
                                                  await imagePicker.getImage(
                                                      source:
                                                          ImageSource.gallery);
                                              this.setState(() {
                                                if (pickedFile != null) {
                                                  petImage3 =
                                                      File(pickedFile.path);
                                                  _images.add(petImage3);
                                                } else {
                                                  print('No image selected.');
                                                }
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            padding: EdgeInsets.all(0),
                                            child: Text(
                                              "GALLERY",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          FlatButton(
                                            onPressed: () async {
                                              var pickedFile =
                                                  await imagePicker.getImage(
                                                      source: ImageSource.camera);
                                              this.setState(() {
                                                if (pickedFile != null) {
                                                  petImage3 =
                                                      File(pickedFile.path);
                                                  _images.add(petImage3);
                                                } else {
                                                  print('No image captured.');
                                                }
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            padding: EdgeInsets.all(0),
                                            child: Text(
                                              "CAMERA",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            });
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black45,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: petImage3 != null
                              ? Image.file(
                                  petImage3,
                                  fit: BoxFit.cover,
                                )
                              : Icon(
                                  Icons.add,
                                  color: Colors.black,
                                  size: 30,
                                ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                backgroundColor: Colors.white,
                                elevation: 5,
                                child: Container(
                                  height: 150,
                                  width: 350,
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10.0, top: 10),
                                        child: Text(
                                          "Upload Image",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10.0),
                                        child: Text(
                                          "Select a Photo..",
                                          style: TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      Row(
                                        children: [
                                          FlatButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            padding: EdgeInsets.all(0),
                                            child: Text(
                                              "CANCEL",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          Spacer(),
                                          FlatButton(
                                            onPressed: () async {
                                              var pickedFile =
                                                  await imagePicker.getImage(
                                                      source:
                                                          ImageSource.gallery);
                                              this.setState(() {
                                                if (pickedFile != null) {
                                                  petImage4 =
                                                      File(pickedFile.path);
                                                  _images.add(petImage4);
                                                } else {
                                                  print('No image selected.');
                                                }
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            padding: EdgeInsets.all(0),
                                            child: Text(
                                              "GALLERY",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          FlatButton(
                                            onPressed: () async {
                                              var pickedFile =
                                                  await imagePicker.getImage(
                                                      source: ImageSource.camera);
                                              this.setState(() {
                                                if (pickedFile != null) {
                                                  petImage4 =
                                                      File(pickedFile.path);
                                                  _images.add(petImage4);
                                                } else {
                                                  print('No image captured.');
                                                }
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            padding: EdgeInsets.all(0),
                                            child: Text(
                                              "CAMERA",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            });
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black45,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: petImage4 != null
                              ? Image.file(
                                  petImage4,
                                  fit: BoxFit.cover,
                                )
                              : Icon(
                                  Icons.add,
                                  color: Colors.black,
                                  size: 30,
                                ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                backgroundColor: Colors.white,
                                elevation: 5,
                                child: Container(
                                  height: 150,
                                  width: 350,
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10.0, top: 10),
                                        child: Text(
                                          "Upload Image",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10.0),
                                        child: Text(
                                          "Select a Photo..",
                                          style: TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      Row(
                                        children: [
                                          FlatButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            padding: EdgeInsets.all(0),
                                            child: Text(
                                              "CANCEL",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          Spacer(),
                                          FlatButton(
                                            onPressed: () async {
                                              var pickedFile =
                                                  await imagePicker.getImage(
                                                      source:
                                                          ImageSource.gallery);
                                              this.setState(() {
                                                if (pickedFile != null) {
                                                  petImage5 =
                                                      File(pickedFile.path);
                                                  _images.add(petImage5);
                                                } else {
                                                  print('No image selected.');
                                                }
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            padding: EdgeInsets.all(0),
                                            child: Text(
                                              "GALLERY",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          FlatButton(
                                            onPressed: () async {
                                              var pickedFile =
                                                  await imagePicker.getImage(
                                                      source: ImageSource.camera);
                                              this.setState(() {
                                                if (pickedFile != null) {
                                                  petImage5 =
                                                      File(pickedFile.path);
                                                  _images.add(petImage5);
                                                } else {
                                                  print('No image captured.');
                                                }
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            padding: EdgeInsets.all(0),
                                            child: Text(
                                              "CAMERA",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            });
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black45,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: petImage5 != null
                              ? Image.file(
                                  petImage5,
                                  fit: BoxFit.cover,
                                )
                              : Icon(
                                  Icons.add,
                                  color: Colors.black,
                                  size: 30,
                                ),
                        ),
                      ),
                    ),

                  ],
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: isLoading ? Center(child: CircularProgressIndicator(strokeWidth: 2, backgroundColor: Colors.red,)) : GenericBShadowButton(
                        buttonText: "Save Changes",
                        onPressed: () async {
                          if(_images.isEmpty){
                            Fluttertoast.showToast(msg: "Atleast select one image of your pet.");
                          }
                          if(_formKey.currentState.validate() && _images.isNotEmpty){
                            if (widget.package != null) {
                              Map<String, dynamic> myMap = {
                                "pkgName": widget.package.pkgName,
                                "price": widget.package.price,
                                "profileCount": widget.package.profileCount,
                                "time": widget.package.time,
                                "remaining": widget.package.remaining - 1,
                              };
                              PackageDetail pkgDetail =
                              PackageDetail.fromJson(myMap);
                              this.setState(() {
                                isLoading = true;
                              });
                              final User user = auth.currentUser;
                              final uid = user.uid;
                              _pet.ownerId = uid;
                              //_pet.type = type;
                              repo.storePkgInfo(pkgDetail);
                              repo.pkg.value = pkgDetail;
                              repo.pkg.notifyListeners();
                              await uploadImageForAllProfile(_images[0]);
                            } else {
                              this.setState(() {
                                isLoading = true;
                              });
                              final User user = auth.currentUser;
                              final uid = user.uid;
                              _pet.ownerId = uid;
                              _pet.type = type;
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              if(prefs.containsKey("packageDetail")){
                                prefs.remove("packageDetail");
                              };
                              await uploadImage(_images[0]);
                            }
                          }
                          //Navigator.popAndPushNamed(context, AllProfiles.allProfilesScreenRoute);
                        },
                        width: MediaQuery.of(context).size.width / 1.4,
                        height: 50,
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  uploadImageForAllProfile(image) async {
    var reference = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
    firebase_storage.StorageUploadTask uploadTask = reference.putFile(image);
    (await uploadTask.onComplete).ref.getDownloadURL().then((value) async {
      //setState(() {
      urls.add(value);
      index++;
      //});
      if (index == _images.length) {
        _pet.images = urls;
        var id = FirebaseCredentials().db.collection('Pet').doc().id;
        _pet.petId = id;
        await FirebaseCredentials().db.collection('User').doc(auth.currentUser.uid).set(
            {
              "pet" : FieldValue.arrayUnion([id]),

            }, SetOptions(merge: true));
        _pet.latitude = lat;
        _pet.longitude = lng;
        _pet.lockStatus = false;
        _pet.visible = true;
        await FirebaseCredentials().db.collection('Pet').doc(id).set(
            _pet.toMap(),SetOptions(merge: true)).whenComplete(() {
          Navigator.pushReplacementNamed(context, AllProfiles.allProfilesScreenRoute);
        });
      } else {
        uploadImageForAllProfile(_images[index]);
      }
    });
  }

  uploadImage(image) async {
    var reference = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
    firebase_storage.StorageUploadTask uploadTask = reference.putFile(image);
    (await uploadTask.onComplete).ref.getDownloadURL().then((value) async {
        urls.add(value);
        index++;
      if (index == _images.length) {
        _pet.images = urls;
        var id = FirebaseCredentials().db.collection('Pet').doc().id;
        _pet.petId = id;
        await FirebaseCredentials().db.collection('User').doc(auth.currentUser.uid).set(
            {
              "pet" : FieldValue.arrayUnion([id]),
            }, SetOptions(merge: true));
        _pet.latitude = lat;
        _pet.longitude = lng;
        _pet.visible = true;
        _pet.lockStatus = false;
        await FirebaseCredentials().db.collection('Pet').doc(id).set(
              _pet.toMap(),SetOptions(merge: true)).whenComplete(() => Navigator.pushReplacementNamed(context, PetSlideScreen.petSlideScreenRouteName));
      } else {
        uploadImage(_images[index]);
      }
    });
  }
}
