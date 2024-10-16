import 'dart:convert';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:weather_app/secrets.dart';
import 'additional_info.dart';
import 'weather_forecast.dart';
import 'package:http/http.dart' as http;

class Weatherscreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const Weatherscreen({super.key, required this.onToggleTheme});

  @override
  State<Weatherscreen> createState() => _WeatherscreenState();
}

class _WeatherscreenState extends State<Weatherscreen> {
  String CityName = "Bhubaneswar";  // This can be updated by user input

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      final result = await http.get(
        Uri.parse("https://api.openweathermap.org/data/2.5/forecast?q=$CityName&APPID=$openWeatherAPIKEY"),
      );
      final data = jsonDecode(result.body);
      if (data["cod"] != "200") {
        throw data["message"];
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentWeather();
  }

  void _searchCity() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String userInput = "";

        return AlertDialog(
          title: Text('Search Cities'),
          content: TextField(
            onChanged: (value) {
              userInput = value; // Capture user input
            },
            decoration: InputDecoration(
              hintText: 'Enter city name',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Search'),
              onPressed: () {
                setState(() {
                  CityName = userInput; // Update the city name
                  getCurrentWeather();  // Fetch weather for the new city
                });
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weather App",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: widget.onToggleTheme,
            tooltip: "Toggle Theme",
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                getCurrentWeather();
              });
            },
            tooltip: "Refresh",
            icon: Icon(Icons.refresh),
          ),
        ],
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: getCurrentWeather(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator.adaptive());
          }
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }

          final data = snapshot.data!;
          final currentWeatherData = data["list"][0];
          final currenttemp = (currentWeatherData["main"]["temp"] - 273.15).round();
          final currentSky = currentWeatherData["weather"][0]["main"];
          final currentfeels_like = (currentWeatherData["main"]["feels_like"] - 273.15).round();
          final currentwind_speed = currentWeatherData["wind"]["speed"];
          final currentpressure = currentWeatherData["main"]["pressure"];
          final currenthumidity = currentWeatherData["main"]["humidity"];
          final currentvisibility = currentWeatherData["visibility"];
          final curentgust = currentWeatherData["wind"]["gust"];
          final currentcity = data["city"]["name"];

          return Padding(
            padding: const EdgeInsets.all(15.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  //main card
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      elevation: 20,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Padding(
                            padding: EdgeInsets.all(15.0),
                            child: Column(
                              children: [
                                Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "$currentcity",
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      IconButton(
                                        onPressed: _searchCity, // Call function to search city
                                        tooltip: "search cities",
                                        icon: Icon(Icons.search),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  "$currenttemp°C",
                                  style: TextStyle(
                                    fontSize: 35,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Icon(
                                  currentSky == "Clouds"
                                      ? Icons.cloud
                                      : currentSky == "Rain"
                                      ? Icons.cloudy_snowing
                                      : currentSky == "Sunny"
                                      ? Icons.sunny
                                      : Icons.error,
                                  size: 40,
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  "$currentSky",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  //weather forecast
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      "Weather Forecast",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      itemCount: 9,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final hourlyforecast = data["list"][index + 1];
                        final hourlysky = data["list"][index + 1]["weather"][0]["main"];
                        final hourlytemp =
                        (data["list"][index + 1]["main"]["temp"] - 273.15).round();
                        final time = DateTime.parse(hourlyforecast["dt_txt"]);
                        return ForecastItem(
                          time: DateFormat.j().format(time),
                          icon: hourlysky == "Clouds"
                              ? Icons.cloud
                              : hourlysky == "Rain"
                              ? Icons.cloudy_snowing
                              : hourlysky == "Sunny"
                              ? Icons.sunny
                              : Icons.error,
                          temp: hourlytemp.toString(),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  //additional info
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      "Additional Information",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            AdditionalInfo(
                              icon: Icons.wind_power,
                              label: "Wind Speed",
                              value: "$currentwind_speed km/h",
                            ),
                            AdditionalInfo(
                              icon: Icons.thermostat,
                              label: "Feels Like",
                              value: "$currentfeels_like° C",
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            AdditionalInfo(
                              icon: Icons.visibility,
                              label: "Visibility",
                              value: "$currentvisibility m",
                            ),
                            AdditionalInfo(
                              icon: Icons.air,
                              label: "Gust",
                              value: curentgust.toString(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            AdditionalInfo(
                              icon: Icons.water_drop_outlined,
                              label: "Humidity",
                              value: "$currenthumidity%",
                            ),
                            AdditionalInfo(
                              icon: Icons.beach_access,
                              label: "Pressure",
                              value: "$currentpressure hPa",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
