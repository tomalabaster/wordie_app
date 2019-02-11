import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:wordie_app/models/word.dart';

class WordService {

  List<String> _words;

  Future<Word> getNewWord({int length = 0}) async {
    if (this._words == null) {
      this._words = await this.loadWords();
      this._words = this._words.where((word) => word.length < 6).toList();
    }

    if (length > 0) {
      _words = _words.where((word) => word.length == length).toList();
    }

    String word;
    String description;

    while (description == null) {
      word = _words[Random().nextInt(_words.length)];
      description = await this._getDescriptionForWord(word);
    }

    description = description[0].toUpperCase() + description.substring(1) + (description[description.length -1] == '.' ? '' : '.');

    return new Word(word, description);
  }
  
  Future<String> _getDescriptionForWord(String word) async {
    var descriptionResponse = await http.get(
      "https://od-api.oxforddictionaries.com:443/api/v1/entries/en/$word",
      headers: {
        "app_id": "8cd1b1f3",
        "app_key": "a20594df9253da18316269048a9faa1f"
      }
    );

    if (descriptionResponse.body != null) {
      if (descriptionResponse.statusCode == 404) {
        return null;
      }
      
      var json = jsonDecode(descriptionResponse.body) as Map<String, dynamic>;

      if (json.containsKey("results")) {
        var results = json["results"] as List;

        if (results.length > 0) {
          var result = results[0];

          var lexicalEntries = result["lexicalEntries"] as List;

          if (lexicalEntries.length > 0) {
            var lexicalEntry = lexicalEntries[0];

            var entries = lexicalEntry["entries"] as List;

            if (entries.length > 0) {
              var entry = entries[0];

              var senses = entry["senses"];
              
              if (senses.length > 0) {
                var sense = senses[0];

                var definitions = sense["definitions"] as List<dynamic>;

                if (definitions.length > 0) {
                  return definitions[0];
                }
              }
            }
          }
        }
      }
    }

    return null;
  }

  Future loadWords() async {
    var wordsString =  await rootBundle.loadString('assets/words.json');
    var parsedWords = json.decode(wordsString)["words"];
    return parsedWords.cast<String>();
  }
} 