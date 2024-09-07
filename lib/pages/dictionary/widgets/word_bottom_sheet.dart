import 'package:flutter/material.dart';
import 'package:open_pdf/models/word_model.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';

class WordBottomSheet extends StatelessWidget {
  final Word word;
  const WordBottomSheet({
    super.key,
    required this.word,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      builder: (context, scrollController) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(5.0),
          margin: const EdgeInsets.all(5.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(16.0),
            ),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    word.word,
                    style: context.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    word.definition,
                    style: context.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  if (word.examples.isNotEmpty) ...[
                    Text(
                      'Examples:',
                      style: context.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    ...word.examples.map((example) => Text('• $example')),
                    const SizedBox(height: 16),
                  ],
                  if (word.synonyms.isNotEmpty) ...[
                    Text(
                      'Synonyms:',
                      style: context.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(word.synonyms.join(', ')),
                    const SizedBox(height: 16),
                  ],
                  if (word.antonyms.isNotEmpty) ...[
                    Text(
                      'Antonyms:',
                      style: context.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(word.antonyms.join(', ')),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
