import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/pages/home/widgets/pdf_card_options.dart';
import 'package:open_pdf/pages/home/widgets/pdf_info_widget.dart';
import 'package:open_pdf/pages/pdfViewer/pdf_js_view.dart';
import 'package:open_pdf/providers/download_provider.dart';
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
    return Consumer2<PdfProvider, DownloadProvider>(
        builder: (context, pdfProvider, downloadProvider, _) {
      return GestureDetector(
        onLongPress: isDownloadCard
            ? null
            : () {
                if (pdf.networkUrl != null && pdf.networkUrl != '') {
                  downloadProvider.toggleSelectedFiles(pdf);
                } else {
                  pdfProvider.toggleSelectedFiles(pdf);
                }

                debugPrint("long press ${pdfProvider.selectedFiles.length}");
              },
        onTap: () async {
          log("the single tap list pdf card");
          await onListPdfCardSingleTap(pdfProvider, context);
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

  Future<void> onListPdfCardSingleTap(
      PdfProvider provider, BuildContext context) async {
    debugPrint("pdf  ${pdf.fileName} ${provider.isMultiSelected}");
    final downloadProvider = context.read<DownloadProvider>();

    if (pdf.isSelected ||
        provider.isMultiSelected ||
        downloadProvider.isMultiSelected) {
      if (pdf.networkUrl != null && pdf.networkUrl != '') {
        downloadProvider.toggleSelectedFiles(pdf);
      } else {
        provider.toggleSelectedFiles(pdf);
      }
    } else {
      debugPrint("pdf.networkUrl ${pdf.networkUrl}");

      provider.clearSelectedFiles();
      downloadProvider.clearSelectedFiles();

      final base64 = await provider.convertBase64(pdf.filePath!);

      context.push(
        navigateTo: PdfJsView(base64: base64, pdfName: pdf.fileName!),
      );
      Future.delayed(const Duration(seconds: 1)).whenComplete(
        () async {
          await updateLastOpenedValue(downloadProvider, provider);
        },
      );
    }
  }

  Future<void> updateLastOpenedValue(
      DownloadProvider downloadProvider, PdfProvider pdfProvider) async {
    {
      if (pdf.networkUrl != null && pdf.networkUrl != '') {
        await downloadProvider.updateLastOpenedValue(pdf);
      } else {
        pdfProvider.updateLastOpenedValue(pdf);
      }
    }
  }
}
