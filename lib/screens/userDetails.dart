import 'package:flutter/material.dart';
import 'package:pett_tagg/constant.dart';
import 'package:pett_tagg/widgets/generic_shadow_button.dart';
import 'package:pett_tagg/widgets/reportDialog.dart';
import 'package:pett_tagg/widgets/petMediaDialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pett_tagg/screens/ownerProfile.dart';

class UserDetails extends StatefulWidget {
  static const String userDetailsRoute = "UserDetails";
  String petId;
  String ownerId;
  bool isMyProfile;

  UserDetails({this.petId, this.ownerId, this.isMyProfile});

  @override
  _UserDetailsState createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Map<String, dynamic> data = Map();
  Future<DocumentSnapshot> snap;

  List<dynamic> imageList = [];

  @override
  void setState(fn) {
    super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    getSnap();
  }

  Future<DocumentSnapshot> getSnap(){
    snap = FirebaseFirestore.instance.collection('Pet').doc(widget.petId).get();
    return snap;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          "User Details",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder(
                future : snap,
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text("Something went wrong");
                  }
                  if (snapshot.hasData) {
                    data = snapshot.data.data();
                    List<dynamic> images = data['images'] ?? [];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(top: 15),
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.pink, width: 1),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: CircleAvatar(
                                  radius: 35,
                                  backgroundImage: images.isNotEmpty
                                      ? NetworkImage(data['images'][0])
                                      : AssetImage('assets/profile.png'),
                                  backgroundColor: Colors.transparent,
                                ),
                              ),
                              SizedBox(
                                width: 40,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['name'],
                                    style: name.copyWith(fontSize: 20),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  buildRichText(
                                      "Age: ", data['age'].toString()),
                                  SizedBox(
                                    height: 2,
                                  ),
                                  buildRichText("Size: ", data['size']),
                                  SizedBox(
                                    height: 2,
                                  ),
                                  buildRichText("Breed: ", data['breed']),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        buildRichText("Pet Behaviour: ", data['behaviour']),
                        SizedBox(
                          height: 4,
                        ),
                        buildRichText("Pet Description: ", data['description']),
                      ],
                    );
                  }
                  return CircularProgressIndicator(
                    strokeWidth: 2,
                    backgroundColor: Colors.pinkAccent,
                  );
                },
              ),
              SizedBox(
                height: 30,
                child: Divider(
                  height: 2,
                  color: Colors.pink,
                ),
              ),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('User')
                    .doc(widget.ownerId)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text("Something went wrong");
                  }
                  if (snapshot.hasData) {
                    Map<String, dynamic> data = snapshot.data.data();
                    List<dynamic> images = data.containsKey("images") ? data['images'] : [];
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Owner",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.pink, width: 1),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: InkWell(
                                  child: CircleAvatar(
                                    radius: 35,
                                    backgroundImage: images.isNotEmpty
                                        ? NetworkImage(data['images'][0])
                                        : AssetImage('assets/ownerProfile.png'),
                                    backgroundColor: Colors.white12,
                                  ),
                                  onTap: (){
                                    if(widget.isMyProfile){
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (context){
                                            return OwnerProfile(ownerId: widget.ownerId,);
                                          }
                                      ));
                                    }
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 40,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${data['firstName']} ${data['lastName']}",
                                    style: name.copyWith(fontSize: 20),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          buildRichText(
                              "Owner Description: ", data['description']),
                          SizedBox(
                            height: 30,
                            child: Divider(
                              height: 2,
                              color: Colors.pink,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return CircularProgressIndicator(
                    strokeWidth: 2,
                    backgroundColor: Colors.pinkAccent,
                  );
                },
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Pet's Media",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    FutureBuilder(
                      future : snap,
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text("Something went wrong");
                        }
                        if (snapshot.hasData) {
                          Map<String, dynamic> data =
                              snapshot.data.data();
                          imageList = data['images'] ?? [];
                          return Container(
                            padding: EdgeInsets.only(top: 10),
                            width: MediaQuery.of(context).size.width,
                            height: 100,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: imageList!=null ? imageList.length : 0,
                                itemBuilder: (BuildContext ctx, index) {
                                  return Container(
                                    width: 90,
                                    height: 90,
                                    padding: EdgeInsets.only(
                                        left: 12, top: 8, bottom: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return PetMediaDialog(
                                                imagePath: imageList[index],
                                              );
                                            });
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: data['images']!=null ? Image.network(
                                          imageList[index],
                                          fit: BoxFit.cover,
                                        ):null,
                                      ),
                                    ),
                                  );
                                }),
                          );
                        }
                        return Center(
                            child: CircularProgressIndicator(
                          strokeWidth: 2,
                          backgroundColor: Colors.pinkAccent,
                        ));
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
                child: Divider(
                  height: 2,
                  color: Colors.pink,
                ),
              ),
              Center(
                child: GenericBShadowButton(
                  buttonText: "Report This Profile",
                  width: MediaQuery.of(context).size.width / 2,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return ReportDialog();
                      },
                    );
                  },
                ),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  RichText buildRichText(String key, String value) {
    return RichText(
      text: TextSpan(
        text: key,
        style: TextStyle(
          color: Colors.black,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
        children: <TextSpan>[
          TextSpan(
            text: value,
            style: TextStyle(
                color: Colors.pink[900], fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }
}

/**/
