import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class drawerclass extends StatelessWidget {
  const drawerclass({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            child:  Center(child: Text('WEATHER APP',style: TextStyle(fontWeight:FontWeight.bold),)),
            height: 200,
            width: double.infinity,
            color: Colors.blueGrey,
          ),
          ListTile(
            onTap: (){
              launchUrl(Uri.parse("https://github.com/harshxrajput"));
            },
            leading: Icon(Icons.person),
            title: Text('About Me',style: TextStyle(fontWeight:FontWeight.bold),),
          ),
          ListTile(
            onTap: (){
              launchUrl(Uri.parse("mailto:harshxkumar7@gmail.com"));
            },
            leading: Icon(Icons.mail),
            title: Text('Contact Me',style: TextStyle(fontWeight:FontWeight.bold),),
          )
        ],
      ),
    );
  }
}
