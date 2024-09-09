import 'package:flutter/material.dart';
import 'package:open_pdf/global_widgets/global_loading_widget.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/utils/enumerates.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:provider/provider.dart';

class DownloadCard extends StatelessWidget {
  final PdfModel pdf;
  final int index;
  final DownloadStatus? downloadStatus;

  const DownloadCard({
    super.key,
    required this.pdf,
    required this.index,
    required this.downloadStatus,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      tileColor: context.theme.primaryColor.withOpacity(0.5),
      title: Text(
        pdf.fileName,
        style: context.textTheme.bodySmall,
      ),
      trailing: downloadStatus == null
          ? const GlobalLoadingWidget()
          : _buildTrailingButton(context),
    );
  }

  Widget _buildTrailingButton(BuildContext context) {
    switch (downloadStatus) {
      case DownloadStatus.ongoing:
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.red),
              onPressed: () {},
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
        );

      case DownloadStatus.completed:
        return IconButton(
          icon: const Icon(
            Icons.delete,
            color: Colors.red,
            size: 30,
          ),
          onPressed: () {},
        );

      case DownloadStatus.cancelled:
        return IconButton(
          icon: const Icon(Icons.restart_alt, color: Colors.orange),
          onPressed: () {},
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
