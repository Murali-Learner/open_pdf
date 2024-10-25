import 'package:flutter/foundation.dart';
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
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: context.theme.primaryColor.withOpacity(0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
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

Future<void> showDeleteConfirmationDialog(
    BuildContext context, AsyncCallback onConfirmDelete,
    {String content =
        'Are you sure you want to delete selected items?'}) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete Confirmation'),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              context.pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await onConfirmDelete();
              context.pop();
            },
            child: const Text(
              'Delete',
              style:
                  TextStyle(color: Colors.red), // Red color for delete action
            ),
          ),
        ],
      );
    },
  );
}
