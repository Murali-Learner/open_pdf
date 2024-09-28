import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_pdf/global_widgets/global_loading_widget.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/pages/pdfViewer/widgets/pdf_control_buttons.dart';
import 'package:open_pdf/pages/pdfViewer/widgets/pdf_view_app_bar.dart';
import 'package:open_pdf/providers/pdf_control_provider.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/utils/constants.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:pdfx/pdfx.dart';
import 'package:provider/provider.dart';

class ViewPdfPage extends StatefulWidget {
  final PdfModel pdf;
  const ViewPdfPage({
    super.key,
    required this.pdf,
  });

  @override
  State<ViewPdfPage> createState() => _ViewPdfPageState();
}

class _ViewPdfPageState extends State<ViewPdfPage> {
  final ScrollController scrollController = ScrollController();
  late PdfControlProvider provider;
  late PdfControllerPinch pinchController;

  @override
  void initState() {
    super.initState();
    provider = context.read<PdfControlProvider>();
    pinchController = PdfControllerPinch(
        document: PdfDocument.openFile(widget.pdf.filePath!));
    WidgetsBinding.instance.addPostFrameCallback((timestamp) {
      provider.setCurrentPage(pinchController.initialPage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<PdfControlProvider, PdfProvider>(
      builder: (context, viewProvider, pdfProvider, _) {
        final path = widget.pdf.filePath;

        if (provider.isLoading) {
          return const GlobalLoadingWidget();
        }

        if (provider.errorMessage.isNotEmpty) {
          return Center(child: Text("Error: ${provider.errorMessage}"));
        }

        if (path == null || !File(path).existsSync()) {
          return const Center(child: Text("PDF file not found"));
        }
        log("path checking finished ${viewProvider.pdfCurrentPage}");

        return Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    if (viewProvider.showAppbar) {
                      log("app bar visible, hiding it");
                      viewProvider.setAppBarVisibility(false);
                      viewProvider.setPdfToolsVisibility(false);
                    } else {
                      log("app bar not visible, showing it");
                      viewProvider.setAppBarVisibility(true);
                      viewProvider.setPdfToolsVisibility(true);
                    }
                  },
                  child: AnimatedPadding(
                    duration: Constants.globalDuration,
                    padding: EdgeInsets.only(
                      top: context.height(
                        viewProvider.showAppbar &&
                                viewProvider.pdfCurrentPage == 1
                            ? 7.5
                            : 0,
                      ),
                    ),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: PdfViewPinch(
                        key: ValueKey(path),
                        controller: pinchController,
                        padding: viewProvider.showAppbar &&
                                viewProvider.pdfCurrentPage == 1
                            ? 20
                            : 10,
                        maxScale: 20,
                        scrollDirection: viewProvider.pdfScrollMode,
                        onDocumentError: (error) =>
                            viewProvider.setErrorMessage,
                        onDocumentLoaded: (document) async {
                          viewProvider.setTotalPages(document.pagesCount);
                          viewProvider.init(pinchController);
                        },
                        onPageChanged: (page) {
                          debugPrint(
                              'page change: $page/${viewProvider.totalPages}');

                          provider.setCurrentPage(page);
                        },
                      ),
                    ),
                  ),
                ),
                if (viewProvider.showPdfTools)
                  Positioned(
                    bottom: context.height(5),
                    left: 0,
                    right: 0,
                    child: const PdfControlButtons(),
                  ),
                if (viewProvider.showAppbar)
                  PdfViewAppBar(
                    pdf: widget.pdf,
                  )
              ],
            ),
          ),
        );
      },
    );
  }
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
