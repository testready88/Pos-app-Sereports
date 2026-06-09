// Stub file for web platform - provides type stubs for sqflite
// ignore_for_file: avoid_print, unused_import

// Stub Database class for web
class Database {
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    throw UnimplementedError('Database.query not available on web');
  }

  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    throw UnimplementedError('Database.insert not available on web');
  }

  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    throw UnimplementedError('Database.update not available on web');
  }

  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    throw UnimplementedError('Database.delete not available on web');
  }

  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    throw UnimplementedError('Database.rawQuery not available on web');
  }

  Future<void> execute(String sql, [List<Object?>? arguments]) async {
    throw UnimplementedError('Database.execute not available on web');
  }

  Future<void> close() async {
    throw UnimplementedError('Database.close not available on web');
  }
}

// Stub ConflictAlgorithm for web
class ConflictAlgorithm {
  static const ConflictAlgorithm replace = ConflictAlgorithm._();
  const ConflictAlgorithm._();
}

// Stub getDatabasesPath for web
Future<String> getDatabasesPath() async {
  throw UnimplementedError('getDatabasesPath not available on web');
}

// Stub openDatabase for web
Future<Database> openDatabase(
  String path, {
  int? version,
  void Function(Database db, int version)? onCreate,
  void Function(Database db, int oldVersion, int newVersion)? onUpgrade,
}) async {
  throw UnimplementedError('openDatabase not available on web');
}

// Stub join function from path package for web
String join(String part1,
    [String? part2,
    String? part3,
    String? part4,
    String? part5,
    String? part6,
    String? part7,
    String? part8,
    String? part9,
    String? part10,
    String? part11,
    String? part12,
    String? part13,
    String? part14,
    String? part15,
    String? part16]) {
  throw UnimplementedError('path.join not available on web');
}
