import 'package:flutter/material.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/pages/home/widgets/pdf_option_item.dart';

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
          text: "Add to Favorites",
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
          onTap: () => _handleDelete(context),
        ),
      ],
    );
  }

  void _handleAddToFavorites(BuildContext context) {
    Navigator.pop(context);
    // TODO: Add logic to add to favorites
  }

  void _handleSharePdf(BuildContext context, PdfModel pdf) {
    Navigator.pop(context);
    sharePdf(pdf);
  }

  void _handleDelete(BuildContext context) {
    Navigator.pop(context);
    // TODO: Add delete logic here
  }

  void sharePdf(PdfModel pdf) {
    debugPrint("Sharing ${pdf.fileName}");
  }
}
