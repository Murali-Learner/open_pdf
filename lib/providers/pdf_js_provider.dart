import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class PdfJsProvider extends ChangeNotifier {
  InAppWebViewController? webViewController;

  void setWebViewController(
      InAppWebViewController webViewController, String base64) {
    this.webViewController = webViewController;
    webViewController.evaluateJavascript(source: "renderPdf('$base64')");
    notifyListeners();
  }
}
