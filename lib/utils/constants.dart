import 'package:flutter/material.dart';

class Constants {
  static const String pdfAsset = "assets/dart_flutter.pdf";
  static const String dictionaryAsset = "assets/eng_dictionary.db";
  static const String dummyPdfPreviewAsset = "assets/dummy.jpeg";
  static const String appLogo = "assets/open_pdf_logo.jpeg";
  static const Duration globalDuration = Duration(milliseconds: 200);
  static GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey previewContainer = GlobalKey();

  static const Color pdfViewIconsColor = Colors.green;
}
