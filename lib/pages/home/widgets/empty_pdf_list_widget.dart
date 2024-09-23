import 'package:flutter/material.dart';
import 'package:open_pdf/pages/download/downloads_page.dart';
import 'package:open_pdf/pages/pdfViewer/view_pdf_page.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:provider/provider.dart';

class EmptyPdfListWidget extends StatelessWidget {
  const EmptyPdfListWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "No PDFs Available",
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                // color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // Secondary description text
            Text(
              "Upload or download your first PDF to get started!",
              style: context.textTheme.bodyMedium?.copyWith(
                  // color: Colors.grey.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Buttons for action
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final provider = context.read<PdfProvider>();
                    provider.clearSelectedFiles();
                    await context
                        .read<PdfProvider>()
                        .pickFile()
                        .whenComplete(() {
                      if (provider.currentPDF != null) {
                        context.push(
                            navigateTo: ViewPdfPage(pdf: provider.currentPDF!));
                      }
                    });
                  },
                  icon: const Icon(Icons.upload_file),
                  label: const Text("Upload File"),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<PdfProvider>().clearSelectedFiles();
                    context.push(navigateTo: const DownloadPage());
                  },
                  icon: const Icon(Icons.download),
                  label: const Text("Download PDF"),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
