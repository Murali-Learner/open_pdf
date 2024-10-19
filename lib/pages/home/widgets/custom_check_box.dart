import 'package:flutter/material.dart';
import 'package:open_pdf/utils/extensions/naming_extension.dart';

class CustomCheckbox extends StatelessWidget {
  final bool isSelected;
  final ValueChanged<bool?> onChanged;
  final String label;

  const CustomCheckbox({
    super.key,
    required this.isSelected,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: isSelected,
          onChanged: onChanged,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Text(label.toPascalCase()),
      ],
    );
  }
}
