import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fsearch/fsearch.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pett_tagg/chat/repo/route_argument.dart';
import 'package:multi_select_item/multi_select_item.dart';
import 'package:pett_tagg/constant.dart';

class MessageContainerWithSearchBar extends StatefulWidget {
  @override
  _MessageContainerWithSearchBarState createState() =>
      _MessageContainerWithSearchBarState();
}

class _MessageContainerWithSearchBarState
    extends State<MessageContainerWithSearchBar> {
  FirebaseAuth auth = FirebaseAuth.instance;
  SlidableController slidableController;
  MultiSelectController controller = MultiSelectController();
  var chattedWith;
  String userId;
  Color tileColor = bgColor;
  List<QueryDocumentSnapshot> chatHistory = [];

  @override
  void initState() {
    // TODO: implement initState
    slidableController = SlidableController();
    controller.disableEditingWhenNoneSelected = true;
    super.initState();
    userId = auth.currentUser.uid;
  }

  void selectAll() {
    setState(() {
      controller.toggleAll();
      tileColor = Colors.grey;
    });
  }

  deleteAll()async{
    chatHistory.forEach((element) async{
      await FirebaseFirestore.instance
          .collection("Pet")
          .doc(element.data()['petId'])
          .update({
        'chattedWith':
        FieldValue.arrayRemove([userId])
      });
      String groupChatId =
          '${element.data()['ownerId']}-$userId';
      print("GroupChatId : $groupChatId");
      QuerySnapshot snappy =
          await FirebaseFirestore.instance
          .collection("messages")
          .doc("$groupChatId")
          .collection("$groupChatId")
          .get();
      snappy.docs.forEach((element) {
        element.reference.delete();
      });
    });
    chatHistory.clear();
    setState(() {
      controller.deselectAll();
      controller.set(chatHistory.length);
      controller.deselectAll();
      tileColor = bgColor;
    });
    Navigator.pop(context);
  }

  getChatHistory() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('User')
        .doc(auth.currentUser.uid)
        .get();
    Map<String, dynamic> data = snap.data();
    chattedWith = data.containsKey('chattedWith') ? data['chattedWith'] : [];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 1.25,
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
            child: FSearch(
              height: 40.0,
              backgroundColor: Colors.white,
              suffixes: [
                Padding(
                  padding: EdgeInsets.only(right: 3, left: 10),
                  child: Text(
                    'Recent',
                    style: TextStyle(
                      color: Colors.grey.withOpacity(0.7),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 10, left: 0),
                  child: Icon(
                    Icons.arrow_downward,
                    size: 12,
                    color: Colors.grey.withOpacity(0.7),
                  ),
                ),
              ],
              prefixes: [
                Padding(
                  padding: EdgeInsets.only(right: 10, left: 10),
                  child: Icon(
                    Icons.search,
                    color: Colors.grey.withOpacity(0.7),
                  ),
                )
              ],
              style: TextStyle(color: Colors.grey.withOpacity(0.7)),
              onSearch: (value) {
                /// do something
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10, left: 16, bottom: 10),
            child: Text(
              'Recent Matches',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.pink[900]),
              textAlign: TextAlign.left,
            ),
          ),
          Container(
              padding: EdgeInsets.only(left: 16, right: 10),
              color: Color.fromRGBO(255, 246, 247, 1),
              height: 120,
              width: double.infinity,
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Pet')
                    .where('${auth.currentUser.uid}', isEqualTo: 1)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    int length = snapshot.data.docs.length;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> data =
                            snapshot.data.docs[index].data();
                        var images = data["images"];
                        return SizedBox(
                          height: 100,
                          width: 80,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      User user =
                                          FirebaseAuth.instance.currentUser;
                                      String userId = await user.uid;
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.setString('id', userId);
                                      DocumentSnapshot doc =
                                          await FirebaseFirestore.instance
                                              .collection('User')
                                              .doc(data['ownerId'])
                                              .get();
                                      var ownerImage = doc['images'];
                                      Navigator.of(context).pushNamed('/chat',
                                          arguments: RouteArgument(
                                              param1: data['ownerId'],
                                              param2: ownerImage.length > 0
                                                  ? doc['images'][0]
                                                  : 'default',
                                              param3:
                                                  doc['firstName'] ?? 'User'));
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.pink, width: 1),
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                      child: CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(images[0]),
                                        radius: 30,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 20,
                                    height: 20,
                                    padding: EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Image.asset(
                                      "assets/2x/Icon awesome-heart@2x.png",
                                    ),
                                  ),
                                ],
                                alignment: Alignment.bottomRight,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 5, left: 10, bottom: 5),
                                child: Text(
                                  data['name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      backgroundColor: Colors.pink,
                    ),
                  );
                },
              )),
          Divider(
            height: 2,
            color: Colors.black12,
          ),
          Padding(
            padding: EdgeInsets.only(top: 10, left: 16, bottom: 10),
            child: Row(
              children: [
                Text(
                  'Chats',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.pink[900]),
                  textAlign: TextAlign.left,
                ),
                Spacer(),
                controller.isSelecting
                    ? Row(
                      children: [
                        IconButton(
                            icon: Icon(Icons.select_all_sharp),
                            onPressed: selectAll,
                          ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: (){
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text(
                                      "Delete Chats",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                      ),
                                    ),
                                    content: Text(
                                      "Are your Sure",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                      ),
                                    ),
                                    elevation: 5,
                                    contentPadding: EdgeInsets.all(10),
                                    actions: [
                                      FlatButton(
                                        onPressed: () {
                                          setState(() {
                                            controller.isSelecting = false;
                                            tileColor = bgColor;
                                          });
                                          Navigator.of(context).pop();
                                        },
                                        height: 40,
                                        color: Colors.white,
                                        child: Text(
                                          "No",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      FlatButton(
                                        onPressed: deleteAll,
                                        color: Colors.white,
                                        height: 40,
                                        child: Text(
                                          "Yes",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                });
                          },
                        ),
                      ],
                    )
                    : Container(),
              ],
            ),
          ),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('Pet')
                .where('chattedWith', arrayContains: userId)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                chatHistory = snapshot.data.docs;
                int length = snapshot.data.docs.length;
                print("Chat History Length : $length");
                controller.set(length);
                return Expanded(
                  child: ListView.builder(
                    itemCount: length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> data =
                          snapshot.data.docs[index].data();
                      var petImages = data['images'];
                      return MultiSelectItem(
                        isSelecting: controller.isSelecting,
                        onSelected: () {
                          setState(() {
                            controller.toggle(index);
                          });
                        },
                        child: Slidable(
                          actionPane: SlidableStrechActionPane(),
                          key: UniqueKey(),
                          dismissal: SlidableDismissal(
                            child: SlidableDrawerDismissal(),
                            onDismissed: (actionType) {
                              setState(() {
                                snapshot.data.docs.removeAt(index);
                              });
                            },
                          ),
                          secondaryActions: <Widget>[
                            Container(
                                padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                                child: IconSlideAction(
                                  caption: 'Delete',
                                  color: Colors.red,
                                  icon: Icons.delete,
                                  onTap: () async {
                                    //showDeleteDialog();
                                    await FirebaseFirestore.instance
                                        .collection("Pet")
                                        .doc(snapshot.data.docs[index]
                                            .data()['petId'])
                                        .update({
                                      'chattedWith':
                                          FieldValue.arrayRemove([userId])
                                    });
                                    String groupChatId =
                                        '${snapshot.data.docs[index].data()['ownerId']}-$userId';
                                    print("GroupChatId : $groupChatId");
                                    QuerySnapshot snappy =
                                        await FirebaseFirestore.instance
                                            .collection("messages")
                                            .doc("$groupChatId")
                                            .collection("$groupChatId")
                                            .get();
                                    snappy.docs.forEach((element) {
                                      element.reference.delete();
                                    });
                                    setState(() {
                                      snapshot.data.docs.removeAt(index);
                                    });
                                  },
                                )),
                          ],
                          child: InkWell(
                            onTap: () async {
                              User user = FirebaseAuth.instance.currentUser;
                              String userId = await user.uid;
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setString('id', userId);
                              DocumentSnapshot doc = await FirebaseFirestore
                                  .instance
                                  .collection('User')
                                  .doc(data['ownerId'])
                                  .get();
                              var ownerImage = doc['images'];
                              Navigator.of(context).pushNamed('/chat',
                                  arguments: RouteArgument(
                                      param1: data['ownerId'],
                                      param2: ownerImage.length > 0
                                          ? doc['images'][0]
                                          : 'default',
                                      param3: doc['firstName'] ?? 'User'));
                            },
                            child: Column(
                              children: [
                                Container(
                                  // width: double.infinity,
                                  height: 70,
                                  child: ListTile(
                                    tileColor: tileColor,
                                    trailing: IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: ()async{
                                        await FirebaseFirestore.instance
                                            .collection("Pet")
                                            .doc(snapshot.data.docs[index]
                                            .data()['petId'])
                                            .update({
                                          'chattedWith':
                                          FieldValue.arrayRemove([userId])
                                        });
                                        String groupChatId =
                                            '${snapshot.data.docs[index].data()['ownerId']}-$userId';
                                        print("GroupChatId : $groupChatId");
                                        QuerySnapshot snappy =
                                        await FirebaseFirestore.instance
                                            .collection("messages")
                                            .doc("$groupChatId")
                                            .collection("$groupChatId")
                                            .get();
                                        snappy.docs.forEach((element) {
                                          element.reference.delete();
                                        });
                                        setState(() {
                                          snapshot.data.docs.removeAt(index);
                                        });
                                      },
                                    ),
                                    title: Text(
                                      data['name'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    /*subtitle: Text(
                                      'Lorem Ipsum is simply dummy text of the printing and typesetting industry. ',
                                      style: TextStyle(
                                        fontSize: 13,
                                      ),
                                    ),*/
                                    leading: SizedBox(
                                      height: 100,
                                      width: 55,
                                      child: Stack(
                                        alignment: Alignment.bottomRight,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.pink, width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                            ),
                                            child: CircleAvatar(
                                              radius: 60,
                                              backgroundImage:
                                                  NetworkImage(petImages[0]),
                                            ),
                                          ),
                                          Container(
                                            width: 20,
                                            height: 20,
                                            padding: EdgeInsets.all(3),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            child: Image.asset(
                                              "assets/2x/Icon awesome-heart@2x.png",
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 3,),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.pink,
                    strokeWidth: 2,
                  ),
                );
              } else {
                return Container();
              }
            },
          ),
        ],
      ),
    );
  }
}

/*Dismissible(
                        key: UniqueKey(),
                        background: Container(color: Colors.red[700]),
                        direction: DismissDirection.horizontal,
                        onDismissed: (direction)async{
                          await FirebaseFirestore.instance.collection("Pet").doc(snapshot.data.docs[index].data()['petId']).update(
                              {
                                'chattedWith' : FieldValue.arrayRemove([userId])
                              });
                          //setState(() {
                            snapshot.data.docs.removeAt(index);
                          //});
                        },
                        child: InkWell(
                          onTap: ()async{
                            User user =
                                FirebaseAuth.instance.currentUser;
                            String userId = await user.uid;
                            SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                            await prefs.setString('id', userId);
                            DocumentSnapshot doc =
                            await FirebaseFirestore.instance
                                .collection('User')
                                .doc(data['ownerId'])
                                .get();
                            var ownerImage = doc['images'];
                            Navigator.of(context).pushNamed('/chat',
                                arguments: RouteArgument(
                                    param1: data['ownerId'],
                                    param2: ownerImage.length > 0
                                        ? doc['images'][0]
                                        : 'default',
                                    param3:
                                    doc['firstName'] ?? 'User'));
                          },
                          child: Container(
                            // width: double.infinity,
                            height: 70,
                            child: ListTile(
                              title: Text(
                                data['name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              /*subtitle: Text(
                                'Lorem Ipsum is simply dummy text of the printing and typesetting industry. ',
                                style: TextStyle(
                                  fontSize: 13,
                                ),
                              ),*/
                              leading: SizedBox(
                                height: 100,
                                width: 55,
                                child: Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.pink, width: 1),
                                        borderRadius: BorderRadius.circular(100),
                                      ),
                                      child: CircleAvatar(
                                        radius: 60,
                                        backgroundImage: NetworkImage(petImages[0]),
                                      ),
                                    ),
                                    Container(
                                      width: 20,
                                      height: 20,
                                      padding: EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20)),
                                      child: Image.asset(
                                        "assets/2x/Icon awesome-heart@2x.png",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );*/
