import 'package:flutter/material.dart';
import 'package:open_pdf/providers/pdf_control_provider.dart';
import 'package:open_pdf/utils/enumerates.dart';
import 'package:provider/provider.dart';

Color? _getColor(bool isSelected) {
  return isSelected ? Colors.green : null;
}

class ScrollModeButton extends StatelessWidget {
  const ScrollModeButton({
    super.key,
    required this.icon,
    required this.scrollMode,
  });
  final IconData icon;
  final PdfScrollMode scrollMode;
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PdfControlProvider>();
    return GestureDetector(
      onTap: () {
        provider.setScrollMode(scrollMode);
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: _getColor(provider.pdfScrollMode == scrollMode),
        ),
        child: Icon(icon),
      ),
    );
  }
}
