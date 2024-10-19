import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:open_pdf/providers/pdf_js_provider.dart';
import 'package:provider/provider.dart';

class PdfJsView extends StatefulWidget {
  const PdfJsView({Key? key, required this.base64}) : super(key: key);
  final String base64;
  @override
  _PdfJsViewState createState() => _PdfJsViewState();
}

class _PdfJsViewState extends State<PdfJsView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<PdfJsProvider>(builder: (context, provider, _) {
      return Scaffold(
        body: Center(
          child: SizedBox(
            height: 1000,
            // width: context.width(80),
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
        ),
      );
    });
  }
}
