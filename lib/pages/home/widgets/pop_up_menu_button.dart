import 'package:flutter/material.dart';
import 'package:open_pdf/favourites/favorites_list_page.dart';
import 'package:open_pdf/pages/download/downloads_page.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:provider/provider.dart';

class PopupMenuButtonWidget extends StatelessWidget {
  const PopupMenuButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final pdfProvider = context.read<PdfProvider>();
    return PopupMenuButton<int>(
      padding: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      onSelected: (value) {
        switch (value) {
          case 1:
            debugPrint("Downloads selected");
            pdfProvider.clearSelectedFiles();
            context.push(navigateTo: const DownloadPage());
            break;
          case 2:
            pdfProvider.clearSelectedFiles();
            context.push(navigateTo: const FavoritesListPage());
            break;
          // case 3:
          //   pdfProvider.clearSelectedFiles();
          //   context.push(navigateTo: const SettingsPage());

          //   break;
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
        // const PopupMenuItem(
        //   value: 3,
        //   child: Text("Settings"),
        // ),
      ],
      icon: const Icon(Icons.more_vert),
    );
  }
}
