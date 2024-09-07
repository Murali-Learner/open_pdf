import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:open_pdf/global_widgets/global_loading_widget.dart';
import 'package:open_pdf/pages/download/widgets/download_button.dart';
import 'package:open_pdf/pages/home/widgets/home_pdf_list.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/utils/extensions/spacer_extension.dart';
import 'package:provider/provider.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  DownloadPageState createState() => DownloadPageState();
}

class DownloadPageState extends State<DownloadPage> {
  final TextEditingController _searchController = TextEditingController();
  late final PdfProvider provider;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    provider = context.read<PdfProvider>();
    // await provider.askPermissions();
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
      appBar: AppBar(
        title: const Text('Downloads'),
      ),
      body: Consumer<PdfProvider>(
        builder: (context, provider, _) {
          log("internet ${provider.isInternetConnected}");
          return provider.isLoading
              ? const GlobalLoadingWidget()
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(
                        value: provider.downloadProgress,
                        minHeight: 50,
                      ),
                      20.vSpace,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _searchController,
                              validator: (value) {
                                if (value != null && value.isEmpty) {
                                  return 'Please provide a link';
                                } else {
                                  return null;
                                }
                              },
                              onFieldSubmitted: (value) {},
                              onChanged: (value) {},
                              decoration: InputDecoration(
                                errorBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                labelText: 'Provide link to dowload',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          DownloadButton(
                            pdfUrl: _searchController.text.trim(),
                          ),
                        ],
                      ),
                      10.vSpace,
                      HomePdfListView(
                          // pdfLists: provider.totalPdfs.values.toList().where((e) {
                          //   return e.networkUrl != null;
                          // }).toList(),
                          )
                    ],
                  ),
                );
        },
      ),
    );
  }
}
