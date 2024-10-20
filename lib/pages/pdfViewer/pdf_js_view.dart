import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:open_pdf/pages/pdfViewer/widgets/pdf_control_buttons.dart';
import 'package:open_pdf/pages/pdfViewer/widgets/pdf_view_app_bar.dart';
import 'package:open_pdf/providers/pdf_control_provider.dart';
import 'package:open_pdf/providers/pdf_js_provider.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:provider/provider.dart';

class PdfJsView extends StatefulWidget {
  const PdfJsView({super.key, required this.base64});
  final String base64;
  @override
  _PdfJsViewState createState() => _PdfJsViewState();
}

class _PdfJsViewState extends State<PdfJsView> {
  @override
  Widget build(BuildContext context) {
    return Consumer3<PdfJsProvider, PdfControlProvider, PdfProvider>(
        builder: (context, provider, viewProvider, pdfProvider, _) {
      return Scaffold(
        body: Center(
          child: Column(
            children: [
              SizedBox(
                height: context.height(100),
                child: InAppWebView(
                  initialFile: "assets/pdfjs/pdfjs.html",
                  onLoadStop: (controller, url) {
                    provider.setWebViewController(
                      controller,
                      widget.base64,
                    );
                  },
                ),
              ),
              // if (viewProvider.showPdfTools)
              //   Positioned(
              //     bottom: context.height(5),
              //     left: 0,
              //     right: 0,
              //     child: const PdfControlButtons(),
              //   ),
              // if (viewProvider.showAppbar)
              //   PdfViewAppBar(
              //     pdf: widget.pdf,
              //   )
            ],
          ),
        ),
      );
    });
  }
}
