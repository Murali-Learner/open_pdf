import 'package:flutter/material.dart';
import 'package:open_pdf/utils/constants.dart';

class PdfOptionItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const PdfOptionItem({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: ColorConstants.whiteColor,
      ),
      title: Text(
        text,
        style: TextStyle(
          fontSize: 14,
        ),
      ),
      onTap: onTap,
    );
  }
}
