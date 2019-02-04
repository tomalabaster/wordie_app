import 'package:flutter/material.dart';

class Character extends StatefulWidget {

  final double widthHeight;
  final String character;
  final bool selected;
  final bool correct;

  const Character({
    Key key,
    this.widthHeight,
    this.character,
    this.selected,
    this.correct
  });

  @override
  _CharacterState createState() => _CharacterState();
}

class _CharacterState extends State<Character> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(32, 162, 226, 1.0),
        border: Border.all(style: BorderStyle.none, width: 0.0)
      ),
      width: this.widget.widthHeight,
      height: this.widget.widthHeight,
      child: Center(
        child: Text(
          this.widget.character.toUpperCase(),
          key: this.widget.key,
          style: TextStyle(
            color: this.widget.correct ? Colors.green : this.widget.selected ? Colors.orange : Colors.white,
            fontFamily: 'Subscribe',
            fontSize: 32.0,
            fontWeight: FontWeight.normal
          )
        )
      )
    );
  }
}