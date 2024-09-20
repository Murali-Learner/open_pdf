import 'package:flutter/material.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/pages/home/widgets/pdf_option_item.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:open_pdf/utils/toast_utils.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class PdfOptionsBottomSheet extends StatelessWidget {
  final PdfModel pdf;

  const PdfOptionsBottomSheet({
    super.key,
    required this.pdf,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PdfProvider>();
    return Wrap(
      children: [
        PdfOptionItem(
          icon: Icons.favorite,
          text: "${pdf.isFav ? "Remove from" : "Add to"} Favorites",
          onTap: () async => await _handleAddToFavorites(context),
        ),
        PdfOptionItem(
          icon: Icons.share,
          text: "Share",
          onTap: () => _handleSharePdf(context, pdf),
        ),
        PdfOptionItem(
          icon: Icons.delete,
          text: "Delete",
          onTap: () async {
            await provider.removeFromTotalPdfList(pdf);
            context.pop();
          },
        ),
      ],
    );
  }

  Future<void> _handleAddToFavorites(BuildContext context) async {
    await context.read<PdfProvider>().toggleFavorite(pdf);
    context.pop();
  }

  void _handleSharePdf(BuildContext context, PdfModel pdf) {
    sharePdf(pdf);
    context.pop();
  }

  void sharePdf(PdfModel pdf) async {
    try {
      await Share.shareXFiles([XFile(pdf.filePath!)],
          text: 'Check out this PDF file!',
          subject: "Check out this pdf file!");
      debugPrint("Sharing ${pdf.fileName}");
    } catch (e) {
      debugPrint("Error while sharing file $e");
      ToastUtils.showErrorToast("Error while sharing");
    }
  }
}
