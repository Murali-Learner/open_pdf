import 'package:flutter/material.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/pages/home/widgets/list_pdf_card.dart';
import 'package:open_pdf/utils/extensions/spacer_extension.dart';

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
      itemCount: 16, //pdfLists.length,
      separatorBuilder: (BuildContext context, int index) {
        return 10.vSpace;
      },
      itemBuilder: (BuildContext context, int index) {
        return ListPdfCard(
          pdf: pdfLists[0],
          index: 0,
        );
      },
    );
  }
}
