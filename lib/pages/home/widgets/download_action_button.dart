import 'package:flutter/material.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/pages/home/widgets/ongoing_download_widget.dart';
import 'package:open_pdf/providers/download_provider.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/utils/extensions/spacer_extension.dart';
import 'package:provider/provider.dart';

class DownloadActionButton extends StatelessWidget {
  final PdfModel pdf;

  const DownloadActionButton({super.key, required this.pdf});

  @override
  Widget build(BuildContext context) {
    switch (pdf.downloadStatus) {
      case "ongoing":
        return OngoingDownloadWidget(pdf: pdf);

      case "completed":
        return IconButton(
          icon: const Icon(Icons.delete, color: Colors.red, size: 30),
          onPressed: () {},
        );

      case "cancelled":
        return Row(
          children: [
            GestureDetector(
              child:
                  const Icon(Icons.restart_alt, size: 30, color: Colors.orange),
              onTap: () async {
                final downloadProvider = context.read<DownloadProvider>();
                final pdfProvider = context.read<PdfProvider>();
                await downloadProvider.removeFromCancelledList(pdf);
                await downloadProvider.restartDownload(pdf);
                pdfProvider.setCurrentTabIndex(0);
              },
            ),
            10.hSpace,
            GestureDetector(
              child: const Icon(Icons.delete, size: 30, color: Colors.orange),
              onTap: () async {
                final downloadProvider = context.read<DownloadProvider>();
                final pdfProvider = context.read<PdfProvider>();
                await downloadProvider.removeFromCancelledList(pdf);
                pdfProvider.removeFromTotalPdfList(pdf);
              },
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
