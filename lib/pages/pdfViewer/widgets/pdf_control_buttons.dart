import 'package:flutter/material.dart';
import 'package:open_pdf/pages/pdfViewer/widgets/dictonary_bottom_sheet.dart';
import 'package:open_pdf/providers/pdf_control_provider.dart';
import 'package:open_pdf/utils/constants.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:provider/provider.dart';

class PdfControlButtons extends StatelessWidget {
  const PdfControlButtons({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Consumer<PdfControlProvider>(builder: (context, provider, _) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Material(
          elevation: 4.0,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: EdgeInsets.all(5),
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
                  tooltip: "First page",
                  icon: const Icon(
                    Icons.first_page,
                    color: Constants.pdfViewIconsColor,
                  ),
                  onPressed: () {
                    provider.gotoFirstPage();
                  },
                ),
                IconButton(
                  tooltip: "Last page",
                  icon: const Icon(
                    Icons.last_page,
                    color: Constants.pdfViewIconsColor,
                  ),
                  onPressed: () => provider.gotoLastPage(),
                ),
                IconButton(
                  tooltip: "Next page",
                  icon: const Icon(
                    Icons.arrow_downward,
                    color: Constants.pdfViewIconsColor,
                  ),
                  onPressed: () => provider.nextPage(),
                ),
                IconButton(
                  tooltip: "Previous page",
                  icon: const Icon(
                    Icons.arrow_upward,
                    color: Constants.pdfViewIconsColor,
                  ),
                  onPressed: () => provider.previousPage(),
                ),
                IconButton(
                  tooltip: "Open dictionary",
                  icon: Icon(
                    Icons.menu_book_outlined,
                    color: Constants.pdfViewIconsColor,
                  ),
                  onPressed: () {
                    context.hideKeyBoard();
                    showModalBottomSheet(
                      showDragHandle: true,
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      builder: (context) => const DictionaryBottomSheet(),
                    );
                  },
                  // const Spacer(),
                  // const ScrollModeButtonsRow(),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
