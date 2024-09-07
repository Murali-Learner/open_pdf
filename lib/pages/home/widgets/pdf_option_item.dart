import 'package:flutter/material.dart';

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
      leading: Icon(icon),
      title: Text(text),
      onTap: onTap,
    );
  }
}
