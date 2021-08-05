import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pett_tagg/models/videoModel.dart';
import 'package:pett_tagg/widgets/generic_shadow_button.dart';
import 'package:pett_tagg/widgets/uploadImageDialog.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as Path;
import 'package:pett_tagg/utilities/firebase_credentials.dart';
import 'package:pett_tagg/models/owner_model.dart';
import 'package:progress_indicator_button/progress_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'package:pett_tagg/models/trimmerModel.dart';
import 'package:path_provider/path_provider.dart';

class EditProfileScreen extends StatefulWidget {
  static const String editProfileScreenRoute = "EditProfileScreen";
  String id;
  String ownerId;

  EditProfileScreen({this.id, this.ownerId});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File petImage1;
  File petImage2;
  File petImage3;
  File petImage4;
  File petImage5;
  File petImage6;
  File petImage7;
  File petImage8;
  File petImage9;
  File ownerImage1;
  File ownerImage2;
  File ownerImage3;
  bool uploading = false;
  int val = 0;
  int index = 0;
  int ownerIndex=0;
  bool visibility = false;
  int _state = 4;
  bool isLoading = false;
  int mediaCount = 0;
  int videoCount = 0;
  bool videoCancelVisibility = false;
  int videoIndex=0;
  Uint8List uint8list;
  String thumbPath;

  String videoResult;

  CollectionReference imgRef;

  Trimmer trimmer = new Trimmer();

  /*final RoundedLoadingButtonController _btnController =
      new RoundedLoadingButtonController();*/

  List<File> _images = [];
  List<File> _ownerImages = [];
  List<VideoModel> _videos = [];
  List<dynamic> urlsPet = [];
  List<dynamic> urlsOwner = [];
  List<dynamic> imagesPet = [];
  List<dynamic> ownerImages = [];
  List<String> videoUrl = [];
  List<dynamic> petVideos = [];

  Person _person = Person();
  Pet _pet = Pet();

  final FirebaseAuth auth = FirebaseAuth.instance;

  ImagePicker imagePicker = ImagePicker();
  CollectionReference users = FirebaseFirestore.instance.collection('User');
  CollectionReference pet = FirebaseFirestore.instance.collection('Pet');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCount();
    imgRef = FirebaseFirestore.instance.collection('Pet');
    print("Pet ID : ${widget.id}");
  }

  uploadOwnerImage(image) async {
    var reference = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
    firebase_storage.StorageUploadTask uploadTask = reference.putFile(image);
    (await uploadTask.onComplete).ref.getDownloadURL().then((value) async {
      urlsOwner.add(value);
      ownerIndex++;
      if (index == _ownerImages.length) {
        _pet.images = urlsOwner;
        _ownerImages.clear();
        await FirebaseCredentials()
            .db
            .collection('User')
            .doc(widget.ownerId)
            .update({'images': FieldValue.arrayUnion(urlsOwner)}).then((value){
          setState(() {
            isLoading = false;
          });
        });
      } else {
        uploadOwnerImage(_ownerImages[ownerIndex]);
      }
    });
  }

  uploadPetImage(image) async {
    var reference = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
    firebase_storage.StorageUploadTask uploadTask = reference.putFile(image);
    (await uploadTask.onComplete).ref.getDownloadURL().then((value) async {
      urlsPet.add(value);
      index++;
      if (index == _images.length) {
        _pet.images = urlsPet;
        _images.clear();
        await FirebaseCredentials()
            .db
            .collection('Pet')
            .doc(widget.id)
            .update({'images': FieldValue.arrayUnion(urlsPet)}).then((value){
              setState(() {
                isLoading = false;
              });
        });
      } else {
        uploadPetImage(_images[index]);
      }
    });
  }

  getCount()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey('packageName')){
      String pkg = prefs.getString('packageName');
      if(pkg == 'STANDARD'){
        setState(() {
          mediaCount = 5;
          videoCount = 2;
        });
      }
      else if(pkg == 'PETTAGPLUS'){
        setState(() {
          mediaCount = 5+5;
          videoCount = 2+2;
        });      }
      else if(pkg == 'BREEDER'){
        setState(() {
          mediaCount = 30;
        });
      }
      else if(pkg == 'RESCUER'){
        setState(() {
          mediaCount = 3;
          videoCount = 1;
        });
      }
    }
  }

  uploadVideo(video) async {
    var reference = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('${DateTime.now().millisecondsSinceEpoch}.mp4');
    firebase_storage.StorageUploadTask uploadTask = reference.putFile(video);
    (await uploadTask.onComplete).ref.getDownloadURL().then((value) async {
      setState(() {
        videoUrl.add(value);
        videoIndex++;
      });
      if (videoIndex == _videos.length) {
        _videos.clear();
        //
        await FirebaseCredentials()
            .db
            .collection('Pet')
            .doc(widget.id)
            .update({'videos': FieldValue.arrayUnion(videoUrl)}).then((value){
          setState(() {
            isLoading = false;
          });
        });
      } else {
        uploadVideo(File(_videos[videoIndex].path));
      }
    });
  }

  getThumbnail(url)async{
   await VideoThumbnail.thumbnailFile(
      video: url,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.WEBP,
      maxHeight: 64, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
      quality: 75,
    ).then((value){
      setState(() {
        thumbPath = value;
      });
   });

    /*setState(() {
      uint8list;
    });*/
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
            color: Colors.pink,
            size: 22,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Add Media",
          style: TextStyle(
              fontSize: 20, color: Colors.black54, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
            top: 16.0, right: 20.0, left: 20.0, bottom: 0),
        child: CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Text(
                    "Pet Images",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFC3548),
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
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
                  return StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseCredentials()
                        .db
                        .collection('Pet')
                        .doc(widget.id)
                        .snapshots(),
                    builder:
                        (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.hasData) {
                        Map<String, dynamic> data = snapshot.data.data();
                        imagesPet = data['images'] ?? [];
                        if (index < imagesPet.length) {
                          visibility = true;
                          _state = 0;
                        } else if (_images.length > index - imagesPet.length) {
                          visibility = true;
                          _state = 1;
                        } else {
                          visibility = false;
                        }
                        return AddMediaWidget(
                          child: (index < imagesPet.length)
                              ? imagesPet[index] != null
                                  ? Image.network(
                                      imagesPet[index],
                                      fit: BoxFit.cover,
                                    )
                                  : Container()
                              : (_images.length > 0 &&
                                      (index - imagesPet.length) <
                                          _images.length)
                                  ? Image.file(
                                      _images[(index) - imagesPet.length],
                                      fit: BoxFit.cover,
                                    )
                                  : Container(),
                          isEmpty: visibility,
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
                                                  visibility = true;
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
                                                  visibility = true;
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
                          onTapCancel: () {
                            if (index < imagesPet.length) {
                              print('State : $_state');
                              FirebaseFirestore.instance
                                  .collection("Pet")
                                  .doc(widget.id)
                                  .update({
                                "images":
                                    FieldValue.arrayRemove([imagesPet[index]])
                              });
                              print("Deleted : ${imagesPet[index]}");
                              imagesPet.removeAt(index);
                            } else {
                              print('State : $_state');
                              setState(() {
                                _images.removeAt(index - imagesPet.length);
                              });
                            }
                          },
                          index: index,
                          array: imagesPet,
                          docId: widget.id,
                        );
                      }

                      return Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          backgroundColor: Colors.pink,
                        ),
                      );
                    },
                  );
                },
                childCount: mediaCount,
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  SizedBox(height: 20,),
                  Divider(height: 1,color: Colors.pink[50],),
                  SizedBox(height: 10,),
                  Text(
                    "Pet Videos",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFC3548),
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
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
                      int videosLength = _videos.length;

                  return FutureBuilder(
                    future: FirebaseCredentials()
                        .db
                        .collection('Pet')
                        .doc(widget.id)
                        .get(),
                    builder: (context, snapshot) {
                      if(snapshot.hasData){
                        Map<String, dynamic> data = snapshot.data.data();
                        petVideos = data['videos'] ?? [];

                        if (index < petVideos.length) {
                          videoCancelVisibility = true;
                          _state = 0;
                        } else if (_videos.length > index - petVideos.length) {
                          videoCancelVisibility = true;
                          _state = 1;
                        } else {
                          videoCancelVisibility = false;
                        }
                        if(index < petVideos.length){
                          getThumbnail(petVideos[index]);
                          //sleep(Duration(seconds: 3));
                        }

                        /*if(index >= videosLength){
                          videoCancelVisibility = false;
                        }
                        else{
                          videoCancelVisibility = true;
                        }*/
                        return AddMediaWidget(
                          child: (index < petVideos.length)
                              ? petVideos[index] != null
                              ? Image.asset(
                            thumbPath ?? "",
                            fit: BoxFit.cover,
                          )
                              : Container()
                              : (_videos.length > 0 &&
                              (index - petVideos.length) <
                                  _videos.length)
                              ? Image.memory(
                            _videos[(index) - petVideos.length].thumbnail,
                            fit: BoxFit.cover,
                          )
                              : Container(),
                          /*(videosLength > 0) ? (videosLength > index) ?  ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(_videos[index].thumbnail)) : Container() : Container(),*/
                          isEmpty: videoCancelVisibility,
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
                                            "Upload Video",
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
                                            "Select a Video.",
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
                                                var videoFile =
                                                await imagePicker.getVideo(source: ImageSource.gallery);

                                                if (videoFile != null) {
                                                  await trimmer.loadVideo(
                                                      videoFile: File(videoFile.path));
                                                  videoResult = await Navigator.of(context)
                                                      .push(TrimmerModel(trimmer));
                                                  final uint8list =
                                                  await VideoThumbnail.thumbnailData(
                                                    video: videoFile.path,
                                                    imageFormat: ImageFormat.JPEG,
                                                    maxHeight: 300,
                                                    maxWidth: 300,
                                                    // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
                                                    quality: 30,
                                                  );
                                                  setState(() {
                                                    _videos.add(VideoModel(
                                                        path: videoResult,
                                                        thumbnail: uint8list));
                                                    videoCancelVisibility = true;
                                                  });
                                                  print(
                                                      "Video Length : ${_videos.length}");
                                                } else {
                                                  print('No video selected.');
                                                }
                                                //_btnController.reset();
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
                                                var videoFile =
                                                await imagePicker.getVideo(source: ImageSource.camera);

                                                if (videoFile != null) {
                                                  await trimmer.loadVideo(
                                                      videoFile: File(videoFile.path));
                                                  videoResult = await Navigator.of(context)
                                                      .push(TrimmerModel(trimmer));
                                                  final uint8list =
                                                  await VideoThumbnail.thumbnailData(
                                                    video: videoFile.path,
                                                    imageFormat: ImageFormat.JPEG,
                                                    maxHeight: 300,
                                                    maxWidth: 300,
                                                    // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
                                                    quality: 30,
                                                  );
                                                  setState(() {

                                                    _videos.add(VideoModel(
                                                        path: videoResult,
                                                        thumbnail: uint8list));
                                                    videoCancelVisibility = true;
                                                  });
                                                  print(
                                                      "Video Length : ${_videos.length}");
                                                } else {
                                                  print('No video selected.');
                                                }
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
                          onTapCancel: () {
                            _videos.removeAt(index);
                            setState(() {});
                          },
                          index: index,
                          array: imagesPet,
                          docId: widget.id,
                        );
                      }
                      else{
                        return Center(child: CircularProgressIndicator(backgroundColor: Colors.pink,strokeWidth: 2,),);
                      }
                    }
                  );
                },
                childCount: videoCount,
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    isLoading ? Center(child: CircularProgressIndicator(strokeWidth: 2,backgroundColor: Colors.pink,)):GenericBShadowButton(
                      onPressed: (){
                        if (_images.length > 0) {
                          setState((){
                            isLoading = true;
                          });
                          Timer(Duration(seconds: 3), () async {
                            index = 0;
                            ownerIndex = 0;
                            await uploadPetImage(_images[0]);
                            //_btnController.success();
                          });
                        }
                        else if(_ownerImages.length > 0){
                          setState((){
                            isLoading = true;
                          });
                          Timer(Duration(seconds: 3), () async {
                            index = 0;
                            ownerIndex = 0;
                            await uploadOwnerImage(_ownerImages[0]);
                            //_btnController.success();
                          });
                        }
                        else if(_videos.length > 0){
                          setState(() {
                            isLoading = true;
                          });
                          uploadVideo(File(_videos[videoIndex].path));
                        }
                      },
                      buttonText: 'Add Media',
                      width: MediaQuery.of(context).size.width / 2.5,
                      height: 50,
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class AddMediaWidget extends StatefulWidget {
  AddMediaWidget(
      {this.child,
      this.onTap,
      this.onTapCancel,
      this.isEmpty,
      this.docId,
      this.index,
      this.array});

  Widget child;
  Function onTap;
  Function onTapCancel;
  bool isEmpty;
  String docId;
  int index;
  List<dynamic> array;

  @override
  _AddMediaWidgetState createState() => _AddMediaWidgetState();
}

class _AddMediaWidgetState extends State<AddMediaWidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 190,
            width: 120,
            color: Colors.black12,
            child: widget.child,
          ),
        ),
        Visibility(
          visible: widget.isEmpty,
          child: Positioned(
            top: 0,
            left: 0,
            child: InkWell(
                onTap: widget.onTapCancel,
                /*(){
                  FirebaseFirestore.instance
                      .collection("Pet")
                      .doc(widget.docId)
                      .update({
                    "images":
                    FieldValue.arrayRemove([widget.array[widget.index]])
                  }).then((value) =>
                      () {
                    print("Deleted : ${widget.array[widget.index]}");
                    widget.array.removeAt(widget.index);
                  });
                },*/
                child: Icon(
                  Icons.highlight_remove_sharp,
                  color: Colors.black,
                )),
          ),
        ),
        Positioned(
          bottom: 5,
          right: 5,
          child: InkWell(
            onTap: widget.onTap,
            child: Image.asset(
              "assets/3x/Icon feather-plus-circle@3x.png",
              height: 25,
              width: 25,
            ),
          ),
        ),
      ],
    );
  }
}
