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
    final provider = context.watch<PdfProvider>();
    return GestureDetector(
      onLongPress: isDownloadCard
          ? null
          : () {
              provider.toggleSelectedFiles(pdf);
              debugPrint("long press ${provider.selectedFiles.length}");
            },
      onTap: () {
        debugPrint("pdf  ${pdf.fileName} ${provider.isMultiSelected}");
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
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: pdf.isSelected && !isDownloadCard
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
              child: PdfInfoWidget(
                pdf: pdf,
                isDownloadCard: isDownloadCard,
              ),
            ),
            10.hSpace,
            Consumer<PdfProvider>(
              builder: (context, provider, _) {
                return pdf.downloadStatus == DownloadStatus.completed.name
                    ? PdfCardOptions(pdf: pdf, index: index)
                    : DownloadActionButton(pdf: pdf);
              },
            ),
          ],
        ),
      ),
    );
  }
}
