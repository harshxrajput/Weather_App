import 'dart:convert';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/drawer.dart';
import 'package:weather_app/secrets.dart';
import 'additional_info.dart';
import 'weather_forecast.dart';
import 'background_helper.dart'; // Import the background helper
import 'package:http/http.dart' as http;
import 'air_quality_widget.dart';

class _WeatherscreenState extends State<Weatherscreen> {
  late String CityName; // Use the default city passed from the previous screen
  int aqi = 0; // Default AQI


  @override
  void initState() {
    super.initState();
    CityName = widget.defaultCity; // Set initial city
    loadWeatherAndAirQuality();    // Fetch AQI on startup
  }




  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      final result = await http.get(
        Uri.parse(
          "https://api.openweathermap.org/data/2.5/forecast?q=$CityName&APPID=$openWeatherAPIKEY",
        ),
      );
      final data = jsonDecode(result.body);

      if (data["cod"] != "200") {
        throw data["message"];
      }

      // Extract and print lat/lon for debugging
      double lat = data["city"]["coord"]["lat"];
      double lon = data["city"]["coord"]["lon"];
      print("Weather Data Fetched for $CityName: lat=$lat, lon=$lon");

      return data;
    } catch (e) {
      throw "Error fetching weather: $e";
    }
  }


  Future<Map<String, dynamic>> getAirQualityData(double lat, double lon) async {
    try {
      final result = await http.get(
        Uri.parse(
          "https://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$openWeatherAPIKEY",
        ),
      );
      final data = jsonDecode(result.body);

      if (data.containsKey("list") && data["list"].isNotEmpty) {
        return data;
      } else {
        throw "Invalid air quality data";
      }
    } catch (e) {
      throw "Error fetching AQI: $e";
    }
  }



  Future<void> loadWeatherAndAirQuality() async {
    try {
      // Fetch weather and extract city coordinates
      final weatherData = await getCurrentWeather();
      double lat = weatherData["city"]["coord"]["lat"];
      double lon = weatherData["city"]["coord"]["lon"];

      // Fetch AQI for the searched city
      final airQualityData = await getAirQualityData(lat, lon);
      int newAqi = airQualityData["list"][0]["main"]["aqi"];

      print("Weather and AQI fetched for $CityName: AQI = $newAqi"); // Debugging

      // Update UI once with all new data
      setState(() {
        aqi = newAqi;
      });

    } catch (e) {
      print("Error loading weather and AQI: $e");
    }
  }


  void _searchCity() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String userInput = "";
        return Dialog(
          backgroundColor: Colors.white.withOpacity(0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Search Cities',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  onChanged: (value) {
                    userInput = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter city name',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.black54),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text(
                        'Search',
                        style: TextStyle(color: Colors.black54),
                      ),
                      onPressed: () {
                        setState(() {
                          CityName = userInput;
                        });
                        Navigator.of(context).pop();

                        // Fetch new weather and AQI for the searched city
                        loadWeatherAndAirQuality();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  bool isNightTime() {
    final now = DateTime.now();
    final hour = now.hour;
    return hour < 6 || hour >= 18;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {}); // Trigger a refresh by calling setState
      },
      child: FutureBuilder(
        future: getCurrentWeather(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator.adaptive()),
            );
          }
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text(snapshot.error.toString())),
            );
          }
          final data = snapshot.data!;
          final currentWeatherData = data["list"][0];
          final currentSky = currentWeatherData["weather"][0]["main"];
          final isNight = isNightTime();
          return Scaffold(
            backgroundColor: Colors.transparent,
            extendBodyBehindAppBar: true,
            body: Stack(
              children: [
                // Background Image
                Container(
                  decoration: BackgroundHelper.getWeatherBackground(currentSky),
                ),
                // Nighttime Overlay
                if (isNight)
                  ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        color: Colors.black.withOpacity(0.5), // Reduce brightness
                      ),
                    ),
                  ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(), // Enable scrolling
                    child: Column(
                      children: [
                        // Add some vertical spacing for the status bar
                        SizedBox(height: MediaQuery.of(context).padding.top + 20),
                        // Main Weather Card
                        SizedBox(
                          width: 300,
                          height: 250,
                          child: WeatherCard(
                            cityName: data["city"]["name"],
                            temperature: (currentWeatherData["main"]["temp"] - 273.15).round(),
                            weatherCondition: currentSky,
                            onSearchCity: _searchCity,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Weather Forecast
                        // Add this below the "Additional Information" section

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Air Quality",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        AirQualityWidget(aqi: aqi),
                        const SizedBox(height: 20,),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            "Weather Forecast",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            itemCount: data["list"].length > 9 ? 9 : data["list"].length - 1,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              final hourlyforecast = data["list"][index + 1];
                              final hourlysky = data["list"][index + 1]["weather"][0]["main"];
                              final hourlytemp =
                              (data["list"][index + 1]["main"]["temp"] - 273.15).round();
                              final time = DateTime.parse(hourlyforecast["dt_txt"]);
                              return ForecastItem(
                                time: DateFormat.j().format(time),
                                icon: getWeatherIcon(hourlysky),
                                temp: hourlytemp.toString(),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Additional Information
                        Align(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            "Additional Information",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        AdditionalInfoSection(
                          windSpeed: "${currentWeatherData["wind"]["speed"]} km/h",
                          feelsLike:
                          "${(currentWeatherData["main"]["feels_like"] - 273.15).round()}° C",
                          visibility: "${currentWeatherData["visibility"]} m",
                          gust: currentWeatherData["wind"]["gust"].toString(),
                          humidity: "${currentWeatherData["main"]["humidity"]}%",
                          pressure: "${currentWeatherData["main"]["pressure"]} hPa",
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  IconData getWeatherIcon(String condition) {
    switch (condition) {
      case "Thunderstorm":
        return Icons.bolt;
      case "Drizzle":
        return Icons.water_drop;
      case "Rain":
        return Icons.cloudy_snowing;
      case "Snow":
        return Icons.ac_unit;
      case "Clear":
        return Icons.wb_sunny;
      case "Clouds":
        return Icons.cloud;
      case "Mist":
      case "Smoke":
      case "Haze":
      case "Dust":
      case "Fog":
      case "Sand":
      case "Ash":
        return Icons.foggy;
      default:
        return Icons.error;
    }
  }
}

class Weatherscreen extends StatefulWidget {
  final String defaultCity; // Accept the default city as a parameter
  const Weatherscreen({super.key, required this.defaultCity});

  @override
  State<Weatherscreen> createState() => _WeatherscreenState();
}

// Weather Card Widget
class WeatherCard extends StatelessWidget {
  final String cityName;
  final int temperature;
  final String weatherCondition;
  final VoidCallback onSearchCity;

  const WeatherCard({
    super.key,
    required this.cityName,
    required this.temperature,
    required this.weatherCondition,
    required this.onSearchCity,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.3),
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  cityName,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                ),
                SizedBox(width: 8),
                IconButton(
                  onPressed: onSearchCity,
                  tooltip: "Search Cities",
                  icon: Icon(Icons.search),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              "$temperature°C",
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Icon(getWeatherIcon(weatherCondition), size: 40),
            const SizedBox(height: 15),
            Text(
              weatherCondition,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  IconData getWeatherIcon(String condition) {
    switch (condition) {
      case "Thunderstorm":
        return Icons.bolt;
      case "Drizzle":
        return Icons.water_drop;
      case "Rain":
        return Icons.cloudy_snowing;
      case "Snow":
        return Icons.ac_unit;
      case "Clear":
        return Icons.wb_sunny;
      case "Clouds":
        return Icons.cloud;
      case "Mist":
      case "Smoke":
      case "Haze":
      case "Dust":
      case "Fog":
      case "Sand":
      case "Ash":
        return Icons.foggy;
      default:
        return Icons.error;
    }
  }
}

// Additional Information Section
class AdditionalInfoSection extends StatelessWidget {
  final String windSpeed;
  final String feelsLike;
  final String visibility;
  final String gust;
  final String humidity;
  final String pressure;

  const AdditionalInfoSection({
    super.key,
    required this.windSpeed,
    required this.feelsLike,
    required this.visibility,
    required this.gust,
    required this.humidity,
    required this.pressure,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            AdditionalInfo(icon: Icons.wind_power, label: "Wind Speed", value: windSpeed),
            AdditionalInfo(icon: Icons.thermostat, label: "Feels Like", value: feelsLike),
          ],
        ),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            AdditionalInfo(icon: Icons.visibility, label: "Visibility", value: visibility),
            AdditionalInfo(icon: Icons.air, label: "Gust", value: gust),
          ],
        ),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            AdditionalInfo(icon: Icons.water_drop_outlined, label: "Humidity", value: humidity),
            AdditionalInfo(icon: Icons.beach_access, label: "Pressure", value: pressure),
          ],
        ),
      ],
    );
  }
}