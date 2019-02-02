import 'dart:io';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:wordie_app/character.dart';
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
            if (snapshot.hasData) {
              return Column(
                children: <Widget>[
                  GestureDetector(
                    child: Column(
                      key: GlobalObjectKey("grid"),
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: this.buildGridForWord(context, snapshot.data)
                    ),
                    onPanStart: (details) {
                      print(details.globalPosition);
                    },
                    onPanUpdate: (details) {
                      //print(details.globalPosition);
                      var rect = GlobalObjectKey("grid").currentContext.findRenderObject() as RenderBox;
                      var result = HitTestResult();
                      if (rect.hitTest(result, position: details.globalPosition)) {
                        // print(rect.localToGlobal(Offset(0, 0)));
                        var row = (details.globalPosition.dx / (rect.semanticBounds.width / 8.0)).floor();
                        var column = (details.globalPosition.dy / (rect.semanticBounds.height / 8.0)).floor();
                        var itemNumber = ((column * 8) + 1) + row;
                        // print(itemNumber);
                        var currentWidget = GlobalObjectKey("$itemNumber").currentWidget as Text;
                        //print(currentWidget);
                      }
                    },
                  ),
                  Text(snapshot.data.description),
                  RaisedButton(
                    onPressed: () {
                      this.setState(() {});
                    },
                  )
                ]
              );
            }

            return CircularProgressIndicator();
          }
        )
      ),
    );
  }

  List<Widget> buildGridForWord(BuildContext context, Word word) {
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

    var grid = [];

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

    print("$startingRow, $startingColumn");

    grid[startingRow][startingColumn] = word.word[0];

    for (var i=1; i<word.word.length; i++) {
      startingRow = this.getNextRowForWord(startingRow, direction);
      startingColumn = this.getNextColumnForWord(startingColumn, direction);
      // print("$startingRow, $startingColumn");
      grid[startingRow][startingColumn] = word.word[i];
    }

    for (var i=0; i<grid.length; i++) {
      // print(grid[i]);
    }

    var rows = <Widget>[];

    var size = MediaQuery.of(context).size;

    var sizePerCell = size.width > size.height ? size.height / 8 : size.width / 8;

    for (var i=0; i<grid.length; i++) {
      var row = grid[i];
      var children = <Widget>[];
      for (var j=0; j<row.length; j++) {
        children.add(
          Character(
            key: GlobalObjectKey("${((i * 8) + 1) + j}"),
            widthHeight: sizePerCell,
            character: row[j],
          )
        );
      }
      rows.add(Row(children: children,));
    }

    return rows; 
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
