import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  requestLocationPermission();
  runApp(const MainApp());
}

Future<bool> requestLocationPermission() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return false;
  }

  permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return false;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return false;
  }

  return true; 
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
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
  late String imageToShow = "sun";
  late double minTemperature = 0;
  late double maxTemperature = 0;
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
                Positioned(
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/$imageToShow.jpg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.1,
                  left: MediaQuery.of(context).size.width * 0.2,
                  child: Text(
                    snapshot.data?[0].toString() ?? "Permission for geolocalization was denied",
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                            color: Colors.black,      
                            blurRadius: 2.0,          
                            offset: Offset(2.0, 2.0), 
                          ),
                      ]
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.2,
                  left: MediaQuery.of(context).size.width * 0.25,
                  child: Text(
                    "${meteo.hourly.values.elementAt(1)[DateTime.now().hour]} °C",
                    style: const TextStyle(
                      fontSize: 58,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black,      
                          blurRadius: 2.0,          
                          offset: Offset(2.0, 2.0), 
                        ),
                      ]
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.3,
                  left: MediaQuery.of(context).size.width * 0.3,
                  child: Text(
                    "MIN: ${minTemperature} °C   MAX: ${maxTemperature} °C ",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black,      
                          blurRadius: 2.0,          
                          offset: Offset(2.0, 2.0), 
                        ),
                      ]
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * -0.3,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: DraggableScrollableSheet(
                    initialChildSize: 0.3,
                    minChildSize: 0.1,
                    maxChildSize: 0.5,
                    builder: (context, scrollController) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.4),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: 24,
                          itemBuilder: (context, i) {
                            final hour = meteo.hourly.values.first[i].substring(11);
                            final humidity = "${meteo.hourly.values.elementAt(2)[i]}%";
                            final temperature = "${meteo.hourly.values.elementAt(1)[i]} °C";
                            if (i == 0) {
                              return Column(
                                children: [
                                
                                Container(
                                  margin: const EdgeInsets.symmetric(vertical: 5),
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          const Text(
                                        "Time",
                                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white,shadows: [
                                            Shadow(
                                              color: Colors.black, 
                                              blurRadius: 2.0, 
                                              offset: Offset(2.0, 2.0), 
                                            ),
                                          ],),
                                        ),
                                        const Divider(color: Colors.white),
                                          Text(
                                        hour,
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white,shadows: [
                                            Shadow(
                                              color: Colors.black,  
                                              blurRadius: 2.0,
                                              offset: Offset(2.0, 2.0),
                                            ),
                                          ],),
                                        ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          const Text(
                                        "Humidity",
                                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white,shadows: [
                                          Shadow(
                                            color: Colors.black,
                                            blurRadius: 2.0,
                                            offset: Offset(2.0, 2.0), 
                                          ),
                                        ],),
                                      ),
                                      const Divider(color: Colors.white),
                                      Text(
                                        humidity,
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white,shadows: [
                                          Shadow(
                                            color: Colors.black,
                                            blurRadius: 2.0,
                                            offset: Offset(2.0, 2.0),
                                          ),
                                        ],),
                                      ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          const Text(
                                        "Temp",
                                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white,shadows: [
                                          Shadow(
                                            color: Colors.black, 
                                            blurRadius: 2.0, 
                                            offset: Offset(2.0, 2.0),
                                          ),
                                        ],),
                                      ),
                                      const Divider(color: Colors.white),
                                      Text(
                                        temperature,
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white,shadows: [
                                          Shadow(
                                            color: Colors.black,    
                                            blurRadius: 2.0,  
                                            offset: Offset(2.0, 2.0),
                                          ),
                                        ],),
                                      ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(color: Colors.white)
                              ],
                              );
                            } else {
                              return Column(
                              children: [
                                
                                Container(
                                  margin: const EdgeInsets.symmetric(vertical: 5),
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        hour,
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white,shadows: [
                                            Shadow(
                                              color: Colors.black, 
                                              blurRadius: 2.0, 
                                              offset: Offset(2.0, 2.0),
                                            ),
                                          ],),
                                        ),
                                      Text(
                                        humidity,
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white,shadows: [
                                          Shadow(
                                            color: Colors.black, 
                                            blurRadius: 2.0, 
                                            offset: Offset(2.0, 2.0), 
                                          ),
                                        ],),
                                      ),
                                      Text(
                                        temperature,
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white,shadows: [
                                          Shadow(
                                            color: Colors.black,
                                            blurRadius: 2.0, 
                                            offset: Offset(2.0, 2.0), 
                                          ),
                                        ],),
                                      ),
                                    ],
                                  ),
                                ),
                                if (i < 23) const Divider(color: Colors.white),
                              ],
                            );
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
  
  Future<Position> determinePosition() async {

    LocationPermission permission;

    
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      return Position(longitude: 41.9027835, latitude: 12.4963655, timestamp: DateTime.now(), accuracy: 0, altitude: 0, altitudeAccuracy: 0, heading: 0, headingAccuracy: 0, speed: 0, speedAccuracy: 0);
    }

    if (permission == LocationPermission.deniedForever) {
      return Position(longitude: 41.9027835, latitude: 12.4963655, timestamp: DateTime.now(), accuracy: 0, altitude: 0, altitudeAccuracy: 0, heading: 0, headingAccuracy: 0, speed: 0, speedAccuracy: 0);
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
      int humidity = int.parse(meteo.hourly.values.elementAt(2)[DateTime.now().hour]);
          if (humidity < 30) {
            imageToShow = "sun";
        } else if (humidity < 60) {
            imageToShow = "cloud";
        } else {
            imageToShow = "rain";
        }
        minTemperature = double.parse(meteo.hourly.values.elementAt(1).first);
        maxTemperature = double.parse(meteo.hourly.values.elementAt(1).first);
        for (String temperature in meteo.hourly.values.elementAt(1)) {
        double temp = double.parse(temperature);
          if (temp < minTemperature) {
            minTemperature = temp;
          }
          if (temp > maxTemperature) {
            maxTemperature = temp;
          }
        }
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

