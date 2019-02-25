import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wordie_app/features/description_container.dart';
import 'package:wordie_app/features/game_grid/grid.dart';
import 'package:wordie_app/models/word.dart';

class GameFragment extends StatelessWidget {

  final Word word;
  final Function onWordFound;
  final bool delayWhenFound;

  const GameFragment({
    Key key,
    this.word,
    this.onWordFound,
    this.delayWhenFound = true
  }) : super(key: key);

  static Future time(int time) async {
    Completer c = new Completer();

    new Timer(new Duration(seconds: time), () {
      c.complete('done with time out');
    });

    return c.future;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
              child: Grid(
                word: this.word,
                grid: this.buildGridForWord(context, this.word),
                onWordFound: () async {
                  if (this.delayWhenFound) {
                    await GameFragment.time(1);
                  }

                  this.onWordFound();
                }
              )
            ),
            Expanded(
              child: DescriptionContainer(word: this.word)
            )
          ]
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
        row.add(alphabet[random.nextInt(25)]);
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