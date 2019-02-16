import 'package:flutter/material.dart';
import 'package:wordie_app/preferences/styles.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
                      Navigator.of(context).pushReplacementNamed('/game');
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