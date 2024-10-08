import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:open_pdf/utils/constants.dart';
import 'package:pdf_render/pdf_render_widgets.dart';
import 'package:pdfx/pdfx.dart';

class PdfControlProvider with ChangeNotifier {
  // PDFViewController? _pdfController;
  // PdfViewerController viewerController = PdfViewerController();
  PdfControllerPinch? pinchController;

  bool _isLoading = false;
  int _pdfCurrentPage = 1;
  int _totalPages = 0;

  String _errorMessage = '';
  bool _showPdfControlButtons = false;
  double _currentZoomLevel = 1.0;
  Axis _pdfScrollMode = Axis.vertical;
  bool _showPdfTools = false;
  bool _showAppbar = true;
  bool _considerScroll = false;

  // PDFViewController? get pdfController => _pdfController;
  int get pdfCurrentPage => _pdfCurrentPage;
  int get totalPages => _totalPages;
  double get currentZoomLevel => _currentZoomLevel;
  Axis get pdfScrollMode => _pdfScrollMode;
  String get errorMessage => _errorMessage;

  bool get isLoading => _isLoading;
  void setIsLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

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

  void init(PdfControllerPinch controller) {
    pinchController = controller;
    notifyListeners();
  }

  void setPdfControlButtons(
    bool showButtons,
  ) {
    _showPdfControlButtons = showButtons;
    debugPrint("_showPdfControlButtons $_showPdfControlButtons");
    notifyListeners();
  }

  void setScrollMode(Axis mode) {
    _pdfScrollMode = mode;
    notifyListeners();
  }

  void setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  // void setPdfController(PDFViewController controller) {
  //   // _pdfController = controller;
  //   notifyListeners();
  // }

  void setPdfViewController(PdfViewerController controller) {
    log("setPdfViewController ${controller.pageCount}");
    // setCurrentPage(controller.currentPageNumber);
    // notifyListeners();
  }

  void setCurrentPage(int page) {
    if (page >= 0 && page < _totalPages) {
      _pdfCurrentPage = page;
      notifyListeners();
    }
  }

  Future<void> gotoPage(int page) async {
    log("goto page number $page  $_pdfCurrentPage");
    if (pinchController != null && _pdfCurrentPage <= _totalPages) {
      _pdfCurrentPage = page;

      pinchController!.animateToPage(pageNumber: page);

      notifyListeners();
    }
  }

  Future<void> nextPage() async {
    if (pinchController != null && _pdfCurrentPage <= _totalPages) {
      log("im here next page ${pinchController!.page}");
      pinchController!
          .nextPage(duration: Constants.globalDuration, curve: Curves.easeIn);
      setCurrentPage(pinchController!.page);
      // _pdfCurrentPage = _pdfCurrentPage + 1;

      notifyListeners();
    }
  }

  Future<void> previousPage() async {
    if (pinchController != null && _pdfCurrentPage > 0) {
      log("im here previous page $_pdfCurrentPage");
      pinchController!.previousPage(
          duration: Constants.globalDuration, curve: Curves.easeIn);
      setCurrentPage(pinchController!.page);
      // _pdfCurrentPage = _pdfCurrentPage - 1;
      notifyListeners();
    }
  }

  // Future<void> gotoFirstPage() async {
  //   if (pinchController != null && _pdfCurrentPage > 0) {
  //     _pdfCurrentPage = 0;
  //     pinchController!.jumpToPage(_pdfCurrentPage);
  //     notifyListeners();
  //   }
  // }

  // Future<void> gotoLastPage() async {
  //   if (pinchController != null && _pdfCurrentPage < _totalPages - 1) {
  //     _pdfCurrentPage = _totalPages;
  //     pinchController!.jumpToPage(_pdfCurrentPage);
  //     notifyListeners();
  //   }
  // }

  Future<void> zoomIn() async {
    // if (_pdfController != null) {
    //   _currentZoomLevel += 0.5;
    //   // await _pdfController!.setZoom(_currentZoomLevel);
    //   notifyListeners();
    // }
  }

  Future<void> zoomOut() async {
    // if (_pdfController != null && _currentZoomLevel > 0.5) {
    //   _currentZoomLevel -= 0.5;
    //   // await _pdfController!.setZoom(_currentZoomLevel);
    //   notifyListeners();
    // }
  }

  Future<void> resetZoom() async {
    // if (_pdfController != null) {
    //   _currentZoomLevel = 1.0;
    //   // await _pdfController!.setZoom(_currentZoomLevel);
    //   notifyListeners();
    // }
  }
}
