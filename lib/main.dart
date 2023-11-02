import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
 
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    getMeteoData(0,0);
    return MaterialApp(
      home: const HomePage()
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final String place = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("aaaa"),
      ),
    );
  }
}

Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    permission = await Geolocator.checkPermission();
    permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }


    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
    print(position);

    return await Geolocator.getCurrentPosition();
  }

Future<Meteo> getMeteoData(double latitude, double longitude) async {
  if (latitude == 0 && longitude == 0) {
    Position tmpPosition = await determinePosition();
    latitude = tmpPosition.latitude;
    longitude = tmpPosition.longitude;
  }
  final response = await http.get(Uri.parse("https://api.open-meteo.com/v1/forecast?latitude="+latitude.toString()+"&longitude="+longitude.toString()));
  if (response.statusCode == 200) {
    return Meteo.fromJson(jsonDecode(response.body) as Map<String,dynamic>);
  } else {
    throw Exception('Failed to load');
  }
}

class Meteo {
  final double lat;
  final double long;
  final String timezone;
  final String timezoneAbbreviation;

  const Meteo ({
    required this.lat,
    required this.long,
    required this.timezone,
    required this.timezoneAbbreviation,
  }); 

  factory Meteo.fromJson(Map<String, dynamic> json) {
    return Meteo(
      lat: json['latitude'] as double,
      long: json['longitude'] as double,
      timezone: json['timezone'] as String,
      timezoneAbbreviation: json['timezone_abbreviation'] as String,
    );
  }
}
