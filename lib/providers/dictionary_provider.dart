import 'package:flutter/material.dart';
import 'package:open_pdf/helpers/db_helper.dart';
import 'package:open_pdf/models/word_model.dart';
import 'package:wikipedia/wikipedia.dart';

class DictionaryProvider with ChangeNotifier {
  DictionaryProvider() {
    fetchAllWords();
  }

  final Map<int, Word> _results = {};
  List<WikipediaSearch> _wikiResults = [];
  bool _isLoading = false;
  bool _isWikiLoading = false;
  bool _showClearButton = false;

  Map<int, Word> get results => _results;
  List<WikipediaSearch> get wikiResults => _wikiResults;
  bool get isLoading => _isLoading;
  bool get isWikiLoading => _isWikiLoading;
  bool get showClearButton => _showClearButton;

  void toggleClearButton(bool value) {
    _showClearButton = value;
    notifyListeners();
  }

  void clearResults() {
    _results.clear();
    _isLoading = false;
    _wikiResults.clear();
    notifyListeners();
  }

  Future<void> searchWikipedia(String query) async {
    _isWikiLoading = true;
    try {
      _wikiResults.clear();
      notifyListeners();
      Wikipedia wikipedia = Wikipedia();
      var wikiResult =
          await wikipedia.searchQuery(searchQuery: query, limit: 10);

      if (wikiResult != null && wikiResult.query != null) {
        _wikiResults = wikiResult.query!.search!;
      } else {
        _wikiResults.clear();
      }
    } catch (e) {
      debugPrint('Error fetching Wikipedia results: $e');
    } finally {
      _isWikiLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchWord(String query) async {
    if (query.isEmpty) return;

    try {
      List<Map<String, dynamic>> results =
          await SearchDbHelper.searchWord(query);

      _isLoading = true;
      _results.clear();
      notifyListeners();

      for (var result in results) {
        Word word = Word.fromMap(result);
        _results[word.id] = word;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error searching word: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllWords() async {
    try {
      List<Map<String, dynamic>> results = await SearchDbHelper.fetchAllWords();
      _isLoading = true;
      _results.clear();
      notifyListeners();
      for (var result in results) {
        Word word = Word.fromMap(result);
        _results[word.id] = word;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching words: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
