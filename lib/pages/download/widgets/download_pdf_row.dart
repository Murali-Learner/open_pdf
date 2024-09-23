import 'package:flutter/material.dart';
import 'package:open_pdf/global_widgets/global_text_form_fields.dart';
import 'package:open_pdf/pages/download/widgets/download_button.dart';
import 'package:open_pdf/providers/theme_provider.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:provider/provider.dart';

class DownloadPdfRow extends StatefulWidget {
  const DownloadPdfRow({super.key});

  @override
  DownloadPdfRowState createState() => DownloadPdfRowState();
}

class DownloadPdfRowState extends State<DownloadPdfRow> {
  final TextEditingController searchController = TextEditingController();
  String _pdfUrl = '';

  @override
  void initState() {
    super.initState();

    searchController.addListener(() {
      setState(() {
        _pdfUrl = searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.white,
      padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Consumer<ThemeProvider>(
            builder: (context, provider, _) {
              return Expanded(
                child: GlobalTextFormField(
                  controller: searchController,
                  labelText: 'Provide link to download',
                  validator: (value) {
                    if (value != null && value.isEmpty) {
                      return 'Please provide a link';
                    } else {
                      return null;
                    }
                  },
                  onChanged: (val) {},
                  onFieldSubmitted: (value) {},
                  border: context.theme.brightness == Brightness.dark
                      ? OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white))
                      : null,
                ),
              );
            },
          ),
          DownloadButton(
            pdfUrl: _pdfUrl,
          ),
        ],
      ),
    );
  }
}
