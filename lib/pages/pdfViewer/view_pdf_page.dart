import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/pages/pdfViewer/widgets/pdf_control_buttons.dart';
import 'package:open_pdf/pages/pdfViewer/widgets/pdf_view_app_bar.dart';
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
    if (position.pixels == position.minScrollExtent) {
      // Show controls when at the top
      provider.setPdfControlButtons(true);
      provider.setAppBarVisibility(true);
    } else if (position.userScrollDirection == ScrollDirection.reverse) {
      // Hide controls when scrolling down
      provider.setPdfControlButtons(false);
      provider.setAppBarVisibility(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<PdfControlProvider, PdfProvider>(
        builder: (context, viewProvider, pdfProvider, _) {
      final path = widget.pdf.filePath;
      return Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              provider.errorMessage.isNotEmpty
                  ? Center(
                      child: Text("Error ${provider.errorMessage}"),
                    )
                  : Padding(
                      padding: EdgeInsets.only(
                        top: context.height(
                          viewProvider.showAppbar &&
                                  viewProvider.pdfCurrentPage == 1
                              ? 7.5
                              : 0,
                        ),
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
                          defaultPage: provider.pdfCurrentPage - 1,
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
                          // onPageScrolled: (page, positionOffset) {
                          //   // log("page $page $positionOffset");
                          //   // if (pdfProvider.considerScroll) {
                          //   //   if (pdfProvider.showPdfTools) {
                          //   //     pdfProvider.setPdfToolsVisibility(false);
                          //   //   }
                          //   //   pdfProvider.setAppBarVisibility(page == 1);
                          //   // }
                          // },
                          onTap: (onTap) {
                            log("onTap ${viewProvider.showAppbar} ${viewProvider.showPdfTools}");
                            // viewProvider.setConsiderScroll(false);
                            if (viewProvider.showAppbar) {
                              log("app bar visible, hiding it");
                              viewProvider.setAppBarVisibility(false);
                              viewProvider.setPdfToolsVisibility(false);
                            } else {
                              log("app bar not visible, showing it");
                              viewProvider.setAppBarVisibility(true);
                              viewProvider.setPdfToolsVisibility(true);
                            }
                            // // Delay and set `considerScroll` to true after a second
                            // Future.delayed(const Duration(seconds: 1))
                            //     .whenComplete(() {
                            //   viewProvider.setConsiderScroll(true);
                            // });
                          },
                          // onTap: (onTap) {
                          //   debugPrint("onTap $onTap");
                          //   viewProvider.setConsiderScroll(false);

                          //   viewProvider.setPdfToolsVisibility(
                          //       !viewProvider.showPdfTools);
                          //   viewProvider
                          //       .setAppBarVisibility(!viewProvider.showAppbar);
                          //   Future.delayed(const Duration(seconds: 1))
                          //       .whenComplete(() {
                          //     viewProvider.setConsiderScroll(true);

                          //     // log()
                          //   });
                          // },
                          onPageChanged: (int? page, int? total) {
                            debugPrint('page change: $page/$total');
                            if (page != null && total != null) {
                              provider.setCurrentPage(
                                  page >= 0 || (page) == total
                                      ? (page + 1)
                                      : page);
                            }
                          },
                        ),
                      ),
                    ),
              if (viewProvider.showPdfTools)
                Positioned(
                  bottom: context.height(5),
                  left: 0,
                  right: 0,
                  // alignment: Alignment.bottomCenter,
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
    });
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
