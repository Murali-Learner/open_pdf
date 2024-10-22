import 'package:flutter/material.dart';
import 'package:open_pdf/pages/dictionary/widgets/dictionary_search_field.dart';
import 'package:open_pdf/pages/dictionary/widgets/search_list_builder.dart';
import 'package:open_pdf/utils/extensions/spacer_extension.dart';

class DictionaryPageColumn extends StatelessWidget {
  const DictionaryPageColumn({
    super.key,
    this.searchWord,
  });
  final String? searchWord;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        10.vSpace,
        DictionSearchField(
          searchWord: searchWord,
        ),
        16.vSpace,
        const SearchListBuilder(),
      ],
    );
  }
}
