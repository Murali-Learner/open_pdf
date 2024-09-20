import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/pages/pdfViewer/widgets/page_information_widget.dart';
import 'package:open_pdf/pages/pdfViewer/widgets/pdf_control_buttons.dart';
import 'package:open_pdf/providers/pdf_control_provider.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/utils/enumerates.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
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
  @override
  void initState() {
    super.initState();
    provider = context.read<PdfControlProvider>();

    scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    ScrollPosition position = scrollController.position;
    log("_scrollListener ${position.pixels}");
    if (position.pixels == position.minScrollExtent) {
      log("true");
      provider.setPdfControlButtons(true);
    } else if (position.userScrollDirection == ScrollDirection.reverse) {
      log("false");
      provider.setPdfControlButtons(false);
    }
  }

  double _verticalDragOffset = 0.0;
  @override
  Widget build(BuildContext context) {
    return Consumer2<PdfControlProvider, PdfProvider>(
        builder: (context, providerViewPdf, providerPdf, _) {
      final path = widget.pdf.filePath;
      return Scaffold(
        // appBar: providerPdf.showAppbar
        //     ? AppBar(
        //         elevation: 4.0,
        //         title: const Text("Pdf Viewer"),
        //         actions: const [
        //           PageInformationWidget(),
        //         ],
        //       )
        //     : null,
        body: SafeArea(
          child: Stack(
            children: [
              provider.errorMessage.isNotEmpty
                  ? Center(
                      child: Text("Error ${provider.errorMessage}"),
                    )
                  : Padding(
                      padding: EdgeInsets.only(
                        top: context.height(providerPdf.showAppbar &&
                                providerPdf.pdfCurrentPage != 1
                            ? 10
                            : 0),
                      ),
                      child: SizedBox(
                        height: context.screenHeight,
                        child: PDFView(
                          key: ValueKey(path),
                          filePath: path,
                          enableSwipe: true,
                          swipeHorizontal:
                              provider.pdfScrollMode == PdfScrollMode.horizontal
                                  ? true
                                  : false,
                          autoSpacing: false,
                          pageFling: true,
                          pageSnap: true,
                          nightMode: false,
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
                          onPageScrolled: (page, positionOffset) {
                            log("page $page $positionOffset");
                            if (providerPdf.considerScroll) {
                              if (providerPdf.showPdfTools) {
                                providerPdf.setPdfToolsVisibility(false);
                              }
                              providerPdf.setAppBarVisibility(page == 0);
                            }
                          },
                          onTap: (onTap) {
                            debugPrint("onTap $onTap");
                            providerPdf.setConsiderScroll(false);

                            providerPdf.setPdfToolsVisibility(
                                !providerPdf.showPdfTools);
                            providerPdf
                                .setAppBarVisibility(!providerPdf.showAppbar);
                            Future.delayed(Duration(seconds: 1))
                                .whenComplete(() {
                              providerPdf.setConsiderScroll(true);
                            });
                          },
                          onPageChanged: (int? page, int? total) {
                            debugPrint('page change: $page/$total');
                            provider.setCurrentPage(page!);
                          },
                        ),
                      ),
                    ),
              if (providerPdf.showPdfTools)
                Positioned(
                  bottom: context.height(5),
                  left: 0,
                  right: 0,
                  // alignment: Alignment.bottomCenter,
                  child: const PdfControlButtons(),
                ),
              if (providerPdf.showAppbar && providerPdf.pdfCurrentPage != 1)
                Container(
                  height: context.height(8),
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                      blurRadius: 6,
                      spreadRadius: 0.1,
                      offset: const Offset(0, 8),
                      color: Colors.grey.withOpacity(0.6),
                    )
                  ]),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                          onPressed: () {
                            context.pop();
                          },
                          icon: const Icon(Icons.arrow_back)),
                      Expanded(
                        flex: 6,
                        child: Text(
                          "${widget.pdf.fileName}",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Spacer(),
                      const PageInformationWidget(),
                    ],
                  ),
                )
            ],
          ),
        ),
      );
    });
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
//  @override
// void initState() {
//   super.initState();
//   provider = context.read<PdfControlProvider>();

//   scrollController.addListener(_scrollListener);
// }

// void _scrollListener() {
//   ScrollPosition position = scrollController.position;

//   if (position.userScrollDirection == ScrollDirection.reverse) {
//     // Hide AppBar and control buttons when scrolling down
//     if (isAppBarVisible) {
//       setState(() {
//         isAppBarVisible = false;
//       });
//       provider.setPdfControlButtons(false);
//     }
//   } else if (position.userScrollDirection == ScrollDirection.forward) {
//     // Show AppBar and control buttons when scrolling up
//     if (!isAppBarVisible) {
//       setState(() {
//         isAppBarVisible = true;
//       });
//       provider.setPdfControlButtons(true);
//     }
//   }
// }
