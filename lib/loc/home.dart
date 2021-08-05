import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as LocationManager;
import 'place_detail.dart';
import 'dart:ui' as ui;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:pett_tagg/utilities/firebase_credentials.dart';
import 'package:pett_tagg/loc/distanceCal.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mp;

//AIzaSyABFmjpW4zSizocefrOcxVOXjzr0kZNsmM
//AIzaSyAyhBpPOOUcNw1QfFjZPI8Nn0xTNB-h2oo
//AIzaSyDtzjTg8cKhyOErBj9UZwO8eMwM8SACIaY

const kGoogleApiKey = "AIzaSyDhEKPfktjxZocQFdTCO0DECINwBsk60E0";
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

class Home extends StatefulWidget {
  String peerId;
  bool isChatSide;

  Home({this.peerId, this.isChatSide});

  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> {
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  GoogleMapController mapController;
  List<PlacesSearchResult> places = [];
  bool isLoading = false;
  String errorMessage;
  Set<Marker> _markers = Set<Marker>();
  Set<Circle> circles;
  int radius = 20000;
  double raaaadius;

  NumberPicker integerInfiniteNumberPicker;
  NumberPicker decimalNumberPicker;
  Uint8List imageMarker;

  getImageMarker() async {
    imageMarker = await getByteFromAsset('assets/logo.png', 120);
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

  getRadius() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    radius = prefs.containsKey('radius') ? prefs.getInt('radius') : 1;
  }

  setRadius(int radius) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('radius', radius);
  }

  Future _showDoubleDialog() async {
    await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return new NumberPickerDialog.integer(
          minValue: 1,
          maxValue: 1000,
          step: 1,
          selectedTextStyle: TextStyle(
              color: Colors.pink, fontSize: 20, fontWeight: FontWeight.bold),
          textStyle: TextStyle(color: Colors.black),
          initialIntegerValue: radius,
          title: new Text(
            "Choose Distance in km",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 17,
            ),
          ),
        );
      },
    ).then((num value) {
      if (value != null) {
        setState(() {
          radius = int.parse((value).toString());
          setRadius(radius);
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getImageMarker();
    getRadius();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    mapController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget expandedChild;
    if (isLoading) {
      expandedChild = Center(child: CircularProgressIndicator(value: null));
    } else if (errorMessage != null) {
      expandedChild = Center(
        child: Text(errorMessage),
      );
    } else {
      expandedChild = buildPlacesList();
    }

    return Scaffold(
        key: homeScaffoldKey,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Stack(
                children: [
                  Container(
                    child: SizedBox(
                      height: 400,
                      child: GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(0.0, 0.0),
                          zoom: 10.0,
                        ),
                        myLocationEnabled: true,
                        markers: _markers,
                        circles: circles,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    top: 10,
                    child: InkWell(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.white,
                        ),
                        child: Icon(Icons.arrow_back, color: Colors.pink, size: 20,),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(child: expandedChild),

            ],
          ),
        ));
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

  void refresh() async {
    final center = await getUserLocation();
    final peerCenter = await getPeerLocation();
    final midPoints = await findMidPoint(center.latitude, center.longitude,
        peerCenter.latitude, peerCenter.longitude);

    raaaadius = mp.SphericalUtil.computeDistanceBetween(
        mp.LatLng(midPoints.latitude, midPoints.longitude),
        mp.LatLng(center.latitude, center.longitude));
    raaaadius = 20000;
    print("Raaaaadius : $raaaadius");
    /*DistanceCal dis = await fetchCartList(
        midPoints,
        center,
        "AIzaSyABFmjpW4zSizocefrOcxVOXjzr0kZNsmM");*/

    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: peerCenter == null ? LatLng(0, 0) : peerCenter, zoom: 10)));
    getNearbyPlaces(peerCenter);
  }

  void refreshForPetDetail() async {
    final center = await getUserLocation();
    //final peerCenter = await getPeerLocation();
    //final midPoints = await findMidPoint(center.latitude, center.longitude, peerCenter.latitude, peerCenter.longitude);

    /*DistanceCal dis = await fetchCartList(
        midPoints,
        center,
        "AIzaSyABFmjpW4zSizocefrOcxVOXjzr0kZNsmM");*/

    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: center == null ? LatLng(0, 0) : center, zoom: 10)));
    getNearbyPlaces(center);
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    if (widget.isChatSide) {
      refresh();
    } else {
      refreshForPetDetail();
    }
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

  Future<LatLng> findMidPoint(lat1, lon1, lat2, lon2) async {
    final latMid = (lat1 + lat2) / 2;
    final lonMid = (lon1 + lon2) / 2;
    return LatLng(latMid, lonMid);
  }

  void getNearbyPlaces(LatLng center) async {
    setState(() {
      this.isLoading = true;
      this.errorMessage = null;
    });

    print("Peer ID : ${widget.peerId}");
    //final peerCenter = await getPeerLocation();
    //final midPoints = await findMidPoint(center.latitude, center.longitude, peerCenter.latitude, peerCenter.longitude);

    final location = Location(center.latitude, center.longitude);
    circles = Set.from([
      Circle(
        circleId: CircleId("mainCircles"),
        center: LatLng(center.latitude, center.longitude),
        radius: (double.parse(widget.isChatSide
            ? raaaadius.toString()
            : (radius * 1000).toString())),
        fillColor: Color.fromRGBO(171, 39, 133, 0.1),
        strokeColor: Color.fromRGBO(171, 39, 133, 0.5),
        strokeWidth: 5,
      )
    ]);
    final result = await _places.searchNearbyWithRadius(
        location, widget.isChatSide ? raaaadius : radius * 1000,
        type: 'park');
    setState(() {
      this.isLoading = false;
      if (result.status == "OK") {
        this.places = result.results;
        result.results.forEach((f) async {
          String id = await f.placeId;
          print("Marker ID : $id");
          _markers.add(Marker(
            icon: BitmapDescriptor.fromBytes(imageMarker),
            markerId: MarkerId(id),
            position: LatLng(f.geometry.location.lat, f.geometry.location.lng),
            visible: true,
            infoWindow: InfoWindow(
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

  void onError(PlacesAutocompleteResponse response) {
    homeScaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(response.errorMessage)),
    );
  }

  Future<void> _handlePressButton() async {
    try {
      final center = await getUserLocation();
      Prediction p = await PlacesAutocomplete.show(
          context: context,
          strictbounds: center == null ? false : true,
          apiKey: kGoogleApiKey,
          onError: onError,
          mode: Mode.fullscreen,
          language: "en",
          location: center == null
              ? null
              : Location(center.latitude, center.longitude),
          radius: center == null ? null : 10000);

      showDetailPlace(p.placeId);
    } catch (e) {
      return;
    }
  }

  Future<Null> showDetailPlace(String placeId) async {
    if (placeId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PlaceDetailWidget(placeId)),
      );
    }
  }

  ListView buildPlacesList() {
    final placesWidget = places.map((f) {
      List<Widget> list = [
        Padding(
          padding: EdgeInsets.only(bottom: 4.0),
          child: Text(
            f.name,
            style: Theme.of(context).textTheme.subtitle,
          ),
        )
      ];
      if (f.formattedAddress != null) {
        list.add(Padding(
          padding: EdgeInsets.only(bottom: 2.0),
          child: Text(
            f.formattedAddress,
            style: Theme.of(context).textTheme.subtitle,
          ),
        ));
      }

      if (f.vicinity != null) {
        list.add(Padding(
          padding: EdgeInsets.only(bottom: 2.0),
          child: Text(
            f.vicinity,
            style: Theme.of(context).textTheme.body1,
          ),
        ));
      }

      if (f.types?.first != null) {
        list.add(Padding(
          padding: EdgeInsets.only(bottom: 2.0),
          child: Text(
            f.types.first,
            style: Theme.of(context).textTheme.caption,
          ),
        ));
      }

      return Padding(
        padding: EdgeInsets.only(top: 4.0, bottom: 4.0, left: 8.0, right: 8.0),
        child: Card(
          child: InkWell(
            onTap: () {
              showDetailPlace(f.placeId);
            },
            highlightColor: Colors.lightBlueAccent,
            splashColor: Colors.red,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: list,
              ),
            ),
          ),
        ),
      );
    }).toList();

    return ListView(shrinkWrap: true, children: placesWidget);
  }
}
