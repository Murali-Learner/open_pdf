import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:open_pdf/pages/download/widgets/tab_bar_view_widget.dart';
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
  late PdfProvider pdfProvider;
  late DownloadProvider downloadProvider;
  @override
  void initState() {
    super.initState();
    pdfProvider = context.read<PdfProvider>();
    downloadProvider = context.read<DownloadProvider>();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        switchToOngoingTab();
      },
    );
  }

  void switchToOngoingTab() {
    final onGoingDownloads =
        downloadProvider.getSpecificStatusDownloads(DownloadTaskStatus.running);

    if (onGoingDownloads.isEmpty) {
      downloadProvider.setTabIndex(1);
    } else {
      downloadProvider.setTabIndex(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DownloadProvider>(builder: (context, downloadProvider, _) {
      return DefaultTabController(
        animationDuration: const Duration(milliseconds: 100),
        length: 3,
        key: GlobalKey(debugLabel: "TabBarKey"),
        initialIndex: downloadProvider.currentIndex,
        child: Column(
          children: [
            Material(
              elevation: Constants.globalElevation,
              color: ColorConstants.color,
              child: Padding(
                padding: const EdgeInsets.only(top: 0),
                child: TabBar(
                  onTap: (value) {
                    downloadProvider.setTabIndex(value);
                  },
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
            const TabBarViewWidget(),
          ],
        ),
      );
    });
  }
}
