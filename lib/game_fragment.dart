import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:wordie_app/grid.dart';
import 'package:wordie_app/models/word.dart';
import 'package:wordie_app/services/word_service.dart';

class GameFragment extends StatefulWidget {

  final WordService wordService;

  const GameFragment({
    Key key,
    this.wordService
  }) : super(key: key);

  @override
  State<GameFragment> createState() {
    return new _GameFragmentState();
  }

  static Future time(int time) async {
    Completer c = new Completer();

    new Timer(new Duration(seconds: time), () {
      c.complete('done with time out');
    });

    return c.future;
  }
}

class _GameFragmentState extends State<GameFragment> {

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: FutureBuilder(
          future: this.widget.wordService.getNewWord(),
          builder: (context, AsyncSnapshot<Word> snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
                    child: Grid(
                      word: snapshot.data,
                      grid: this.buildGridForWord(context, snapshot.data),
                      onWordFound: () async {
                        await GameFragment.time(1);

                        this.setState(() {});
                      }
                    )
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color.fromRGBO(32, 162, 226, 1.0)
                            ),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.only(left: 32.0, right: 32.0),
                              child: AutoSizeText(
                                snapshot.data.description,
                                style: TextStyle(
                                  color: Colors.deepOrange,
                                  fontFamily: 'Subscribe'
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 3,
                              )
                            )
                          )
                        )
                      )
                    )
                  )
                ]
              );
            }

            return CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            );
          }
        )
      )
    );
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