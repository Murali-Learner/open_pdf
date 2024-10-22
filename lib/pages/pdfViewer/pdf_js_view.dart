import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:open_pdf/pages/pdfViewer/widgets/expandable_fab.dart';
import 'package:open_pdf/pages/pdfViewer/widgets/pdf_page_slider.dart';
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
  late PdfJsProvider provider;
  final GlobalKey webViewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    provider = context.read<PdfJsProvider>();
    Future.delayed(Duration.zero, () {
      provider.pdfLoading = true;
      provider.showSlider = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PdfJsProvider>(
      builder: (context, provider, _) {
        return SafeArea(
          child: Scaffold(
            body: Center(
              child: Stack(
                children: [
                  SizedBox(
                    height: context.screenHeight,
                    child: ModalProgressHUD(
                      inAsyncCall: provider.pdfLoading,
                      child: InAppWebView(
                        key: webViewKey,
                        initialFile: provider.pdfJsHtml,
                        initialSettings: settings,
                        onReceivedError: (controller, request, error) {
                          provider.setErrorMessage(error.description);
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
                  ),
                  const PageNumberSlider(),
                  PdfViewAppBar(
                    pdfName: widget.pdfName,
                  ),
                ],
              ),
            ),
            floatingActionButton: const ExpandableFab(),
          ),
        );
      },
    );
  }
}
