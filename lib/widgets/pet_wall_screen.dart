import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pett_tagg/constant.dart';
import 'package:pett_tagg/screens/addNewFeed.dart';
import 'package:pett_tagg/models/PostModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pett_tagg/chat/repo/route_argument.dart';

class PetWallScreen extends StatefulWidget {
  @override
  _PetWallScreenState createState() => _PetWallScreenState();
}

class _PetWallScreenState extends State<PetWallScreen> {
  dialog(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Container(
                width: size.width * 0.8,
                height: size.height * 0.2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Color(0xFF707070)),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: size.height * 0.03),
                      child: Text(
                        "Are you sure to Delete?",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: size.height * 0.05),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: size.width * 0.3,
                              height: size.height * 0.06,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color:
                                          Color(0xFF0f1013).withOpacity(0.2)),
                                  color: Colors.white),
                              child: Center(
                                child: Text(
                                  "Yes",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: size.width * 0.3,
                              height: size.height * 0.06,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color:
                                          Color(0xFF0f1013).withOpacity(0.2)),
                                  color: Colors.white),
                              child: Center(
                                child: Text(
                                  "No",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
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
        });
  }

  List<PostModel> posts = [];
  bool isLoading = false;
  final FirebaseAuth auth = FirebaseAuth.instance;

  /*getPosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('Pet').get();
    List<DocumentSnapshot> petsList = snapshot.docs;
    print("Pet List : ${petsList.length}");
    for (int i = 0; i < petsList.length; i++) {
      await FirebaseFirestore.instance
          .collection('Pet')
          .doc(petsList[i].data()['petId'])
          .collection('Post')
          .get()
          .then((value) {
        var docs = value.docs;
        for (var doc in docs) {
          Map<String, dynamic> data = doc.data();
          posts.add(PostModel(
            petId: data['petId'].toString(),
            picUrl: data['postPicture'][0].toString(),
            postDescription: data['postDescription'].toString(),
            postId: data['petId'].toString(),
            time: data['time'].toString(),
            userId: data['userId'].toString(),
            petAge: data['petAge'].toString(),
            petImageUrl: data['petImage'].toString(),
            petName: data['petName'].toString(),
          ));
        }
      });
    }
    setState(() {
      isLoading = false;
    });
  }*/

  updateStarCounter({postId, status}) async {
    DocumentSnapshot snap =
        await FirebaseFirestore.instance.collection('Post').doc(postId).get();
    int counter = snap.data()['stars'] != null ? snap.data()['stars'] : 0;
    if (!snap.data().containsKey(auth.currentUser.uid)) {
      counter++;
      FirebaseFirestore.instance.collection('Post').doc(postId).update({
        'stars': counter,
      });
      updateInteraction(postId: postId, status: status);
    }
  }

  updateHeartCounter({postId, status}) async {
    DocumentSnapshot snap =
        await FirebaseFirestore.instance.collection('Post').doc(postId).get();
    int counter = snap.data()['hearts'] != null ? snap.data()['hearts'] : 0;
    if (!snap.data().containsKey(auth.currentUser.uid)) {
      counter++;
      FirebaseFirestore.instance.collection('Post').doc(postId).set({
        'hearts': counter,
      }, SetOptions(merge: true));
      updateInteraction(postId: postId, status: status);
    }
  }

  updateInteraction({postId, status}) async {
    FirebaseFirestore.instance.collection('Post').doc(postId).set({
      auth.currentUser.uid: status,
    }, SetOptions(merge: true));
  }

  updateHeart({postId, status}) async {
    FirebaseFirestore.instance.collection('Post').doc(postId).set({
      auth.currentUser.uid: status,
    }, SetOptions(merge: true));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //getPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      //height: MediaQuery.of(context).size.height/1.25,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 50,
            child: RaisedButton(
              elevation: 0,
              child: Text(
                "Add Your New Feed",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              textColor: Colors.black,
              color: Colors.white,
              onPressed: () {
                Navigator.pushNamed(context, AddNewFeed.addNewFeedScreenRoute);
              },
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            height: MediaQuery.of(context).size.height / 1.4,
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.pink,
                      strokeWidth: 2,
                    ),
                  )
                : StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('Post')
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        List<DocumentSnapshot> docs = snapshot.data.docs;

                        return ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white70,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  height: 400,
                                  //color: Colors.teal,
                                  child: GestureDetector(
                                    onTap: () {},
                                    child: Card(
                                      elevation: 0.0,
                                      color: Colors.white54,
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            left: 15,
                                            right: 10,
                                            top: 15,
                                            bottom: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 40,
                                                  backgroundImage: NetworkImage(
                                                      docs[index]
                                                          .data()['petImage']),
                                                ),
                                                Padding(
                                                  padding:
                                                      EdgeInsets.only(left: 15),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        docs[index]
                                                            .data()['petName'],
                                                        style: name.copyWith(
                                                            fontSize: 17),
                                                      ),
                                                      Text(
                                                        docs[index]
                                                            .data()['time'],
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color: Colors.black38,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Spacer(),
                                                IconButton(
                                                  onPressed: () {
                                                    dialog(context);
                                                  },
                                                  icon: Icon(
                                                    Icons.more_horiz,
                                                    color: Colors.black26,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              padding: EdgeInsets.only(
                                                  top: 10,
                                                  right: 5,
                                                  bottom: 10),
                                              child: Text(
                                                docs[index]
                                                    .data()['postDescription'],
                                                style: TextStyle(
                                                  color: Colors.pink[900],
                                                  fontSize: 13,
                                                ),
                                                textAlign: TextAlign.start,
                                              ),
                                            ),
                                            Container(
                                              width: double.infinity,
                                              height: 190,
                                              padding: EdgeInsets.only(
                                                  top: 10,
                                                  right: 5,
                                                  bottom: 10),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.network(
                                                  docs[index]
                                                      .data()['postPicture'][0],
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              alignment: Alignment.centerRight,
                                              width: double.infinity,
                                              height: 40,
                                              padding: EdgeInsets.only(
                                                  top: 0, right: 5, bottom: 0),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(docs[index]
                                                      .data()['stars']!=null ?docs[index]
                                                      .data()['stars'].toString() : "0" ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      top: 0,
                                                      left: 0,
                                                      right: 0,
                                                    ),
                                                    child: IconButton(
                                                      icon: Container(
                                                        width: 25,
                                                        height: 30,
                                                        padding:
                                                            EdgeInsets.all(5),
                                                        decoration: BoxDecoration(
                                                            color: Color(
                                                                0xFFFFFAFA),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20)),
                                                        child: Image.asset(
                                                          "assets/2x/Icon awesome-star@2x.png",
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        updateStarCounter(
                                                            postId: docs[index]
                                                                    .data()[
                                                                'postId'],
                                                            status: 2);
                                                      },
                                                    ),
                                                  ),
                                                  Text(docs[index]
                                                      .data()['hearts']!=null ?docs[index]
                                                      .data()['hearts'].toString() : "0"),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 0,
                                                            left: 0,
                                                            right: 0),
                                                    child: IconButton(
                                                      icon: Container(
                                                        width: 25,
                                                        height: 30,
                                                        padding:
                                                            EdgeInsets.all(5),
                                                        decoration: BoxDecoration(
                                                            color: Color(
                                                                0xFFFFFAFA),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20)),
                                                        child: Image.asset(
                                                          "assets/2x/Icon awesome-heart@2x.png",
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        updateHeartCounter(
                                                            postId: docs[index]
                                                                    .data()[
                                                                'postId'],
                                                            status: 1);
                                                      },
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 2,
                                                            left: 10,
                                                            right: 0),
                                                    child: InkWell(
                                                      onTap: () async {
                                                        User user = FirebaseAuth
                                                            .instance
                                                            .currentUser;
                                                        String userId =
                                                            await user.uid;
                                                        SharedPreferences
                                                            prefs =
                                                            await SharedPreferences
                                                                .getInstance();
                                                        await prefs.setString(
                                                            'id', userId);
                                                        DocumentSnapshot doc =
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'User')
                                                                .doc(docs[index]
                                                                        .data()[
                                                                    'userId'])
                                                                .get();
                                                        var ownerImage =
                                                            doc['images'];
                                                        Navigator.of(context).pushNamed(
                                                            '/chat',
                                                            arguments: RouteArgument(
                                                                param1:
                                                                    doc['id'],
                                                                param2: ownerImage
                                                                            .length >
                                                                        0
                                                                    ? doc['images']
                                                                        [0]
                                                                    : 'default',
                                                                param3: doc[
                                                                        'firstName'] ??
                                                                    'User'));
                                                      },
                                                      child: Container(
                                                        width: 25,
                                                        height: 25,
                                                        padding:
                                                            EdgeInsets.all(5),
                                                        decoration: BoxDecoration(
                                                            color: Color(
                                                                0xFFFFFAFA),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20)),
                                                        child: Image.asset(
                                                          "assets/2x/Icon simple-hipchat@2x.png",
                                                          color:
                                                              Colors.pink[200],
                                                        ),
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
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            "Something Went Wrong",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black45,
                              fontSize: 20,
                            ),
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
                    }),
          ),
        ],
      ),
    );
  }
}

/*SubCollection Logic
Container(
            height: MediaQuery.of(context).size.height / 1.4,
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.pink,
                      strokeWidth: 2,
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white70,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            height: 400,
                            //color: Colors.teal,
                            child: GestureDetector(
                              onTap: () {},
                              child: Card(
                                elevation: 0.0,
                                color: Colors.white54,
                                child: Container(
                                  padding: EdgeInsets.only(
                                      left: 15, right: 10, top: 15, bottom: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 40,
                                            backgroundImage:
                                                NetworkImage(posts[index].petImageUrl),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(left: 15),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  posts[index].petName,
                                                  style: name.copyWith(
                                                      fontSize: 17),
                                                ),
                                                Text(
                                                  posts[index].time,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.black38,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Spacer(),
                                          Icon(
                                            Icons.more_horiz,
                                            color: Colors.black26,
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(
                                            top: 10, right: 5, bottom: 10),
                                        child: Text(
                                          posts[index].postDescription,
                                          style: TextStyle(
                                            color: Colors.pink[900],
                                            fontSize: 13,
                                          ),
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        height: 190,
                                        padding: EdgeInsets.only(
                                            top: 10, right: 5, bottom: 10),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.network(
                                            posts[index].picUrl,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.centerRight,
                                        width: double.infinity,
                                        height: 40,
                                        padding: EdgeInsets.only(
                                            top: 0, right: 5, bottom: 0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 0, left: 0, right: 0),
                                              child: IconButton(
                                                  icon: Container(
                                                    width: 25,
                                                    height: 30,
                                                    padding: EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Color(0xFFFFFAFA),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20)),
                                                    child: Image.asset(
                                                      "assets/2x/Icon awesome-star@2x.png",
                                                    ),
                                                  ),
                                                  onPressed: () {}),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 0, left: 0, right: 0),
                                              child: IconButton(
                                                  icon: Container(
                                                    width: 25,
                                                    height: 30,
                                                    padding: EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Color(0xFFFFFAFA),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20)),
                                                    child: Image.asset(
                                                      "assets/2x/Icon awesome-heart@2x.png",
                                                    ),
                                                  ),
                                                  onPressed: () {}),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 2, left: 10, right: 0),
                                              child: Container(
                                                width: 25,
                                                height: 25,
                                                padding: EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                    color: Color(0xFFFFFAFA),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20)),
                                                child: Image.asset(
                                                  "assets/2x/Icon simple-hipchat@2x.png",
                                                  color: Colors.pink[200],
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
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      );
                    },
                  ),
          ),*/
