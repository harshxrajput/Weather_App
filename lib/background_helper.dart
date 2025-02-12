import 'package:flutter/material.dart';

class BackgroundHelper {
  static BoxDecoration getWeatherBackground(String condition) {
    String imageUrl;
    switch (condition) {
      case "Clear":
        imageUrl = "https://i.pinimg.com/736x/b4/c8/50/b4c85094fd2267bb59aabb051907d6ee.jpg"; // Replace with actual URL
        break;
      case "Rain":
        imageUrl = "https://i.pinimg.com/736x/ee/29/c5/ee29c56f07a3e2d9bb981b9f1b78a40a.jpg"; // Replace with actual URL
        break;
      case "Clouds":
        imageUrl = "https://i.pinimg.com/736x/6f/6c/e8/6f6ce82f6844a8788e5ae407d460ebdb.jpg"; // Replace with actual URL
        break;
      case "Snow":
        imageUrl = "https://i.pinimg.com/736x/86/91/11/869111b9cd984ceecb864a0787fad668.jpg"; // Replace with actual URL
        break;
      case "Thunderstorm":
        imageUrl = "https://i.pinimg.com/736x/cc/88/ef/cc88ef66fd38cf35a01ed999af3313cd.jpg"; // Replace with actual URL
        break;
      default:
        imageUrl = "https://i.pinimg.com/736x/36/f6/5e/36f65ebaefaf561149960432b50cbf99.jpg"; // Replace with actual URL
    }
    return BoxDecoration(
      image: DecorationImage(
        image: NetworkImage(imageUrl),
        fit: BoxFit.cover,
      ),
    );
  }
}