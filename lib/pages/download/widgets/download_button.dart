import 'package:flutter/material.dart';
import 'package:open_pdf/global_widgets/global_loading_widget.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
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
    return Consumer<PdfProvider>(builder: (context, provider, _) {
      return provider.btnLoading
          ? const GlobalLoadingWidget()
          : IconButton(
              icon: const Icon(Icons.download),
              onPressed: () async {
                // context.push(
                //     navigateTo: DocumentSaveScreen(dirType: DirType.download));
                final provider = context.read<PdfProvider>();

                await provider.downloadAndSavePdf(
                  "https://enos.itcollege.ee/~jpoial/allalaadimised/reading/Android-Programming-Cookbook.pdf",
                );
              },
            );
    });
  }
}
