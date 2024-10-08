import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_pdf/global_widgets/global_loading_widget.dart';
import 'package:open_pdf/pages/download/widgets/download_pdf_row.dart';
import 'package:open_pdf/pages/download/widgets/download_tab_bar.dart';
import 'package:open_pdf/pages/download/widgets/no_internet_widget.dart';
import 'package:open_pdf/providers/download_provider.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/utils/extensions/spacer_extension.dart';
import 'package:provider/provider.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  DownloadPageState createState() => DownloadPageState();
}

class DownloadPageState extends State<DownloadPage> {
  late final PdfProvider provider;
  late final DownloadProvider downloadProvider;

  @override
  void initState() {
    super.initState();
    provider = context.read<PdfProvider>();
    downloadProvider = context.read<DownloadProvider>();
    provider.internetSubscription();
  }

  @override
  void dispose() {
    provider.internetDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PdfProvider>();
    final downloadProvider = context.watch<DownloadProvider>();
    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Downloads'),
        elevation: 2.0,
        scrolledUnderElevation: 5.0,
        actions: [
          if (kDebugMode)
            IconButton(
              onPressed: () async {
                await provider.clearData();
                await downloadProvider.clearData();
              },
              icon: const Icon(Icons.delete),
            ),
        ],
      ),
      body: provider.isLoading
          ? const GlobalLoadingWidget()
          : !provider.isInternetConnected
              ? const NoInternetScreen()
              : Column(
                  children: [
                    const DownloadPdfRow(),
                    10.vSpace,
                    const Expanded(child: DownloadTabBar()),
                  ],
                ),
    );
  }
}
