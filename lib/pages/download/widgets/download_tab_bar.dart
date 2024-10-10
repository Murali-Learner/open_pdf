import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:open_pdf/pages/download/widgets/download_list_view.dart';
import 'package:open_pdf/providers/download_provider.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/utils/constants.dart';
import 'package:provider/provider.dart';

class DownloadTabBar extends StatefulWidget {
  const DownloadTabBar({super.key});

  @override
  DownloadTabBarState createState() => DownloadTabBarState();
}

class DownloadTabBarState extends State<DownloadTabBar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PdfProvider pdfProvider;
  late DownloadProvider downloadProvider;
  @override
  void initState() {
    super.initState();
    pdfProvider = context.read<PdfProvider>();
    downloadProvider = context.read<DownloadProvider>();
    _tabController = TabController(length: 3, vsync: this);

    switchToOngoingTab();
  }

  void switchToOngoingTab() {
    final onGoingDownloads =
        downloadProvider.getSpecificStatusDownloads(DownloadTaskStatus.running);
    // _tabController.addListener(
    //   () {},
    // );
    if (onGoingDownloads.isEmpty) {
      _tabController.animateTo(1);
    } else {
      _tabController.animateTo(0);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PdfProvider>(builder: (context, provider, _) {
      return Column(
        children: [
          Material(
            elevation: Constants.globalElevation,
            color: ColorConstants.color,
            child: Padding(
              padding: const EdgeInsets.only(top: 0),
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(
                    child: Text("Ongoing"),
                  ),
                  Tab(
                    child: Text("Completed"),
                  ),
                  Tab(
                    child: Text("Canceled"),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: const [
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
          ),
        ],
      );
    });
  }
}
