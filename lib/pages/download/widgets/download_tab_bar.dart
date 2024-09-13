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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        context
            .read<PdfProvider>()
            .setDownloadStatus(DownloadStatus.values[_tabController.index]);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                offset: Offset(0, 3),
                blurRadius: 1,
                spreadRadius: 1,
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Ongoing'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
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
  }
}
