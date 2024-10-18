import 'package:flutter/material.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/providers/download_provider.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/utils/extensions/spacer_extension.dart';
import 'package:provider/provider.dart';

class DownloadActionButton extends StatelessWidget {
  final PdfModel pdf;

  const DownloadActionButton({super.key, required this.pdf});

  @override
  Widget build(BuildContext context) {
    debugPrint("pdf.downloadStatus ${pdf.downloadStatus}");
    switch (pdf.downloadStatus) {
      case "running" || "enqueued" || "undefined" || "paused":
        return Row(
          children: [
            (pdf.downloadStatus == "paused")
                ? _buildResumeButton(context)
                : _buildPauseButton(context),
            10.hSpace,
            _buildCancelButton(context),
          ],
        );

      case "canceled" || "failed":
        return Row(
          children: [
            _buildRestartButton(context),
            10.hSpace,
            _buildDeleteButton(context),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPauseButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.pause, color: Colors.orange, size: 30),
      onPressed: () async {
        final downloadProvider = context.read<DownloadProvider>();
        await downloadProvider.pauseDownload(pdf);
      },
    );
  }

  Widget _buildResumeButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.play_arrow, color: Colors.green, size: 30),
      onPressed: () async {
        final downloadProvider = context.read<DownloadProvider>();
        await downloadProvider.resumeDownload(pdf);
      },
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.cancel, color: Colors.red, size: 30),
      onPressed: () async {
        final downloadProvider = context.read<DownloadProvider>();
        await downloadProvider.cancelDownload(pdf);
        await downloadProvider.removeTaskFormDownloader(pdf.taskId!);
      },
    );
  }

  Widget _buildRestartButton(BuildContext context) {
    return GestureDetector(
      child: const Icon(Icons.restart_alt, size: 30, color: Colors.orange),
      onTap: () async {
        final downloadProvider = context.read<DownloadProvider>();
        downloadProvider.setTabIndex(0);
        await downloadProvider.restartDownload(pdf);
      },
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return GestureDetector(
      child: const Icon(Icons.delete, size: 30, color: Colors.orange),
      onTap: () async {
        final downloadProvider = context.read<DownloadProvider>();
        final pdfProvider = context.read<PdfProvider>();
        await downloadProvider.removeFromDownloadedMap(pdf);
        await downloadProvider.removeTaskFormDownloader(pdf.taskId!);
        pdfProvider.removeFromTotalPdfList(pdf);
      },
    );
  }
}
