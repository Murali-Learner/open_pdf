import 'package:flutter/material.dart';

class PopupMenuButtonWidget extends StatelessWidget {
  const PopupMenuButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      padding: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      onSelected: (value) {
        switch (value) {
          case 1:
            debugPrint("Option 1 selected");
            break;
          case 2:
            debugPrint("Option 2 selected");
            break;
          case 3:
            debugPrint("Option 3 selected");
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 1,
          child: Text("Downloads"),
        ),
        const PopupMenuItem(
          value: 2,
          child: Text("Favorites"),
        ),
        const PopupMenuItem(
          value: 3,
          child: Text("Settings"),
        ),
      ],
      icon: const Icon(Icons.more_vert),
    );
  }
}
