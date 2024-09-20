import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/pages/home/widgets/empty_pdf_list_widget.dart';
import 'package:open_pdf/pages/home/widgets/floating_dial_widget.dart';
import 'package:open_pdf/pages/home/widgets/home_pdf_grid.dart';
import 'package:open_pdf/pages/home/widgets/home_pdf_list.dart';
import 'package:open_pdf/pages/home/widgets/pop_up_menu_button.dart';
import 'package:open_pdf/pages/home/widgets/view_mode_buttons_row.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/utils/enumerates.dart';
import 'package:open_pdf/utils/extensions/spacer_extension.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Open PDF"),
        actions: [
          const PopupMenuButtonWidget(),
          Consumer<PdfProvider>(
            builder: (context, provider, child) {
              return Visibility(
                visible: provider.isMultiSelected,
                child: IconButton(
                  onPressed: () {
                    provider.clearSelectedFiles();
                    log("selected files ${provider.selectedFiles.length}");
                  },
                  icon: const Icon(Icons.delete),
                ),
              );
            },
          ),
        ],
        elevation: 5.0,
      ),
      body: Consumer<PdfProvider>(
        builder: (context, provider, _) {
          final List<PdfModel> pdfList = _getFilteredAndSortedPdfList(
              provider.totalPdfList.values.toList());
          return pdfList.isEmpty
              ? const NoPdfListWidget()
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const ViewModeButtonsRow(),
                      10.vSpace,
                      Expanded(
                        child: provider.selectedViewMode == ViewMode.list
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
  }

  List<PdfModel> _getFilteredAndSortedPdfList(List<PdfModel> totalPdfList) {
    final List<PdfModel> pdfList = totalPdfList
        .where((pdf) =>
            pdf.downloadStatus != DownloadStatus.cancelled.name &&
            pdf.downloadStatus != DownloadStatus.ongoing.name &&
            pdf.lastOpened != null)
        .toList();

    pdfList.sort(
        (a, b) => b.lastOpened?.compareTo(a.lastOpened ?? DateTime(0)) ?? 0);
    return pdfList;
  }
}
