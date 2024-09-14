import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/providers/pdf_viewer_provider.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:provider/provider.dart';

class PdfViewerScreen extends StatefulWidget {
  final PdfModel pdfModel;
  const PdfViewerScreen({super.key, required this.pdfModel});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  @override
  void initState() {
    context.read<PdfViewerProvider>().initView();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pdfModel.fileName ?? ""),
      ),
      body: Column(
        children: [
          Consumer<PdfViewerProvider>(builder: (context, pdfViewerProvider, _) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: PdfViewer.file(
                  widget.pdfModel.filePath ?? "",
                  controller: pdfViewerProvider.pdfController!,
                  params: PdfViewerParams(
                    onViewerReady: (document, controller) {
                      pdfViewerProvider.handlePDF();

                      controller.setZoom(controller.centerPosition, 0.5);
                    },
                    boundaryMargin: const EdgeInsets.all(20),
                    activeMatchTextColor: Colors.red,
                    enableTextSelection: true,
                    panEnabled: true,

                    minScale:
                        0.5, // Allow zooming out to half the original size
                    maxScale: 2, // Allow zooming in to twice the original size
                    onInteractionEnd: (details) {
                      // log("Interaction End $details");
                    },
                    onInteractionUpdate: (details) {
                      if (pdfViewerProvider.pdfController!.currentZoom < 0.2) {
                        pdfViewerProvider.pdfController!.setZoom(
                            pdfViewerProvider.pdfController!.centerPosition,
                            0.4);
                      }
                    },
                    onInteractionStart: (details) {
                      // log("Interaction Start $details");
                    },
                    onPageChanged: (pageNumber) {
                      // log("pageNumber: $pageNumber");
                      // final pdf = provider.currentPDF!.copyWith(
                      //   pageNumber: pageNumber,
                      // );

                      // provider.setCurrentPDF(pdf);
                    },
                  ),
                ),
              ),
            );
          })
        ],
      ),
    );
  }
}
