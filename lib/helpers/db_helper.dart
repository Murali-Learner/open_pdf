import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_pdf/utils/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class SearchDbHelper {
  static Database? _database;
  static final SearchDbHelper _instance = SearchDbHelper._internal();

  factory SearchDbHelper() {
    return _instance;
  }

  SearchDbHelper._internal() {
    _initializeDatabase();
  }

  static Future<Database> get database async {
    _database ??= await _initializeDatabase();
    return _database!;
  }

  static Future<Database> _initializeDatabase() async {
    try {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = '${documentsDirectory.path}/eng_dictionary.db';
      bool dbExists = await File(path).exists();

      if (!dbExists) {
        ByteData data = await rootBundle.load(Constants.dictionaryAsset);
        List<int> bytes =
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

        await File(path).writeAsBytes(bytes, flush: true);
      }
      _database = await openDatabase(path, readOnly: true);
    } catch (e) {
      debugPrint("Error trying to get database: $e");
      rethrow;
    }
    return _database!;
  }

  static Future<List<Map<String, dynamic>>> searchWord(String query) async {
    try {
      final db = await database;
      var res = await db.query(
        'words',
        where: 'en_word LIKE ?',
        whereArgs: ['%$query%'],
      );
      return res;
    } catch (e) {
      debugPrint("error querying database $e");
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> fetchAllWords() async {
    final db = await database;
    return await db.query(
      'words',
      limit: 100,
    );
  }
}
