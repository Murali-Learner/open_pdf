import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/pages/home/widgets/pdf_card_options.dart';
import 'package:open_pdf/pages/pdfViewer/view_pdf_page.dart';
import 'package:open_pdf/providers/download_provider.dart';
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

class PdfInfoWidget extends StatelessWidget {
  final PdfModel pdf;
  final bool isDownloadCard;

  const PdfInfoWidget(
      {super.key, required this.pdf, required this.isDownloadCard});

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
        log("pdf.fileName  ${pdf.fileName}");
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            children: [
              SizedBox(
                child: Text(
                  pdf.fileName ?? 'Unknown Files',
                  style: context.textTheme.bodyLarge!.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          8.vSpace,
          if (pdf.downloadStatus == DownloadStatus.ongoing.name)
            Consumer<PdfProvider>(builder: (context, provider, _) {
              return LinearProgressIndicator(
                value: pdf.downloadProgress,
              );
            }),
          Text(
            pdf.fileSize ?? '',
            style: context.textTheme.bodyMedium!.copyWith(
              color: pdf.isSelected ? Colors.white : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

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

class OngoingDownloadWidget extends StatefulWidget {
  final PdfModel pdf;

  const OngoingDownloadWidget({super.key, required this.pdf});

  @override
  OngoingDownloadWidgetState createState() => OngoingDownloadWidgetState();
}

class OngoingDownloadWidgetState extends State<OngoingDownloadWidget> {
  bool _isCancelling = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<DownloadProvider>();
    return _isCancelling
        ? const SizedBox(
            height: 35,
            width: 35,
            child: CircularProgressIndicator(),
          )
        : GestureDetector(
            onTap: () async {
              if (mounted) {
                setState(() {
                  _isCancelling = true;
                });
              }

              await provider.cancelDownload(widget.pdf);

              if (mounted) {
                setState(() {
                  _isCancelling = false;
                });
              }
            },
            child: const Icon(
              Icons.cancel,
              color: Colors.red,
              size: 35,
            ),
          );
  }
}
