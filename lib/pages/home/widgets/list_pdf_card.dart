import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/pages/home/widgets/pdf_card_options.dart';
import 'package:open_pdf/pages/home/widgets/pdf_info_widget.dart';
import 'package:open_pdf/pages/pdfViewer/pdf_js_view.dart';
import 'package:open_pdf/providers/download_provider.dart';
import 'package:open_pdf/providers/pdf_control_provider.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/utils/constants.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:open_pdf/utils/extensions/spacer_extension.dart';
import 'package:provider/provider.dart';

class ListPdfCard extends StatelessWidget {
  final PdfModel pdf;
  final bool isDownloadCard;
  final int index;

  const ListPdfCard(
      {super.key,
      required this.pdf,
      this.isDownloadCard = false,
      required this.index});

  @override
  Widget build(BuildContext context) {
    return Consumer<PdfProvider>(builder: (context, provider, _) {
      return GestureDetector(
        onLongPress: isDownloadCard
            ? null
            : () {
                provider.toggleSelectedFiles(pdf);
                debugPrint("long press ${provider.selectedFiles.length}");
              },
        onTap: () async {
          debugPrint("pdf  ${pdf.fileName} ${provider.isMultiSelected}");
          if (pdf.downloadStatus == DownloadTaskStatus.complete.name) {
            if (pdf.isSelected || provider.isMultiSelected) {
              provider.toggleSelectedFiles(pdf);
            } else {
              context.read<PdfControlProvider>().resetValues();
              provider.updateLastOpenedValue(pdf);
              await context.read<DownloadProvider>().updateLastOpenedValue(pdf);

              final base64 = await provider.convertBase64(pdf.filePath!);

              context.push(
                navigateTo:
                    PdfJsView(base64: base64, pdfName: pdf.fileName ?? ''),
              );
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: pdf.isSelected
                ? ColorConstants.amberColor
                : context.theme.primaryColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border:
                Border.all(color: context.theme.primaryColor.withOpacity(0.5)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: PdfInfoWidget(
                  pdf: pdf,
                  isDownloadCard: isDownloadCard,
                ),
              ),
              10.hSpace,
              if (!pdf.isSelected) PdfCardOptions(pdf: pdf, index: index)
            ],
          ),
        ),
      );
    });
  }
}
