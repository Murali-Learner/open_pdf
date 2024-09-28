import 'package:flutter/material.dart';
import 'package:open_pdf/providers/pdf_control_provider.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
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
  final Axis scrollMode;
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PdfControlProvider>();
    return GestureDetector(
      onTap: () {
        provider.setScrollMode(
            scrollMode == Axis.horizontal ? Axis.vertical : Axis.horizontal);
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: provider.pdfScrollMode == scrollMode ? Colors.amber : null,
        ),
        child: Icon(
          icon,
          color: provider.pdfScrollMode == scrollMode
              ? context.theme.primaryColor
              : null,
        ),
      ),
    );
  }
}
