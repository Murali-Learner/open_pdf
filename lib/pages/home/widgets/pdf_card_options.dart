import 'package:flutter/material.dart';
import 'package:open_pdf/global_widgets/global_loading_widget.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/pages/home/widgets/pdf_option_bottom_sheet.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
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
      return provider.moreBtnLoading
          ? const GlobalLoadingWidget()
          : GestureDetector(
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
    });
  }
}
