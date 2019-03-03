import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:wordie_app/services/game_state_service.dart';

class MockDocumentReference extends Mock implements DocumentReference {}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}

void main() {

  group("when getting words completed count", () {
    
    test('if the user is new, 0 is returned', () async {
      // arrange
      var mockUserStore = MockDocumentReference();
      var mockUserSnapshot = MockDocumentSnapshot();

      when(mockUserSnapshot.data).thenReturn({});
      when(mockUserStore.get()).thenAnswer((_) => Future.value(mockUserSnapshot));

      var gameStateService = FirebaseGameStateService(mockUserStore);

      // act
      var wordsCompletedCount = await gameStateService.getWordsCompletedCount();

      // assert
      expect(wordsCompletedCount, 0);
    });

    test('if the user has completed words, the number of completed words is returned', () async {
      // arrange
      var mockUserStore = MockDocumentReference();
      var mockUserSnapshot = MockDocumentSnapshot();

      when(mockUserSnapshot.data).thenReturn({
        "words": ["word1", "word2", "word3", "word4", "word5"]
      });
      when(mockUserStore.get()).thenAnswer((_) => Future.value(mockUserSnapshot));

      var gameStateService = FirebaseGameStateService(mockUserStore);

      // act
      var wordsCompletedCount = await gameStateService.getWordsCompletedCount();

      // assert
      expect(wordsCompletedCount, 5);
    });
  });
}

// class MockDocumentReference extends Mock implements DocumentReference {

//   MockDocumentSnapshot _snapshot = MockDocumentSnapshot({});

//   @override
//   Future<DocumentSnapshot> get() {
//     return Future.value(this._snapshot);
//   }
  
//   @override
//   Future<void> updateData(Map<String, dynamic> data) {
//     this._snapshot.data = data;
//     return (){}();
//   }

//   @override
//   Future<void> setData(Map<String, dynamic> data, {bool merge = false}) {
//     this._snapshot.data = data;
//     return (){}();
//   }
// }
// class MockDocumentSnapshot extends Mock implements DocumentSnapshot {

//   Map<String, dynamic> _data = {};

//   MockDocumentSnapshot(this._data);

//   @override
//   Map<String, dynamic> get data => this._data;

//   set data(Map<String, dynamic> data) {
//     this._data = data;
//   }
// }