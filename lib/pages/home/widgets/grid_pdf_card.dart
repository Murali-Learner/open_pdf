import 'package:flutter/material.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/pages/home/widgets/pdf_card_options.dart';
import 'package:open_pdf/pages/pdfViewer/pdf_js_view.dart';
import 'package:open_pdf/providers/download_provider.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/utils/constants.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:open_pdf/utils/extensions/date_time_extension.dart';
import 'package:open_pdf/utils/extensions/spacer_extension.dart';
import 'package:provider/provider.dart';

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
    return Consumer<PdfProvider>(builder: (_, pdfProvider, __) {
      return GestureDetector(
        onLongPress: () {
          pdfProvider.toggleSelectedFiles(pdf);
          debugPrint("long press ${pdfProvider.selectedFiles.length}");
        },
        onTap: () async {
          await onGridPdfCardSingleTap(pdfProvider, context);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: pdf.isSelected
                ? ColorConstants.amberColor
                : context.theme.primaryColor.withOpacity(0.3),
          ),
          padding: const EdgeInsets.all(5),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(6),
                        topLeft: Radius.circular(6)),
                    child: AspectRatio(
                      aspectRatio: 0.9,
                      child: pdf.thumbnail == null
                          ? Image.asset(Constants.appLogo)
                          : Image.memory(
                              pdf.thumbnail!,
                              fit: BoxFit.cover,
                            ),
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
                              width: context.width(30),
                              child: Text(
                                pdf.fileName!,
                                style: context.textTheme.bodyLarge,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            4.vSpace,
                            SizedBox(
                              child: Text(
                                pdf.lastOpened!.timeAgo(),
                                style: context.textTheme.bodySmall!.copyWith(),
                              ),
                            ),
                          ],
                        ),
                        if (!pdf.isSelected)
                          PdfCardOptions(
                            pdf: pdf,
                            index: index,
                          )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Future<void> onGridPdfCardSingleTap(
      PdfProvider pdfProvider, BuildContext context) async {
    final downloadProvider = context.read<DownloadProvider>();

    if (pdf.isSelected || pdfProvider.isMultiSelected) {
      pdfProvider.toggleSelectedFiles(pdf);
    } else {
      debugPrint("pdf.networkUrl ${pdf.networkUrl}");

      pdfProvider.clearSelectedFiles();

      final base64 = await pdfProvider.convertBase64(pdf.filePath!);

      context.push(
        navigateTo: PdfJsView(base64: base64, pdfName: pdf.fileName!),
      );
      Future.delayed(const Duration(seconds: 1)).whenComplete(
        () async {
          await updateLastOpenedValue(downloadProvider, pdfProvider);
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
