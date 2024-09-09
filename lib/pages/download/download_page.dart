import 'package:flutter/material.dart';
import 'package:open_pdf/global_widgets/global_loading_widget.dart';
import 'package:open_pdf/pages/download/widgets/download_pdf_row.dart';
import 'package:open_pdf/pages/download/widgets/download_tab_bar.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:provider/provider.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  DownloadPageState createState() => DownloadPageState();
}

class DownloadPageState extends State<DownloadPage> {
  late final PdfProvider provider;

  @override
  void initState() {
    super.initState();
    provider = context.read<PdfProvider>();
  }

  @override
  void dispose() {
    provider.internetDispose();
    provider.internetSubscription();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Downloads'),
      ),
      body: context.watch<PdfProvider>().isLoading
          ? const GlobalLoadingWidget()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  DownloadPdfRow(),
                  Expanded(child: DownloadTabBar()),
                ],
              ),
            ),
    );
  }
}
