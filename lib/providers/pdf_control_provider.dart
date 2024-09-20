import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:open_pdf/utils/enumerates.dart';
import 'package:pdf_render/pdf_render.dart';

class PdfControlProvider with ChangeNotifier {
  PDFViewController? _pdfController;
  int _pdfCurrentPage = 0;
  int _totalPages = 0;
  String _errorMessage = '';
  bool _showPdfControlButtons = false;
  double _currentZoomLevel = 1.0;
  PdfScrollMode _pdfScrollMode = PdfScrollMode.vertical;

  PDFViewController? get pdfController => _pdfController;
  int get pdfCurrentPage => _pdfCurrentPage;
  int get totalPages => _totalPages;
  double get currentZoomLevel => _currentZoomLevel;
  PdfScrollMode get pdfScrollMode => _pdfScrollMode;
  String get errorMessage => _errorMessage;
  bool get showPdfControlButtons => _showPdfControlButtons;

  void setTotalPages(int pages) {
    _totalPages = pages;
    notifyListeners();
  }

  void resetValues() {
    _pdfCurrentPage = 0;
    _totalPages = 0;
    _errorMessage = "";
    _showPdfControlButtons = false;
    _currentZoomLevel = 0.0;
    notifyListeners();
  }

  void setPdfControlButtons(
    bool showButtons,
  ) {
    _showPdfControlButtons = showButtons;
    debugPrint("_showPdfControlButtons $_showPdfControlButtons");
    notifyListeners();
  }

  Future<Uint8List> getPdfThumbNail(String path) async {
    PdfDocument doc = await PdfDocument.openFile(path);

    PdfPage page = await doc.getPage(1);
    final pageImage = await page.render();
    final image = await pageImage.createImageDetached();
    final pngData = await image.toByteData(format: ImageByteFormat.png);

    return pngData!.buffer.asUint8List();
  }
  //  FutureBuilder(
  //             future: provider.getPdfThumbNail(pdf),
  //             builder: (context, snapshot) {
  //               return snapshot.hasData
  //                   ? Image.memory((snapshot.data!))
  //                   : const SizedBox();
  //             },
  //           ),

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
    if (_pdfController != null && _pdfCurrentPage < _totalPages - 1) {
      _pdfCurrentPage = page;
      await _pdfController!.setPage(_pdfCurrentPage);
      notifyListeners();
    }
  }

  Future<void> nextPage() async {
    if (_pdfController != null && _pdfCurrentPage < _totalPages - 1) {
      _pdfCurrentPage++;
      await _pdfController!.setPage(_pdfCurrentPage);
      notifyListeners();
    }
  }

  Future<void> previousPage() async {
    if (_pdfController != null && _pdfCurrentPage > 0) {
      _pdfCurrentPage--;
      await _pdfController!.setPage(_pdfCurrentPage);
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
      _pdfCurrentPage = _totalPages - 1;
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
