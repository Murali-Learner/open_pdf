import 'package:flutter/material.dart';
import 'package:open_pdf/pages/download/widgets/download_pdf_row.dart';
import 'package:open_pdf/providers/download_provider.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:open_pdf/utils/toast_utils.dart';
import 'package:provider/provider.dart';

class DownloadButton extends StatefulWidget {
  const DownloadButton({
    super.key,
    required this.pdfUrl,
  });
  final String pdfUrl;
  @override
  State<DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.download,
        size: 30,
      ),
      onPressed: () async {
        final downloadProvider = context.read<DownloadProvider>();
        final pdfProvider = context.read<PdfProvider>();
        pdfProvider.setCurrentTabIndex(0);

        if (widget.pdfUrl.isEmpty) {
          ToastUtils.showErrorToast("Please enter URL");
          return;
        }
        debugPrint("widget.pdfUrl ${widget.pdfUrl}");

        final downloadPdfTextFieldState =
            context.findAncestorStateOfType<DownloadPdfRowState>();
        context.hideKeyBoard();

        downloadPdfTextFieldState!.searchController.clear();
        await downloadProvider.downloadAndSavePdf(
          widget.pdfUrl,
          pdfProvider.addToTotalPdfList,
        );
      },
    );
  }
}
