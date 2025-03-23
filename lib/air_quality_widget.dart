import 'package:flutter/material.dart';

class AirQualityWidget extends StatelessWidget {
  final int aqi; // AQI (1 to 5 scale from OpenWeatherMap)

  const AirQualityWidget({super.key, required this.aqi});

  // Determine AQI category
  String getAqiStatus(int aqi) {
    switch (aqi) {
      case 1:
        return "Good";
      case 2:
        return "Fair";
      case 3:
        return "Moderate";
      case 4:
        return "Poor";
      case 5:
        return "Very Poor";
      default:
        return "Unknown";
    }
  }

  // Determine AQI range (shown next to AQI number)
  String getAqiRange(int aqi) {
    switch (aqi) {
      case 1:
        return "(0-50)";
      case 2:
        return "(51-100)";
      case 3:
        return "(101-150)";
      case 4:
        return "(151-200)";
      case 5:
        return "(201-300+)";
      default:
        return "(Unknown)";
    }
  }

  // Determine health impact based on AQI (1–5)
  String getHealthImpact(int aqi) {
    switch (aqi) {
      case 1:
        return "Air quality is excellent. No risk.";
      case 2:
        return "Air quality is acceptable. Minor concerns for sensitive people.";
      case 3:
        return "May cause mild discomfort for sensitive individuals.";
      case 4:
        return "Unhealthy. Everyone may experience some health effects.";
      case 5:
        return "Very unhealthy. Health warnings. Avoid outdoor activities.";
      default:
        return "No data available.";
    }
  }

  // Determine the color based on AQI (1–5)
  Color getAqiColor(int aqi) {
    switch (aqi) {
      case 1:
        return Colors.green.shade500; // Good
      case 2:
        return Colors.lightGreen; // Fair
      case 3:
        return Colors.yellow.shade300; // Moderate
      case 4:
        return Colors.orange; // Poor
      case 5:
        return Colors.red.shade800; // Very Poor
      default:
        return Colors.grey; // Unknown
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: getAqiColor(aqi).withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Air Quality Index",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // AQI Value with Range
              Row(
                children: [
                  Text(
                    "AQI: $aqi ",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    getAqiRange(aqi), // Displays range next to AQI
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              // AQI Category
              Text(
                getAqiStatus(aqi),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Health Impact Message
          Text(
            getHealthImpact(aqi),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
