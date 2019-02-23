import 'dart:async';

import 'package:appcenter_analytics/appcenter_analytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wordie_app/main.dart';
import 'package:wordie_app/preferences/styles.dart';

class HomeScreen extends StatefulWidget {
  
  final FirebaseAnalytics analytics;

  const HomeScreen({
    Key key,
    this.analytics
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();
  }

  Future<void> asyncInitState() async {
    await this.widget.analytics.logAppOpen();
    await AppCenterAnalytics.trackEvent("app_open");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.WordieBlue,
      body: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 96.0),
                  child: Text(
                    "Wordie!",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Subscribe',
                      fontSize: 72.0
                    ),
                  )
                ),
                Padding(
                  padding: EdgeInsets.only(top: 96.0),
                  child: GestureDetector(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 4.0
                        ),
                        borderRadius: BorderRadius.circular(8.0)
                      ),
                      padding: EdgeInsets.fromLTRB(24.0, 10.0, 24.0, 8.0),
                      child: Text(
                        "Play!",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Subscribe',
                          fontSize: 32.0
                        ),
                      )
                    ),
                    onTap: () {
                      Navigator.of(context).pushNamed('/game');
                    },
                  )
                ),
                Padding(
                  padding: EdgeInsets.only(top: 48.0),
                  child: GestureDetector(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(24.0, 10.0, 24.0, 8.0),
                      child: Text(
                        "About",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Subscribe',
                          fontSize: 28.0
                        ),
                      )
                    ),
                    onTap: () {
                      Navigator.of(context).pushNamed('/about');
                    },
                  )
                ),
              ],
            )
          )
        ]
      ),
    );
  }
}