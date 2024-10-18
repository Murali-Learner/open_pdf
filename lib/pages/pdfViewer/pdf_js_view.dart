import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class PdfJsView extends StatefulWidget {
  const PdfJsView({Key? key}) : super(key: key);

  @override
  _PdfJsViewState createState() => _PdfJsViewState();
}

class _PdfJsViewState extends State<PdfJsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: 500,
          child: InAppWebView(
            initialFile: "assets/pdfjs/pdfjs.html",
          ),
        ),
      ),
    );
  }
}
