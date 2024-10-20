import 'package:flutter/material.dart';
import 'package:open_pdf/pages/pdfViewer/widgets/dictonary_bottom_sheet.dart';
import 'package:open_pdf/pages/pdfViewer/widgets/page_information_widget.dart';
import 'package:open_pdf/providers/pdf_control_provider.dart';
import 'package:open_pdf/providers/pdf_js_provider.dart';
import 'package:open_pdf/utils/constants.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:provider/provider.dart';

class PdfControlButtons extends StatelessWidget {
  const PdfControlButtons({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Consumer2<PdfControlProvider, PdfJsProvider>(
        builder: (context, pdfProvider, pdfJsProvider, _) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Material(
          elevation: 4.0,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: Constants.globalDuration,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // IconButton(
                //   icon: const Icon(Icons.zoom_in),
                //   onPressed: () {
                //     provider.nextPage();
                //     provider.zoomUp();
                //   },
                // ),
                // IconButton(
                //   icon: const Icon(Icons.zoom_out),
                //   onPressed: () => provider.zoomDown(),
                // ),

                IconButton(
                  tooltip: "Previous page",
                  icon: Icon(
                    Icons.arrow_back,
                    color: ColorConstants.amberColor,
                  ),
                  onPressed: () async {
                    await pdfJsProvider.changePage(false);
                    // return await provider.previousPage();
                  },
                ),
                IconButton(
                  tooltip: "Next page",
                  icon: Icon(
                    Icons.arrow_forward,
                    color: ColorConstants.amberColor,
                  ),
                  onPressed: () async {
                    await pdfJsProvider.changePage(true);
                    // await provider.nextPage();
                  },
                ),
                const PageInformationWidget(),
                IconButton(
                  tooltip: "Open dictionary",
                  icon: Icon(
                    Icons.menu_book_outlined,
                    color: ColorConstants.amberColor,
                  ),
                  onPressed: () {
                    context.hideKeyBoard();
                    showModalBottomSheet(
                      showDragHandle: true,
                      context: context,
                      backgroundColor: context.theme.scaffoldBackgroundColor,
                      barrierColor: ColorConstants.color.withOpacity(0.5),
                      isScrollControlled: true,
                      useSafeArea: true,
                      builder: (context) => const DictionaryBottomSheet(),
                    );
                  },
                ),
                // const Spacer(),
                // const ScrollModeButtonsRow(),
              ],
            ),
          ),
        ),
      );
    });
  }
}
