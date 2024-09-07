import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:open_pdf/pages/dictionary/widgets/search_list_builder.dart';
import 'package:open_pdf/providers/dictionary_provider.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:provider/provider.dart';

class DictionaryPage extends StatefulWidget {
  const DictionaryPage({super.key});

  @override
  DictionaryPageState createState() => DictionaryPageState();
}

class DictionaryPageState extends State<DictionaryPage> {
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    final provider = context.read<DictionaryProvider>();
    Future.delayed(Duration.zero).whenComplete(() {
      provider.fetchAllWords();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<DictionaryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dictionary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                provider.toggleClearButton(value.isNotEmpty ? true : false);
                if (value.isEmpty) {
                  provider.fetchAllWords();
                  return;
                }

                provider.searchWord(value.trim());
              },
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Enter word to search',
                border: const OutlineInputBorder(),
                suffixIcon: Consumer<DictionaryProvider>(
                    builder: (context, provider, _) {
                  log("provider.showClearButton: ${provider.showClearButton}");
                  return provider.showClearButton
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            provider.fetchAllWords();
                            provider.toggleClearButton(false);

                            context.hideKeyBoard();
                          },
                        )
                      : const SizedBox.shrink();
                }),
              ),
              onSubmitted: (value) {
                provider.searchWord(value.trim());
              },
            ),
            const SizedBox(height: 16),
            const SearchListBuilder(),
          ],
        ),
      ),
    );
  }
}
