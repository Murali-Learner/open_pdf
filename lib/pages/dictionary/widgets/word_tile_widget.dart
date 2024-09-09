import 'package:flutter/material.dart';
import 'package:open_pdf/models/word_model.dart';
import 'package:open_pdf/pages/dictionary/widgets/word_bottom_sheet.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';

class WordTile extends StatelessWidget {
  const WordTile({
    super.key,
    required this.word,
  });

  final Word word;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(10),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        tileColor: context.theme.primaryColor.withOpacity(0.5),
        onTap: () {
          context.hideKeyBoard();
          showModalBottomSheet(
            showDragHandle: true,
            context: context,
            isScrollControlled: true,
            builder: (context) => WordBottomSheet(word: word),
          );
        },
        title: Text(word.word),
        subtitle: Text(word.definition),
      ),
    );
  }
}
