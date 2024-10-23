import 'package:flutter/material.dart';
import 'package:open_pdf/utils/constants.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:open_pdf/utils/extensions/spacer_extension.dart';

Future<void> showGlobalBottomSheet({
  required BuildContext context,
  required Widget child,
  bool isScrollControlled = true,
  bool useSafeArea = true,
  bool showDragHandle = true,
  BoxConstraints? constraints,
}) async {
  return showModalBottomSheet(
    showDragHandle: showDragHandle,
    context: context,
    constraints: constraints,
    backgroundColor: context.theme.scaffoldBackgroundColor,
    barrierColor: ColorConstants.color.withOpacity(0.5),
    isScrollControlled: isScrollControlled,
    useSafeArea: useSafeArea,
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.width(2),
          vertical: context.height(2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            child,
            5.vSpace,
            GestureDetector(
              onTap: () {
                context.pop();
              },
              child: Text(
                "Done",
                style: TextStyle(
                  color: ColorConstants.amberColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
