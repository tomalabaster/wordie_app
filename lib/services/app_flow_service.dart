import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';

abstract class IAppFlowService {
  Future<bool> hasHadTodaysSkip();
  Future<void> setHasHadTodaysSkip(bool hasHadTodaysSkip);
}

class AppFlowService extends IAppFlowService {

  final Database _database;

  AppFlowService(this._database);

  Future<bool> hasHadTodaysSkip() async {
    var users = await this._database.query("Users");

    if (users.length == 0) {
      return true;
    } else {
      var dateTimeLastSkippedString = users[0]["dateLastSkipped"];
      var dateTimeLastSkipped = DateTime.parse(dateTimeLastSkippedString);
      var dateLastSkipped = DateTime(dateTimeLastSkipped.year, dateTimeLastSkipped.month, dateTimeLastSkipped.day);
      var today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

      return !dateLastSkipped.isBefore(today);
    }
  }

  Future<void> setHasHadTodaysSkip(bool hasHadTodaysSkip) async {
    await this._database.update(
      "Users",
      {
        "dateLastSkipped": DateTime.now().toIso8601String()
      });
  }
}

class FirebaseAppFlowService extends IAppFlowService {

  final DocumentReference _userStore;

  FirebaseAppFlowService(this._userStore);

  bool _hasHadTodaysSkip;

  @override
  Future<bool> hasHadTodaysSkip() async {
    if (this._hasHadTodaysSkip == null) {
      var snapshot = await this._userStore.get();

      if (snapshot.data.containsKey("dateLastSkipped")) {
        var dateTimeLastSkipped = DateTime.parse(snapshot.data["dateLastSkipped"]);
        var dateLastSkipped = DateTime(dateTimeLastSkipped.year, dateTimeLastSkipped.month, dateTimeLastSkipped.day);
        var today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

        this._hasHadTodaysSkip = !dateLastSkipped.isBefore(today);
      } else {
        this._hasHadTodaysSkip = false;
      }
    }

    return this._hasHadTodaysSkip;
  }

  @override
  Future<void> setHasHadTodaysSkip(bool hasHadTodaysSkip) async {
    this._hasHadTodaysSkip = hasHadTodaysSkip;

    var data = (await this._userStore.get()).data;

    data["dateLastSkipped"] = DateTime.now().toIso8601String();
    
    await this._userStore.updateData(data);
  }
}