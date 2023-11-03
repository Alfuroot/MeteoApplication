import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      theme: ThemeData(
        primaryColor: Colors.blue, // Set the primary color
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Position> position;
  late Future<Meteo> meteoData;
  late Meteo meteo = Meteo();

  @override
  void initState() {
    super.initState();
    meteoData = getMeteoData(meteo);
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: FutureBuilder(
      future: Future.wait([getLocality(), getMeteoData(meteo)]),
      builder: (ctx, snapshot) {
        if (snapshot.hasData) {
          return Stack(
            children: [
              // Background Image taking more space
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/sunbg.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              // Top Text Overlapping the Background Image
              Positioned(
                top: MediaQuery.of(context).size.height * 0.3, // Adjust the top position as needed
                left: MediaQuery.of(context).size.width * 0.35, // Adjust the left position as needed
                child: Text(
                  snapshot.data?[0].toString() ?? "Permission for geolocalization was denied",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              // Content Container
              Positioned(
                top: MediaQuery.of(context).size.height / 3,
                left: 0,
                right: 0,
                bottom: 0,
                child: ListView(
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // Adjust the radius for rounded corners
                      ),
                      elevation: 4, // Add a shadow to the card
                      margin: EdgeInsets.all(0), // Adjust the margin as needed
                      color: Colors.white, // Background color of the card
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            for (var i = 0; i < 24; i++)
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.blue, width: 1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      meteo.hourly.values.first[i].substring(11),
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      meteo.hourly.values.elementAt(1)[i],
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
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

  Future<Meteo> getMeteoData(Meteo meteo) async {
    Position tmpPosition = await determinePosition();
    final response = await http.get(Uri.parse("https://api.open-meteo.com/v1/forecast?latitude=${tmpPosition.latitude}&longitude=${tmpPosition.longitude}&hourly=temperature_2m,precipitation_probability&forecast_days=1"));
    if (response.statusCode == 200) {
      meteo.setLatitude(Meteo.fromJson(jsonDecode(response.body) as Map<String,dynamic>).latitude);
      meteo.setLongitude(Meteo.fromJson(jsonDecode(response.body) as Map<String,dynamic>).longitude);
      meteo.setHourly(Meteo.fromJson(jsonDecode(response.body) as Map<String,dynamic>).hourly);
      meteo.setHourlyUnits(Meteo.fromJson(jsonDecode(response.body) as Map<String,dynamic>).hourlyUnits);
      return Meteo.fromJson(jsonDecode(response.body) as Map<String,dynamic>);
    } else {
      throw Exception('Failed to load');
    }
  }
}

class Meteo {
  double latitude;
  double longitude;
  double generationTimeMs;
  int utcOffsetSeconds;
  String timezone;
  String timezoneAbbreviation;
  double elevation;
  Map<String, String> hourlyUnits;
  Map<String, List<String>> hourly;

  Meteo({
    this.latitude = 0.0,
    this.longitude = 0.0, 
    this.generationTimeMs = 0.0, 
    this.utcOffsetSeconds = 0, 
    this.timezone = '', 
    this.timezoneAbbreviation = '', 
    this.elevation = 0.0, 
    this.hourlyUnits = const {}, 
    this.hourly = const {}, 
  });

  factory Meteo.fromJson(Map<String, dynamic> json) {

    Map<String, dynamic> hourlyUnitsJson = json['hourly_units'];
    Map<String, dynamic> hourlyJson = json['hourly'];

    Map<String, String> hourlyUnits = Map<String, String>.from(
        hourlyUnitsJson.map((key, value) => MapEntry(key, value.toString())));
    
    Map<String, List<String>> hourly = Map<String, List<String>>.from(
        hourlyJson.map((key, value) {
      List<String> values = (value as List).map((v) => v.toString()).toList();
      return MapEntry(key, values);
    }));

    return Meteo(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      generationTimeMs: (json['generationtime_ms'] as num).toDouble(),
      utcOffsetSeconds: json['utc_offset_seconds'] as int,
      timezone: json['timezone'] as String,
      timezoneAbbreviation: json['timezone_abbreviation'] as String,
      elevation: (json['elevation'] as num).toDouble(),
      hourlyUnits: hourlyUnits,
      hourly: hourly,
    );
  }

  // Setters
  void setLatitude(double value) {
    latitude = value;
  }

  void setLongitude(double value) {
    longitude = value;
  }

  void setGenerationTimeMs(double value) {
    generationTimeMs = value;
  }

  void setUtcOffsetSeconds(int value) {
    utcOffsetSeconds = value;
  }

  void setTimezone(String value) {
    timezone = value;
  }

  void setTimezoneAbbreviation(String value) {
    timezoneAbbreviation = value;
  }

  void setElevation(double value) {
    elevation = value;
  }

  void setHourlyUnits(Map<String, String> value) {
    hourlyUnits = value;
  }

  void setHourly(Map<String, List<String>> value) {
    hourly = value;
  }
}