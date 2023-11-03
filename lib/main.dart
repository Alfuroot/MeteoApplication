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
    return const MaterialApp(
      home: HomePage()
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late Future<Position> position;
  late Future<Meteo> meteoData;
  @override
    void initState() {
      super.initState();
      // this should not be done in build method.
      meteoData = getMeteoData();
    }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FutureBuilder(
          future: Future.wait([getLocality(),getMeteoData()]),
          builder: (ctx, snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 3,
                    width: MediaQuery.of(context).size.width,
                    child: const Image(image: AssetImage("assets/sunbg.jpg"),
                    )
                  ),
                  Text(snapshot.data?.first.toString() ?? "Permission for geolocalization was denied"),
                  Text(meteoData.toString()),
                ]
              );
            } else {
                return const Center(
            child: CircularProgressIndicator(),
            );
            }
          }, 
        ),
      ),
    );
  }

  Widget displayImage(String imagePath) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 3,
      child: Expanded(
          child: Container(
            margin: const EdgeInsets.only(top: 20, right: 50),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30)),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
      ),
    );
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
    return position;
  }

  Future<String?> getLocality() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    return placemarks.first.locality;
  }

  Future<Meteo> getMeteoData() async {
    Position tmpPosition = await determinePosition();
    final response = await http.get(Uri.parse("https://api.open-meteo.com/v1/forecast?latitude=${tmpPosition.latitude}&longitude=${tmpPosition.longitude}&hourly=temperature_2m,precipitation_probability&forecast_days=1"));
    if (response.statusCode == 200) {
      return Meteo.fromJson(jsonDecode(response.body) as Map<String,dynamic>);
    } else {
      throw Exception('Failed to load');
    }
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
