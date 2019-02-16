class DatabaseQueryStrings {

  static String createUsersTable = '''CREATE TABLE Users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    dateLastSkipped TEXT NOT NULL);''';

  static String createWordsCompletedTable = '''
  CREATE TABLE WordsCompleted (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    word TEXT NOT NULL,
    dateCompleted TEXT NOT NULL
  );
  ''';

  static String seedUsersTable = '''INSERT INTO Users 
    (dateLastSkipped) VALUES ("${DateTime.now().subtract(Duration(days: 1)).toIso8601String()}");''';
}