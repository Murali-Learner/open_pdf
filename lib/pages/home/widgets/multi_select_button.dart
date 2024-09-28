import 'package:flutter/material.dart';
import 'package:open_pdf/pages/home/widgets/view_mode_buttons_row.dart';
import 'package:open_pdf/providers/download_provider.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/utils/constants.dart';
import 'package:provider/provider.dart';

class MultiSelectionDeleteButton extends StatelessWidget {
  const MultiSelectionDeleteButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PdfProvider>();
    return Tooltip(
      message: "Delete Selection",
      child: GestureDetector(
        onTap: () {
          showDeleteConfirmationDialog(context, () async {
            final downloadProvider = context.read<DownloadProvider>();
            await downloadProvider.deleteSelectedFiles(provider.selectedFiles);

            provider.deleteSelectedFiles();
          });
        },
        child: Icon(
          Icons.delete,
          size: 30,
          color: ColorConstants.amberColor,
        ),
      ),
    );
  }
}
