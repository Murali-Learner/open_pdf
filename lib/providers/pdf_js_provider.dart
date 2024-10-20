import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class PdfJsProvider extends ChangeNotifier {
  InAppWebViewController? webViewController;
  String _errorMessage = '';
  int _currentPage = 1;
  int _totalPages = 0;
  int get totalPages => _totalPages;
  int get currentPage => _currentPage;

  void setTotalPages(int value) {
    _totalPages = value;
    notifyListeners();
  }

  void setCurrentPage(int value) {
    _currentPage = value;
    notifyListeners();
  }

  String get errorMessage => _errorMessage;

  void setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> setWebViewController(
      InAppWebViewController webViewController, String base64) async {
    this.webViewController = webViewController;
    await webViewController.evaluateJavascript(source: "renderPdf('$base64')");

    webViewController.addJavaScriptHandler(
      handlerName: 'totalPdfPages',
      callback: (contents) {
        var receivedData = contents.first;
        if (receivedData != null && receivedData is int) {
          setTotalPages(receivedData);
        }
      },
    );
    webViewController.addJavaScriptHandler(
      handlerName: 'onPageChanged',
      callback: (contents) {
        var receivedData = contents.first;
        if (receivedData != null && receivedData is int) {
          log("current  $receivedData");
          setCurrentPage(receivedData);
        }
      },
    );
    notifyListeners();
  }

  Future<void> selectAllContent() async {
    await webViewController!.evaluateJavascript(
      source: "document.execCommand('selectAll');",
    );
  }

  Future<void> changePage(isNextPage) async {
    await webViewController!.evaluateJavascript(
      source: "changePage($isNextPage)",
    );
  }

  Future<void> jumpPage(int newPage) async {
    await webViewController!.evaluateJavascript(
      source: "jumpToPage($newPage)",
    );
  }
}
