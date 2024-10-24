import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/pages/home/widgets/empty_pdf_list_widget.dart';
import 'package:open_pdf/pages/home/widgets/floating_dial_widget.dart';
import 'package:open_pdf/pages/home/widgets/home_list_selector.dart';
import 'package:open_pdf/pages/home/widgets/home_pdf_grid.dart';
import 'package:open_pdf/pages/home/widgets/home_pdf_list.dart';
import 'package:open_pdf/pages/home/widgets/multi_select_button.dart';
import 'package:open_pdf/pages/home/widgets/pop_up_menu_button.dart';
import 'package:open_pdf/pages/home/widgets/view_mode_buttons_row.dart';
import 'package:open_pdf/providers/download_provider.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/utils/constants.dart';
import 'package:open_pdf/utils/enumerates.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:open_pdf/utils/extensions/spacer_extension.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PdfProvider pdfProvider;
  late final DownloadProvider downloadProvider;

  @override
  void initState() {
    super.initState();
    pdfProvider = context.read<PdfProvider>();
    downloadProvider = context.read<DownloadProvider>();
  }

  List<PdfModel> getFilteredAndSortedPdfList() {
    final Map<String, PdfModel> pdfMap;

    switch (pdfProvider.selectedCheckList) {
      case CheckList.all:
        pdfMap = getTotalPdfMap(
            pdfProvider.localPdfList, downloadProvider.downloadedPdfMap);
        break;
      case CheckList.local:
        pdfMap = pdfProvider.localPdfList;
        break;
      default:
        pdfMap = downloadProvider.downloadedPdfMap;
    }

    return pdfMap.values
        .where((pdf) =>
            pdf.downloadStatus == DownloadTaskStatus.complete.name &&
            pdf.lastOpened != null)
        .toSet()
        .toList()
      ..sort((a, b) => b.lastOpened!.compareTo(a.lastOpened!));
  }

  Map<String, PdfModel> getTotalPdfMap(
      Map<String, PdfModel> map1, Map<String, PdfModel> map2) {
    return {...map1, ...map2};
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<PdfProvider, DownloadProvider>(
      builder: (context, pdfProvider, downloadProvider, _) {
        final List<PdfModel> pdfList = getFilteredAndSortedPdfList();
        var list = [
          ...pdfProvider.localPdfList.values,
          ...downloadProvider.downloadedPdfMap.values
        ];

        debugPrint("list ${list.length}");

        return Scaffold(
          appBar: AppBar(
            leading: pdfProvider.selectedFiles.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      pdfProvider.clearSelectedFiles();
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                    ),
                  ),
            title: Text(
              " ${pdfProvider.selectedFiles.isEmpty ? 'Open PDF' : pdfProvider.selectedFiles.length} ",
              style: TextStyle(
                color: ColorConstants.amberColor,
              ),
            ),
            actions: [
              if (pdfProvider.selectedFiles.isEmpty)
                const PopupMenuButtonWidget(),
              if (pdfProvider.selectedFiles.isNotEmpty)
                const MultiSelectionDeleteButton(),
              10.hSpace,
            ],
          ),
          body: list.isEmpty
              ? const EmptyPdfListWidget()
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          HomeListSelector(),
                          ViewModeButtonsRow(),
                        ],
                      ),
                      10.vSpace,
                      pdfList.isEmpty
                          ? Center(
                              child: Text(
                                "No PDF list found",
                                textAlign: TextAlign.center,
                                style: context.textTheme.labelLarge!.copyWith(
                                  color: ColorConstants.amberColor,
                                  fontSize: 20,
                                  // letterSpacing: 0.5,
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : Expanded(
                              child: pdfProvider.viewMode == ViewMode.list
                                  ? HomePdfListView(
                                      pdfLists: pdfList,
                                    )
                                  : HomePdfGridView(
                                      pdfLists: pdfList,
                                    ),
                            ),
                    ],
                  ),
                ),
          floatingActionButton: const FloatingDial(),
        );
      },
    );
  }
}
