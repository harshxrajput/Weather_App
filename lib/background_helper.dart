import 'package:flutter/material.dart';

class BackgroundHelper {
  static BoxDecoration getWeatherBackground(String condition) {
    String assetPath = "assets/default.jpg"; // Default image
    switch (condition.toLowerCase()) {
      case "clear":
        assetPath = "assets/images/clear_day.jpg";
        break;
      case "clouds":
        assetPath = "assets/images/cloudy_day.jpg";
        break;
      case "rain":
        assetPath = "assets/images/rainy.jpg";
        break;
      case "snow":
        assetPath = "assets/images/snowy.jpg";
        break;
      case "Thunderstorm":
        assetPath = "assets/images/stormy.jpg";
        break;
      default:
        assetPath = "assets/images/default.jpg";
    }

    return BoxDecoration(
      image: DecorationImage(
        image: AssetImage(assetPath),
        fit: BoxFit.cover,
      ),
    );
  }
}