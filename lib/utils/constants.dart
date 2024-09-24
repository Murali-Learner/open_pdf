import 'package:flutter/material.dart';

class Constants {
  static const String pdfAsset = "assets/dart_flutter.pdf";
  static const String dictionaryAsset = "assets/eng_dictionary.db";
  static const String dummyPdfPreviewAsset = "assets/dummy.jpeg";
  static const String appLogo = "assets/open_pdf_logo.jpeg";
  static const Duration globalDuration = Duration(milliseconds: 200);
  static GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey previewContainer = GlobalKey();

  static const double globalElevation = 4.0;
}

class ColorConstants {
  static const Color pdfViewIconsColor = Colors.green;
  static Color get backgroundColor => Colors.black;
  static Color get primaryColor => Colors.amber;
  static Color get color => const Color(0xFF20232a);
  static Color get whiteColor => const Color.fromARGB(255, 255, 255, 255);
}
