import 'package:flutter/material.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/pages/home/widgets/empty_pdf_list_widget.dart';
import 'package:open_pdf/pages/home/widgets/floating_dial_widget.dart';
import 'package:open_pdf/pages/home/widgets/home_pdf_grid.dart';
import 'package:open_pdf/pages/home/widgets/home_pdf_list.dart';
import 'package:open_pdf/pages/home/widgets/multi_select_button.dart';
import 'package:open_pdf/pages/home/widgets/pop_up_menu_button.dart';
import 'package:open_pdf/pages/home/widgets/view_mode_buttons_row.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/utils/constants.dart';
import 'package:open_pdf/utils/enumerates.dart';
import 'package:open_pdf/utils/extensions/spacer_extension.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PdfProvider pdfProvider;

  @override
  void initState() {
    super.initState();
    pdfProvider = context.read<PdfProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PdfProvider>(builder: (context, provider, _) {
      return Scaffold(
        appBar: AppBar(
          leading: provider.selectedFiles.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    provider.clearSelectedFiles();
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                  ),
                ),
          title: Text(
            " ${provider.selectedFiles.isEmpty ? 'Open PDF' : provider.selectedFiles.length} ",
            style: TextStyle(
              color: ColorConstants.amberColor,
            ),
          ),
          actions: [
            if (provider.selectedFiles.isEmpty) const PopupMenuButtonWidget(),
            if (provider.selectedFiles.isNotEmpty)
              const MultiSelectionDeleteButton(),
            10.hSpace,
          ],
        ),
        body: Consumer<PdfProvider>(
          builder: (context, provider, _) {
            final List<PdfModel> pdfList =
                provider.getFilteredAndSortedPdfList();
            return pdfList.isEmpty
                ? const EmptyPdfListWidget()
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const ViewModeButtonsRow(),
                        10.vSpace,
                        Expanded(
                          child: provider.viewMode == ViewMode.list
                              ? HomePdfListView(
                                  pdfLists: pdfList,
                                )
                              : HomePdfGridView(
                                  pdfLists: pdfList,
                                ),
                        ),
                      ],
                    ),
                  );
          },
        ),
        floatingActionButton: const FloatingDial(),
      );
    });
  }
}
