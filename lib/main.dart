import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'weather_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      home: const CitySelectionScreen(),
    );
  }
}

class CitySelectionScreen extends StatefulWidget {
  const CitySelectionScreen({super.key});

  @override
  State<CitySelectionScreen> createState() => _CitySelectionScreenState();
}

class _CitySelectionScreenState extends State<CitySelectionScreen> {
  Future<String?> getDefaultCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('defaultCity');
  }

  Future<void> saveDefaultCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('defaultCity', city);
  }

  @override
  void initState() {
    super.initState();
    checkForDefaultCity();
  }

  Future<void> checkForDefaultCity() async {
    final defaultCity = await getDefaultCity();
    if (defaultCity == null) {
      // No default city found, ask the user to input their city
      _showCityInputDialog();
    } else {
      // Default city found, navigate to the weather screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Weatherscreen(defaultCity: defaultCity),
        ),
      );
    }
  }

  void _showCityInputDialog() {
    String userInput = "";
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Your City'),
          content: TextField(
            onChanged: (value) {
              userInput = value;
            },
            decoration: const InputDecoration(hintText: 'e.g., New York'),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (userInput.isNotEmpty) {
                  await saveDefaultCity(userInput); // Save the city
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Weatherscreen(defaultCity: userInput),
                    ),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Show a loading indicator
      ),
    );
  }
}