import 'dart:async';
import 'dart:convert';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pett_tagg/models/address.dart' as adrs;
import 'package:pett_tagg/utilities/maps_util.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<dynamic> setCurrentLocation() async {
  var location = new Location();
   MapsUtil mapsUtil = new MapsUtil();
  final whenDone = new Completer();
  adrs.Address _address = new adrs.Address();
  location.requestService().then((value) async {
    location.getLocation().then((_locationData) async {
     /* String _addressName = await mapsUtil.getAddressName(
          new LatLng(_locationData?.latitude, _locationData?.longitude),
          'AIzaSyC3YYz8jqvHY3Yup1lzIdlU51FsjHKH5yE');*/
      final coordinates =
          new Coordinates(_locationData.latitude, _locationData.longitude);
      var addresses =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);
      var first = addresses.first;
      _address = adrs.Address.fromJSON({
        'address': first.addressLine,
        'latitude': _locationData?.latitude,
        'longitude': _locationData?.longitude
      });
      await changeCurrentLocation(_address);
      whenDone.complete(_address);
    }).timeout(Duration(seconds: 10), onTimeout: () async {
      await changeCurrentLocation(_address);
      whenDone.complete(_address);
      return null;
    }).catchError((e) {
      whenDone.complete(_address);
      return null;
    });
  });
  return whenDone.future;
}

Future<adrs.Address> changeCurrentLocation(adrs.Address _address) async {
  if (!_address.isUnknown()) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('address', json.encode(_address.toMap()));
  }
  return _address;
}

Future<adrs.Address> getCurrentLocation() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //await prefs.clear();
  if (prefs.containsKey('address')) {
    return adrs.Address.fromJSON(json.decode(prefs.getString('address')));
  } else {
    return adrs.Address.fromJSON({});
  }
}
