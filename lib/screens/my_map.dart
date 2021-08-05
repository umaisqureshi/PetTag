import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pett_tagg/geo_firestore/geo_firestore.dart';
import 'package:pett_tagg/geo_firestore/geo_utils.dart';
import 'package:pett_tagg/repo/settingRepo.dart';
import 'package:flutter/material.dart';
import 'package:pett_tagg/utilities/helper.dart';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:pett_tagg/utilities/firebase_credentials.dart';
import 'package:location/location.dart' as LocationManager;
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'dart:ui' as ui;
import '../main.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mp;

class MyMap extends StatefulWidget {
  bool isVisible;
  String peerId;
  bool isChatSide;

  MyMap({this.isVisible, this.isChatSide, this.peerId});

  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  Set<Marker> _markers = Set<Marker>();
  int radius = 50;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  CameraUpdate cameraUpdate;
  GoogleMapController mapController;
  Set<Circle> circles;
  NumberPicker integerInfiniteNumberPicker;
  NumberPicker decimalNumberPicker;
  bool isLeft;
  String petId;
  bool isLoading = false;
  String errorMessage = '';
  var rightColors;
  var leftColors;
  var leftIconColor;
  var rightIconColor;
  List<PlacesSearchResult> places = [];
  int raaaadius;

  //AIzaSyCBfQv3UsQhuG8m8iRArEuBBSHoDHVT_sI
  //AIzaSyABFmjpW4zSizocefrOcxVOXjzr0kZNsmM

  GoogleMapsPlaces _placesList =
      GoogleMapsPlaces(apiKey: "AIzaSyDhEKPfktjxZocQFdTCO0DECINwBsk60E0");

  Uint8List imageMarker;

  getImageMarker() async {
    imageMarker = await getByteFromAsset('assets/logo.png', 200);
  }

  static Future<Uint8List> getByteFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  Future<LatLng> getUserLocation() async {
    final location = LocationManager.Location();
    LocationManager.LocationData locationData;
    try {
      locationData = await location.getLocation();
      final lat = locationData.latitude;
      final lng = locationData.longitude;
      final center = LatLng(lat, lng);
      return center;
    } on Exception {
      locationData = null;
      return null;
    }
  }

  Future<LatLng> getPeerLocation() async {
    var snap = await FirebaseCredentials()
        .db
        .collection('User')
        .doc(widget.peerId)
        .get();
    return LatLng(snap.data()['latitude'], snap.data()['longitude']);
  }

  getLoc(BuildContext context) async {
    await getCurrentLocation().then((value) async {
      if (!value.isUnknown()) {
        var _coord = LatLng(value.latitude, value.longitude);
        cameraUpdate = CameraUpdate.newCameraPosition(CameraPosition(
          target: _coord,
          zoom: getZoomLevel(
              (GeoUtils.capRadius(double.parse(radius.toString())) * 1000)),
        ));
        GeoFirestore geoFirestore =
            GeoFirestore(FirebaseCredentials().db.collection('User'));
        final queryLocation = GeoPoint(value.latitude, value.longitude);
        final List<DocumentSnapshot> documents =
            await geoFirestore.getAtLocation(
                queryLocation, double.parse(radius.toString()) * 1000);
        documents.forEach((document) async {
          if (documents.isNotEmpty) {
            await _setMarkers(document, context);
          }
        });
        if (mounted) setState(() {});
      }
    });
  }

  getRadius() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    radius = prefs.containsKey('radius') ? prefs.getInt('radius') : 10;
  }

  setRadius(int radius) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('radius', radius);
  }

  // ignore: missing_return
  getCorrespondingPet(String petId) async {
    DocumentSnapshot shot =
        await FirebaseFirestore.instance.collection("Pet").doc(petId).get();
    return shot.data()['images'][0];
  }

  Future<void> _setMarkers(DocumentSnapshot point, context) async {
    String imageUrl;
    petId = point['pet'][0];
    imageUrl = await getCorrespondingPet(point['pet'][0]);

    await Helper.getMarkerImage(point, context, imageUrl, point['pet'][0])
        .then((marker) {
      setState(() {
        _markers.add(marker);
      });
    });
  }

  void refreshForPetDetail() async {
    final center = await getUserLocation();
    getNearbyPlaces(center);
  }

  void refresh() async {
    final peerCenter = await getPeerLocation();
    getNearbyPlaces(peerCenter);
  }

  void getNearbyPlaces(LatLng center) async {
    setState(() {
      this.isLoading = true;
      this.errorMessage = null;
    });

    final location = Location(center.latitude, center.longitude);
    final result =
        await _placesList.searchNearbyWithRadius(location, 50000, type: 'park');

    setState(() {
      this.isLoading = false;
      if (result.status == "OK") {
        this.places = result.results;
        result.results.forEach((f) async {
          String id = await f.placeId;
          _markers.add(Marker(
            // icon: BitmapDescriptor.fromBytes(imageMarker),
            icon: BitmapDescriptor.defaultMarker,
            markerId: MarkerId(id),
            position: LatLng(f.geometry.location.lat, f.geometry.location.lng),
            visible: true,
            infoWindow: InfoWindow(
                onTap: () {
                  /*showDialog(
                      context: context,
                      builder: (context) {
                        return Container(
                          height: 300,
                          width: 400,
                          child: Dialog(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Share with:",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.pink,
                                            fontSize: 15),
                                      ),
                                      InkWell(
                                        onTap: () => Navigator.of(context).pop(),
                                        child: Icon(
                                          Icons.cancel_outlined,
                                          color: Colors.black,
                                          size: 24,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: (){

                                      },
                                      child: Container(
                                        height: 130,
                                        width: 100,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: Image.asset(
                                                "assets/logo@3xUpdated.png",
                                                width: 70,
                                                height: 70,
                                              ),
                                            ),
                                            Text(
                                              "PetTag",
                                              style: TextStyle(
                                                color: Colors.red[900],
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: (){

                                      },
                                      child: Container(
                                        height: 130,
                                        width: 100,
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(16.0),
                                              child: Image.asset(
                                                "assets/placeholder.png",
                                                height: 60,
                                                width: 60,
                                              ),
                                            ),
                                            Text(
                                              "Google Maps",
                                              style: TextStyle(
                                                color: Colors.red[900],
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: (){

                                      },
                                      child: Container(
                                        height: 130,
                                        width: 100,
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(16.0),
                                              child: Image.asset(
                                                "assets/shareIcon.png",
                                                width: 60,
                                                height: 60,
                                              ),
                                            ),
                                            Text(
                                              "Other Apps",
                                              style: TextStyle(
                                                color: Colors.red[900],
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      });*/
                },
                title: f.name,
                snippet:
                    "Ratings : ${f.rating != null ? f.rating.toString() : '0'}"),
          ));
        });
      } else {
        this.errorMessage = result.errorMessage;
      }
    });
  }

  double getZoomLevel(double radius) {
    double zoomLevel = 11;
    if (radius > 0) {
      double radiusElevated = radius + radius / 2;
      double scale = radiusElevated / 500;
      zoomLevel = 16 - math.log(scale) / math.log(2);
    }
    zoomLevel = num.parse(zoomLevel.toStringAsFixed(2));
    return zoomLevel;
  }

  Future _showDoubleDialog() async {
    await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return new NumberPickerDialog.integer(
          minValue: 1,
          maxValue: 1000,
          step: 1,
          initialIntegerValue: radius,
          title: new Text(
            "Choose Distance in km",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      },
    ).then((num value) {
      if (value != null) {
        setState(() {
          radius = value;
          setRadius(radius);
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getRadius();
    if (mounted) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          cameraUpdate = CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(0.0, 0.0),
            zoom: 18,
          ));
        });
        getLoc(context);
      });
    }
  }

  @override
  void dispose() {
    _markers.clear();
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          extendBodyBehindAppBar: true,
          key: _scaffoldKey,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            centerTitle: true,
            title: Stack(
              children: [
                Container(
                  height: 35,
                  width: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                Positioned(
                  left: 4,
                  top: 4,
                  bottom: 4,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        leftColors = Colors.pink;
                        widget.isVisible = true;
                        rightColors = Colors.white;
                        rightIconColor = Colors.black12;
                        leftIconColor = Colors.white;
                        FirebaseFirestore.instance
                            .collection("User")
                            .doc(FirebaseAuth.instance.currentUser.uid)
                            .update({
                          'visible': true,
                        });
                        FirebaseFirestore.instance
                            .collection("Pet")
                            .doc(petId)
                            .update({
                          'visible': true,
                        });
                      });
                    },
                    child: Container(
                      width: 41,
                      height: 33,
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: widget.isVisible
                            ? Colors.pink
                            : Colors.white ?? Colors.pink,
                      ),
                      child: Image.asset(
                        "assets/visiblePet.png",
                        height: 15,
                        width: 15,
                        color: leftIconColor ?? Colors.white,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 4,
                  top: 4,
                  bottom: 4,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        rightColors = Colors.pink;
                        rightIconColor = Colors.white;
                        leftIconColor = Colors.black12;
                        leftColors = Colors.white;
                        widget.isVisible = false;
                        FirebaseFirestore.instance
                            .collection("User")
                            .doc(FirebaseAuth.instance.currentUser.uid)
                            .update({
                          'visible': false,
                        });
                        FirebaseFirestore.instance
                            .collection("Pet")
                            .doc(petId)
                            .update({
                          'visible': true,
                        });
                      });
                    },
                    child: Container(
                      width: 41,
                      height: 33,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: widget.isVisible
                            ? Colors.white
                            : Colors.pink ?? Colors.white,
                      ),
                      child: Image.asset(
                        "assets/invisiblePet.png",
                        height: 15,
                        width: 15,
                        color: rightIconColor ?? Colors.black12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              /*Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: GestureDetector(
                    child: Container(
                      height: 10,
                      width: 35,
                      decoration: BoxDecoration(
                          color: Colors.pink,
                          borderRadius: BorderRadius.circular(30)),
                      child: Icon(Icons.person),
                    ),
                  ))*/
            ],
          ),
          //drawer: Drawerr(),
          body: Stack(
            children: [
              GoogleMap(
                //circles: circles,
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                  widget.isChatSide ? refresh() : refreshForPetDetail();
                  mapController.animateCamera(cameraUpdate);
                },
                initialCameraPosition: CameraPosition(
                  target: LatLng(0.0, 0.0),
                  zoom: 18,
                ),
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                  new Factory<OneSequenceGestureRecognizer>(
                    () => new EagerGestureRecognizer(),
                  ),
                ].toSet(),
                mapType: MapType.normal,
                markers: _markers,
                myLocationEnabled: false,
              ),

              /*Positioned(
                left: 10,
                bottom: 10,
                child: FloatingActionButton.extended(
                  heroTag: "chooseDistanceBtn",
                  onPressed: () async{
                    await _showDoubleDialog();
                    getRadius();
                    print("Radius Value : $radius");
                    getLoc(context);
                  },
                  label: Text(
                    'Choose Distance',
                  ),
                  icon: Icon(
                    Icons.location_searching,
                    color: Colors.white,
                  ),
                ),
              )*/
            ],
          )),
    );
  }
}
