import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:open_pdf/pages/home/widgets/pdf_control_buttons.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:provider/provider.dart';

class PdfViewerWidget extends StatelessWidget {
  const PdfViewerWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pdf Viewer"),
      ),
      body: Consumer<PdfProvider>(builder: (context, provider, _) {
        final path = provider.currentPDF!.filePath;
        debugPrint("current pdf $path");
        return Column(
          children: [
            Text(" ${provider.currentPDF!.filePath}"),
            const PdfControlButtons(),
            Expanded(
              child: PDFView(
                key: ValueKey(path),
                filePath: path,
                enableSwipe: true,
                swipeHorizontal: false,
                autoSpacing: false,
                pageFling: true,
                pageSnap: true,
                defaultPage: provider.pdfCurrentPage,
                fitPolicy: FitPolicy.BOTH,
                preventLinkNavigation: false,
                onRender: (pages) {
                  provider.setTotalPages(
                    pages!,
                  );
                },
                onError: (error) {
                  provider.setErrorMessage(error.toString());
                  debugPrint(error.toString());
                },
                onPageError: (page, error) {
                  provider.setErrorMessage(error.toString());
                  debugPrint('$page: ${error.toString()}');
                },
                onViewCreated: (PDFViewController controller) async {
                  provider.setPdfController(controller);
                  final count = await controller.getPageCount();
                  debugPrint("get page count $count ");
                },
                onLinkHandler: (String? uri) {
                  debugPrint('goto uri: $uri');
                },
                onPageChanged: (int? page, int? total) {
                  debugPrint('page change: $page/$total');
                  provider.setCurrentPage(page!);
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}

Future<String?> _passwordDialog(BuildContext context) async {
  final textController = TextEditingController();
  return await showDialog<String?>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return PasswordDialogWidget(textController: textController);
    },
  );
}

class PasswordDialogWidget extends StatelessWidget {
  const PasswordDialogWidget({
    super.key,
    required this.textController,
  });

  final TextEditingController textController;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter password'),
      content: TextField(
        controller: textController,
        autofocus: true,
        keyboardType: TextInputType.visiblePassword,
        // obscureText: true,
        onSubmitted: (value) => Navigator.of(context).pop(value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            debugPrint("message ${textController.text.trim()}");
            Navigator.of(context).pop(textController.text.trim());
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
