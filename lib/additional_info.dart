import 'package:flutter/material.dart';

class AdditionalInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const AdditionalInfo ({super.key,
  required this.icon,
  required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return  Card(
      child: Container(
        width: 150,
        child: Padding(
          padding:EdgeInsets.all(9.0),
          child: Column(
            children: [
              Icon(icon ,size: 35,),
              const SizedBox(height: 10),
              Text(label,style: TextStyle(fontSize: 20),),
              const SizedBox(height: 10,),
              Text(value,style: TextStyle(fontSize: 16),),
            ],
          ),
        ),
      ),
    );
  }
}