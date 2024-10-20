import 'package:flutter/material.dart';
import 'package:open_pdf/pages/dictionary/widgets/dictionary_column.dart';

class DictionaryBottomSheet extends StatelessWidget {
  const DictionaryBottomSheet({
    super.key,
    this.searchWord = '',
  });
  final String searchWord;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(5.0),
      margin: const EdgeInsets.all(5.0),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16.0),
        ),
      ),
      child: DictionaryPageColumn(
        searchWord: searchWord,
      ),
    );
  }
}
