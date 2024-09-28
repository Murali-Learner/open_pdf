import 'package:flutter/material.dart';
import 'package:open_pdf/global_widgets/global_bottom_sheet.dart';
import 'package:open_pdf/models/word_model.dart';
import 'package:open_pdf/pages/dictionary/widgets/word_bottom_sheet.dart';
import 'package:open_pdf/utils/constants.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:open_pdf/utils/extensions/spacer_extension.dart';

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
      child: GestureDetector(
        onTap: () {
          context.hideKeyBoard();

          showGlobalBottomSheet(
            context: context,
            child: WordBottomSheet(word: word),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: ColorConstants.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    4.vSpace,
                    Text(
                      word.definition,
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            theme.textTheme.bodyMedium!.color?.withOpacity(0.8),
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
    );
  }
}
