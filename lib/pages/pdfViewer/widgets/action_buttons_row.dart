import 'package:flutter/material.dart';
import 'package:open_pdf/pages/pdfViewer/widgets/dictonary_bottom_sheet.dart';
import 'package:open_pdf/pages/pdfViewer/widgets/page_information_widget.dart';
import 'package:open_pdf/providers/dictionary_provider.dart';
import 'package:open_pdf/providers/pdf_control_provider.dart';
import 'package:open_pdf/providers/pdf_js_provider.dart';
import 'package:open_pdf/utils/constants.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:provider/provider.dart';

class ActionsButtonRow extends StatelessWidget {
  const ActionsButtonRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<PdfControlProvider, PdfJsProvider>(
        builder: (context, pdfProvider, pdfJsProvider, _) {
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            tooltip: "Previous page",
            icon: Icon(
              Icons.arrow_back,
              color: ColorConstants.amberColor,
            ),
            onPressed: () async {
              await pdfJsProvider.changePage(false);
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
            onPressed: () async {
              context.hideKeyBoard();
              final provider = context.read<DictionaryProvider>();

              provider.clearResults();
              await provider.fetchAllWords();
              provider.toggleClearButton(false);

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
      );
    });
  }
}
