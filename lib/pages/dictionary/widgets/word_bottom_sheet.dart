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
    final theme = context.theme;

    return Container(
      width: double.infinity,
      // padding: const EdgeInsets.all(5.0),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16.0),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                word.word,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                word.definition,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              if (word.examples.isNotEmpty) ...[
                Text(
                  'Examples:',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...word.examples.map((example) => Text('• $example')),
                const SizedBox(height: 16),
              ],
              if (word.synonyms.isNotEmpty) ...[
                Text(
                  'Synonyms:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(word.synonyms.join(', ')),
                const SizedBox(height: 16),
              ],
              if (word.antonyms.isNotEmpty) ...[
                Text(
                  'Antonyms:',
                  style: theme.textTheme.titleMedium,
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
  }
}
