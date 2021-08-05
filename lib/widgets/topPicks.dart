import 'package:flutter/material.dart';
import 'package:pett_tagg/constant.dart';
import 'package:pett_tagg/screens/userDetails.dart';
import 'package:pett_tagg/widgets/generic_shadow_button.dart';
import 'package:pett_tagg/widgets/mySearchDialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pett_tagg/utilities/firebase_credentials.dart';

class TopPicks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
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

                      if(snapshot.hasData){

                        int length = snapshot.data.docs.length;
                        return GridView.builder(
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
                            var images = data["images"];
                            String petId = data['petId'];
                            String ownerId = data['ownerId'];
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
        Positioned(
          bottom: 20,
          right: 10,
          left: 10,
          child: GenericBShadowButton(
            buttonText: 'Unlock Top Picks',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return MySearchDialog();
                },
              );
            },
          ),
        )
      ],
    );
  }
}
