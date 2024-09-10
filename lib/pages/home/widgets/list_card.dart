import 'package:flutter/material.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/pages/home/widgets/pdf_card_options.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';

class ListPdfCard extends StatelessWidget {
  final PdfModel pdf;
  final int index;
  const ListPdfCard({super.key, required this.pdf, required this.index});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      tileColor: context.theme.primaryColor.withOpacity(0.5),
      title: Text(
        pdf.fileName,
        style: context.textTheme.bodyLarge,
      ),
      subtitle: Text(
        "${pdf.fileSize.toStringAsFixed(2)} KB",
        style: context.textTheme.bodyLarge,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: PdfCardOptions(
        pdf: pdf,
        index: index,
      ),
    );
  }
}
