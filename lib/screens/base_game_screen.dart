import 'dart:io';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:wordie_app/models/word.dart';
import 'package:wordie_app/services/analytics_service.dart';
import 'package:wordie_app/services/app_flow_service.dart';
import 'package:wordie_app/services/game_state_service.dart';
import 'package:wordie_app/services/word_service.dart';

abstract class BaseGameScreen extends StatefulWidget {

  final IAppFlowService appFlowService;
  final IGameStateService gameStateService;
  final IWordService wordService;
  final IAnalyticsService analyticsService;

  const BaseGameScreen({
    Key key,
    this.appFlowService,
    this.gameStateService,
    this.wordService,
    this.analyticsService
  }) : super(key: key);
}

abstract class BaseGameScreenState extends State<BaseGameScreen> with SingleTickerProviderStateMixin {

  BannerAd bannerAd;
  InterstitialAd interstitialAd;
  MobileAdTargetingInfo targetingInfo;
  double bottomPadding = 0.0;
  FutureBuilder gameFragment;
  Word word;
  bool skipAllowed = false;
  bool showingInterstitialAd = false;
  bool failedToLoadInterstitial = false;

  int numberCompleted = 0;

  @override
  void initState() {
    super.initState();

    this.widget.analyticsService.trackEvent("app_open", data: null);

    this.targetingInfo = MobileAdTargetingInfo(
      nonPersonalizedAds: true,
      testDevices: <String>["b33e7086ea0bca1ef39f2b32801854b7"], // Android emulators are considered test devices
    );

    var bannerAdUnitId = Platform.isIOS ? "" : Platform.isAndroid ? "ca-app-pub-8187198937216043/7768566190" : "";

    assert(() {
      bannerAdUnitId = RewardedVideoAd.testAdUnitId;
      return true;
    }());

    this.bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.smartBanner,
      targetingInfo: this.targetingInfo,
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
  }

  @override
  void dispose() {
    bannerAd?.dispose();
    super.dispose();
  }

  void loadNumberCompleted() async {
    var numberCompleted = await this.widget.gameStateService.getWordsCompletedCount();

    this.setState(() {
      this.numberCompleted = numberCompleted;
    });
  }

  void setupInterstitialAd() {
    var interstitialAdUnitId = Platform.isIOS ? "" : Platform.isAndroid ? "ca-app-pub-8187198937216043/3516443492" : "";

    assert(() {
      interstitialAdUnitId = InterstitialAd.testAdUnitId;
      return true;
    }());
    
    this.interstitialAd = InterstitialAd(
      adUnitId: interstitialAdUnitId,
      targetingInfo: this.targetingInfo,
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
    
    var analyticsEvent = "";
    var analyticsData = {
      "word": this.word.word,
      "description": this.word.description
    };

    if (wordFound) {
      analyticsEvent = "word_found";
    } else {
      analyticsEvent = "word_skipped";
      await this.widget.gameStateService.setWordSkipped(this.word);
    }
    
    await this.widget.analyticsService.trackEvent(
      analyticsEvent,
      data: analyticsData
    );
  }
}