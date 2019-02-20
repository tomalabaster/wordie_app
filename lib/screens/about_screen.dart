import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wordie_app/preferences/styles.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.WordieBlue,
      body: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.topLeft,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: GestureDetector(
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                )
              ),
            )
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(left: 32.0, right: 32.0),
              child: Text(
                "This app is my first game made using Flutter!\n\nI enjoy making apps so I'll regularly be updating this and others in hope that you can enjoy them too!",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Subscribe',
                  fontSize: 16.0
                ),
                textAlign: TextAlign.center,
              )
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 48.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 24.0),
                    child: GestureDetector(
                      child: Text(
                        "Privacy policy",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Subscribe',
                          fontSize: 16.0
                        ),
                      ),
                      onTap: () async {
                        const url = 'https://tomdev.co.uk/privacy-policy';
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                    ),
                  ),
                  Text(
                    "Made by <tomdev/>",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Subscribe',
                      fontSize: 24.0
                    ),
                  )
                ]
              )
            ),
          )
        ]
      )
    );
  }
}