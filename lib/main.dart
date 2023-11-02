import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
void main() {
  getMeteoData(0,0);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage()
    );
  }
}

<<<<<<< HEAD
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

Future<bool> _handleLocationPermission() async {
  bool serviceEnabled;
  LocationPermission permission;
  
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Location services are disabled. Please enable the services')));
    return false;
  }
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {   
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')));
      return false;
    }
  }
  if (permission == LocationPermission.deniedForever) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Location permissions are permanently denied, we cannot request permissions.')));
    return false;
  }
  return true;
}

Future<Meteo> getMeteoData(double latitude, double longitude) async {
  if (latitude == 0 && longitude == 0) {
    Position tmpPosition = await Geolocator.getCurrentPosition();
    latitude = tmpPosition.latitude;
    longitude = tmpPosition.longitude;
  }
  final response = await http.get(Uri.parse("https://api.open-meteo.com/v1/forecast?latitude="+latitude.toString()+"&longitude="+longitude.toString()));
=======
Future<Meteo> getMeteoData() async {
  final response = await http.get(Uri.parse('https://api.open-https://open-meteo.com/en/docs/ecmwf-api#latitude=40.7967&longitude=14.0735&hourly=temperature_2m.com/v1/ecmwf?'));
>>>>>>> a3bcaf77b2e305998e8c03ee02eaf6d487e5275c
  if (response.statusCode == 200) {
    return Meteo.fromJson(jsonDecode(response.body) as Map<String,dynamic>);
  } else {
    print(response);
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
