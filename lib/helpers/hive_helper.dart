import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/utils/enumerates.dart';

class HiveHelper {
  static const String pdfBoxName = 'pdfBox';
  static Box<PdfModel>? _pdfBox;
  static final HiveHelper _hiveHelper = HiveHelper._internal();

  factory HiveHelper() {
    return _hiveHelper;
  }

  HiveHelper._internal();

  Future<void> initHive() async {
    await Hive.initFlutter();
    Hive.registerAdapter(PdfModelAdapter());
    await Hive.openBox<PdfModel>(pdfBoxName);
    _pdfBox = Hive.box<PdfModel>(pdfBoxName);
  }

  static Future<void> addOrUpdatePdf(PdfModel pdf) async {
    final Map<String, PdfModel> cacheMap = getHivePdfList();
    if (cacheMap.containsKey(pdf.id)) {
      await removeFromCache(pdf.id);
      await _pdfBox?.put(pdf.id, pdf);
    } else {
      await _pdfBox?.put(pdf.id, pdf);
    }
  }

  static Box<PdfModel> getBox() {
    return _pdfBox!;
  }

  static Map<String, PdfModel> getHivePdfList() {
    final Map<String, PdfModel> cacheMap = {};
    for (PdfModel pdf in (_pdfBox?.values ?? [])) {
      cacheMap[pdf.id] = pdf;
    }
    return cacheMap;
  }

  static Map<String, PdfModel> getFavoritePdfList() {
    final Map<String, PdfModel> favoriteMap = {};
    for (PdfModel pdf in (_pdfBox?.values ?? [])) {
      if (pdf.isFav) {
        favoriteMap[pdf.id] = pdf.copyWith(isFav: true);
      }
    }
    return favoriteMap;
  }

  static Future<void> removeFromCache(String pdfId) async {
    debugPrint("file deleted");
    await _pdfBox?.delete(pdfId);
  }

  static bool isCached(String id) {
    return _pdfBox?.get(id) != null;
  }

  static PdfModel? getPdf(String id) {
    return _pdfBox?.get(id)!;
  }

  static bool isFavorite(String id) {
    final pdf = _pdfBox?.get(id);
    return pdf != null && pdf.isFav;
  }

  static Future<void> updateDownloadStatus(
      String id, DownloadStatus status) async {
    final pdf = _pdfBox?.get(id);
    if (pdf != null) {
      final updatedPdf = pdf.copyWith(downloadStatus: status.name);
      await _pdfBox?.put(id, updatedPdf);
    }
  }

  static Future<void> clearAllData() async {
    await _pdfBox?.clear();
  }

  static Future<void> toggleFavorite(PdfModel pdf) async {
    try {
      final isFav = pdf.isFav;

      final updatedPdf = pdf.copyWith(isFav: !isFav);
      await _pdfBox?.put(pdf.id, updatedPdf);
    } catch (e) {
      debugPrint("Error while toggling favorite status: $e");
    }
  }
}
