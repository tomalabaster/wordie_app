import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wordie_app/features/wordie_dialog.dart';
import 'package:wordie_app/screens/base_game_screen.dart';
import 'package:wordie_app/screens/fragments/game_fragment.dart';
import 'package:wordie_app/services/analytics_service.dart';
import 'package:wordie_app/services/app_flow_service.dart';
import 'package:wordie_app/services/game_state_service.dart';
import 'package:wordie_app/services/word_service.dart';

class SpeedRoundScreen extends BaseGameScreen {

  const SpeedRoundScreen({
    Key key,
    this.analyticsService,
    this.appFlowService,
    this.gameStateService,
    this.wordService
  }) : super(
    key: key,
    analyticsService: analyticsService,
    appFlowService: appFlowService,
    gameStateService: gameStateService,
    wordService: wordService
  );

  final IAppFlowService appFlowService;
  final IGameStateService gameStateService;
  final IWordService wordService;
  final IAnalyticsService analyticsService;

  @override
  _SpeedRoundScreenState createState() => _SpeedRoundScreenState();
}

class _SpeedRoundScreenState extends BaseGameScreenState {

  DateTime _timeStarted;
  double _timeRemaining;
  Timer _timeRemainingTimer;
  bool _finished;
  AnimationController _flashingController;
  int _speedRoundNumberCompleted;

  @override
  void initState() {
    super.initState();

    this._timeStarted = DateTime.now();
    this._timeRemaining = 60.0;
    this._finished = false;
    this._speedRoundNumberCompleted = 0;

    this.setupTimer();

    this._flashingController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    )..addListener(() {
      this.setState((){});
    });
  }

  @override
  void dispose() {
    this._timeRemainingTimer.cancel();
    this._flashingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (this.gameFragment == null) {
      this.gameFragment = FutureBuilder(
        future: this.widget.wordService.getNewWord(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            this.word = snapshot.data;
            
            return GameFragment(
              word: snapshot.data,
              onWordFound: () => this.onWordFound(),
            );
          }

          return CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          );
        },
      );
    }

    return WillPopScope(
      onWillPop: () {},
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              backgroundColor: Color.fromRGBO(32, 162, 226, 1.0),
              elevation: 0.0,
              title: Center(
                child: Text(
                  this._timeRemaining.toStringAsFixed(1),
                  style: TextStyle(
                    fontFamily: 'Subscribe',
                    fontSize: 40.0,
                    color: this._flashingController.value < 0.5 ? Colors.white : Colors.red
                  ),
                )
              ),
              leading: Center(
                child: Container(
                  child: Padding(
                    padding: EdgeInsets.only(left: 8.0, right: 8.0),
                    child: GestureDetector(
                      child: Icon(
                        Icons.home,
                        color: Colors.white,
                        size: 32.0,
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    )
                  )
                )
              ),
              actions: <Widget>[
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: GestureDetector(
                      child: Text(
                        this._timeRemainingTimer.isActive ? "Skip" : "Play",
                        style: TextStyle(
                          fontFamily: 'Subscribe',
                          fontSize: 24.0
                        ),
                      ),
                      onTap: this._timeRemainingTimer.isActive ? this.skipButtonPressed : this.play,
                    ),
                  )
                )
              ],
            ),
            backgroundColor: Color.fromRGBO(32, 162, 226, 1.0),
            body: Padding(
              padding: EdgeInsets.only(bottom: this.bottomPadding),
              child: Center(
                child: this.gameFragment
              )
            )
          ),
          this.showingInterstitialAd ? Container(
            color: Colors.black,
          ) : Container(),
          this._finished ? WordieDialog(
            text: "Nice one! You scored...\n\n${this._speedRoundNumberCompleted}",
            buttonText: "Play again!",
            onButtonTapped: this.play,
            onCloseTapped: () {
              this.setState(() {
                this._finished = false;
              });
            },
          ) : Container()
        ]
      )
    );
  }

  @override
  void onWordFound() {
    super.onWordFound();
    
    this._speedRoundNumberCompleted += 1;
  }

  void setupTimer() {
    this._timeRemainingTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      this.setState(() {
        this._timeRemaining = 60.0 - DateTime.now().difference(this._timeStarted).inMilliseconds / 1000;
        if (this._timeRemaining <= 0.0) {
          this._timeRemaining = 0.0;
          this._finished = true;
          this._timeRemainingTimer.cancel();
          this._flashingController.repeat();
          this.showingInterstitialAd = true;
          this.interstitialAd.show();
        }
      });
    });
  }

  void play() {
    this.setState(() {
      this._timeStarted = DateTime.now();
      this._timeRemaining = 60.0;
      this._finished = false;
      this._flashingController.reset();
      this.showingInterstitialAd = false;
      this._speedRoundNumberCompleted = 0;
      this.setupTimer();
    });
  }
}
