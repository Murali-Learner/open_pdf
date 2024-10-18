import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:open_pdf/pages/download/widgets/download_list_view.dart';

class TabBarViewWidget extends StatelessWidget {
  const TabBarViewWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Expanded(
      child: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        children: [
          DownloadListView(
            statuses: [
              DownloadTaskStatus.running,
              DownloadTaskStatus.paused,
              DownloadTaskStatus.undefined,
              DownloadTaskStatus.enqueued,
            ],
          ),
          DownloadListView(
            statuses: [DownloadTaskStatus.complete],
          ),
          DownloadListView(
            statuses: [
              DownloadTaskStatus.canceled,
              DownloadTaskStatus.failed,
            ],
          ),
        ],
      ),
    );
  }
}
