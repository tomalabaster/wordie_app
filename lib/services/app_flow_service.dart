import 'dart:async';

import 'package:sqflite/sqflite.dart';

class AppFlowService {

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