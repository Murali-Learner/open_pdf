import 'package:flutter/material.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/utils/enumerates.dart';
import 'package:provider/provider.dart';

Color? _getColor(bool isSelected) {
  return isSelected ? Colors.green : null;
}

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
          color: _getColor(provider.viewMode == viewMode),
        ),
        child: Icon(icon),
      ),
    );
  }
}
