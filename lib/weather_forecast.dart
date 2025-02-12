import 'package:flutter/material.dart';

class ForecastItem extends StatelessWidget {
  final IconData icon;
  final String time;
  final String temp;
  const ForecastItem ({super.key,
  required this.icon,
    required this.time,
    required this.temp,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.3),
      child: Container(
        width: 100,
        child: Padding(
          padding:EdgeInsets.all(5.0),
          child: Column(
            children: [
              Text(time,style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,),
              const SizedBox(height: 5,),
              Icon(icon,size: 40,),
              const SizedBox(height: 5),
              Text(temp+"°C",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
            ],
          ),
        ),
      ),
    );
  }
}
