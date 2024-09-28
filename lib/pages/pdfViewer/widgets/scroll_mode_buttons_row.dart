import 'package:flutter/material.dart';
import 'package:open_pdf/pages/pdfViewer/widgets/scroll_mode_button.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:open_pdf/utils/extensions/spacer_extension.dart';

class ScrollModeButtonsRow extends StatelessWidget {
  const ScrollModeButtonsRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // const Spacer(),
        Container(
          decoration: BoxDecoration(
            color: context.theme.primaryColor.withOpacity(0.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const ScrollModeButton(
                icon: Icons.swap_horiz,
                scrollMode: Axis.vertical,
              ),
              10.hSpace,
              const ScrollModeButton(
                icon: Icons.swap_vert,
                scrollMode: Axis.horizontal,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
