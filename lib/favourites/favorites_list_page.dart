import 'package:flutter/material.dart';
import 'package:open_pdf/pages/home/widgets/list_pdf_card.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:provider/provider.dart';

class FavoritesListPage extends StatelessWidget {
  const FavoritesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        // backgroundColor: context.theme.scaffoldBackgroundColor,
        // surfaceTintColor: context.theme.scaffoldBackgroundColor,
        // shadowColor:
        //     context.theme.appBarTheme.iconTheme!.color!.withOpacity(0.5),
        elevation: 5,
      ),
      body: Consumer<PdfProvider>(
        builder: (context, provider, _) {
          if (provider.favoritesList.isEmpty) {
            return const Center(child: Text('No favorites added'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 15,
            ),
            itemCount: provider.favoritesList.keys.length,
            itemBuilder: (context, index) {
              final favMap = provider
                  .favoritesList[provider.favoritesList.keys.elementAt(index)];
              return ListPdfCard(
                index: index,
                pdf: favMap!,
              );
            },
          );
        },
      ),
    );
  }
}
