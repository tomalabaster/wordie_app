import 'package:flutter/material.dart';

class Character extends StatefulWidget {

  final double widthHeight;
  final String character;

  const Character({
    Key key,
    this.widthHeight,
    this.character
  });

  @override
  _CharacterState createState() => _CharacterState();
}

class _CharacterState extends State<Character> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.lightBlue,
      width: this.widget.widthHeight,
      height: this.widget.widthHeight,
      child: Center(
        child: Text(
          this.widget.character.toUpperCase(),
          key: this.widget.key,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.0,
            fontWeight: FontWeight.bold
          )
        )
      )
    );
  }
}