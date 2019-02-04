import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:wordie_app/game_fragment.dart';
import 'package:wordie_app/grid.dart';
import 'package:wordie_app/models/word.dart';
import 'package:wordie_app/services/word_service.dart';

void main() {

  var appId = Platform.isIOS ? "ca-app-pub-8187198937216043~3354678461" : Platform.isAndroid ? "ca-app-pub-8187198937216043~2308942688" : "";

  FirebaseAdMob.instance.initialize(appId: FirebaseAdMob.testAppId);

  var wordService = WordService();

  runApp(
    MyApp(
      wordService: wordService,
    )
  );
}

class MyApp extends StatelessWidget {

  final WordService wordService;

  const MyApp({
    Key key,
    this.wordService
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(wordService: this.wordService),
    );
  }
}

class MyHomePage extends StatefulWidget {

  const MyHomePage({
    Key key,
    this.wordService
  }) : super(key: key);

  final WordService wordService;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  BannerAd _bannerAd;
  MobileAdTargetingInfo _targetingInfo;
  double bottomPadding = 0.0;
  GameFragment gameFragment;
  bool showSkipModal = false;
  bool skipAllowed = false;

  @override
  void initState() {
    super.initState();

    this._targetingInfo = MobileAdTargetingInfo(
      nonPersonalizedAds: true,
      testDevices: <String>[], // Android emulators are considered test devices
    );

    this._bannerAd = BannerAd(
      adUnitId: BannerAd.testAdUnitId,
      size: AdSize.smartBanner,
      targetingInfo: this._targetingInfo,
      listener: (MobileAdEvent event) {
        print("BannerAd event is $event");
        this.setState(() {
          this.bottomPadding = 50.0;
        });
      },
    )..load()..show();

    RewardedVideoAd.instance.listener = (RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) {
      print("RewardedVideoAd event $event");
      if (event == RewardedVideoAdEvent.rewarded) {
        this.setState(() {
          this.skipAllowed = rewardAmount == 1;
        });
      } else if (event == RewardedVideoAdEvent.loaded) {
        RewardedVideoAd.instance.show();
      } else if (event == RewardedVideoAdEvent.closed) {
        this.setState(() {
          this.showSkipModal = false;
          this.gameFragment = null;
        });
      }
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
      this.gameFragment = GameFragment(
        wordService: this.widget.wordService,
      );
    }

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: Color.fromRGBO(32, 162, 226, 1.0),
            elevation: 0.0,
            title: Text(
              "Wordie",
              style: TextStyle(
                fontFamily: 'Subscribe',
                fontSize: 40.0
              ),
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
                  child: Text(
                    "74",
                    style: TextStyle(
                      color: Colors.orangeAccent,
                      fontFamily: 'Subscribe',
                      fontSize: 24.0,
                      height: 1.1
                    ),
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
                    onTap: () {
                      this.setState(() {
                        this.showSkipModal = true;
                      });
                    },
                  ),
                )
              )
            ],
          ),
          backgroundColor: Color.fromRGBO(32, 162, 226, 1.0),
          body: Padding(
            padding: EdgeInsets.only(bottom: this.bottomPadding),
            child: this.gameFragment,
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
                                        child: Text(
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
                                      await RewardedVideoAd.instance.load(
                                        adUnitId: RewardedVideoAd.testAdUnitId,
                                        targetingInfo: this._targetingInfo);
                                    },
                                  )
                                ),
                                // Padding(
                                //   padding: EdgeInsets.only(top: 16.0),
                                //   child: GestureDetector(
                                //     child: Container(
                                //       width: 128.0,
                                //       height: 48.0,
                                //       decoration: BoxDecoration(
                                //         borderRadius: BorderRadius.circular(8.0),
                                //         color: Colors.green
                                //       ),
                                //       child: Center(
                                //         child: Text(
                                //           "Go pro!",
                                //           style: TextStyle(
                                //             color: Colors.white,
                                //             fontFamily: 'Subscribe',
                                //             fontSize: 28.0
                                //           )
                                //         )
                                //       )
                                //     ),
                                //   )
                                // )
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
        ) : Container()
      ]
    );
  }
}
