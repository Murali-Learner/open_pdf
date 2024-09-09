import 'package:flutter/material.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/pages/home/widgets/list_card.dart';

class HomePdfListView extends StatelessWidget {
  final List<PdfModel> pdfLists;
  const HomePdfListView({
    super.key,
    required this.pdfLists,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: pdfLists.length, //pdfLists.length,
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox(height: 10);
      },
      itemBuilder: (BuildContext context, int index) {
        return ListPdfCard(
          pdf: pdfLists[index],
          index: index,
        );
      },
    );
  }
}
