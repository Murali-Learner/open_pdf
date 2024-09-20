import 'package:flutter/material.dart';
import 'package:open_pdf/global_widgets/global_text_form_fields.dart';
import 'package:open_pdf/pages/dictionary/widgets/search_list_builder.dart';
import 'package:open_pdf/providers/dictionary_provider.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:open_pdf/utils/extensions/spacer_extension.dart';
import 'package:provider/provider.dart';

class DictionaryPage extends StatefulWidget {
  final bool showAppbar;
  const DictionaryPage({
    super.key,
    this.showAppbar = true,
  });

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
      appBar: widget.showAppbar
          ? AppBar(
              title: const Text('Dictionary'),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            10.vSpace,
            GlobalTextFormField(
              controller: _searchController,
              labelText: 'Enter word to search',
              onFieldSubmitted: (value) {
                provider.searchWord(value.trim());
              },
              onChanged: (value) {
                provider.toggleClearButton(value.isNotEmpty);
                if (value.isEmpty) {
                  provider.fetchAllWords();
                } else {
                  provider.searchWord(value.trim());
                }
              },
              suffixIcon:
                  Consumer<DictionaryProvider>(builder: (context, provider, _) {
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
            const SizedBox(height: 16),
            const SearchListBuilder(),
          ],
        ),
      ),
    );
  }
}
