import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
void main() {
  getMeteoData();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(children: [
            Image.asset("assets/clouds.png"),
          ],)
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key})
}

Future<Meteo> getMeteoData() async {
  final response = await http.get(Uri.parse('https://api.open-https://open-meteo.com/en/docs/ecmwf-api#latitude=40.7967&longitude=14.0735&hourly=temperature_2m.com/v1/ecmwf?'));
  if (response.statusCode == 200) {
    return Meteo.fromJson(jsonDecode(response.body) as Map<String,dynamic>);
  } else {
    throw Exception('Failed to load');
  }
}

class Meteo {
  final double latitude;
  final double longitude;
  final String timezone;
  final String timezoneAbbreviation;

  const Meteo ({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.timezoneAbbreviation,
  }); 

  factory Meteo.fromJson(Map<String, dynamic> json) {
    return Meteo(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      timezone: json['timezone'] as String,
      timezoneAbbreviation: json['timezone_abbreviation'] as String,
    );
  }
}