import 'package:flutter/material.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/pages/home/widgets/list_pdf_card.dart';
import 'package:open_pdf/providers/download_provider.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:provider/provider.dart';

class FavoritesListPage extends StatelessWidget {
  const FavoritesListPage({super.key});
  Map<String, PdfModel> getFavPdfMap(Map<String, PdfModel> totalPdfList) {
    return Map.fromEntries(
      totalPdfList.entries.where((entry) => entry.value.isFav),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        elevation: 5,
      ),
      body: Consumer2<PdfProvider, DownloadProvider>(
        builder: (context, pdfProvider, downloadProvider, _) {
          final favMapList = getFavPdfMap({
            ...pdfProvider.totalPdfList,
            ...downloadProvider.downloadedPdfMap
          }).values.toList();

          if (favMapList.isEmpty) {
            return const Center(child: Text('No favorites added'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 15,
            ),
            itemCount: favMapList.length,
            itemBuilder: (context, index) {
              final favMap = favMapList[index];
              return ListPdfCard(
                index: index,
                pdf: favMap,
              );
            },
          );
        },
      ),
    );
  }
}
