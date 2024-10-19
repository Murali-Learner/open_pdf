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

// const pdfBase64 = 'JVBERi0xLjQKJfbk/N8KMSAwIG9iago8PAovVHlwZSAvQ2F0YWxvZwovVmVyc2lvbiAvMS40Ci9QYWdlcyAyIDAgUgovVmlld2VyUHJlZmVyZW5jZXMgMyAwIFIKL0xhbmcgKGVuLUlOKQo+PgplbmRvYmoKNCAwIG9iago8PAovS2V5d29yZHMgKERBRk03OVh1OGc4LEJBRC1nUVNsUXlBKQovQXV0aG9yIChzYWkgbXVyYWxpKQovQ3JlYXRvciAoQ2FudmEpCi9Qcm9kdWNlciAoQ2FudmEpCi9UaXRsZSAoZGFuaSBTY2h3YWlnZXIpCi9DcmVhdGlvbkRhdGUgKEQ6MjAyMjA5MjIwNzMwMDArMDAnMDAnKQo+PgplbmRvYmoKMiAwIG9iago8PAovVHlwZSAvUGFnZXMKL0tpZHMgWzUgMCBSIDYgMCBSXQovQ291bnQgMgo+PgplbmRvYmoKMyAwIG9iago8PAovRGlzcGxheURvY1RpdGxlIHRydWUKPj4KZW5kb2JqCjUgMCBvYmoKPDwKL1R5cGUgL1BhZ2UKL1Jlc291cmNlcyA3IDAgUgovTWVkaWFCb3ggWzAuMCA2LjYzMDAzIDU5NC45NTk5NiA4NDguODhdCi9Db250ZW50cyA4IDAgUgovU3RydWN0UGFyZW50cyAwCi9QYXJlbnQgMiAwIFIKL1RhYnMgL1MKL0JsZWVkQm94IFswLjAgNi42MzAwMyA1OTQuOTU5OTYgODQ4Ljg4XQovVHJpbUJveCBbMC4wIDYuNjMwMDMgNTk0Ljk1OTk2IDg0OC44OF0KL0Nyb3BCb3ggWzAuMCA2LjYzMDAzIDU5NC45NTk5NiA4NDguODhdCi9Sb3RhdGUgMAovQW5ub3RzIFtdCj4+CmVuZG9iago2IDAgb2JqCjw8Ci9UeXBlIC9QYWdlCi9SZXNvdXJjZXMgOSAwIFIKL01lZGlhQm94IFswLjAgNi42MzAwMyA1OTQuOTU5OTYgODQ4Ljg4XQovQ29udGVudHMgMTAgMCBSCi9TdHJ1Y3RQYXJlbnRzIDEKL1BhcmVudCAyIDAgUgovVGFicyAvUwovQmxlZWRCb3ggWzAuMCA2LjYzMDAzIDU5NC45NTk5NiA4NDguODhdCi9UcmltQm94IFswLjAgNi42MzAwMyA1OTQuOTU5OTYgODQ4Ljg4XQovQ3JvcEJveCBbMC4wIDYuNjMwMDMgNTk0Ljk1OTk2IDg0OC44OF0KL1JvdGF0ZSAwCi9Bbm5vdHMgW10KPj4KZW5kb2JqCjcgMCBvYmoKPDwKL1Byb2NTZXQgWy9QREYgL1RleHQgL0ltYWdlQiAvSW1hZ2VDIC9JbWFnZUldCi9FeHRHU3RhdGUgMTEgMCBSCi9YT2JqZWN0IDw8Ci9YOSAxMiAwIFIKPj4KL0ZvbnQgMTMgMCBSCj4+CmVuZG9iago4IDAgb2JqCjw8Ci9MZW5ndGggMTA2MzcKL0ZpbHRlciAvRmxhdGVEZWNvZGUKPj4Kc3RyZWFtDQp4nO1d264st3F9n6+YZwNq8X4BBAO62EEeDCSxAOd9J3YQ7OMgzv8DWYtkN4vTzbOnx6MjRRkZlmZXd/NSl1VFsrp6MTaXf64K
