import 'package:flutter/material.dart';
import 'package:open_pdf/helpers/db_helper.dart';
import 'package:open_pdf/models/word_model.dart';

class DictionaryProvider with ChangeNotifier {
  DictionaryProvider() {
    fetchAllWords();
  }

  final Map<int, Word> _results = {};
  bool _isLoading = false;
  bool _showClearButton = false;

  Map<int, Word> get results => _results;
  bool get isLoading => _isLoading;
  bool get showClearButton => _showClearButton;

  void toggleClearButton(bool value) {
    _showClearButton = value;
    notifyListeners();
  }

  void clearResults() {
    _results.clear();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchWord(String query) async {
    if (query.isEmpty) return;

    _isLoading = true;
    _results.clear();
    notifyListeners();

    try {
      List<Map<String, dynamic>> results =
          await SearchDbHelper.searchWord(query);
      for (var result in results) {
        Word word = Word.fromMap(result);
        _results[word.id] = word;
      }
      debugPrint("Search Words ${results.length}");
    } catch (e) {
      debugPrint('Error searching word: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllWords() async {
    _isLoading = true;
    _results.clear();
    notifyListeners();

    try {
      List<Map<String, dynamic>> results = await SearchDbHelper.fetchAllWords();
      for (var result in results) {
        Word word = Word.fromMap(result);
        _results[word.id] = word;
      }
    } catch (e) {
      debugPrint('Error fetching words: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
