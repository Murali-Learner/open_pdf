import 'package:flutter/material.dart';
import 'package:open_pdf/pages/home/widgets/grid_pdf_card.dart';
import 'package:open_pdf/providers/pdf_provider.dart';

class HomePdfGridView extends StatelessWidget {
  // final List<PdfModel> pdfLists;
  const HomePdfGridView({
    super.key,
    required this.provider,
    // required this.pdfLists
  });
  final PdfProvider provider;
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: 16,
      itemBuilder: (BuildContext context, int index) {
        return GridPdfCard(
          pdf: provider.currentPDF!,
          index: index,
        );
      },
    );
  }
}
