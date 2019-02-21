import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wordie_app/models/word.dart';
import 'package:wordie_app/preferences/database_query_strings.dart';
import 'package:wordie_app/screens/about_screen.dart';
import 'package:wordie_app/screens/game_screen.dart';
import 'package:wordie_app/screens/home_screen.dart';
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

  await Firestore.instance.settings(
    timestampsInSnapshotsEnabled: true
  );
  
  var user = await FirebaseAuth.instance.signInAnonymously();
  print(user.uid);

  var userStore =  Firestore.instance.collection('users').document(user.uid);
  var wordsCollection = Firestore.instance.collection('words');

  var analytics = FirebaseAnalytics();
  var appFlowService = FirebaseAppFlowService(userStore);
  var gameStateService = FirebaseGameStateService(userStore);
  var wordService = FirebaseWordService(wordsCollection);

  var oldGameStateService = GameStateService(database);

  await migrateIfNeeded(oldGameStateService, gameStateService, database);

  runApp(
    MyApp(
      analytics: analytics,
      appFlowService: appFlowService,
      gameStateService: gameStateService,
      wordService: wordService,
    )
  );
}

Future<void> migrateIfNeeded(IGameStateService oldService, IGameStateService newService, Database database) async {
  if ((await oldService.getWordsCompletedCount()) > 0) {
    var oldCompletedWordsRaw = await database.query("WordsCompleted");
    var oldCompletedWords = oldCompletedWordsRaw.map((word) => word["word"]);

    for (var word in oldCompletedWords) {
      await newService.setWordCompleted(Word(word, ""));
    }

    await database.delete("WordsCompleted");
  }
}

class MyApp extends StatelessWidget {

  final FirebaseAnalytics analytics;
  final IAppFlowService appFlowService;
  final IGameStateService gameStateService;
  final IWordService wordService;

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
      routes: {
        '/': (context) => HomeScreen(),
        '/game': (context) => GameScreen(
          analytics: this.analytics,
          appFlowService: this.appFlowService,
          gameStateService: this.gameStateService,
          wordService: this.wordService
        ),
        '/about': (context) => AboutScreen()
      },
    );
  }
}
