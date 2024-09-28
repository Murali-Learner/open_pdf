import 'package:flutter/material.dart';
import 'package:open_pdf/global_widgets/global_bottom_sheet.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/pages/home/widgets/pdf_option_bottom_sheet.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:provider/provider.dart';

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
    return Consumer<PdfProvider>(builder: (context, provider, _) {
      return GestureDetector(
        onTap: () {
          if (!pdf.isSelected) {
            showGlobalBottomSheet(
                context: context, child: PdfOptionsBottomSheet(pdf: pdf));
          }
        },
        child: Icon(
          Icons.more_vert,
          color: pdf.isSelected ? context.theme.primaryColor : null,
        ),
      );
    });
  }
}
