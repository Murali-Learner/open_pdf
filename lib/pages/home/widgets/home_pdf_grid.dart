import 'package:flutter/material.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/pages/home/widgets/grid_pdf_card.dart';

class HomePdfGridView extends StatelessWidget {
  final List<PdfModel> pdfLists;
  const HomePdfGridView({
    super.key,
    required this.pdfLists,
    // required this.pdfLists
  });
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: pdfLists.length,
      itemBuilder: (BuildContext context, int index) {
        return GridPdfCard(
          pdf: pdfLists[index],
          index: index,
        );
      },
    );
  }
}
