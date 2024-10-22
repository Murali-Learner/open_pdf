import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:open_pdf/pages/pdfViewer/widgets/dictonary_bottom_sheet.dart';
import 'package:open_pdf/providers/dictionary_provider.dart';
import 'package:open_pdf/utils/constants.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:provider/provider.dart';

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

  Future<void> setWebViewController(InAppWebViewController webViewController,
      String base64, BuildContext context) async {
    this.webViewController = webViewController;
    await webViewController.evaluateJavascript(source: "renderPdf('$base64')");

    webViewController.addJavaScriptHandler(
      handlerName: 'onPageChanged',
      callback: (contents) {
        var receivedData = contents.first;
        if (receivedData != null && receivedData is int) {
          debugPrint("onPageChanged  $receivedData");
          setCurrentPage(receivedData);
        }
      },
    );
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
      handlerName: 'copyText',
      callback: (contents) async {
        String? receivedData = contents.first;
        //  await webViewController.getSelectedText();
        if (receivedData != null) {
          log("copyText  $receivedData");

          final ClipboardData data = ClipboardData(text: receivedData);
          Clipboard.setData(data);
          // webViewController.clearFocus();
          await hideContextMenu();
        }
      },
    );
    webViewController.addJavaScriptHandler(
      handlerName: 'searchDictionary',
      callback: (contents) async {
        String? receivedData = contents.first;
        //  await webViewController.getSelectedText();
        if (receivedData != null) {
          log("copyText  $receivedData");

          final dictionaryProvider = context.read<DictionaryProvider>();

          await dictionaryProvider.searchWord(receivedData);
          dictionaryProvider.toggleClearButton(receivedData.isNotEmpty);

          await webViewController.clearFocus();
          await hideContextMenu();

          await showModalBottomSheet(
            showDragHandle: true,
            context: context,
            backgroundColor: context.theme.scaffoldBackgroundColor,
            barrierColor: ColorConstants.color.withOpacity(0.5),
            isScrollControlled: true,
            useSafeArea: true,
            builder: (context) => DictionaryBottomSheet(
              searchWord: receivedData.trim(),
            ),
          );
        }
      },
    );
    notifyListeners();
  }

  Future<void> hideContextMenu() async {
    await webViewController!.evaluateJavascript(source: "hideContextMenu()");
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
