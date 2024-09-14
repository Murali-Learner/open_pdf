import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:open_pdf/utils/constants.dart';
import 'package:pdfrx/pdfrx.dart';

class PdfViewerProvider extends ChangeNotifier {
  PdfViewerController? _pdfController;

  PdfViewerController? get pdfController => _pdfController;
  void initView() {
    _pdfController = PdfViewerController();
  }

  void handlePDF() {
    if (_pdfController != null) {
      if (_pdfController!.isReady) {
        _pdfController!.goToPage(
          pageNumber: 0,
          duration: Constants.globalDuration,
        );
      } else {
        log("PDF Controller is not ready yet.");
      }
    }
  }
}
