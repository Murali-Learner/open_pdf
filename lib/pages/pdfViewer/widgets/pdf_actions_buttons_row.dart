import 'package:flutter/material.dart';
import 'package:open_pdf/pages/pdfViewer/widgets/dictonary_bottom_sheet.dart';
import 'package:open_pdf/pages/pdfViewer/widgets/page_information_widget.dart';
import 'package:open_pdf/providers/dictionary_provider.dart';
import 'package:open_pdf/providers/pdf_control_provider.dart';
import 'package:open_pdf/providers/pdf_js_provider.dart';
import 'package:open_pdf/utils/constants.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:provider/provider.dart';

class PdfActionsButtonRow extends StatelessWidget {
  const PdfActionsButtonRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<PdfControlProvider, PdfJsProvider>(
        builder: (context, pdfProvider, pdfJsProvider, _) {
      return ListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: [
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
            onPressed: () async {
              context.hideKeyBoard();
              final provider = context.read<DictionaryProvider>();

              provider.clearResults();
              await provider.fetchAllWords();
              provider.toggleClearButton(false);

              showModalBottomSheet(
                showDragHandle: true,
                context: context,
                constraints: BoxConstraints(maxHeight: context.height(70)),
                backgroundColor: context.theme.scaffoldBackgroundColor,
                barrierColor: ColorConstants.color.withOpacity(0.5),
                isScrollControlled: true,
                useSafeArea: true,
                builder: (context) => const DictionaryBottomSheet(),
              );
            },
          ),
          IconButton(
            tooltip: "Slider",
            icon: Icon(
              pdfJsProvider.showSlider
                  ? Icons.arrow_drop_down_rounded
                  : Icons.arrow_drop_up_rounded,
              color: ColorConstants.amberColor,
              size: 40,
            ),
            onPressed: () async {
              pdfJsProvider.showSlider = !pdfJsProvider.showSlider;
            },
          ),
        ],
      );
    });
  }
}
