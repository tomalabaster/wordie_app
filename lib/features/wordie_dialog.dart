import 'package:flutter/material.dart';

class WordieDialog extends StatelessWidget {

  final String text;
  final String buttonText;
  final Function onButtonTapped;
  final Function onCloseTapped;

  const WordieDialog({
    Key key,
    this.text,
    this.buttonText,
    this.onButtonTapped,
    this.onCloseTapped
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 1.0,
      child: Material(
        color: Colors.black.withAlpha(196),
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(left: 32.0, right: 32.0),
            child: Container(
              height: 360.0,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                      child: Container(
                        height: 360.0,
                        width: MediaQuery.of(context).size.width - 64,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            width: 4.0
                          ),
                          borderRadius: BorderRadius.circular(8.0)
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              this.text,
                              style: TextStyle(
                                fontFamily: 'Subscribe',
                                fontSize: 24.0
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 32.0),
                              child: GestureDetector(
                                child: Container(
                                  width: 128.0,
                                  height: 48.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0),
                                    color: Color.fromRGBO(32, 162, 226, 1.0)
                                  ),
                                  child: Center(
                                    child: Text(
                                      this.buttonText,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Subscribe',
                                        fontSize: 28.0
                                      )
                                    )
                                  )
                                ),
                                onTap: this.onButtonTapped
                              )
                            ),
                          ]
                        ),
                        padding: EdgeInsets.all(16.0),
                      ),
                    )
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      child: Container(
                        width: 32.0,
                        height: 32.0,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 4.0
                          ),
                          borderRadius: BorderRadius.circular(32.0),
                          color: Colors.white
                        ),
                        child: Center(
                          child: Text(
                            "X",
                            style: TextStyle(
                              fontFamily: "Subscribe",
                              fontSize: 24.0,
                              height: 1.1
                            ),
                          )
                        ),
                      ),
                      onTap: this.onCloseTapped,
                    ),
                  ),
                ]
              )
            )
          ),
        )
      )
    );
  }
}