import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:open_pdf/pages/download/widgets/download_pdf_card.dart';
import 'package:open_pdf/providers/download_provider.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:provider/provider.dart';

class DownloadListView extends StatefulWidget {
  const DownloadListView({
    required this.statuses,
    super.key,
  });
  final List<DownloadTaskStatus> statuses;

  @override
  DownloadListViewState createState() => DownloadListViewState();
}

class DownloadListViewState extends State<DownloadListView> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<DownloadProvider, PdfProvider>(
      builder: (context, downloadProvider, pdfProvider, _) {
        final filteredPdfList =
            downloadProvider.getFilteredListByStatus(widget.statuses);

        if (filteredPdfList.isEmpty) {
          return Center(
            child: Text("No ${widget.statuses.first.name} downloads."),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          itemCount: filteredPdfList.length,
          separatorBuilder: (BuildContext context, int index) {
            return const SizedBox(height: 10);
          },
          itemBuilder: (BuildContext context, int index) {
            debugPrint(
                "filteredPdfList ${filteredPdfList[index].downloadStatus}");

            return DownloadPdfCard(
              pdf: filteredPdfList[index],
              index: index,
            );
          },
        );
      },
    );
  }
}
