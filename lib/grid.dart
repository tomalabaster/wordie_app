import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:wordie_app/character.dart';
import 'package:wordie_app/models/word.dart';

class Grid extends StatefulWidget {

  final Word word;
  final List grid;
  final Function onWordFound;

  const Grid({
    Key key,
    this.word,
    this.grid,
    this.onWordFound
  });

  @override
  _GridState createState() => _GridState();
}

class _GridState extends State<Grid> {

  List<List<int>> visited = [];
  bool found = false;
  Offset start;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        color: Color.fromRGBO(32, 162, 226, 1.0),
        child: Column(
          key: GlobalObjectKey("grid"),
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: this.buildGridForWord(context, this.widget.word)
        )
      ),
      onPanStart: (details) {
        this.start = details.globalPosition;
      },
      onPanUpdate: (details) {
        var rect = GlobalObjectKey("grid").currentContext.findRenderObject() as RenderBox;
        var pos = rect.globalToLocal(this.start);
        var row = (pos.dx / (rect.semanticBounds.width / 8.0)).floor();
        var column = (pos.dy / (rect.semanticBounds.height / 8.0)).floor();

        var currentPoint = [details.globalPosition.dx, details.globalPosition.dy];

        var angle = (atan2(currentPoint[1] - this.start.dy, currentPoint[0] - this.start.dx) * 180) / pi;
        
        var direction = this.getDirection(angle);

        var size = MediaQuery.of(context).size;

        var sizePerCell = size.width > size.height ? size.height / 8 : size.width / 8;

        var thing = this.getThing(currentPoint, direction);

        var chars = (thing.abs() / sizePerCell).floor() + 1;
        
        this.visited.clear();
        
        this.visited.add([column, row]);
        
        for (var i=0; i<chars - 1; i++) {
          var col = this.getNextColumnForWord(this.visited.last[0], this.getMirroredDirection(direction));
          var row = this.getNextRowForWord(this.visited.last[1], this.getMirroredDirection(direction));

          this.visited.add([
            col,
            row
          ]);
        }

        this.setState((){});
      },
      onPanEnd: (details) {
        var chars = "";
        for (var i=0; i<this.visited.length; i++) {
          chars = chars + this.widget.grid[this.visited[i][0]][this.visited[i][1]];
        }

        print(chars);

        if (chars.toUpperCase() == this.widget.word.word.toUpperCase()) {
          this.setState(() {
            this.found = true;
          });
          this.widget.onWordFound();
        } else {
          this.setState(() {
            this.visited.clear();
          });
        }
      },
    );
  }

  String getMirroredDirection(String direction) {
    switch (direction) {
      case "rtlrtl":
        return "ttbttb";
      case "rtlttb":
        return "rtlttb";
      case "rtlbtt":
        return "ltrttb";
      case "ltrltr":
        return "bttbtt";
      case "ltrttb":
        return "rtlbtt";
      case "ltrbtt":
        return "ltrbtt";
      case "ttbttb":
        return "rtlrtl";
      case "bttbtt":
        return "ltrltr";
      default:
        return "rtlrtl";
    }
  }

  double getThing(List currentPoint, String direction) {
    if (direction[3] == "r" || direction[3] == "l") {
      return currentPoint[0] - this.start.dx;
    } else {
      return currentPoint[1] - this.start.dy;
    }
  }

  String getDirection(double angle) {
    if (angle >= 0 && angle < 22.5) {
      return "rtlrtl";
    } else if (angle >= 22.5 && angle < 67.5) {
      return "rtlttb";
    } else if (angle >= 67.5 && angle < 112.5) {
      return "ttbttb";
    } else if (angle >= 112.5 && angle < 157.5) {
      return "ltrttb";
    } else if (angle >= 157.5 && angle <= 180) {
      return "ltrltr";
    } else if (angle >= -180 && angle < -157.5) {
      return "ltrltr";
    } else if (angle >= -157.5 && angle < -112.5) {
      return "ltrbtt";
    } else if (angle >= -112.5 && angle < -67.5) {
      return "bttbtt";
    } else if (angle >= -67.5 && angle < -22.5) {
      return "rtlbtt";
    } else if (angle >= -22.5 && angle < 0) {
      return "rtlrtl";
    }

    return "rtlrtl";
  }

  List<Widget> buildGridForWord(BuildContext context, Word word) {
    var rows = <Widget>[];

    var size = MediaQuery.of(context).size;

    var sizePerCell = size.width > size.height ? size.height / 8 : size.width / 8;

    for (var i=0; i<this.widget.grid.length; i++) {
      var row = this.widget.grid[i];
      var children = <Widget>[];
      for (var j=0; j<row.length; j++) {
        var correct = this.found ? this.visited.any((coords) => coords[0] == i && coords[1] == j) : false;
        children.add(
          Character(
            widthHeight: sizePerCell,
            character: row[j],
            selected: this.visited.any((coords) => coords[0] == i && coords[1] == j),
            correct: correct,
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