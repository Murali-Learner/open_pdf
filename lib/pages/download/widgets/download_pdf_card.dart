import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/pages/home/widgets/download_action_button.dart';
import 'package:open_pdf/pages/home/widgets/pdf_card_options.dart';
import 'package:open_pdf/pages/home/widgets/pdf_info_widget.dart';
import 'package:open_pdf/pages/pdfViewer/view_pdf_page.dart';
import 'package:open_pdf/providers/download_provider.dart';
import 'package:open_pdf/providers/pdf_control_provider.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:open_pdf/utils/extensions/spacer_extension.dart';
import 'package:provider/provider.dart';

class DownloadPdfCard extends StatelessWidget {
  final PdfModel pdf;
  final int index;

  const DownloadPdfCard({super.key, required this.pdf, required this.index});

  @override
  Widget build(BuildContext context) {
    return Consumer<PdfProvider>(builder: (context, provider, _) {
      return GestureDetector(
        onTap: () {
          debugPrint(
              "pdf  ${pdf.fileName} ${provider.isMultiSelected} ${pdf.filePath}");
          onSingleTap(provider, context);
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: pdf.isSelected
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PdfInfoWidget(
                      pdf: pdf,
                      isDownloadCard: true,
                    ),
                    if (pdf.downloadStatus == DownloadTaskStatus.running.name ||
                        pdf.downloadStatus == DownloadTaskStatus.paused.name)
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: pdf.downloadProgress,
                            ),
                          ),
                          5.hSpace,
                          Text(
                            "${(pdf.downloadProgress!).toStringAsFixed(0)}%",
                            style: context.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              10.hSpace,
              pdf.downloadStatus == DownloadTaskStatus.complete.name
                  ? PdfCardOptions(pdf: pdf, index: index)
                  : DownloadActionButton(pdf: pdf),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPauseButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.pause, color: Colors.orange),
      onPressed: () async {
        final provider = context.read<DownloadProvider>();
        await FlutterDownloader.pause(taskId: pdf.taskId!);
        await provider.pauseDownload(pdf);
      },
    );
  }

  Widget _buildResumeButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.play_arrow, color: Colors.green),
      onPressed: () async {
        final provider = context.read<DownloadProvider>();

        await provider.resumeDownload(pdf);
      },
    );
  }

  void onSingleTap(PdfProvider provider, BuildContext context) async {
    if (pdf.downloadStatus == DownloadTaskStatus.complete.name) {
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
  }
}
