import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:open_pdf/utils/extensions/spacer_extension.dart';

class DownloadProgressIndicator extends StatelessWidget {
  final PdfModel pdf;

  const DownloadProgressIndicator({super.key, required this.pdf});

  @override
  Widget build(BuildContext context) {
    if (pdf.downloadStatus != DownloadTaskStatus.running.name &&
        pdf.downloadStatus != DownloadTaskStatus.paused.name) {
      return const SizedBox.shrink();
    }

    final progress = pdf.downloadProgress ?? 0.0;
    final progressText = progress.toStringAsFixed(0);

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: SizedBox(
              height: 8,
              child: LinearProgressIndicator(
                value: progress / 100,
                backgroundColor: Colors.grey.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  pdf.downloadStatus == DownloadTaskStatus.paused.name
                      ? Colors.orange
                      : Colors.amber,
                ),
              ),
            ),
          ),
        ),
        5.hSpace,
        Text(
          "$progressText%",
          style: context.textTheme.bodyLarge,
          textAlign: TextAlign.end,
        ),
      ],
    );
  }
}
