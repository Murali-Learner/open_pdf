import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:open_pdf/utils/enumerates.dart';

class PdfControlProvider with ChangeNotifier {
  PDFViewController? _pdfController;
  int _pdfCurrentPage = 1;
  int _totalPages = 0;
  String _errorMessage = '';
  bool _showPdfControlButtons = false;
  double _currentZoomLevel = 1.0;
  PdfScrollMode _pdfScrollMode = PdfScrollMode.vertical;
  bool _showPdfTools = false;
  bool _showAppbar = true;
  bool _considerScroll = false;

  PDFViewController? get pdfController => _pdfController;
  int get pdfCurrentPage => _pdfCurrentPage;
  int get totalPages => _totalPages;
  double get currentZoomLevel => _currentZoomLevel;
  PdfScrollMode get pdfScrollMode => _pdfScrollMode;
  String get errorMessage => _errorMessage;

  bool get showPdfTools => _showPdfTools;
  void setPdfToolsVisibility(bool value) {
    _showPdfTools = value;
    notifyListeners();
  }

  bool get showAppbar => _showAppbar;
  void setAppBarVisibility(bool value) {
    _showAppbar = value;
    notifyListeners();
  }

  bool get considerScroll => _considerScroll;
  void setConsiderScroll(bool value) {
    _considerScroll = value;
    notifyListeners();
  }

  void setTotalPages(int pages) {
    _totalPages = pages;
    notifyListeners();
  }

  void resetValues() {
    _pdfCurrentPage = 1;
    _totalPages = 0;
    _errorMessage = "";
    _showPdfControlButtons = false;
    _currentZoomLevel = 0.0;
    _showAppbar = true;
    _showPdfTools = false;
    notifyListeners();
  }

  void setPdfControlButtons(
    bool showButtons,
  ) {
    _showPdfControlButtons = showButtons;
    debugPrint("_showPdfControlButtons $_showPdfControlButtons");
    notifyListeners();
  }

  void setScrollMode(PdfScrollMode mode) {
    _pdfScrollMode = mode;
    notifyListeners();
  }

  void setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void setPdfController(PDFViewController controller) {
    _pdfController = controller;
    notifyListeners();
  }

  void setCurrentPage(int page) {
    if (page >= 0 && page < _totalPages) {
      _pdfCurrentPage = page;
      notifyListeners();
    }
  }

  Future<void> gotoPage(int page) async {
    log("goto page number $page  $_pdfCurrentPage");
    if (_pdfController != null && _pdfCurrentPage <= _totalPages) {
      _pdfCurrentPage = page;
      if (page == 1) {
        await _pdfController!.setPage(0);
      } else {
        await _pdfController!.setPage(_pdfCurrentPage);
      }
      notifyListeners();
    }
  }

  Future<void> nextPage() async {
    log("im here next page ${_pdfCurrentPage + 1}");
    if (_pdfCurrentPage < _totalPages - 1) {
      await _pdfController!.setPage(_pdfCurrentPage);
      notifyListeners();
    }
  }

  Future<void> previousPage() async {
    if (_pdfController != null && _pdfCurrentPage > 0) {
      await _pdfController!.setPage(_pdfCurrentPage - 1 - 1);
      notifyListeners();
    }
  }

  Future<void> gotoFirstPage() async {
    if (_pdfController != null && _pdfCurrentPage > 0) {
      _pdfCurrentPage = 0;
      await _pdfController!.setPage(_pdfCurrentPage);
      notifyListeners();
    }
  }

  Future<void> gotoLastPage() async {
    if (_pdfController != null && _pdfCurrentPage < _totalPages - 1) {
      _pdfCurrentPage = _totalPages;
      await _pdfController!.setPage(_pdfCurrentPage);
      notifyListeners();
    }
  }

  Future<void> zoomIn() async {
    if (_pdfController != null) {
      _currentZoomLevel += 0.5;
      // await _pdfController!.setZoom(_currentZoomLevel);
      notifyListeners();
    }
  }

  Future<void> zoomOut() async {
    if (_pdfController != null && _currentZoomLevel > 0.5) {
      _currentZoomLevel -= 0.5;
      // await _pdfController!.setZoom(_currentZoomLevel);
      notifyListeners();
    }
  }

  Future<void> resetZoom() async {
    if (_pdfController != null) {
      _currentZoomLevel = 1.0;
      // await _pdfController!.setZoom(_currentZoomLevel);
      notifyListeners();
    }
  }
}
