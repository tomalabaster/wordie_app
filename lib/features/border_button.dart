import 'package:flutter/material.dart';

class BorderButton extends StatelessWidget {

  final String text;
  final Function onTap;

  const BorderButton({
    Key key,
    this.text,
    this.onTap
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
          this.text,
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Subscribe',
            fontSize: 32.0
          ),
        )
      ),
      onTap: this.onTap,
    );
  }
}