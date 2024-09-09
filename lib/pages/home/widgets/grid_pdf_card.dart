import 'package:flutter/material.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/pages/home/widgets/pdf_card_options.dart';
import 'package:open_pdf/utils/constants.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:open_pdf/utils/extensions/spacer_extension.dart';

class GridPdfCard extends StatelessWidget {
  final PdfModel pdf;
  final int index;
  const GridPdfCard({
    super.key,
    required this.pdf,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: context.theme.primaryColor.withOpacity(0.5),
      ),
      padding: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          AspectRatio(
            aspectRatio: 3 / 2.6,
            child: Image.asset(
              Constants.dummyPdfPreviewAsset,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 5,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      child: Text(
                        pdf.fileName,
                        style: context.textTheme.bodyMedium,
                      ),
                    ),
                    4.vSpace,
                    SizedBox(
                      child: Text(
                        "${pdf.fileSize.toStringAsFixed(2)} KB",
                        style: context.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                PdfCardOptions(
                  pdf: pdf,
                  index: index,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
