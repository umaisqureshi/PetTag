import 'package:flutter/material.dart';
import 'package:flutter_snackbar/flutter_snackbar.dart';
import 'package:pett_tagg/utilities/firebase_credentials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pett_tagg/screens/userDetails.dart';

class MyTreat extends StatefulWidget {

  @override
  _MyTreatState createState() => _MyTreatState();
}

class _MyTreatState extends State<MyTreat> {
  GlobalKey<SnackBarWidgetState> _globalKey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
                    future: FirebaseFirestore.instance
                        .collection('Pet')
                        .where('${FirebaseCredentials().auth.currentUser.uid}',
                        isEqualTo: 2)
                        .get(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      List<QueryDocumentSnapshot> myList = [];
                      if(snapshot.hasData){
                        snapshot.data.docs.forEach((element) {
                          if(element.data().containsKey(FirebaseCredentials().auth.currentUser.uid)){
                            myList.add(element);
                          }
                        });
                        int length = myList.length;
                        return length > 0 ?GridView.builder(
                          shrinkWrap: true,
                          itemCount: length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 2,
                            crossAxisSpacing: 2,
                            //childAspectRatio: 3 / 4,
                          ),
                          itemBuilder: (context, index) {
                            Map<String, dynamic> data =
                            snapshot.data.docs[index].data();
                            var images = myList[index].data()['images'];//data["images"];
                            String petId = myList[index].data()['petId'];//data['petId'];
                            String ownerId = myList[index].data()['ownerId'];//data['ownerId'];
                            return GestureDetector(
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                    return UserDetails(
                                      ownerId: ownerId,
                                      petId: petId,
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
                                            data['name'],
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
                          child: Padding(
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
                                        "You don't have any Treat.",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      )),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      else if(snapshot.hasError){
                        return Text('Something Went Wrong', style: TextStyle(color: Colors.black38, fontWeight: FontWeight.bold, fontSize: 17,),);
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
                  "You don't have any Treats.",
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
