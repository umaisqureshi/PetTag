import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pett_tagg/models/likedByModel.dart';
import 'package:pett_tagg/utilities/firebase_credentials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pett_tagg/screens/userDetails.dart';

class Treat extends StatefulWidget {
  @override
  _TreatState createState() => _TreatState();
}

class _TreatState extends State<Treat> {

  List<dynamic> likedBy = [];
  List<LikedBy> detailList = [];
  int length = 0;

  getTreatLength()async{
    await FirebaseFirestore.instance.collection("User").doc(FirebaseAuth.instance.currentUser.uid).get().then((value) {
      value.data().containsKey("treats") ? length = value.data()['treats'] : length = 0;
    });
    setState(() {

    });
  }


  Future<List<LikedBy>> getTreatList()async{
    QuerySnapshot myLikesDocs = await FirebaseCredentials().db.collection('Pet').where('ownerId', isEqualTo: FirebaseCredentials().auth.currentUser.uid).get();
    List<QueryDocumentSnapshot> snap = myLikesDocs.docs;
    detailList.clear();
    snap.forEach((element) {
      element.data()['likedBy'].forEach((value) {
        if(!LikedBy(user_id: value['user_id']).isUserSame()) {
          detailList.add(LikedBy.fromFirebase(value));}
      });
    });

    return detailList;
    /*if(likedBy!=null){
      await likedBy.forEach((element) async{
        QuerySnapshot snap = await FirebaseCredentials().db.collection('Pet').where('ownerId', isEqualTo: element["user_id"]).get();
        detailList.add();
      });
    }*/
    detailList = detailList.toSet().toList();
    return detailList;
   /* if(mounted){
      Future.delayed(Duration(seconds: 1)).whenComplete((){
        if(detailList.length>0){
          setState(() {});
        }
      });
    }*/
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTreatLength();
    getTreatList();
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
                    future: getTreatList(),
                    builder: (context, AsyncSnapshot<List<LikedBy>> snapshot) {
                      if(snapshot.hasData){
                        if(snapshot.data.length >= 15){
                          length = 15;
                        }else if(length==0){
                          length=0;
                        }else{
                          length = snapshot.data.length;
                        }

                        //length = snapshot.data.length;
                        print("DetailsList Length : ${snapshot.data.length}");

                        return length>0 ? GridView.builder(
                          shrinkWrap: true,
                          itemCount: length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 2,
                            crossAxisSpacing: 2,
                            //childAspectRatio: 3 / 4,
                          ),
                          itemBuilder: (context, index) {
                            //Map<String, dynamic> data = snapshot.data.docs[index].data();
                            var images = snapshot.data[index].petImage;
                            String petId = snapshot.data[index].petId;//data['petId'];
                            String ownerId = snapshot.data[index].user_id;//data['ownerId'];
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
                                                  color: Colors.pink, width: 1),
                                              borderRadius:
                                              BorderRadius.circular(100),
                                            ),
                                            child: CircleAvatar(
                                              backgroundImage: images.isNotEmpty
                                                  ? NetworkImage(images[0])
                                                  : AssetImage('assets/profile.png'),
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
                        ) : Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            backgroundColor: Colors.pink,
                          ),
                        );
                      }
                      else if(snapshot.hasError){
                        return Text('', style: TextStyle(color: Colors.black38, fontWeight: FontWeight.bold, fontSize: 17,),);
                      }
                      else
                        return Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            backgroundColor: Colors.pink,
                          ),
                        );
                    }),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
