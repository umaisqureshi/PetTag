import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:pett_tagg/loc/home.dart';
import 'package:pett_tagg/screens/my_map.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';
import 'model/choose.dart';
import 'repo/route_argument.dart';
import 'controller/chat_controller.dart';
import 'package:pett_tagg/utilities/firebase_credentials.dart';
import 'package:lottie/lottie.dart';

class Chat extends StatefulWidget {
  final RouteArgument routeArgument;

  Chat({Key key, @required this.routeArgument}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> with TickerProviderStateMixin {
  AnimationController _controller;
  String userId;
  num userLat;
  num userLng;

  getSharedLocationStatus() async {
    userId = FirebaseCredentials().auth.currentUser.uid;
    FirebaseFirestore.instance
        .collection("User")
        .doc(userId)
        .snapshots()
        .listen((value) {
      if (value.data().containsKey("isLocationShared")) {
        if (value.data()["isLocationShared"]) {
          setState(() {
            _controller.repeat();
          });
        }
      }
      userLat = value.data()['latitude'];
      userLng = value.data()['longitude'];
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(vsync: this);
    getSharedLocationStatus();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 1.0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Material(
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
            clipBehavior: Clip.hardEdge,
            child: CachedNetworkImage(
              placeholder: (context, url) => Container(
                child: CircularProgressIndicator(
                  strokeWidth: 1.0,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                ),
                padding: EdgeInsets.all(15.0),
              ),
              imageUrl: widget.routeArgument.param2,
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(
          widget.routeArgument.param3,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return MyMap(
                      isVisible: true,
                      isChatSide: true,
                      peerId: widget.routeArgument.param1,
                    );
                  }));
                },
                child: Center(
                  child: Text(
                    "Find Nearest Park",
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              )
              /*InkWell(
              onTap: ()async{
                //_controller.repeat();
                _controller.isAnimating ? Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return Home(peerId: widget.routeArgument.param1,isChatSide: true,);
                })):
                await FirebaseFirestore.instance.collection('User').doc(widget.routeArgument.param1).set(
                    {
                      'isLocationShared' : true,
                      userId : [userLat, userLng],
                    }, SetOptions(merge: true));
              },
              child: Container(
                width: 30,
                padding: EdgeInsets.all(0),
                child: Lottie.asset(
                  "assets/anim/tower1.json",
                  height: 20,
                  width: 20,
                  repeat: true,
                  controller: _controller,
                  onLoaded: (composition) {
                    // Configure the AnimationController with the duration of the
                    // Lottie file and start the animation.
                    _controller..duration = composition.duration
                      ..forward();
                  },
                ),
              ),
            ),*/
              ),
          /*GestureDetector(
            child: Container(
                padding: EdgeInsets.only(
                  right: 30,
                  left: 15,
                ),
                child: Image.asset(
                  "assets/2x/Icon material-location-on@2x.png",
                  width: 17,
                  height: 17,
                )),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return Home(peerId: widget.routeArgument.param1,isChatSide: true,);
              }));
            },
          ),*/
        ],
      ),
      body: ChatScreen(
        peerId: widget.routeArgument.param1,
        peerAvatar: widget.routeArgument.param2,
        peerName: widget.routeArgument.param3,
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String peerId;
  final String peerAvatar;
  final String peerName;

  ChatScreen(
      {Key key,
      @required this.peerId,
      @required this.peerAvatar,
      @required this.peerName})
      : super(key: key);

  @override
  State createState() => ChatScreenState(
      peerId: peerId, peerAvatar: peerAvatar, peerName: peerName);
}

class ChatScreenState extends StateMVC<ChatScreen> {
  String peerId;
  String peerAvatar;
  final String peerName;
  ChatController _con;

  ChatScreenState(
      {Key key,
      @required this.peerId,
      @required this.peerAvatar,
      @required this.peerName})
      : super(ChatController()) {
    this._con = controller;
  }

  updateStatus(status) async {
    await FirebaseCredentials()
        .db
        .collection('token')
        .doc(FirebaseCredentials().auth.currentUser.uid)
        .set({
      "isOnline": status,
    }, SetOptions(merge: true));
  }

  @override
  void initState() {
    super.initState();
    _con.focusNode.addListener(_con.onFocusChange);
    _con.listScrollController.addListener(_con.scrollListener);
    _con.init(peerId);
    updateStatus(true);
  }

  @override
  void dispose() async {
    super.dispose();
    updateStatus(false);

    _con.onBackPress();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            // List of messages
            _con.buildListMessage(peerAvatar),
            _con.buildInput(peerId),
          ],
        ),
        _con.buildLoading()
      ],
    );
  }
}
