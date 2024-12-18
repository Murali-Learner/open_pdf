import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/pages/pdfViewer/pdf_js_view.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:open_pdf/utils/extensions/date_time_extension.dart';
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
              {
                provider.toggleSelectedFiles(pdf);
              }
            },
      onTap: () async {
        if (pdf.downloadStatus == DownloadTaskStatus.complete.name) {
          if (pdf.isSelected || provider.isMultiSelected) {
            provider.toggleSelectedFiles(pdf);
          } else {
            final base64 = await provider.convertBase64(pdf.filePath!);
            context.push(
              navigateTo: PdfJsView(base64: base64, pdfName: pdf.fileName!),
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          8.vSpace,
          if (pdf.downloadStatus == DownloadTaskStatus.complete.name)
            SizedBox(
              child: Text(
                pdf.lastOpened!.timeAgo(),
                style: context.textTheme.bodyMedium,
              ),
            ),
        ],
      ),
    );
  }
}
