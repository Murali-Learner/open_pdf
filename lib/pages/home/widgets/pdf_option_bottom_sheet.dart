// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/pages/home/widgets/pdf_option_item.dart';
import 'package:open_pdf/providers/download_provider.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:open_pdf/utils/toast_utils.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class PdfOptionsBottomSheet extends StatelessWidget {
  final PdfModel pdf;

  const PdfOptionsBottomSheet({
    super.key,
    required this.pdf,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PdfProvider>();
    final downloadProvider = context.read<DownloadProvider>();
    return Wrap(
      children: [
        PdfOptionItem(
          icon: Icons.favorite,
          text: "${pdf.isFav ? "Remove from" : "Add to"} Favorites",
          onTap: () async => await _handleAddToFavorites(context),
        ),
        PdfOptionItem(
          icon: Icons.share,
          text: "Share",
          onTap: () => _handleSharePdf(context, pdf),
        ),
        if (pdf.networkUrl != null && pdf.networkUrl!.isNotEmpty)
          PdfOptionItem(
            icon: Icons.delete,
            text: "Delete permanently",
            onTap: () {
              showDeleteConfirmationDialog(context, pdf);
            },
          ),
        PdfOptionItem(
          icon: Icons.delete,
          text: "Delete from history",
          onTap: () async {
            await provider.deleteFormHistory(pdf);
            await downloadProvider.removeFromCompletedList(pdf);
            context.pop();
          },
        ),
      ],
    );
  }

  Future<void> _handleAddToFavorites(BuildContext context) async {
    await context.read<PdfProvider>().toggleFavorite(pdf);
    await context.read<DownloadProvider>().toggleFavorite(pdf);

    context.pop();
  }

  void _handleSharePdf(BuildContext context, PdfModel pdf) {
    sharePdf(pdf);
    context.pop();
  }

  void sharePdf(PdfModel pdf) async {
    try {
      await Share.shareXFiles([XFile(pdf.filePath!)],
          text: 'Check out this PDF file!',
          subject: "Check out this pdf file!");
      debugPrint("Sharing ${pdf.fileName}");
    } catch (e) {
      debugPrint("Error while sharing file $e");
      ToastUtils.showErrorToast("Error while sharing");
    }
  }
}

void showDeleteConfirmationDialog(
  BuildContext context,
  PdfModel pdf,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete Confirmation'),
        content: Text("Are you sure you want to delete this ${pdf.fileName}"),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              context.pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              log("delete perme");
              final pdfProvider = context.read<PdfProvider>();
              final downloadProvider = context.read<DownloadProvider>();

              pdfProvider.removeFromTotalPdfList(pdf);
              await downloadProvider.deleteCompletely(pdf);
              context.pop();
              context.pop();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );
}
