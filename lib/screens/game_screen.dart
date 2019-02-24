import 'package:flutter/material.dart';
import 'package:wordie_app/screens/base_game_screen.dart';
import 'package:wordie_app/screens/fragments/game_fragment.dart';
import 'package:wordie_app/services/analytics_service.dart';
import 'package:wordie_app/services/app_flow_service.dart';
import 'package:wordie_app/services/game_state_service.dart';
import 'package:wordie_app/services/word_service.dart';

class GameScreen extends BaseGameScreen {

  const GameScreen({
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
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends BaseGameScreenState {

  @override
  void initState() {
    super.initState();

    this.loadNumberCompleted();
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
                  this.numberCompleted == 0 ? "Wordie" : "${this.numberCompleted}",
                  style: TextStyle(
                    fontFamily: 'Subscribe',
                    fontSize: 40.0
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
                        "Skip",
                        style: TextStyle(
                          fontFamily: 'Subscribe',
                          fontSize: 24.0
                        ),
                      ),
                      onTap: () async {
                        if (await this.widget.appFlowService.hasHadTodaysSkip()) {
                          this.setState(() {
                            this.showingInterstitialAd = true;
                          });

                          this.interstitialAd.show();
                        } else {
                          await this.widget.appFlowService.setHasHadTodaysSkip(true);

                          this.skip();
                        }
                      },
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
          ) : Container()
        ]
      )
    );
  }
}
