import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:pett_tagg/constant.dart';
import 'package:pett_tagg/widgets/generic_shadow_button.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:pett_tagg/utilities/firebase_credentials.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AddNewFeed extends StatefulWidget {
  static const String addNewFeedScreenRoute = "AddNewFeed";

  @override
  _AddNewFeedState createState() => _AddNewFeedState();
}

class _AddNewFeedState extends State<AddNewFeed> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool isUploading = false;
  List<File> _images = [];
  List<dynamic> urlsPet = [];
  ImagePicker imagePicker = ImagePicker();
  var petImage1;
  bool isVisible = true;
  String userId;
  String petId;
  String postPicUrl;
  String postId;
  String petImageUrl;
  String petAge;
  String petName;

  final _formKey = GlobalKey<FormState>();

  TextEditingController description = TextEditingController();

  getKeys() async {
    QuerySnapshot snap = await FirebaseCredentials()
        .db
        .collection('Pet')
        .where('ownerId', isEqualTo: auth.currentUser.uid)
        .get();
    if (snap.docs.isNotEmpty) {
      userId = snap.docs[0].data()['ownerId'];
      petId = snap.docs[0].data()['petId'];
      petImageUrl = snap.docs[0].data()['images'][0];
      petName = snap.docs[0].data()['name'];
      petAge = snap.docs[0].data()['age'];
    }
  }

  uploadImage(image) async {
    var reference = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
    firebase_storage.StorageUploadTask uploadTask = reference.putFile(image);
    (await uploadTask.onComplete).ref.getDownloadURL().then((value) async {
      FirebaseCredentials()
          .db
          .collection('Post')
          .doc(postId)
          .update({
        'postPicture': FieldValue.arrayUnion([value])
      }).then((value) {
        setState(() {
          isUploading = false;
        });
      });
    });
  }

/*
  uploadImage(image) async {
    var reference = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
    firebase_storage.StorageUploadTask uploadTask = reference.putFile(image);
    (await uploadTask.onComplete).ref.getDownloadURL().then((value) async {
      FirebaseCredentials()
          .db
          .collection('Pet')
          .doc(petId)
          .collection('Post')
          .doc(postId)
          .update({
        'postPicture': FieldValue.arrayUnion([value])
      }).then((value) {
        setState(() {
          isUploading = false;
        });
      });
    });
  }
*/

  uploadPost() async {
    DocumentReference docRef = FirebaseCredentials()
        .db
        .collection('User')
        .doc(userId)
        .collection('Post')
        .doc();
    String postId = docRef.id;
  }

  getPostId() {
    postId = FirebaseCredentials()
        .db
        .collection('Post')
        .doc()
        .id;
  }

  /*getPostId() {
    postId = FirebaseCredentials()
        .db
        .collection('Pet')
        .doc(petId)
        .collection('Post')
        .doc()
        .id;
  }*/

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getKeys();
    getPostId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.redAccent,
            size: 22,
          ),
        ),
        title: Text(
          "Add Feed",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 40,
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 200,
                        width: MediaQuery.of(context).size.width / 1.4,
                        decoration: BoxDecoration(
                            color: Colors.black12.withOpacity(0.1)),
                        child: _images.length > 0
                            ? Image.file(
                                _images[0],
                                fit: BoxFit.cover,
                              )
                            : Center(),
                      ),
                    ),
                    Visibility(
                      visible: isVisible,
                      child: GestureDetector(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                              setState(() {
                                                isVisible = false;
                                                if (pickedFile != null) {
                                                  petImage1 =
                                                      File(pickedFile.path);
                                                  _images.add(petImage1);
                                                  print(
                                                      "Images Length : ${_images.length}");
                                                } else {
                                                  print('No image selected.');
                                                }
                                                //_btnController.reset();
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
                                                      source:
                                                          ImageSource.camera);
                                              setState(() {
                                                isVisible = false;
                                                if (pickedFile != null) {
                                                  petImage1 =
                                                      File(pickedFile.path);
                                                  _images.add(petImage1);
                                                } else {
                                                  print('No image captured.');
                                                }
                                                //_btnController.reset();
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
                            },
                          );
                        },
                        child: Container(
                          height: 50,
                          width: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.black12.withOpacity(0.1),
                          ),
                          child: Center(child: Text("Add Your Feed Image")),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: isVisible,
                      child: Positioned(
                        bottom: 16,
                        right: 16,
                        child: GestureDetector(
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                        source: ImageSource
                                                            .gallery);
                                                setState(() {
                                                  isVisible = false;
                                                  if (pickedFile != null) {
                                                    petImage1 =
                                                        File(pickedFile.path);
                                                    _images.add(petImage1);
                                                    print(
                                                        "Images Length : ${_images.length}");
                                                  } else {
                                                    print('No image selected.');
                                                  }
                                                  //_btnController.reset();
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
                                                        source:
                                                            ImageSource.camera);
                                                setState(() {
                                                  isVisible = false;
                                                  if (pickedFile != null) {
                                                    petImage1 =
                                                        File(pickedFile.path);
                                                    _images.add(petImage1);
                                                  } else {
                                                    print('No image captured.');
                                                  }
                                                  //_btnController.reset();
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
                              },
                            );
                          },
                          child: Image.asset(
                              "assets/2x/Icon feather-plus-circle@2x.png"),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Text("Add Your Feed description", style: pinkHeadingStyle),
                SizedBox(
                  height: 10,
                ),
                Container(
                  height: 100,
                  width: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: TextFormField(
                      textAlign: TextAlign.center,
                      controller: description,
                      maxLength: 100,
                      buildCounter: (context,
                              {currentLength, isFocused, maxLength}) =>
                          null,
                      decoration: InputDecoration(
                        hintText: "Feed-Description",
                        filled: true,
                        fillColor: Colors.white,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                isUploading
                    ? Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.pink,
                    strokeWidth: 2,
                  ),
                ) : GenericBShadowButton(
                        buttonText: "Save",
                        height: 45,
                        width: 160,
                        onPressed: () async{
                          if (_images.length > 0) {
                            DateFormat dateFormat =
                                DateFormat("yyyy-MM-dd HH:mm:ss");
                            setState(() {
                              isUploading = true;
                            });
                            await uploadImage(_images[0]);
                            FirebaseCredentials()
                                .db
                                .collection('Post')
                                .doc(postId)
                                .set({
                              'petImage' : petImageUrl,
                              'petName' : petName,
                              'petAge' : petAge,
                              'petId': petId,
                              'userId': userId,
                              'time': dateFormat.format(DateTime.now()),
                              'postId': postId,
                              'postPicture': postPicUrl,
                              'postDescription': description.text,
                            }, SetOptions(merge: true)).then((value) {
                              setState(() {
                                isUploading = false;
                              });
                            });
                            /*FirebaseCredentials()
                                .db
                                .collection('Pet')
                                .doc(petId)
                                .collection('Post')
                                .doc(postId)
                                .set({
                              'petImage' : petImageUrl,
                              'petName' : petName,
                              'petAge' : petAge,
                              'petId': petId,
                              'userId': userId,
                              'time': dateFormat.format(DateTime.now()),
                              'postId': postId,
                              'postPicture': postPicUrl,
                              'postDescription': description.text,
                            }, SetOptions(merge: true)).then((value) {
                              setState(() {
                                isUploading = false;
                              });
                            });*/
                          }
                        },
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
