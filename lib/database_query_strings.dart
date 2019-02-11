class DatabaseQueryStrings {

  static String createUsersTable = '''CREATE TABLE Users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    dateLastSkipped TEXT NOT NULL);''';

  static String seedUsersTable = '''INSERT INTO Users 
    (dateLastSkipped) VALUES ("${DateTime.now().subtract(Duration(days: 1)).toIso8601String()}");''';
}