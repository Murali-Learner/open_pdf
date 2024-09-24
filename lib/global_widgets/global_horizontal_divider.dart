import 'package:flutter/material.dart';

class GlobalHorizontalDivider extends StatelessWidget {
  final double thickness;
  final double indent;
  final double endIndent;

  const GlobalHorizontalDivider({
    super.key,
    this.thickness = 1.0,
    this.indent = 0.0,
    this.endIndent = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      thickness: thickness,
      indent: indent,
      endIndent: endIndent,
    );
  }
}
