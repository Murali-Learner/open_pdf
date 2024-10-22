import 'package:flutter/material.dart';
import 'package:open_pdf/global_widgets/global_text_form_fields.dart';
import 'package:open_pdf/providers/dictionary_provider.dart';
import 'package:open_pdf/utils/constants.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:provider/provider.dart';

class DictionSearchField extends StatefulWidget {
  const DictionSearchField({
    super.key,
    this.searchWord,
  });
  final String? searchWord;

  @override
  State<DictionSearchField> createState() => _DictionSearchFieldState();
}

class _DictionSearchFieldState extends State<DictionSearchField> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    _searchController = TextEditingController(text: widget.searchWord);
    setState(() {
      _searchController.text = widget.searchWord ?? '';
    });
    debugPrint(" _searchController.text  ${_searchController.text}");
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DictionaryProvider>();

    return GlobalTextFormField(
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
      border: context.theme.brightness == Brightness.dark
          ? OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.white))
          : null,
      suffixIcon: Consumer<DictionaryProvider>(builder: (context, provider, _) {
        return provider.showClearButton
            ? IconButton(
                icon: Icon(
                  Icons.clear,
                  color: ColorConstants.amberColor,
                ),
                onPressed: () {
                  _searchController.clear();
                  provider.fetchAllWords();
                  provider.toggleClearButton(false);
                  context.hideKeyBoard();
                },
              )
            : const SizedBox.shrink();
      }),
    );
  }
}
