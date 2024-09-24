import 'package:flutter/material.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/utils/enumerates.dart';
import 'package:provider/provider.dart';

class ViewModeButton extends StatelessWidget {
  const ViewModeButton({
    super.key,
    required this.icon,
    required this.viewMode,
  });
  final IconData icon;
  final ViewMode viewMode;
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PdfProvider>();
    return GestureDetector(
      onTap: () {
        provider.setViewMode(viewMode);
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: provider.viewMode == viewMode ? Colors.amber : null,
        ),
        child: Icon(
          icon,
          color: provider.viewMode == viewMode ? null : Colors.amber,
        ),
      ),
    );
  }
}
