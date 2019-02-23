import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:appcenter/appcenter.dart';
import 'package:appcenter_analytics/appcenter_analytics.dart';
import 'package:appcenter_crashes/appcenter_crashes.dart';
import 'package:wordie_app/models/word.dart';
import 'package:wordie_app/preferences/database_query_strings.dart';
import 'package:wordie_app/screens/about_screen.dart';
import 'package:wordie_app/screens/game_screen.dart';
import 'package:wordie_app/screens/home_screen.dart';
import 'package:wordie_app/screens/speed_round_screen.dart';
import 'package:wordie_app/services/analytics_service.dart';
import 'package:wordie_app/services/app_flow_service.dart';
import 'package:wordie_app/services/game_state_service.dart';
import 'package:wordie_app/services/word_service.dart';

void main() async {

  await setupAppCenter();
  await setupAdMob();
  await setupFirestore();

  var database = await setupDatabase();
  
  var user = await FirebaseAuth.instance.signInAnonymously();
  print(user.uid);

  var userStore = Firestore.instance.collection('users').document(user.uid);
  var wordsCollection = Firestore.instance.collection('words');

  if (!(await userStore.get()).exists) {
    userStore.setData({});
  }

  var analytics = await setupFirebaseAnalytics(user.uid);
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
      analyticsService: MultiAnalyticsProviderService([
        FirebaseAnalyticsService(analytics),
        AppCenterAnalyticsService()
      ]),
    )
  );
}

Future<void> setupAppCenter() async {
  var appSecret = Platform.isIOS ? "50cec087-cf57-45cf-9710-efd77455e0e0" : Platform.isAndroid ? "df941685-d68f-4856-9fe5-40f1025fb3f9" : "";

  await AppCenter.start(appSecret, [AppCenterAnalytics.id, AppCenterCrashes.id]);

  assert(await () async {
    await AppCenterAnalytics.setEnabled(false);
    return true;
  }(), true);
}

Future<void> setupAdMob() async {
  var appId = Platform.isIOS ? "ca-app-pub-8187198937216043~3354678461" : Platform.isAndroid ? "ca-app-pub-8187198937216043~2308942688" : "";

  assert(() {
    appId = FirebaseAdMob.testAppId;
    return true;
  }());

  FirebaseAdMob.instance.initialize(appId: appId);
}

Future<void> setupFirestore() async {
  await Firestore.instance.settings(
    timestampsInSnapshotsEnabled: true
  );
}

Future<FirebaseAnalytics> setupFirebaseAnalytics(String userId) async {
  var analytics = FirebaseAnalytics();

  assert(await () async {
    if (Platform.isAndroid) {
      await analytics.android.setAnalyticsCollectionEnabled(false);
    }
    return true;
  }(), true);

  await analytics.logLogin();
  await analytics.setUserId(userId);

  return analytics;
}

Future<Database> setupDatabase() async {
  var databasesPath = await getDatabasesPath();
  var path = join(databasesPath, 'intellihome.db');
  return await openDatabase(
      path,
      version: 2,
      onCreate: (Database db, int version) async {
        await db.execute(DatabaseQueryStrings.createUsersTable);
        await db.execute(DatabaseQueryStrings.seedUsersTable);
        await db.execute(DatabaseQueryStrings.createWordsCompletedTable);
    });
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
  final IAnalyticsService analyticsService;

  const MyApp({
    Key key,
    this.analytics,
    this.appFlowService,
    this.gameStateService,
    this.wordService,
    this.analyticsService
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wordie',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorObservers: [FirebaseAnalyticsObserver(analytics: this.analytics)],
      routes: {
        '/': (context) => HomeScreen(analytics: this.analytics),
        '/game': (context) => GameScreen(
          analyticsService: this.analyticsService,
          appFlowService: this.appFlowService,
          gameStateService: this.gameStateService,
          wordService: this.wordService
        ),
        '/speed_round': (context) => SpeedRoundScreen(
          analyticsService: this.analyticsService,
          appFlowService: this.appFlowService,
          gameStateService: this.gameStateService,
          wordService: this.wordService
        ),
        '/about': (context) => AboutScreen()
      },
    );
  }
}
