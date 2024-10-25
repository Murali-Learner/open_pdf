import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/pages/download/widgets/download_action_button.dart';
import 'package:open_pdf/pages/download/widgets/download_progress_bar.dart';
import 'package:open_pdf/pages/home/widgets/pdf_card_options.dart';
import 'package:open_pdf/pages/home/widgets/pdf_info_widget.dart';
import 'package:open_pdf/pages/pdfViewer/pdf_js_view.dart';
import 'package:open_pdf/providers/download_provider.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:open_pdf/utils/extensions/spacer_extension.dart';
import 'package:provider/provider.dart';

class DownloadPdfCard extends StatelessWidget {
  final PdfModel pdf;
  final int index;

  const DownloadPdfCard({super.key, required this.pdf, required this.index});

  @override
  Widget build(BuildContext context) {
    return Consumer2<PdfProvider, DownloadProvider>(
        builder: (context, pdfProvider, downloadProvider, _) {
      return GestureDetector(
        onTap: () {
          // debugPrint("pdf  ${pdf.toJson()}");
          onSingleTap(pdfProvider, context);
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border:
                Border.all(color: context.theme.primaryColor.withOpacity(0.5)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PdfInfoWidget(
                      pdf: pdf,
                      isDownloadCard: true,
                    ),
                    DownloadProgressIndicator(pdf: pdf),
                  ],
                ),
              ),
              10.hSpace,
              pdf.downloadStatus == DownloadTaskStatus.complete.name
                  ? PdfCardOptions(pdf: pdf, index: index)
                  : DownloadActionButton(pdf: pdf),
            ],
          ),
        ),
      );
    });
  }

  void onSingleTap(PdfProvider provider, BuildContext context) async {
    if (pdf.downloadStatus == DownloadTaskStatus.complete.name) {
      if (pdf.isSelected || provider.isMultiSelected) {
        provider.toggleSelectedFiles(pdf);
      } else {
        provider.updateLastOpenedValue(pdf);
        context
            .read<DownloadProvider>()
            .updateLastOpenedValue(pdf)
            .whenComplete(
          () {
            provider.convertBase64(pdf.filePath!).then(
              (base64) {
                context.push(
                  navigateTo:
                      PdfJsView(base64: base64, pdfName: pdf.fileName ?? ''),
                );
              },
            );
          },
        );
      }
    }
  }
}
