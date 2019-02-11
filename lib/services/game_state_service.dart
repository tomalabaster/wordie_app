import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:wordie_app/models/word.dart';

class GameStateService {

  final Database _database;

  GameStateService(this._database);

  Future<void> setWordCompleted(Word word) async {
    await this._database.insert(
      "WordsCompleted",
      {
        "word": word.word,
        "dateCompleted": DateTime.now().toIso8601String()
      });
  }

  Future<int> getWordsCompletedCount() async {
    var wordsCompleted = await this._database.query("WordsCompleted");

    return wordsCompleted.length;
  }
}