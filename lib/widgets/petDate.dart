import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pett_tagg/models/likedByModel.dart';
import 'package:pett_tagg/utilities/firebase_credentials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pett_tagg/screens/userDetails.dart';

class PetDate extends StatefulWidget {
  @override
  _PetDateState createState() => _PetDateState();
}

class _PetDateState extends State<PetDate> {
  int length = 0;
  bool isLoading = true;



  Future<List<LikedBy>> getPetDate() async {
    List<LikedBy> list = [];
    QuerySnapshot myLikesDocs = await FirebaseFirestore.instance
        .collection('Pet')
        .where('${FirebaseCredentials().auth.currentUser.uid}', isEqualTo: 1)
        .get();
    List<QueryDocumentSnapshot> snap = myLikesDocs.docs;
    list.clear();
    snap.forEach((element) {
      element.data()['likedBy'].forEach((value) {
      if(!LikedBy(user_id: value['user_id']).isUserSame()) {
        list.add(LikedBy.fromFirebase(value));}
      });
    });
   var filterList =  list.distinct();
    return filterList;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 1.23,
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height - 150,
                child: FutureBuilder(
                    future: getPetDate(),
                    builder: (context, AsyncSnapshot<List<LikedBy>> snapshot) {
                      if (snapshot.hasData) {
                        isLoading = false;

                        return isLoading
                            ? Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  backgroundColor: Colors.pink,
                                ),
                              )
                            : GridView.builder(
                                shrinkWrap: true,
                                itemCount: snapshot.data.length,

                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 2,
                                  crossAxisSpacing: 2,
                                  //childAspectRatio: 3 / 4,
                                ),
                                itemBuilder: (context, index) {
/*        var images = data["images"];
        String petId = data['petId'];
        String ownerId = data['ownerId'];*/

                                  return GestureDetector(
                                    onTap: () => Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return UserDetails(
                                        ownerId: snapshot.data[index].user_id,
                                        petId: snapshot.data[index].petId,
                                        isMyProfile: false,
                                      );
                                    })),
                                    child: Container(
                                      //padding: EdgeInsets.symmetric(horizontal: 5),
                                      width: 200,
                                      height: 150,
                                      child: Card(
                                        shadowColor: Colors.white,
                                        elevation: 2.0,
                                        child: GridTile(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 15,
                                                bottom: 15,
                                                left: 15,
                                                right: 15),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.pink,
                                                        width: 1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100),
                                                  ),
                                                  child: CircleAvatar(
                                                    backgroundImage:
                                                        NetworkImage(
                                                            snapshot.data[index].petImage),
                                                    radius: 50,
                                                  ),
                                                ),
                                                Text(
                                                  snapshot.data[index].petName,
                                                  style: TextStyle(
                                                    fontSize: 17,
                                                    color: Colors.pink,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                      } else if (snapshot.hasError) {
                        return Text(
                          'Something Went Wrong',
                          style: TextStyle(
                            color: Colors.black38,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        );
                      } else
                        return Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            backgroundColor: Colors.black,
                          ),
                        );
                    }),
              ),
            ],
          ),
        ),
        /*Padding(
          padding: const EdgeInsets.all(15.0),
          child: SizedBox(
            height: 50,
            width: MediaQuery.of(context).size.width / 2,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.brown[300],
                  border: Border.all(
                    color: Colors.pink[100],
                    width: 2,
                  ),
                ),
                child: Center(
                    child: Text(
                  "You don't have any PetDates.",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                )),
              ),
            ),
          ),
        ),*/
      ],
    );
  }
}

class MyLikesList extends StatelessWidget {
  List<QueryDocumentSnapshot> docs = [];

  MyLikesList({this.docs});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: docs
            .map((e) {
              return LikedByList(list: e['likedBy']);
            })
            .toSet()
            .toList(),
      ),
    );
  }
}

class LikedByList extends StatefulWidget {
  List<dynamic> list;

  LikedByList({this.list});

  @override
  _LikedByListState createState() => _LikedByListState();
}

class _LikedByListState extends State<LikedByList> {
  List<dynamic> mapList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // final ids = myList.map((e) => e.id).toSet();
    // myList.retainWhere((x) => ids.remove(x.id));

    if (mounted) {
      setState(() {
        var mappList = widget.list.toSet();
        widget.list.retainWhere((x) => mappList.remove(x['user_id']));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    mapList.forEach((element) {
      print("${element["user_id"]}");
    });
    return GridView.builder(
      shrinkWrap: true,
      itemCount: mapList.length,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        //childAspectRatio: 3 / 4,
      ),
      itemBuilder: (context, index) {
/*        var images = data["images"];
        String petId = data['petId'];
        String ownerId = data['ownerId'];*/

        return GestureDetector(
          onTap: () =>
              Navigator.push(context, MaterialPageRoute(builder: (context) {
            return UserDetails(
              ownerId: mapList[index]["user_id"],
              petId: mapList[index]["petId"],
              isMyProfile: false,
            );
          })),
          child: Container(
            //padding: EdgeInsets.symmetric(horizontal: 5),
            width: 200,
            height: 150,
            child: Card(
              shadowColor: Colors.white,
              elevation: 2.0,
              child: GridTile(
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 15, bottom: 15, left: 15, right: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.pink, width: 1),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: CircleAvatar(
                          backgroundImage:
                              NetworkImage(mapList[index]["petImage"]),
                          radius: 50,
                        ),
                      ),
                      Text(
                        mapList[index]["petName"],
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.pink,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
