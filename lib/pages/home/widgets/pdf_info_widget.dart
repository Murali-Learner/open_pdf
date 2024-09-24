import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/pages/pdfViewer/view_pdf_page.dart';
import 'package:open_pdf/providers/pdf_control_provider.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/utils/enumerates.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:open_pdf/utils/extensions/spacer_extension.dart';
import 'package:provider/provider.dart';

class PdfInfoWidget extends StatelessWidget {
  final PdfModel pdf;
  final bool isDownloadCard;

  const PdfInfoWidget(
      {super.key, required this.pdf, required this.isDownloadCard});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PdfProvider>();

    return GestureDetector(
      onLongPress: isDownloadCard
          ? null
          : () {
              provider.toggleSelectedFiles(pdf);
              debugPrint("long press ${provider.selectedFiles.length}");
            },
      onTap: () {
        log("pdf.fileName  ${pdf.fileName}");
        if (pdf.downloadStatus == DownloadStatus.completed.name) {
          if (pdf.isSelected || provider.isMultiSelected) {
            provider.toggleSelectedFiles(pdf);
          } else {
            context.read<PdfControlProvider>().resetValues();

            context.push(
              navigateTo: ViewPdfPage(
                pdf: pdf,
              ),
            );
          }
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            children: [
              SizedBox(
                child: Text(
                  pdf.fileName ?? 'Unknown Files',
                  style: context.textTheme.bodyLarge!.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          8.vSpace,
          if (pdf.downloadStatus == DownloadStatus.ongoing.name)
            Consumer<PdfProvider>(builder: (context, provider, _) {
              return LinearProgressIndicator(
                value: pdf.downloadProgress,
              );
            }),
          Text(
            pdf.fileSize ?? '',
            style: context.textTheme.bodyMedium!.copyWith(
              color: pdf.isSelected ? Colors.white : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
