import 'package:flutter/material.dart';
import 'package:open_pdf/pages/home/widgets/view_mode_button.dart';
import 'package:open_pdf/utils/enumerates.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:open_pdf/utils/extensions/spacer_extension.dart';

class ViewModeButtonsRow extends StatelessWidget {
  const ViewModeButtonsRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            color: context.theme.primaryColor.withOpacity(0.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const ViewModeButton(
                icon: Icons.window,
                viewMode: ViewMode.grid,
              ),
              10.hSpace,
              const ViewModeButton(
                icon: Icons.list,
                viewMode: ViewMode.list,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
