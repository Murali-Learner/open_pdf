import 'package:flutter/material.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/pages/home/widgets/download_action_button.dart';
import 'package:open_pdf/pages/home/widgets/pdf_card_options.dart';
import 'package:open_pdf/pages/home/widgets/pdf_info_widget.dart';
import 'package:open_pdf/pages/pdfViewer/view_pdf_page.dart';
import 'package:open_pdf/providers/pdf_control_provider.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/utils/enumerates.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:open_pdf/utils/extensions/spacer_extension.dart';
import 'package:provider/provider.dart';

class DownloadPdfCard extends StatelessWidget {
  final PdfModel pdf;

  final int index;

  const DownloadPdfCard({super.key, required this.pdf, required this.index});

  @override
  Widget build(BuildContext context) {
    return Consumer<PdfProvider>(builder: (context, provider, _) {
      return GestureDetector(
        onLongPress: () {
          provider.toggleSelectedFiles(pdf);
          debugPrint("long press ${provider.selectedFiles.length}");
        },
        onTap: () {
          debugPrint("pdf  ${pdf.fileName} ${provider.isMultiSelected}");
          onSingleTap(provider, context);
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: pdf.isSelected
                ? context.theme.primaryColor.withOpacity(0.8)
                : context.theme.primaryColor.withOpacity(0.1),
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
                    5.vSpace,
                    if (pdf.downloadStatus == DownloadStatus.ongoing.name)
                      LinearProgressIndicator(
                        value: pdf.downloadProgress,
                      ),
                  ],
                ),
              ),
              10.hSpace,
              pdf.downloadStatus == DownloadStatus.completed.name
                  ? PdfCardOptions(pdf: pdf, index: index)
                  : DownloadActionButton(pdf: pdf),
            ],
          ),
        ),
      );
    });
  }

  void onSingleTap(PdfProvider provider, BuildContext context) {
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
  }
}
