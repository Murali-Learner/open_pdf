import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:open_pdf/pages/pdfViewer/widgets/dictonary_bottom_sheet.dart';
import 'package:open_pdf/pages/pdfViewer/widgets/expandable_fab.dart';
import 'package:open_pdf/pages/pdfViewer/widgets/pdf_view_app_bar.dart';
import 'package:open_pdf/providers/dictionary_provider.dart';
import 'package:open_pdf/providers/pdf_js_provider.dart';
import 'package:open_pdf/utils/constants.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:open_pdf/utils/toast_utils.dart';
import 'package:provider/provider.dart';

class PdfJsView extends StatefulWidget {
  const PdfJsView({
    super.key,
    required this.base64,
    required this.pdfName,
  });
  final String base64;
  final String pdfName;
  @override
  PdfJsViewState createState() => PdfJsViewState();
}

class PdfJsViewState extends State<PdfJsView> {
  InAppWebViewSettings settings =
      InAppWebViewSettings(isInspectable: kDebugMode);
  late ContextMenu contextMenu;
  late PdfJsProvider provider;
  final GlobalKey webViewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    provider = context.read<PdfJsProvider>();

    contextMenu = ContextMenu(
      menuItems: [
        ContextMenuItem(
            id: 1,
            title: "Dictionary",
            action: () async {
              String selectedText =
                  await provider.webViewController?.getSelectedText() ?? "";

              final dictionaryProvider = context.read<DictionaryProvider>();
              dictionaryProvider.searchWord(selectedText);
              provider.webViewController?.clearFocus();

              showModalBottomSheet(
                showDragHandle: true,
                context: context,
                backgroundColor: context.theme.scaffoldBackgroundColor,
                barrierColor: ColorConstants.color.withOpacity(0.5),
                isScrollControlled: true,
                useSafeArea: true,
                builder: (context) => DictionaryBottomSheet(
                  searchWord: selectedText.trim(),
                ),
              );
            }),
        ContextMenuItem(
          id: 2,
          title: "Copy",
          action: () async {
            String selectedText =
                await provider.webViewController?.getSelectedText() ?? "";

            final ClipboardData data = ClipboardData(text: selectedText);
            Clipboard.setData(data);
            provider.webViewController?.clearFocus();

            ToastUtils.showSuccessToast("Copied $selectedText to clipboard");
          },
        ),
        ContextMenuItem(
          id: 3,
          title: "SelectAll",
          action: () async {
            await provider.selectAllContent();
          },
        ),
      ],
      settings: ContextMenuSettings(hideDefaultSystemContextMenuItems: true),
      onCreateContextMenu: (hitTestResult) async {
        String selectedText =
            await provider.webViewController?.getSelectedText() ?? "";

        debugPrint("hit test result: $hitTestResult $selectedText");
      },
      onContextMenuActionItemClicked: (menuItem) {
        debugPrint("menuItem result: $menuItem");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PdfJsProvider>(builder: (context, provider, _) {
      return SafeArea(
        child: Scaffold(
          body: Center(
            child: Stack(
              children: [
                SizedBox(
                  height: context.screenHeight,
                  // width: context.width(80),
                  child: InAppWebView(
                    key: webViewKey,
                    initialFile: "assets/pdfjs/pdfjs.html",
                    // contextMenu: contextMenu,
                    initialSettings: settings,
                    onReceivedError: (controller, request, error) {
                      provider.setErrorMessage(error.description);
                    },
                    onNavigationResponse:
                        (controller, navigationResponse) async {
                      debugPrint(
                          "navigationResponse ${navigationResponse.response}");
                      return null;
                    },
                    onConsoleMessage: (controller, consoleMessage) {
                      log("on console message ${consoleMessage.message}");
                    },
                    onLoadStop: (controller, url) {
                      provider.setWebViewController(
                        controller,
                        widget.base64,
                        context,
                      );
                    },
                  ),
                ),
                PdfViewAppBar(
                  pdfName: widget.pdfName,
                ),
              ],
            ),
          ),
          floatingActionButton: const ExpandableFab(),
        ),
      );
    });
  }
}
