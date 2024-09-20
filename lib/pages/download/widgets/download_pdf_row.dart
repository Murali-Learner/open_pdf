import 'package:flutter/material.dart';
import 'package:open_pdf/global_widgets/global_text_form_fields.dart';
import 'package:open_pdf/pages/download/widgets/download_button.dart';

class DownloadPdfRow extends StatefulWidget {
  const DownloadPdfRow({Key? key}) : super(key: key);

  @override
  _DownloadPdfRowState createState() => _DownloadPdfRowState();
}

class _DownloadPdfRowState extends State<DownloadPdfRow> {
  final TextEditingController _searchController = TextEditingController();
  String _pdfUrl = '';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _pdfUrl = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: GlobalTextFormField(
              controller: _searchController,
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
            ),
          ),
          DownloadButton(
            pdfUrl: _pdfUrl,
          ),
        ],
      ),
    );
  }
}
