import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wordie_app/preferences/database_query_strings.dart';
import 'package:wordie_app/screens/game_screen.dart';
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
      home: GameScreen(
        analytics: this.analytics,
        appFlowService: this.appFlowService,
        gameStateService: this.gameStateService,
        wordService: this.wordService
      ),
    );
  }
}
