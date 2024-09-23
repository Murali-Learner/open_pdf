import 'package:flutter/material.dart';
import 'package:open_pdf/pages/download/widgets/download_list_view.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/utils/enumerates.dart';
import 'package:provider/provider.dart';

class DownloadTabBar extends StatefulWidget {
  const DownloadTabBar({super.key});

  @override
  DownloadTabBarState createState() => DownloadTabBarState();
}

class DownloadTabBarState extends State<DownloadTabBar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PdfProvider provider;
  @override
  void initState() {
    super.initState();
    provider = context.read<PdfProvider>();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.animateTo(1);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        provider.setCurrentTabIndex(_tabController.index);
        _tabController.animateTo(provider.currentTabIndex);
      }
    });
  }

  void switchToOngoingTab() {
    _tabController.animateTo(0);
    provider.setCurrentTabIndex(0);
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
            elevation: 4.0,
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
                    child: Text("Cancelled"),
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
                  status: DownloadStatus.ongoing,
                ),
                DownloadListView(
                  status: DownloadStatus.completed,
                ),
                DownloadListView(
                  status: DownloadStatus.cancelled,
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
