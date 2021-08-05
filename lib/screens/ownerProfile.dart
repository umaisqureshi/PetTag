import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pett_tagg/screens/pet_chat_screen.dart';
import 'package:pett_tagg/screens/settings_screen.dart';
import 'package:pett_tagg/utilities/firebase_credentials.dart';
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
import 'package:pett_tagg/screens/editOwnerInfo.dart';

class OwnerProfile extends StatefulWidget {
  static const String ownerProfileScreenRoute = 'OwnerProfileScreen';

  OwnerProfile({this.ownerId});

  String ownerId;

  @override
  _OwnerProfileState createState() => _OwnerProfileState();
}

class _OwnerProfileState extends State<OwnerProfile> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  File _imagesToUpload;
  ImagePicker imagePicker = ImagePicker();
  bool isUploading = false;

  RichText buildRichText(String key, String value) {
    return RichText(
      text: TextSpan(
        text: "$key : ",
        style: TextStyle(
          color: Colors.black,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
        children: <TextSpan>[
          TextSpan(
            text: value,
            style: TextStyle(
                color: Colors.pink[900],
                fontWeight: FontWeight.normal,
                fontSize: 15),
          ),
        ],
      ),
    );
  }

  uploadImage(image) async {
    var reference = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
    firebase_storage.StorageUploadTask uploadTask = reference.putFile(image);
    (await uploadTask.onComplete).ref.getDownloadURL().then((value) async {
      FirebaseCredentials()
          .db
          .collection('User')
          .doc(auth.currentUser.uid)
          .update({
        'images': FieldValue.arrayUnion([value])
      }).then((value) {
        setState(() {
          isUploading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          splashColor: Colors.transparent,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.pink,
            size: 22,
          ),
        ),
        title: Text(
          "Owner Details",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          /*FlatButton(
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(
                builder: (context){
                  return EditOwnerInfoScreen(id: widget.ownerId,);
                }
              ));
            },
            child: Text(
              "EDIT",
              style: TextStyle(
                  color: Colors.black45,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),*/
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 0.0),
          child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('User')
                  .doc(widget.ownerId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text("Something went wrong");
                }
                if (snapshot.hasData) {
                  Map<String, dynamic> data = snapshot.data.data();
                  List<dynamic> _images = data['images'] ?? [];
                  return CustomScrollView(
                    slivers: [
                      SliverList(
                        delegate: SliverChildListDelegate([
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.pink, width: 1),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: InkWell(
                                  child: CircleAvatar(
                                    radius: 60,
                                    backgroundImage: _images.isNotEmpty
                                        ? NetworkImage(_images[0])
                                        : AssetImage('assets/ownerProfile.png'),
                                    backgroundColor: Colors.white12,
                                  ),
                                  onTap: () {
                                    Navigator.pushNamed(context,
                                        OwnerProfile.ownerProfileScreenRoute);
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 30,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 30.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${data['firstName']} ${data['lastName']}",
                                      style: name.copyWith(fontSize: 20),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    buildRichText(
                                        'Age', "${data['age']}"),
                                    buildRichText(
                                        'Interested In', "${data['interest']}"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Divider(
                            height: 1,
                            color: Colors.pink[100],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            child: buildRichText("Description",
                                "${data['description']}"),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Divider(
                            height: 1,
                            color: Colors.pink[100],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Pet's Media",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                        ]),
                      ),
                      SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 15.0,
                          crossAxisSpacing: 15.0,
                          childAspectRatio: 8.0 / 12.0,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    height: 190,
                                    width: 120,
                                    color: Colors.black12,
                                    child: Image.network(
                                      _images[index],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  child: InkWell(
                                      onTap: () {
                                        FirebaseFirestore.instance
                                            .collection('User')
                                            .doc(auth.currentUser.uid)
                                            .update({
                                          'images': FieldValue.arrayRemove(
                                              [_images[index]])
                                        });
                                      },
                                      child: Icon(
                                        Icons.highlight_remove_sharp,
                                        color: Colors.black,
                                      )),
                                ),
                              ],
                            );
                          },
                          childCount: _images.length ?? 1,
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildListDelegate([
                          SizedBox(
                            height: 20,
                          ),
                          isUploading
                              ? Center(
                                  child: CircularProgressIndicator(
                                    backgroundColor: Colors.pink,
                                    strokeWidth: 2,
                                  ),
                                )
                              : GenericBShadowButton(
                                  buttonText: 'Add Owner Media',
                                  height: 50,
                                  width: 300,
                                  onPressed: () async {
                                    await showDialog(
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
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10.0,
                                                            top: 10),
                                                    child: Text(
                                                      "Upload Image",
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10.0),
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
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        padding:
                                                            EdgeInsets.all(0),
                                                        child: Text(
                                                          "CANCEL",
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                      Spacer(),
                                                      FlatButton(
                                                        onPressed: () async {
                                                          var pickedFile =
                                                              await imagePicker
                                                                  .getImage(
                                                                      source: ImageSource
                                                                          .gallery);
                                                          setState(() {
                                                            //visibility = true;
                                                            if (pickedFile !=
                                                                null) {
                                                              _imagesToUpload =
                                                                  File(pickedFile
                                                                      .path);

                                                              print(
                                                                  "Images Length : $_imagesToUpload");
                                                            } else {
                                                              print(
                                                                  'No image selected.');
                                                            }
                                                            //_btnController.reset();
                                                          });
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        padding:
                                                            EdgeInsets.all(0),
                                                        child: Text(
                                                          "GALLERY",
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                      FlatButton(
                                                        onPressed: () async {
                                                          var pickedFile =
                                                              await imagePicker
                                                                  .getImage(
                                                                      source: ImageSource
                                                                          .camera);
                                                          setState(() {
                                                            //visibility = true;
                                                            if (pickedFile !=
                                                                null) {
                                                              _imagesToUpload =
                                                                  File(pickedFile
                                                                      .path);
                                                            } else {
                                                              print(
                                                                  'No image captured.');
                                                            }
                                                            //_btnController.reset();
                                                          });
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        padding:
                                                            EdgeInsets.all(0),
                                                        child: Text(
                                                          "CAMERA",
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
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
                                    if (_imagesToUpload != null) {
                                      setState(() {
                                        isUploading = true;
                                      });
                                      uploadImage(_imagesToUpload);
                                    }
                                  },
                                ),
                          SizedBox(
                            height: 20,
                          ),
                        ]),
                      ),
                    ],
                  );
                }
                return Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.pink,
                    strokeWidth: 2,
                  ),
                );
              }),
        ),
      ),
    );
  }
}
/*StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('User')
                  .doc(auth.currentUser.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text("Something went wrong");
                }
                if(snapshot.hasData){
                  Map<String, dynamic> data = snapshot.data.data();
                  List<dynamic> _images = data['images'] ?? [];
                  return Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.pink, width: 1),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: InkWell(
                              child: CircleAvatar(
                                radius: 60,
                                backgroundImage: _images.isNotEmpty ? NetworkImage(_images[0]) : AssetImage('assets/ownerProfile.png'),
                                backgroundColor: Colors.white12,
                              ),
                              onTap: () {
                                Navigator.pushNamed(
                                    context, OwnerProfile.ownerProfileScreenRoute);
                              },
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${data['firstName']} ${data['lastName']}",
                                  style: name.copyWith(fontSize: 20),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                buildRichText('Age', "${data['age'] ?? 0}"),
                                buildRichText('Interested In', "${data['interest']}"),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Divider(height: 1, color: Colors.pink[100],),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        child: buildRichText("Description", "SJWE WEJNWE FNWEJNFJWE NEFJNWJKF JKWNFJ NWJKFN WJKN"),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Divider(height: 1, color: Colors.pink[100],),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: 300,
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 15.0,
                            crossAxisSpacing: 15.0,
                            childAspectRatio: 8.0 / 12.0,
                          ),
                          scrollDirection: Axis.vertical,
                          itemCount: _images.length,
                          itemBuilder: (BuildContext context, int index){
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                height: 190,
                                width: 120,
                                color: Colors.black12,
                                child: Image.network(_images[index], fit: BoxFit.cover,),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  );
                }
                return Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.pink,
                    strokeWidth: 2,
                  ),
                );
              }
            )*/
