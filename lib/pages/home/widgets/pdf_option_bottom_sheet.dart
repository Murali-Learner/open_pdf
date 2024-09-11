import 'package:flutter/material.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/pages/home/widgets/pdf_option_item.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:provider/provider.dart';

class PdfOptionsBottomSheet extends StatelessWidget {
  final PdfModel pdf;

  const PdfOptionsBottomSheet({
    super.key,
    required this.pdf,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        PdfOptionItem(
          icon: Icons.favorite,
          text: "${pdf.isFav ? "Remove from" : "Add to"} Favorites",
          onTap: () => _handleAddToFavorites(context),
        ),
        PdfOptionItem(
          icon: Icons.share,
          text: "Share",
          onTap: () => _handleSharePdf(context, pdf),
        ),
        PdfOptionItem(
          icon: Icons.delete,
          text: "Delete",
          onTap: () => _handleDelete(context, pdf),
        ),
      ],
    );
  }

  void _handleAddToFavorites(BuildContext context) {
    context.read<PdfProvider>().toggleFavorite(pdf);
    context.pop();
  }

  void _handleSharePdf(BuildContext context, PdfModel pdf) {
    context.pop();
    sharePdf(pdf);
  }

  void _handleDelete(BuildContext context, PdfModel pdf) {
    context.pop();
    context.read<PdfProvider>().removeFromTotalPdfList(pdf);
  }

  void sharePdf(PdfModel pdf) {
    // TODO: share pdf
    debugPrint("Sharing ${pdf.fileName}");
  }
}
