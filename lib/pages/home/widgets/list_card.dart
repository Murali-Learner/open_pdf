import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/pages/home/widgets/pdf_card_options.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/utils/enumerates.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:provider/provider.dart';

class ListPdfCard extends StatelessWidget {
  final PdfModel pdf;
  final int index;
  const ListPdfCard({super.key, required this.pdf, required this.index});

  @override
  Widget build(BuildContext context) {
    log("download progress ${pdf.downloadProgress}");
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      tileColor: context.theme.primaryColor.withOpacity(0.5),
      title: Text(
        pdf.fileName!,
        style: context.textTheme.bodyLarge!.copyWith(
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        "\n${pdf.fileSize!.toStringAsFixed(2)} KB",
        style: context.textTheme.bodyMedium,
      ),
      trailing: Consumer<PdfProvider>(builder: (context, provider, _) {
        return pdf.downloadStatus == DownloadStatus.completed.name
            ? PdfCardOptions(
                pdf: pdf,
                index: index,
              )
            : _buildTrailingButton(context);
      }),
    );
  }

  Widget _buildTrailingButton(BuildContext context) {
    switch (pdf.downloadStatus) {
      case "ongoing":
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

      case "completed":
        return IconButton(
          icon: const Icon(
            Icons.delete,
            color: Colors.red,
            size: 30,
          ),
          onPressed: () {},
        );

      case "cancelled":
        return IconButton(
          icon: const Icon(Icons.restart_alt, color: Colors.orange),
          onPressed: () {},
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
