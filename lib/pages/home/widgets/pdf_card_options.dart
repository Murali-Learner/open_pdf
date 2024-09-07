import 'package:flutter/material.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/pages/home/widgets/pdf_option_bottom_sheet.dart';

class PdfCardOptions extends StatelessWidget {
  const PdfCardOptions({
    super.key,
    required this.pdf,
    required this.index,
  });

  final PdfModel pdf;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          showDragHandle: true,
          builder: (BuildContext context) {
            return PdfOptionsBottomSheet(pdf: pdf);
          },
        );
      },
      child: const Icon(Icons.more_vert),
    );
  }
}
