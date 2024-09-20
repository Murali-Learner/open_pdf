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
    final theme = context.theme;

    return Material(
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          context.hideKeyBoard();
          showModalBottomSheet(
            showDragHandle: true,
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (context) => WordBottomSheet(word: word),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? Colors.teal[900]
                : Colors.green[50],
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.brightness == Brightness.dark
                    ? Colors.black.withOpacity(0.5)
                    : Colors.grey.withOpacity(0.2),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.book_rounded,
                  size: 32,
                  color: theme.primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        word.word,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.titleLarge!.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        word.definition,
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.textTheme.bodyMedium!.color
                              ?.withOpacity(0.8),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
