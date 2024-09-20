import 'package:flutter/material.dart';

class NotificationPermissionDialog extends StatelessWidget {
  const NotificationPermissionDialog(
      {super.key, required this.onAllow, required this.onDeny});

  final VoidCallback onAllow;
  final VoidCallback onDeny;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Enable Notifications",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 15),
        Text(
          "We'd like to send you notifications for downloads.",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: onDeny,
              child: const Text(
                "Deny",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
            TextButton(
              onPressed: onAllow,
              child: const Text(
                "Allow",
                style: TextStyle(
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
