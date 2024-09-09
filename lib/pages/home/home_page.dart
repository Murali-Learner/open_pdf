import 'package:flutter/material.dart';
import 'package:open_pdf/pages/download/download_page.dart';
import 'package:open_pdf/pages/home/widgets/floating_dial_widget.dart';
import 'package:open_pdf/pages/home/widgets/home_pdf_grid.dart';
import 'package:open_pdf/pages/home/widgets/home_pdf_list.dart';
import 'package:open_pdf/pages/home/widgets/pop_up_menu_button.dart';
import 'package:open_pdf/pages/home/widgets/view_mode_buttons_row.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Open PDF"),
        actions: const [PopupMenuButtonWidget()],
        elevation: 5.0,
      ),
      body: Consumer<PdfProvider>(
        builder: (context, provider, _) {
          return provider.totalPdfList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await provider.pickFile();
                        },
                        child: const Text("File"),
                      ),
                      10.vSpace,
                      ElevatedButton(
                        onPressed: () {
                          context.push(navigateTo: const DownloadPage());
                        },
                        child: const Text("Download"),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const ViewModeButtonsRow(),
                      10.vSpace,
                      Expanded(
                        child: provider.selectedViewMode == ViewMode.list
                            ? HomePdfListView(
                                pdfLists: provider.totalPdfList.values.toList(),
                              )
                            : HomePdfGridView(
                                pdfLists: provider.totalPdfList.values.toList(),
                              ),
                      ),
                    ],
                  ),
                );
        },
      ),
      floatingActionButton: FloatingDial(),
    );
  }
}
