import 'dart:async';
import 'dart:convert';
//import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MapsUtil {
  static MapsUtil _instance = new MapsUtil.internal();

  MapsUtil.internal();

  factory MapsUtil() => _instance;

  Future<String> getAddressName(LatLng location, String apiKey) async {
    try {
      var endPoint =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=${location?.latitude},${location?.longitude}&language=en&key=AIzaSyC3YYz8jqvHY3Yup1lzIdlU51FsjHKH5yE';
     // var response = jsonDecode((await http.get(endPoint, headers: await LocationUtils.getAppHeaders())).body);
      //return response['results'][0]['formatted_address'];
    } catch (e) {
      print(e);
      return null;
    }
  }
}