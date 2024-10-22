import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:open_pdf/pages/pdfViewer/widgets/expandable_fab.dart';
import 'package:open_pdf/pages/pdfViewer/widgets/pdf_view_app_bar.dart';
import 'package:open_pdf/providers/pdf_js_provider.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
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
                const Positioned(
                  right: 10,
                  bottom: 10,
                  child: ExpandableFab(),
                ),
              ],
            ),
          ),
          // floatingActionButton: const ExpandableFab(),
        ),
      );
    });
  }
}
