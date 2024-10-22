import 'package:flutter/material.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/pages/home/widgets/pdf_card_options.dart';
import 'package:open_pdf/pages/pdfViewer/pdf_js_view.dart';
import 'package:open_pdf/providers/download_provider.dart';
import 'package:open_pdf/providers/pdf_control_provider.dart';
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
    return Consumer<PdfProvider>(builder: (context, pdfProvider, _) {
      return GestureDetector(
        onLongPress: () {
          pdfProvider.toggleSelectedFiles(pdf);
          debugPrint("long press ${pdfProvider.selectedFiles.length}");
        },
        onTap: () async {
          debugPrint("statement ${pdf.toJson()}");
          if (pdf.isSelected || pdfProvider.isMultiSelected) {
            pdfProvider.toggleSelectedFiles(pdf);
          } else {
            context.read<PdfControlProvider>().resetValues();
            pdfProvider.updateLastOpenedValue(pdf);
            await context.read<DownloadProvider>().updateLastOpenedValue(pdf);

            pdfProvider.clearSelectedFiles();
            final base64 = await pdfProvider.convertBase64(pdf.filePath!);
            // if (pdfProvider.currentPDF != null) {
            context.push(
              navigateTo: PdfJsView(base64: base64, pdfName: pdf.fileName!),

              //  ViewPdfPage(
              //   pdf: pdf,
              // ),
            );
            // }
          }
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color:
                // context.theme.primaryColor.withOpacity(0.8)
                pdf.isSelected
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
}
