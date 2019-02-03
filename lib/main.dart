import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:wordie_app/grid.dart';
import 'package:wordie_app/models/word.dart';
import 'package:wordie_app/services/word_service.dart';

void main() {

  var appId = Platform.isIOS ? "ca-app-pub-8187198937216043~3354678461" : Platform.isAndroid ? "ca-app-pub-8187198937216043~2308942688" : "";

  FirebaseAdMob.instance.initialize(appId: FirebaseAdMob.testAppId);

  var wordService = WordService();

  runApp(
    MyApp(
      wordService: wordService,
    )
  );
}

class MyApp extends StatelessWidget {

  final WordService wordService;

  const MyApp({
    Key key,
    this.wordService
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(wordService: this.wordService),
    );
  }
}

class MyHomePage extends StatefulWidget {

  const MyHomePage({
    Key key,
    this.wordService
  }) : super(key: key);

  final WordService wordService;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  BannerAd _bannerAd;
  double bottomPadding = 0.0;

  @override
  void initState() {
    super.initState();

    MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
      nonPersonalizedAds: true,
      testDevices: <String>[], // Android emulators are considered test devices
    );

    this._bannerAd = BannerAd(
      adUnitId: BannerAd.testAdUnitId,
      size: AdSize.smartBanner,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("BannerAd event is $event");
        this.setState(() {
          this.bottomPadding = 51.0;
        });
      },
    )..load()..show();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: GlobalObjectKey("scaffold"),
      body: Center(
        child: FutureBuilder(
          future: this.widget.wordService.getNewWord(),
          builder: (context, AsyncSnapshot<Word> snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 100.0,
                  ),
                  Grid(
                    word: snapshot.data,
                    grid: this.buildGridForWord(context, snapshot.data),
                    onWordFound: this.foundWord
                  ),
                  Expanded(
                    child: Center(
                      child: AutoSizeText(
                        snapshot.data.description,
                        style: TextStyle(
                          
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                      )
                    ),
                  )
                ]
              );
            }

            return CircularProgressIndicator();
          }
        )
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: this.bottomPadding),
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Text("Test"),
              title: Text("Test")
            ),
            BottomNavigationBarItem(
              icon: Text("Test"),
              title: Text("Test")
            )
          ],
        )
      )
    );
  }

  void foundWord() async {
    print("Found!");

    await time(1);

    this.setState(() {});
  }

  static Future time(int time) async {
    Completer c = new Completer();

    new Timer(new Duration(seconds: time), () {
      c.complete('done with time out');
    });

    return c.future;
  }

  List buildGridForWord(BuildContext context, Word word) {
    var grid = [];

    var directions = [
      "rtlrtl",
      "rtlttb",
      "rtlbtt",
      "ltrltr",
      "ltrttb",
      "ltrbtt",
      "ttbttb",
      "bttbtt"
    ];

    var alphabet = "abcdefghijklmnopqrstuvwxyz";

    var random = Random();

    for (var i=0; i<8; i++) {
      var row = [];
      for (var j=0; j<8; j++) {
        row.add(alphabet[random.nextInt(8)]);
      }
      grid.add(row);
    }

    print(word.word);

    var startingRow = random.nextInt(8 - word.word.length);
    var startingColumn = random.nextInt(8 - word.word.length);

    grid[startingRow][startingColumn] = word.word[0];

    var direction = directions[random.nextInt(directions.length)];

    if (direction.startsWith("l")) {
      startingColumn = 7 - startingColumn;
    }

    if (direction.startsWith("b")) {
      startingRow = 7 - startingRow;
    }

    if (direction[3] == "b" && direction != "bttbtt") {
      startingRow = 7 - startingRow;
    }

    grid[startingRow][startingColumn] = word.word[0];

    for (var i=1; i<word.word.length; i++) {
      startingRow = this.getNextRowForWord(startingRow, direction);
      startingColumn = this.getNextColumnForWord(startingColumn, direction);
      grid[startingRow][startingColumn] = word.word[i];
    }

    return grid;
  }

  int getNextColumnForWord(int currentColumn, String direction) {
    switch (direction) {
      case "rtlrtl":
        return currentColumn += 1;
      case "rtlttb":
        return currentColumn += 1;
      case "rtlbtt":
        return currentColumn += 1;
      case "ltrltr":
        return currentColumn -= 1;
      case "ltrttb":
        return currentColumn -= 1;
      case "ltrbtt":
        return currentColumn -= 1;
      case "ttbttb":
        return currentColumn;
      case "bttbtt":
        return currentColumn;
      default:
        return currentColumn;
    }
  }

  int getNextRowForWord(int currentRow, String direction) {
    switch (direction) {
      case "rtlrtl":
        return currentRow;
      case "rtlttb":
        return currentRow += 1;
      case "rtlbtt":
        return currentRow -= 1;
      case "ltrltr":
        return currentRow;
      case "ltrttb":
        return currentRow += 1;
      case "ltrbtt":
        return currentRow -= 1;
      case "ttbttb":
        return currentRow += 1;
      case "bttbtt":
        return currentRow -= 1;
      default:
        return currentRow;
    }
  }
}
