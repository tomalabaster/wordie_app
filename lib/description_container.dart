import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:wordie_app/models/word.dart';

class DescriptionContainer extends StatelessWidget {

  final Word word;

  const DescriptionContainer({Key key, this.word}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
                this.word.description,
                style: TextStyle(
                  color: Color.fromRGBO(32, 162, 226, 1.0),
                  fontFamily: 'Subscribe'
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
              )
            )
          )
        )
      )
    );
  }
}