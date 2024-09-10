import 'package:flutter/material.dart';
import 'package:open_pdf/global_widgets/global_text_form_fields.dart';
import 'package:open_pdf/pages/download/widgets/download_button.dart';

class DownloadPdfRow extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();

  DownloadPdfRow({
    super.key,
  });

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
              onFieldSubmitted: (value) {},
            ),
          ),
          DownloadButton(
            pdfUrl: _searchController.text.trim(),
          ),
        ],
      ),
    );
  }
}
