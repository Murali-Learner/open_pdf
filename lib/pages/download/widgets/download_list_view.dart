import 'package:flutter/material.dart';
import 'package:open_pdf/pages/home/widgets/list_card.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/utils/enumerates.dart';
import 'package:provider/provider.dart';

class DownloadListView extends StatefulWidget {
  const DownloadListView({
    required this.status,
    super.key,
  });
  final DownloadStatus status;

  @override
  DownloadListViewState createState() => DownloadListViewState();
}

class DownloadListViewState extends State<DownloadListView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<PdfProvider>(
      builder: (context, provider, _) {
        final filteredPdfList = provider.totalPdfList.values
            .where((pdf) =>
                pdf.downloadStatus == widget.status.name &&
                pdf.networkUrl != null &&
                pdf.networkUrl!.isNotEmpty)
            .toList();

        if (filteredPdfList.isEmpty) {
          return Center(
            child: Text("No ${widget.status.name} downloads."),
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
            return ListPdfCard(
              pdf: filteredPdfList[index],
              index: index,
            );
          },
        );
      },
    );
  }
}

class DownloadStatusWidget extends StatelessWidget {
  const DownloadStatusWidget({
    super.key,
    required this.groupValue,
    required this.value,
    required this.title,
  });
  final DownloadStatus groupValue;
  final DownloadStatus value;
  final String title;
  @override
  Widget build(BuildContext context) {
    return RadioListTile<DownloadStatus>(
      title: Text(title),
      value: value,
      groupValue: groupValue,
      onChanged: (DownloadStatus? value) {
        context.read<PdfProvider>().setDownloadStatus(value!);
      },
    );
  }
}
