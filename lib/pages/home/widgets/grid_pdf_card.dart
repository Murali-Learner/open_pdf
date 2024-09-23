import 'package:flutter/material.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/pages/home/widgets/pdf_card_options.dart';
import 'package:open_pdf/pages/pdfViewer/view_pdf_page.dart';
import 'package:open_pdf/providers/pdf_control_provider.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/utils/constants.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
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
    final provider = context.watch<PdfProvider>();
    return GestureDetector(
      onLongPress: () {
        provider.toggleSelectedFiles(pdf);
        debugPrint("long press ${provider.selectedFiles.length}");
      },
      onTap: () {
        if (pdf.isSelected || provider.isMultiSelected) {
          provider.toggleSelectedFiles(pdf);
        } else {
          context.read<PdfControlProvider>().resetValues();
          provider.clearSelectedFiles();
          context.push(
            navigateTo: ViewPdfPage(
              pdf: pdf,
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color:
              // context.theme.primaryColor.withOpacity(0.8)
              pdf.isSelected
                  ? context.theme.primaryColor.withOpacity(0.8)
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
                      topRight: Radius.circular(10),
                      topLeft: Radius.circular(10)),
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
                              style: context.textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          4.vSpace,
                          SizedBox(
                            child: Text(
                              pdf.fileSize!,
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
            // if ((pdf.downloadStatus == DownloadStatus.cancelled.name))
            //   Align(
            //     alignment: Alignment.center,
            //     child: GestureDetector(
            //       onTap: () {
            //         if (pdf.networkUrl != null && pdf.networkUrl!.isNotEmpty) {
            //           provider.downloadAndSavePdf(pdf.networkUrl!);
            //         }
            //       },
            //       child: Stack(
            //         children: [
            //           CircularProgressIndicator(),
            //           const Icon(Icons.download),
            //         ],
            //       ),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }
}
