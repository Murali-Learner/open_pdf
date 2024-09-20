import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/pages/home/widgets/pdf_card_options.dart';
import 'package:open_pdf/pages/pdfViewer/view_pdf_page.dart';
import 'package:open_pdf/providers/pdf_control_provider.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/utils/enumerates.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:open_pdf/utils/extensions/spacer_extension.dart';
import 'package:open_pdf/utils/toast_utils.dart';
import 'package:provider/provider.dart';

class ListPdfCard extends StatelessWidget {
  final PdfModel pdf;
  final int index;

  const ListPdfCard({super.key, required this.pdf, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.theme.primaryColor.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              child: GestureDetector(
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
                  child: PdfInfoWidget(pdf: pdf))),
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
    );
  }
}

class PdfInfoWidget extends StatelessWidget {
  final PdfModel pdf;

  const PdfInfoWidget({super.key, required this.pdf});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          children: [
            SizedBox(
              child: Text(
                pdf.fileName ?? 'Unknown File',
                style: context.textTheme.bodyLarge!.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        8.vSpace,
        Text(
          pdf.fileSize!,
          style: context.textTheme.bodyMedium!.copyWith(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class DownloadActionButton extends StatelessWidget {
  final PdfModel pdf;

  const DownloadActionButton({super.key, required this.pdf});

  @override
  Widget build(BuildContext context) {
    debugPrint("pdf.downloadStatus ${pdf.downloadStatus}");

    switch (pdf.downloadStatus) {
      case "ongoing":
        return OngoingDownloadWidget(pdf: pdf);

      case "completed":
        return IconButton(
          icon: const Icon(Icons.delete, color: Colors.red, size: 30),
          onPressed: () {},
        );

      case "cancelled":
        return GestureDetector(
          child: const Icon(Icons.restart_alt, color: Colors.orange),
          onTap: () async {
            final provider = context.read<PdfProvider>();
            await provider.restartDownload(pdf.networkUrl!);
          },
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

class OngoingDownloadWidget extends StatelessWidget {
  final PdfModel pdf;

  const OngoingDownloadWidget({super.key, required this.pdf});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        log("cancel download");
        final provider = context.read<PdfProvider>();
        await provider.cancelDownload(pdf);
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(
            Icons.cancel,
            color: Colors.red,
            size: 35,
          ),
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: context.watch<PdfProvider>().downloadProgress,
            ),
          ),
        ],
      ),
    );
  }
}
