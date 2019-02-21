import 'dart:io';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:wordie_app/models/word.dart';
import 'package:wordie_app/screens/fragments/game_fragment.dart';
import 'package:wordie_app/services/app_flow_service.dart';
import 'package:wordie_app/services/game_state_service.dart';
import 'package:wordie_app/services/word_service.dart';

class GameScreen extends StatefulWidget {

  const GameScreen({
    Key key,
    this.analytics,
    this.appFlowService,
    this.gameStateService,
    this.wordService
  }) : super(key: key);

  final FirebaseAnalytics analytics;
  final IAppFlowService appFlowService;
  final IGameStateService gameStateService;
  final IWordService wordService;

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {

  BannerAd _bannerAd;
  InterstitialAd _interstitialAd;
  MobileAdTargetingInfo _targetingInfo;
  double bottomPadding = 0.0;
  FutureBuilder gameFragment;
  Word word;
  bool skipAllowed = false;
  bool showingInterstitialAd = false;
  bool failedToLoadInterstitial = false;

  int _numberCompleted = 0;

  @override
  void initState() {
    super.initState();

    this.widget.analytics.logAppOpen();

    this._targetingInfo = MobileAdTargetingInfo(
      nonPersonalizedAds: true,
      testDevices: <String>["b33e7086ea0bca1ef39f2b32801854b7"], // Android emulators are considered test devices
    );

    var bannerAdUnitId = Platform.isIOS ? "" : Platform.isAndroid ? "ca-app-pub-8187198937216043/7768566190" : "";

    assert(() {
      bannerAdUnitId = RewardedVideoAd.testAdUnitId;
      return true;
    }());

    this._bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.smartBanner,
      targetingInfo: this._targetingInfo,
      listener: (MobileAdEvent event) {
        print("BannerAd event is $event");
        
        if (event == MobileAdEvent.loaded) {
          this.setState(() {
            this.bottomPadding = 50.0;
          });
        } else if (event == MobileAdEvent.failedToLoad || event == MobileAdEvent.closed) {
          this.setState(() {
            this.bottomPadding = 0.0;
          });
        }
      },
    )..load()..show();

    this.setupInterstitialAd();

    this.loadNumberCompleted();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
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
                  this._numberCompleted == 0 ? "Wordie" : "${this._numberCompleted}",
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

                          this._interstitialAd.show();
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

  void loadNumberCompleted() async {
    var numberCompleted = await this.widget.gameStateService.getWordsCompletedCount();

    this.setState(() {
      this._numberCompleted = numberCompleted;
    });
  }

  void setupInterstitialAd() {
    var interstitialAdUnitId = Platform.isIOS ? "" : Platform.isAndroid ? "ca-app-pub-8187198937216043/3516443492" : "";

    assert(() {
      interstitialAdUnitId = InterstitialAd.testAdUnitId;
      return true;
    }());
    
    this._interstitialAd = InterstitialAd(
      adUnitId: interstitialAdUnitId,
      targetingInfo: this._targetingInfo,
      listener: (event) {
        print("Interstitial ad event: $event");

        if (event == MobileAdEvent.closed) {
          this.skip();
          this.setupInterstitialAd();
        } else if (event == MobileAdEvent.loaded) {
          this.failedToLoadInterstitial = false;
        } else if (event == MobileAdEvent.failedToLoad) {
          this.failedToLoadInterstitial = true;
        }
      }
    )..load();
  }

  void onWordFound() async {
    await this.widget.gameStateService.setWordCompleted(this.word);
    this.skip(
      wordFound: true
    );
    this.loadNumberCompleted();
  }

  void skip({wordFound = false}) async {
    this.setState(() {
      this.skipAllowed = false;
      this.showingInterstitialAd = false;
      this.gameFragment = null;
    });

    if (!wordFound) {
      await this.widget.gameStateService.setWordSkipped(this.word);
    }
  }
}
