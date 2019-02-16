import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wordie_app/database_query_strings.dart';
import 'package:wordie_app/game_fragment.dart';
import 'package:wordie_app/models/word.dart';
import 'package:wordie_app/services/app_flow_service.dart';
import 'package:wordie_app/services/game_state_service.dart';
import 'package:wordie_app/services/word_service.dart';

void main() async {

  var databasesPath = await getDatabasesPath();
  var path = join(databasesPath, 'intellihome.db');
  var database = await openDatabase(
      path,
      version: 2,
      onCreate: (Database db, int version) async {
        await db.execute(DatabaseQueryStrings.createUsersTable);
        await db.execute(DatabaseQueryStrings.seedUsersTable);
        await db.execute(DatabaseQueryStrings.createWordsCompletedTable);
    });

  var appId = Platform.isIOS ? "ca-app-pub-8187198937216043~3354678461" : Platform.isAndroid ? "ca-app-pub-8187198937216043~2308942688" : "";

  assert(() {
    appId = FirebaseAdMob.testAppId;
    return true;
  }());

  FirebaseAdMob.instance.initialize(appId: appId);

  var analytics = FirebaseAnalytics();
  var appFlowService = AppFlowService(database);
  var gameStateService = GameStateService(database);
  var wordService = WordService();

  runApp(
    MyApp(
      analytics: analytics,
      appFlowService: appFlowService,
      gameStateService: gameStateService,
      wordService: wordService,
    )
  );
}

class MyApp extends StatelessWidget {

  final FirebaseAnalytics analytics;
  final AppFlowService appFlowService;
  final GameStateService gameStateService;
  final WordService wordService;

  const MyApp({
    Key key,
    this.analytics,
    this.appFlowService,
    this.gameStateService,
    this.wordService
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wordie',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
        analytics: this.analytics,
        appFlowService: this.appFlowService,
        gameStateService: this.gameStateService,
        wordService: this.wordService
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {

  const MyHomePage({
    Key key,
    this.analytics,
    this.appFlowService,
    this.gameStateService,
    this.wordService
  }) : super(key: key);

  final FirebaseAnalytics analytics;
  final AppFlowService appFlowService;
  final GameStateService gameStateService;
  final WordService wordService;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  BannerAd _bannerAd;
  InterstitialAd _interstitialAd;
  MobileAdTargetingInfo _targetingInfo;
  double bottomPadding = 0.0;
  FutureBuilder gameFragment;
  Word word;
  bool showSkipModal = false;
  bool skipAllowed = false;
  bool showingInterstitialAd = false;
  bool failedToLoadInterstitial = false;
  bool _loadingRewardedVideoAd = false;

  @override
  void initState() {
    super.initState();

    this.widget.analytics.logAppOpen();

    this._targetingInfo = MobileAdTargetingInfo(
      nonPersonalizedAds: true,
      testDevices: <String>[], // Android emulators are considered test devices
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

    RewardedVideoAd.instance.listener = (RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) async {
      print("RewardedVideoAd event $event");
      if (event == RewardedVideoAdEvent.rewarded || event == RewardedVideoAdEvent.completed) {
        this.setState(() {
          this.skipAllowed = true;
        });
      } else if (event == RewardedVideoAdEvent.loaded) {
        RewardedVideoAd.instance.show();
      } else if (event == RewardedVideoAdEvent.closed) {
        if (this.skipAllowed) {
          if (await this._interstitialAd.isLoaded()) {
            this.setState(() {
              this.showingInterstitialAd = true;
            });

            this._interstitialAd.show();
          } else {
            this.skip();
          }
        }
      } else if (event == RewardedVideoAdEvent.failedToLoad) {
        if (await this._interstitialAd.isLoaded()) {
          this.setState(() {
            this.showingInterstitialAd = true;
          });

          this._interstitialAd.show();
        } else {
          this.skip();
        }
      }

      this.setState(() {
        this._loadingRewardedVideoAd = false;
      });
    };
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

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: Color.fromRGBO(32, 162, 226, 1.0),
            elevation: 0.0,
            title: Center(
              child: Text(
                "Wordie",
                style: TextStyle(
                  fontFamily: 'Subscribe',
                  fontSize: 40.0
                ),
              )
            ),
            leading: Center(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.orangeAccent
                  ),
                  borderRadius: BorderRadius.circular(8.0)
                ),
                child: Padding(
                  padding: EdgeInsets.only(left: 8.0, right: 8.0),
                  child: FutureBuilder(
                    future: this.widget.gameStateService.getWordsCompletedCount(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                        return Text(
                          "${snapshot.data}",
                          style: TextStyle(
                            color: Colors.orangeAccent,
                            fontFamily: 'Subscribe',
                            fontSize: 24.0,
                            height: 1.1
                          ),
                        );
                      }

                      return Text(
                        "",
                        style: TextStyle(
                          color: Colors.orangeAccent,
                          fontFamily: 'Subscribe',
                          fontSize: 24.0,
                          height: 1.1
                        ),
                      );
                    }
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
                          this.showSkipModal = true;
                        });
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
        this.showSkipModal ? Opacity(
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
                                  "You've used your free skip for today.\n\nWatch an ad or go pro?",
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
                                        child: this._loadingRewardedVideoAd ? Transform.scale(
                                          scale: 0.5,
                                          child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          )
                                        ) : Text(
                                          "Ad",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Subscribe',
                                            fontSize: 28.0
                                          )
                                        )
                                      )
                                    ),
                                    onTap: () async {
                                      var rewardedAdUnitId = Platform.isIOS ? "" : Platform.isAndroid ? "ca-app-pub-8187198937216043/3240400883" : "";

                                      assert(() {
                                        rewardedAdUnitId = RewardedVideoAd.testAdUnitId;
                                        return true;
                                      }());

                                      this.setState(() {
                                        this._loadingRewardedVideoAd = true;
                                      });
                                      
                                      await RewardedVideoAd.instance.load(
                                        adUnitId: rewardedAdUnitId,
                                        targetingInfo: this._targetingInfo);
                                    },
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
                          onTap: () {
                            this.setState(() {
                              this.showSkipModal = false;
                            });
                          },
                        ),
                      ),
                    ]
                  )
                )
              ),
            )
          )
        ) : Container(),
        this.showingInterstitialAd ? Container(
          color: Colors.black,
        ) : Container()
      ]
    );
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
    this.skip();
  }

  void skip() {
    this.setState(() {
      this.showSkipModal = false;
      this.skipAllowed = false;
      this.showingInterstitialAd = false;
      this.gameFragment = null;
    });
  }
}
