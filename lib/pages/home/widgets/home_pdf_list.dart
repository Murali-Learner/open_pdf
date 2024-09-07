import 'package:flutter/material.dart';
import 'package:open_pdf/pages/home/widgets/list_pdf_card.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:provider/provider.dart';

class HomePdfListView extends StatelessWidget {
  // final List<PdfModel> pdfLists;
  const HomePdfListView({super.key
      // ,
      // required this.pdfLists
      });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PdfProvider>();
    return ListView.separated(
      shrinkWrap: true,
      itemCount: 16, //pdfLists.length,
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox(height: 10);
      },
      itemBuilder: (BuildContext context, int index) {
        return ListPdfCard(
          pdf: provider.currentPDF!,
          index: index,
        );
      },
    );
  }
}
