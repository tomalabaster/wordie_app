import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wordie_app/models/word.dart';

abstract class IGameStateService {
  Future<void> setWordCompleted(Word word);
  Future<int> getWordsCompletedCount();
}

class GameStateService extends IGameStateService {

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

class FirebaseGameStateService extends IGameStateService {

  final DocumentReference _userStore;

  FirebaseGameStateService(this._userStore);
  
  @override
  Future<int> getWordsCompletedCount() async {
    var snapshot = await this._userStore.get();

    if (snapshot.data.containsKey("words")) {
      return (snapshot.data["words"] as List).length;
    }

    return 0;
  }

  @override
  Future<void> setWordCompleted(Word word) async {
    var data = (await this._userStore.get()).data;

    data["words"] = FieldValue.arrayUnion([word.word]);
    
    await this._userStore.updateData(data);
  }

}