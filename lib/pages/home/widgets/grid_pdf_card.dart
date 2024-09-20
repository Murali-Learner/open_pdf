import 'package:flutter/material.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/pages/home/widgets/pdf_card_options.dart';
import 'package:open_pdf/pages/pdfViewer/view_pdf_page.dart';
import 'package:open_pdf/providers/pdf_control_provider.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/utils/constants.dart';
import 'package:open_pdf/utils/enumerates.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:open_pdf/utils/extensions/spacer_extension.dart';
import 'package:open_pdf/utils/toast_utils.dart';
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
        debugPrint("long press");
        // provider.addToSelectedFiles(pdf);
      },
      onTap: () {
        if (pdf.downloadStatus == DownloadStatus.completed.name) {
          context.read<PdfControlProvider>().resetValues();

          context.push(
            navigateTo: ViewPdfPage(
              pdf: pdf,
            ),
          );
        } else {
          ToastUtils.showErrorToast("File is not available");
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color:
              // context.theme.primaryColor.withOpacity(0.8)
              pdf.isSelected
                  ? context.theme.primaryColor.withOpacity(0.8)
                  : context.theme.primaryColor.withOpacity(0.5),
        ),
        padding: const EdgeInsets.all(5),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                AspectRatio(
                  aspectRatio: 0.9,
                  child: pdf.thumbnail == null
                      ? Image.asset(Constants.appLogo)
                      : Image.memory(
                          pdf.thumbnail!,
                          fit: BoxFit.cover,
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
                      Expanded(
                        flex: 5,
                        child: Wrap(
                          // alignment: A,
                          children: [
                            SizedBox(
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
            if ((pdf.downloadStatus == DownloadStatus.cancelled.name))
              Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {
                    if (pdf.networkUrl != null && pdf.networkUrl!.isNotEmpty) {
                      provider.downloadAndSavePdf(pdf.networkUrl!);
                    }
                  },
                  child: Stack(
                    children: [
                      CircularProgressIndicator(),
                      const Icon(Icons.download),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
